import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'main.dart';

/// Painel do Mapa
class BatMapPanel extends StatefulWidget {
  final Iterable<MapEntry<String, LatLng>> filteredEntries;
  final bool isDarkMode;
  final Color Function(String) colorForBat;
  final Function(String, LatLng) onLocationUpdated;

  const BatMapPanel({
    super.key,
    required this.filteredEntries,
    required this.isDarkMode,
    required this.colorForBat,
    required this.onLocationUpdated,
  });

  @override
  State<BatMapPanel> createState() => _BatMapPanelState();
}

class _BatMapPanelState extends State<BatMapPanel> {
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }
  }

  Future<void> _goToUserLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition();
      mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível obter sua localização'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(-3.0448, -60.0228), // Manaus coordinates
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: widget.isDarkMode
                  ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.batdex',
            ),
            MarkerLayer(
              markers: widget.filteredEntries.map((entry) {
                final index = batdex.indexWhere((b) => b.name == entry.key);
                final displayIndex = index >= 0 ? index + 1 : 0;
                return Marker(
                  point: entry.value,
                  width: 120, // Aumentado para o mapa de calor
                  height: 120,
                  child: Draggable<String>(
                    feedback: Material(
                      color: Colors.transparent,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Círculo maior para o mapa de calor (feedback)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.colorForBat(entry.key).withOpacity(0.3),
                              border: Border.all(
                                color: widget.colorForBat(entry.key),
                                width: 2,
                              ),
                            ),
                          ),
                          // Centro com o index
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: widget.colorForBat(entry.key),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '$displayIndex',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    data: entry.key,
                    onDraggableCanceled: (velocity, offset) {
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final localPosition = renderBox.globalToLocal(offset);
                      final latLng = mapController.pointToLatLng(CustomPoint(
                        localPosition.dx,
                        localPosition.dy,
                      ));
                      widget.onLocationUpdated(entry.key, latLng);
                    },
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(entry.key),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Círculo maior para o mapa de calor (área de ocorrência estimada)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.colorForBat(entry.key).withOpacity(0.2),
                              border: Border.all(
                                color: widget.colorForBat(entry.key),
                                width: 1,
                              ),
                            ),
                          ),
                          // Centro com o index
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: widget.colorForBat(entry.key),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                '$displayIndex',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            verticalDirection: VerticalDirection.down,
            children: [
              FloatingActionButton(
                onPressed: () {
                  final currentZoom = mapController.zoom;
                  mapController.move(mapController.center, currentZoom + 1);
                },
                tooltip: 'Aumentar zoom',
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 0),
              FloatingActionButton(
                onPressed: () {
                  final currentZoom = mapController.zoom;
                  mapController.move(mapController.center, currentZoom - 1);
                },
                tooltip: 'Diminuir zoom',
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 0),
              FloatingActionButton(
                onPressed: _goToUserLocation,
                tooltip: 'Localizar-me',
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
