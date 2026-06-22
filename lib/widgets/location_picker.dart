import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, Uint8List;
import 'package:gebeta_gl/gebeta_gl.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/current_location_controller.dart';

class LocationPicker extends StatefulWidget {
  final String apiKey;
  final Function(LatLng) onLocationPicked;
  final bool? showConfirmButton;

  const LocationPicker({
    super.key,
    required this.apiKey,
    required this.onLocationPicked,
    this.showConfirmButton = true,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GebetaMapController? _controller;
  Symbol? _marker;

  LatLng selected = CurrentLocationController.findOrPut().currentLatLng.value ??
      const LatLng(
          9.0192, 38.7525); // default: User's current location || Addis Ababa

  Future<String> loadMapStyle() async {
    return await rootBundle.loadString('assets/map_styles/interactive.json');
  }

  Future<Uint8List> loadMarkerImage() async {
    var byteData = await rootBundle.load("assets/images/location.png");
    return byteData.buffer.asUint8List();
  }

  void _updateMarker(LatLng pos) async {
    selected = pos;

    if (_marker == null) {
      Logger().i('Here');
      // First time → add marker
      _marker = await _controller!.addSymbol(
        SymbolOptions(
          geometry: pos,
          iconImage: "marker",
          iconSize: 1,
          iconAnchor: "bottom",
        ),
      );
    } else {
      Logger().i('Here2');
      // Move marker
      await _controller!.updateSymbol(
        _marker!,
        SymbolOptions(geometry: pos),
      );
    }

    setState(() {});
  }

  void _onMapCreated(GebetaMapController controller) async {
    _controller = controller;
    // setState(() {});

    // controller.onStyleLoadedCallback = () async {
    //
    // };
    //
    // controller.onMapClick = (Point<double> point, LatLng coords) {
    //   _updateMarker(coords);
    // };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Pick Location")),
      body: FutureBuilder<String>(
        future: loadMapStyle(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            Logger().i(snap.error.toString());
            return const Center(child: Text("Something went wrong"));
          }

          return Stack(
            children: [
              GebetaMap(
                apiKey: widget.apiKey,
                onStyleLoadedCallback: () async {
                  final bytes = await loadMarkerImage();
                  await _controller?.addImage("marker", bytes);

                  _updateMarker(selected);
                },
                styleString:
                    'https://api.maptiler.com/maps/openstreetmap/style.json?key=yU14CpCZTnBXOEjOP9Uf',
                onMapCreated: (map) => _onMapCreated(map),
                onMapClick: (point, coords) {
                  _updateMarker(coords);
                  if (widget.showConfirmButton == false) {
                    widget.onLocationPicked(coords);
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: selected,
                  zoom: 13,
                ),
                compassViewPosition: CompassViewPosition.topRight,
              ),

              // Current selected location text
              if (widget.showConfirmButton == true)
                Positioned(
                  bottom: 90,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Lat: ${selected.latitude.toStringAsFixed(6)}, "
                        "Lng: ${selected.longitude.toStringAsFixed(6)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              if (widget.showConfirmButton == true)
                // Confirm button
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onLocationPicked(selected);
                      // Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        "Confirm Location",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
