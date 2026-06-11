// ui/delivery_address_screen.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/api_call_status.dart';
import 'package:ticketmaster_et/constants/assets.dart';
import 'package:ticketmaster_et/controllers/delivery_address_controller.dart';
import 'package:ticketmaster_et/models/delivery_address.dart';
import 'package:ticketmaster_et/prefs/error_card.dart';
import 'package:ticketmaster_et/prefs/error_data.dart';
import 'package:ticketmaster_et/widgets/location_choice.dart';

import '../../../prefs/shimmer_wrapper.dart';
import '../../../widgets/location_picker.dart';
import '../cart/checkout_screen.dart';

class DeliveryAddressScreen extends StatelessWidget {
  DeliveryAddressScreen({super.key});

  final DeliveryAddressController _ctrl =
      Get.find<DeliveryAddressController>(tag: DeliveryAddressController.tag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          final _formKey = GlobalKey<FormState>();

          Get.bottomSheet(
              Container(
                padding: const EdgeInsets.all(16),
                height: Get.height * 0.85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const Text(
                        "Add New Address",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ctrl.nameOfAddress.value,
                        decoration: const InputDecoration(
                          labelText: "Address Name",
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Please enter a name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: LocationPicker(
                              apiKey: gak,
                              showConfirmButton: false,
                              onLocationPicked: (latlng) {
                                _ctrl.latLng.value = latlng;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final validName = _formKey.currentState!.validate();
                            final pickedLocation =
                                !(_ctrl.latLng.value.latitude == 0 &&
                                    _ctrl.latLng.value.longitude == 0);

                            if (!pickedLocation) {
                              Get.snackbar(
                                "Pick Location",
                                "Please tap the map to select a location",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (validName) {
                              _ctrl.addAddress();
                              Get.back(); // close sheet
                            }
                          },
                          child: const Text("Save Address"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              isScrollControlled: true,
              enableDrag: false);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23981C),
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Text(
          'delivery_address'.tr,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (_ctrl.loadingAddresses.value == ApiCallStatus.loading) {
          // show a few shimmer placeholders while the list is loading
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const _ShimmerCardPlaceholder(),
          );
        }

        if (_ctrl.loadingAddresses.value == ApiCallStatus.error) {
          return Center(
              child: ErrorCard(
            errorData: _ctrl.errorLoadingAddresses.value,
            refresh: _ctrl.fetchDeliveryAddresses,
          )
              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     Text(_ctrl.errorLoadingAddresses.value.body),
              //     const SizedBox(height: 12),
              //     ElevatedButton(
              //       onPressed: () => _ctrl.fetchDeliveryAddresses(),
              //       child: const Text('Retry'),
              //     ),
              //   ],
              // ),
              );
        }

        final list = _ctrl.deliveryAddresses;
        if (list.isEmpty) {
          return Center(
              child: ErrorCard(
            errorData: ErrorData(
                title: 'No Saved Addresses',
                body:
                    'You haven\'t saved any addresses yet, tap the plus button below to add one.',
                image: Assets.emptyCart,
                buttonText: 'Refresh'),
            refresh: _ctrl.fetchDeliveryAddresses,
          ));
        }

        return RefreshIndicator(
          onRefresh: () async => _ctrl.fetchDeliveryAddresses(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final addr = list[index];
              return _AddressCard(addr: addr, controller: _ctrl);
            },
          ),
        );
      }),
    );
  }
}

class _ShimmerCardPlaceholder extends StatelessWidget {
  const _ShimmerCardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        // whole inner contents are shimmered
        child: ShimmerWrapper(
          isEnabled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText('Placeholder title', maxLines: 1),
              SizedBox(height: 8),
              Text('Lat: 0.0, Lng: 0.0'),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final DeliveryAddress addr;
  final DeliveryAddressController controller;

  const _AddressCard({required this.addr, required this.controller});

  @override
  Widget build(BuildContext context) {
    // The card itself is not shimmered — only the inner contents via ShimmerWrapper
    final shouldShowCardShimmer = controller.loadingAddresses.value ==
        ApiCallStatus.loading; // whole-list loading state
    final innerShimmerEnabled =
        shouldShowCardShimmer || addr.status == AddressResolveStatus.loading;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ShimmerWrapper(
          isEnabled: innerShimmerEnabled,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      addr.name!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 2,
                    ),
                    _buildTitle(context),
                    // const SizedBox(height: 6),
                    // Text(
                    //   'Lat: ${addr.lat?.toStringAsFixed(6) ?? "?"}, Lng: ${addr.lng?.toStringAsFixed(6) ?? "?"}',
                    //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    // ),
                    // const SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     if (addr.status == AddressResolveStatus.error)
                    //       GestureDetector(
                    //         onTap: () => controller.retryResolve(addr),
                    //         child: const Row(
                    //           children: [
                    //             Icon(Icons.refresh, size: 18, color: Colors.blue),
                    //             SizedBox(width: 6),
                    //             Text('Retry', style: TextStyle(color: Colors.blue)),
                    //           ],
                    //         ),
                    //       )
                    //     else if (addr.status == AddressResolveStatus.loading)
                    //       const SizedBox.shrink()
                    //   ],
                    // )
                  ],
                ),
              ),
              // const Spacer(),
              IconButton(
                  onPressed: () => controller.deleteAddress(addr),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (addr.status == AddressResolveStatus.success &&
        addr.displayName != null) {
      return AutoSizeText(
        addr.displayName!.toTitleCase(),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
        maxLines: 2,
      );
    }

    if (addr.status == AddressResolveStatus.error) {
      // fallback to raw coords
      final lat = addr.lat?.toStringAsFixed(6) ?? '?';
      final lng = addr.lng?.toStringAsFixed(6) ?? '?';
      return Text(
        '($lat, $lng)',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
    }

    // loading or idle: we'll show a skeleton via ShimmerWrapper; but provide a text for semantics
    return const AutoSizeText('Resolving address...', maxLines: 1);
  }
}
