import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'main.dart';
import 'main_screen.dart';
import 'dart:math' as math;
import 'package:collection/collection.dart';

/// Painel do Mapa
class BatMapPanel extends StatefulWidget {
  final Iterable<MapEntry<String, ({LatLng location, int index})>> filteredEntries;
  final bool isDarkMode;
  final Color Function(String) colorForBat;
  final Function(String, int, LatLng) onLocationUpdated;
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
  // Variáveis para controlar o arrasto do marcador
  String? _draggedMarkerId; // Usa um ID único (especie + index)
  
  // Armazena as localizações localmente para uma atualização visual fluida
  late List<MapEntry<String, ({LatLng location, int index})>> _localEntries;
  MapCamera? _cameraOnDrag;

  @override
  void initState() {
    super.initState();
    _localEntries = widget.filteredEntries.toList();
    _requestLocationPermission();
  }

  @override
  void didUpdateWidget(covariant BatMapPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza as entradas locais sempre que o widget pai for reconstruído,
    // mas apenas se não estivermos no meio de uma operação de arraste.
    if (widget.filteredEntries != oldWidget.filteredEntries && _draggedMarkerId == null) {
      _localEntries = widget.filteredEntries.toList();
    }
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
        math.pow(entry.value.location.latitude - location.latitude, 2) +
        math.pow(entry.value.location.longitude - location.longitude, 2)
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
    final Map<String, List<MapEntry<String, ({LatLng location, int index})>>> locationGroups = {};    
    for (var entry in widget.filteredEntries) {
      final key = '${entry.value.location.latitude.toStringAsFixed(4)},${entry.value.location.longitude.toStringAsFixed(4)}';
      locationGroups.putIfAbsent(key, () => []);
      locationGroups[key]!.add(entry);
    }

    // Aplica offset adaptativo se necessário
    // Se não estivermos arrastando, processa as entradas. Caso contrário, usa as locais.
    final List<MapEntry<String, ({LatLng location, int index})>> processedEntries = [];
    if (_draggedMarkerId == null) {
      // Se não estiver arrastando, calcula os offsets
      locationGroups.forEach((locationKey, entries) {
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final adjustedLocation = _applyAdaptiveOffset(
          entry.value.location,
          i,
          entries.length,
        );
        processedEntries.add(MapEntry(entry.key, (location: adjustedLocation, index: entry.value.index)));
      }
    });
    }

    // Usa a lista local durante o arraste para uma atualização fluida,
    // ou a lista processada com offsets em estado normal.
    final List<MapEntry<String, ({LatLng location, int index})>> displayEntries = _draggedMarkerId != null ? _localEntries : processedEntries;

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
              markers: displayEntries.map((entry) {
                final index = batdex.indexWhere((b) => b.name == entry.key);
                final displayIndex = index >= 0 ? index + 1 : 0;
                final density = _calculateDensity(entry.value.location);
                
                // Tamanho variável baseado no modo de visualização e densidade
                // Reduzido em 65% para diminuir poluição visual
                final double baseSize =
                    widget.visualizationMode == MapVisualizationMode.density
                        ? 60.0 + (density * 6.0)
                        : 75.0;
                final double circleSize = baseSize.clamp(60.0, 120.0);
                final double centerSize =
                    widget.visualizationMode == MapVisualizationMode.density
                        ? 18.0 + (density * 2.0)
                        : 22.0;
                
                return Marker(
                  point: entry.value.location,
                  width: circleSize + 20,
                  height: circleSize + 20,
                  child: Listener(
                    onPointerDown: (event) {
                      setState(() {
                        // Identifica o marcador que está sendo arrastado
                        _cameraOnDrag = mapController.camera; // Captura o estado no início
                        _draggedMarkerId = '${entry.key}-${entry.value.index}';
                        // Usa a lista de exibição atual como base para o arraste
                        _localEntries = List.from(displayEntries);
                      });
                    },
                    onPointerMove: (event) {
                      // Usa o estado do mapa capturado no onPointerDown para estabilidade
                      final currentCamera = _cameraOnDrag;
                      if (_draggedMarkerId == '${entry.key}-${entry.value.index}' &&
                          currentCamera != null) {
                        // Converte a posição do cursor na tela para uma coordenada geográfica
                        final newLatLng = currentCamera.pointToLatLng(math.Point(event.position.dx, event.position.dy));
                        
                        // Atualiza a posição visualmente no estado local, sem reconstruir a tela inteira
                        setState(() {
                          final entryIndex = _localEntries.indexWhere((e) =>
                              e.key == entry.key && e.value.index == entry.value.index);
                          if (entryIndex != -1) {
                            _localEntries[entryIndex] = MapEntry(entry.key, (location: newLatLng, index: entry.value.index));
                          }
                        });
                      }
                    },
                    onPointerUp: (event) {
                      // Finaliza o arrasto e atualiza o estado principal
                      final finalEntry = _localEntries.firstWhereOrNull((e) => e.key == entry.key && e.value.index == entry.value.index);
                      if (finalEntry != null) {
                        widget.onLocationUpdated(entry.key, entry.value.index, finalEntry.value.location);
                      }

                      setState(() {
                        _draggedMarkerId = null;
                        _cameraOnDrag = null;
                      });
                    },
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
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: _buildMarkerContent(entry, displayIndex, density, circleSize, centerSize),
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

  Widget _buildMarkerContent(MapEntry<String, ({LatLng location, int index})> entry, int displayIndex, int density, double circleSize, double centerSize) {
    return Stack(
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
            boxShadow: _draggedMarkerId == '${entry.key}-${entry.value.index}' ? [
              BoxShadow(
                color: widget.colorForBat(entry.key).withOpacity(0.8),
                blurRadius: 10,
                spreadRadius: 4,
              )
            ] : [],
          ),
          child: Center(
            child: Text(
              '$displayIndex',
              style: TextStyle(
                color: Colors.white,
                fontSize: (centerSize / 2.2).clamp(9.0, 14.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
