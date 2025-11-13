import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'main.dart';
import 'main_screen.dart';
import 'dart:math' as math;

/// Painel do Mapa
class BatMapPanel extends StatefulWidget {
  final Iterable<MapEntry<String, LatLng>> filteredEntries;
  final bool isDarkMode;
  final Color Function(String) colorForBat;
  final Function(String, LatLng) onLocationUpdated;
  final MapVisualizationMode visualizationMode;
  final bool useAdaptiveOffset;

  const BatMapPanel({
    super.key,
    required this.filteredEntries,
    required this.isDarkMode,
    required this.colorForBat,
    required this.onLocationUpdated,
    this.visualizationMode = MapVisualizationMode.individual,
    this.useAdaptiveOffset = true,
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

  /// Aplica offset adaptativo para evitar sobreposição visual
  /// Com agrupamento espacial inteligente
  LatLng _applyAdaptiveOffset(LatLng original, int index, int totalAtLocation) {
    if (!widget.useAdaptiveOffset || totalAtLocation <= 1) return original;

    // Distribui em círculo ao redor do ponto original
    // Raio aumenta com densidade para melhor espaçamento
    final angle = (2 * math.pi * index) / totalAtLocation;
    final radius = totalAtLocation <= 3 ? 0.0015 : 0.0025; // 150m ou 250m
    
    final latOffset = radius * math.cos(angle);
    final lngOffset = radius * math.sin(angle);
    
    return LatLng(
      original.latitude + latOffset,
      original.longitude + lngOffset,
    );
  }

  /// Calcula densidade em uma localização
  int _calculateDensity(LatLng location) {
    const threshold = 0.001; // ~100m
    return widget.filteredEntries.where((entry) {
      final distance = math.sqrt(
        math.pow(entry.value.latitude - location.latitude, 2) +
        math.pow(entry.value.longitude - location.longitude, 2)
      );
      return distance < threshold;
    }).length;
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
    // Agrupa entradas por localização para aplicar offset
    final Map<String, List<MapEntry<String, LatLng>>> locationGroups = {};
    for (var entry in widget.filteredEntries) {
      final key = '${entry.value.latitude.toStringAsFixed(4)},${entry.value.longitude.toStringAsFixed(4)}';
      locationGroups.putIfAbsent(key, () => []);
      locationGroups[key]!.add(entry);
    }

    // Aplica offset adaptativo se necessário
    final List<MapEntry<String, LatLng>> processedEntries = [];
    locationGroups.forEach((locationKey, entries) {
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final adjustedLocation = _applyAdaptiveOffset(
          entry.value,
          i,
          entries.length,
        );
        processedEntries.add(MapEntry(entry.key, adjustedLocation));
      }
    });

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(-3.0448, -60.0228),
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
              markers: processedEntries.map((entry) {
                final index = batdex.indexWhere((b) => b.name == entry.key);
                final displayIndex = index >= 0 ? index + 1 : 0;
                final density = _calculateDensity(entry.value);
                
                // Tamanho variável baseado no modo de visualização e densidade
                // Reduzido em 65% para diminuir poluição visual
                final double baseSize = widget.visualizationMode == MapVisualizationMode.density
                    ? 50.0 + (density * 5.0)
                    : 65.0;
                final double circleSize = baseSize.clamp(50.0, 100.0);
                final double centerSize = widget.visualizationMode == MapVisualizationMode.density
                    ? 14.0 + (density * 1.5)
                    : 18.0;
                
                return Marker(
                  point: entry.value,
                  width: circleSize + 20,
                  height: circleSize + 20,
                  child: GestureDetector(
                    onTap: () {
                      final infoText = widget.visualizationMode == MapVisualizationMode.density
                          ? '${entry.key} (Densidade: $density)'
                          : entry.key;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(infoText),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Círculo maior com opacidade reduzida
                        Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.colorForBat(entry.key).withOpacity(
                              widget.visualizationMode == MapVisualizationMode.density
                                  ? 0.12 + (density * 0.03)
                                  : 0.15
                            ),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                        // Centro com o index
                        Container(
                          width: centerSize,
                          height: centerSize,
                          decoration: BoxDecoration(
                            color: widget.colorForBat(entry.key),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              '$displayIndex',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (centerSize / 2.4).clamp(8.0, 12.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: _buildLegend(),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  final currentZoom = mapController.zoom;
                  mapController.move(mapController.center, currentZoom + 1);
                },
                tooltip: 'Aumentar zoom',
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                onPressed: () {
                  final currentZoom = mapController.zoom;
                  mapController.move(mapController.center, currentZoom - 1);
                },
                tooltip: 'Diminuir zoom',
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
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

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legenda Ecológica',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.red[400]!, '🍎 Dispersores de sementes'),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              '(morcegos frugívoros)',
              style: TextStyle(fontSize: 9, color: Colors.black54, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 6),
          _buildLegendItem(Colors.blue[400]!, '🌸 Polinizadores'),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              '(morcegos nectarívoros)',
              style: TextStyle(fontSize: 9, color: Colors.black54, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
