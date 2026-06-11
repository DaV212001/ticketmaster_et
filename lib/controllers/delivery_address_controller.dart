// controllers/delivery_address_controller.dart
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gebeta_gl/gebeta_gl.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/api_call_status.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/delivery_address.dart';
import 'package:ticketmaster_et/prefs/error_data.dart';
import 'package:ticketmaster_et/prefs/error_utils.dart';
import 'package:ticketmaster_et/provider/loginpersistence.dart';
import 'package:ticketmaster_et/screens/home/cart/checkout_screen.dart';
import 'package:ticketmaster_et/setup_files/templates/dio_template.dart';

import '../setup_files/logging_wrapper.dart';

class DeliveryAddressController extends GetxController {
  static String tag = 'delivery_address';
  var loadingAddresses = ApiCallStatus.holding.obs;
  var errorLoadingAddresses = ErrorData(title: '', body: '', image: '').obs;
  var deliveryAddresses = <DeliveryAddress>[].obs;

  // Caching reverse geocode results
  final GetStorage _cache = GetStorage();

  // Concurrency control
  final int _concurrencyLimit = 5;
  int _activeCalls = 0;
  final Queue<DeliveryAddress> _queue = Queue<DeliveryAddress>();

  // Put your Gebeta Maps API key here
  final String _gebetaApiKey = gak;

  @override
  void onInit() {
    fetchDeliveryAddresses();
    super.onInit();
  }

  void fetchDeliveryAddresses() async {
    loadingAddresses.value = ApiCallStatus.loading;
    final userId = Get.find<LoginDataProvider>(tag: 'login').loginData?.id;
    try {
      await DioService.dioGet(
        path: '${baseUrlFunc}my-delivery-adress/$userId',
        options: Options(
          headers: {
            "User-Agent": "Mozilla/5.0", // Very important
            "Accept": "application/json"
          },
        ),
        onSuccess: (response) {
          try {
            final data = response.data['data'] as List<dynamic>;
            AppLogger().d(data);
            deliveryAddresses.value = DeliveryAddress.fromJsonList(data);
            loadingAddresses.value = ApiCallStatus.success;

            // start reverse-geocoding pipeline
            _enqueueAllForResolve();
          } catch (e, s) {
            Logger().t(e, stackTrace: s);
            errorLoadingAddresses.value = ErrorData(
                title: 'Parsing error', body: e.toString(), image: '');
            loadingAddresses.value = ApiCallStatus.error;
          }
        },
        onFailure: (error, response) async {
          errorLoadingAddresses.value =
              await ErrorUtil.getErrorData(error.toString());
          loadingAddresses.value = ApiCallStatus.error;
        },
      );
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
      errorLoadingAddresses.value = await ErrorUtil.getErrorData(e.toString());
      loadingAddresses.value = ApiCallStatus.error;
    }
  }

  void _enqueueAllForResolve() {
    for (final addr in deliveryAddresses) {
      // skip if no coords
      if (addr.lat == null || addr.lng == null) continue;
      // if we already have cached value, apply synchronously
      final key = _cacheKey(addr.lat!, addr.lng!);
      final cached = _cache.read(key);
      if (cached != null && cached is String) {
        addr.displayName = cached;
        addr.status = AddressResolveStatus.success;
      } else {
        addr.status = AddressResolveStatus.idle;
        _queue.add(addr);
      }
    }
    deliveryAddresses.refresh();
    _processQueue();
  }

  void _processQueue() {
    // If queue empty or concurrency limit reached, do nothing
    while (_activeCalls < _concurrencyLimit && _queue.isNotEmpty) {
      final addr = _queue.removeFirst();
      _reverseGeocodeAddress(addr);
    }
  }

