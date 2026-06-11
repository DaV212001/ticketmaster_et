import 'package:dio/dio.dart';
import 'package:gebeta_gl/gebeta_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ticketmaster_et/setup_files/templates/dio_template.dart';

import '../screens/home/cart/checkout_screen.dart';
import '../setup_files/logging_wrapper.dart';

class CurrentLocationController extends GetxController {
  static String tag = 'current';
  final RxBool loading = false.obs;
  final RxString displayName = ''.obs;
  final Rx<LatLng?> currentLatLng = Rx<LatLng?>(null);

  final GetStorage _cache = GetStorage();

  // Use same API key used in DeliveryAddressController
  final String _gebetaApiKey = gak;

  @override
  void onInit() {
    fetchCurrentLocation();
    super.onInit();
  }

  Future<void> fetchCurrentLocation() async {
    loading.value = true;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          loading.value = false;
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = pos.latitude;
      final lng = pos.longitude;

      currentLatLng.value = LatLng(lat, lng);

      await reverseGeocode(lat, lng);
    } catch (e, s) {
      AppLogger().t("Current location error => $e", stackTrace: s);
    } finally {
      loading.value = false;
    }
  }

  Future<void> reverseGeocode(double lat, double lng) async {
    final key = _cacheKey(lat, lng);

    // check cache
    final cached = _cache.read(key);
    if (cached != null && cached is String) {
      displayName.value = cached;
      return;
    }

    try {
      final url =
          'https://mapapi.gebeta.app/api/v1/route/revgeocoding?lat=$lat&lon=$lng&apiKey=$_gebetaApiKey';

      await DioService.dioGet(
        path: url,
        options: Options(headers: {
          'Authorization': 'Bearer $_gebetaApiKey',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0'
        }),
        onSuccess: (resp) {
          try {
            final data = resp.data['data'];
            if (data != null && data is List && data.isNotEmpty) {
              final first = data.first;

              final name =
                  '${first['name'] ?? ''}, ${first['City'] ?? ''}, ${first['Country'] ?? ''}'
                      .trim();

              if (name.isNotEmpty) {
                displayName.value = name;
                _cache.write(key, name);
                return;
              }
            }

            displayName.value = '';
          } catch (e, s) {
            AppLogger().t(e, stackTrace: s);
            displayName.value = '';
          }
        },
        onFailure: (error, resp) {
          AppLogger().t("Reverse geocode failed $error");
          displayName.value = '';
        },
      );
    } catch (e, s) {
      AppLogger().t(e, stackTrace: s);
      displayName.value = '';
    }
  }

  String _cacheKey(double lat, double lng) =>
      '${lat.toStringAsFixed(6)}_${lng.toStringAsFixed(6)}';
}
