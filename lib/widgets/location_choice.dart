import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/controllers/delivery_address_controller.dart';

import '../controllers/current_location_controller.dart';
import '../models/delivery_address.dart';
import '../screens/home/cart/checkout_screen.dart';
import 'location_picker.dart';

extension StringCasingExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((str) => str.isEmpty
            ? str
            : '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class CurrentLocationSelector extends StatelessWidget {
  final Function(DeliveryAddress?) onSelected;

  // null = current location
  final Rx<DeliveryAddress?> selected = Rx<DeliveryAddress?>(null);

  CurrentLocationSelector({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final current = CurrentLocationController.findOrPut();
    final delivery =
        Get.find<DeliveryAddressController>(tag: DeliveryAddressController.tag);

    return Obx(() {
      final addresses = delivery.deliveryAddresses;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Delivery Address",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                  onTap: () {
                    final _formKey = GlobalKey<FormState>();

                    Get.bottomSheet(
                        Container(
                          padding: const EdgeInsets.all(16),
                          height: Get.height * 0.85,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: delivery.nameOfAddress.value,
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
                                          delivery.latLng.value = latlng;
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
                                      final validName =
                                          _formKey.currentState!.validate();
                                      final pickedLocation = !(delivery
                                                  .latLng.value.latitude ==
                                              0 &&
                                          delivery.latLng.value.longitude == 0);

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
                                        delivery.addAddress();
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
                  child: const Row(
                    children: [
                      Text(
                        'Add Location',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.add_circle_outline,
                        size: 20,
                      ),
                    ],
                  ))
            ],
          ),
          const SizedBox(height: 16),

          // ---------------------------------------
          // CURRENT LOCATION CARD
          // ---------------------------------------
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color:
                        selected.value == null ? Colors.green : Colors.grey)),
            child: RadioListTile<bool>(
              value: true,
              groupValue: selected.value == null,
              activeColor: Colors.green,
              title: const Text(
                "Current Location",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: current.loading.value
                  ? const Text("Locating...")
                  : current.displayName.value.isNotEmpty
                      ? Text(current.displayName.value.toTitleCase())
                      : null,
              secondary: current.loading.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.my_location,
                      color: Colors.green,
                    ),
              onChanged: (_) {
                selected.value = null;
                onSelected(null);
              },
            ),
          ),

          const SizedBox(height: 8),

          // ---------------------------------------
          // SAVED ADDRESS CARDS
          // ---------------------------------------
          ...addresses.map((e) {
            final isSelected = selected.value?.id == e.id;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: RadioListTile<bool>(
                value: true,
                groupValue: isSelected,
                activeColor: Colors.green,
                title: Text(
                  e.name ?? "Unnamed",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: (e.displayName?.isNotEmpty ?? false)
                    ? Text(e.displayName!.toTitleCase())
                    : (e.lat != null && e.lng != null)
                        ? Text("${e.lat}, ${e.lng}")
                        : null,
                secondary: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                onChanged: (_) {
                  selected.value = e;
                  onSelected(e);
                },
              ),
            );
          }).toList(),
        ],
      );
    });
  }
}