  Future<void> _reverseGeocodeAddress(DeliveryAddress addr) async {
    if (addr.lat == null || addr.lng == null) {
      addr.status = AddressResolveStatus.error;
      deliveryAddresses.refresh();
      return;
    }

    // set loading state for UI
    addr.status = AddressResolveStatus.loading;
    deliveryAddresses.refresh();

    _activeCalls++;

    final cacheKey = _cacheKey(addr.lat!, addr.lng!);
    try {
      // Build Gebeta API URL with query string (matching their docs)
      final url =
          'https://mapapi.gebeta.app/api/v1/route/revgeocoding?lat=${addr.lat}&lon=${addr.lng}&apiKey=$_gebetaApiKey';

      await DioService.dioGet(
        path: url,
        options: Options(headers: {
          'Authorization': 'Bearer $_gebetaApiKey',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0'
        }),
        onSuccess: (response) {
          try {
            final body = response.data;
            // Gebeta returns { "msg": "ok", "data": [ ... ], "count": N }
            final data = body['data'];
            if (data != null && data is List && data.isNotEmpty) {
              final first = data.first;
              final name =
                  '${first['name'] ?? ''}, ${first['City'] ?? ''}, ${first['Country'] ?? ''}';
              if (name.isNotEmpty) {
                addr.displayName = name;
                addr.status = AddressResolveStatus.success;
                // cache it
                _cache.write(cacheKey, name);
                deliveryAddresses.refresh();
                return;
              }
            }
            // fallback: treat as error (will show coords)
            addr.status = AddressResolveStatus.error;
            deliveryAddresses.refresh();
          } catch (e, s) {
            AppLogger().t(e, stackTrace: s);
            addr.status = AddressResolveStatus.error;
            deliveryAddresses.refresh();
          }
        },
        onFailure: (error, response) async {
          // Gebeta may return 401 with message in response
          AppLogger().t('Reverse geocode failed for $url : $error');
          addr.status = AddressResolveStatus.error;
          deliveryAddresses.refresh();
        },
      );
    } catch (e, s) {
      AppLogger().t(e, stackTrace: s);
      addr.status = AddressResolveStatus.error;
      deliveryAddresses.refresh();
    } finally {
      _activeCalls--;
      // continue queue
      _processQueue();
    }
  }

  String _cacheKey(double lat, double lng) =>
      '${lat.toStringAsFixed(6)}_${lng.toStringAsFixed(6)}';

  /// Optional: manual retry for a single address
  void retryResolve(DeliveryAddress addr) {
    // clear previous display and re-enqueue
    addr.displayName = null;
    addr.status = AddressResolveStatus.idle;
    _queue.addFirst(addr);
    _processQueue();
    deliveryAddresses.refresh();
  }

  var latLng = const LatLng(0, 0).obs;
  var nameOfAddress = TextEditingController().obs;
  var addingAddress = false.obs;

  void addAddress() async {
    await Get.showOverlay(
        asyncFunction: () async {
          addingAddress.value = true;
          try {
            await DioService.dioPost(
                path: '${baseUrlFunc}delivery-adress',
                options: Options(headers: {
                  "User-Agent": "Mozilla/5.0",
                  "Accept": "application/json"
                }),
                data: {
                  'user_id':
                      Get.find<LoginDataProvider>(tag: 'login').loginData?.id,
                  'name': nameOfAddress.value.text,
                  'latitude': latLng.value.latitude,
                  'longitude': latLng.value.longitude,
                },
                onSuccess: (response) {
                  // Get.back();
                  Get.snackbar('success'.tr, 'address_added_successfully'.tr,
                      backgroundColor: Colors.green, colorText: Colors.white);
                  fetchDeliveryAddresses();
                });
          } catch (e, s) {
            AppLogger().t(e, stackTrace: s);
            Get.snackbar('error'.tr, 'failed_to_add_address'.tr,
                backgroundColor: Colors.red, colorText: Colors.white);
          } finally {
            addingAddress.value = false;
          }
        },
        loadingWidget: const Center(
          child: SizedBox(
              height: 50, width: 50, child: CircularProgressIndicator()),
        ));
  }

  void deleteAddress(DeliveryAddress address) async {
    await Get.showOverlay(
        asyncFunction: () async {
          addingAddress.value = true;
          try {
            await DioService.dioDelete(
                path: '${baseUrlFunc}delivery-adress/${address.id}',
                options: Options(headers: {
                  "User-Agent": "Mozilla/5.0",
                  "Accept": "application/json"
                }),
                // data: {
                onSuccess: (response) {
                  // Get.back();
                  Get.snackbar('success'.tr, 'address_deleted_successfully'.tr,
                      backgroundColor: Colors.green, colorText: Colors.white);
                  fetchDeliveryAddresses();
                });
          } catch (e, s) {
            AppLogger().t(e, stackTrace: s);
            Get.snackbar('error'.tr, 'failed_to_delete_address'.tr,
                backgroundColor: Colors.red, colorText: Colors.white);
          } finally {
            addingAddress.value = false;
          }
        },
        loadingWidget: const Center(
          child: SizedBox(
              height: 50, width: 50, child: CircularProgressIndicator()),
        ));
  }
}
