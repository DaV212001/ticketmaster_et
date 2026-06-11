// models/delivery_address.dart

enum AddressResolveStatus { idle, loading, success, error }

class DeliveryAddress {
  final int? id;
  final double? lat;
  final double? lng;
  final String? name;

  // Local only
  String? displayName;
  AddressResolveStatus status;

  DeliveryAddress({
    this.name,
    this.id,
    this.lat,
    this.lng,
    this.displayName,
    this.status = AddressResolveStatus.idle,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        name: json["name"],
        lat: json["latitude"] is String
            ? double.tryParse(json["latitude"])
            : (json["latitude"] is num
                ? (json["latitude"] as num).toDouble()
                : null),
        lng: json["longitude"] is String
            ? double.tryParse(json["longitude"])
            : (json["longitude"] is num
                ? (json["longitude"] as num).toDouble()
                : null),
        id: json["id"] is String ? int.tryParse(json["id"]) : json["id"],
      );

  static List<DeliveryAddress> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => DeliveryAddress.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
