import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'main.dart';

/// Uma tela que exibe um mapa interativo mostrando localizações de morcegos em Manaus.
/// 
/// Inclui funcionalidades como:
/// * Alternar entre modo claro/escuro
/// * Localizar usuário no mapa
/// * Visualizar marcadores de morcegos
class BatMap extends StatefulWidget {
  /// Cria uma instância do mapa de morcegos.
  /// [selectedBat] é opcional e, quando fornecido, centraliza o mapa na localização do morcego.
  const BatMap({super.key, this.selectedBat});

  /// O morcego selecionado para exibir no mapa
  final Bat? selectedBat;

  @override
  State<BatMap> createState() => _BatMapState();
}

class _BatMapState extends State<BatMap> {
  final MapController mapController = MapController();
  bool isDarkMode = false;

  // Localizações de exemplo dos morcegos em Manaus
  final Map<String, LatLng> batLocations = {
    'Artibeus lituratus': LatLng(-3.0897, -60.0168),      // UFAM
    'Carollia perspicillata': LatLng(-3.1316, -60.0238),  // Parque do Mindu
    'Sturnira lilium': LatLng(-3.0826, -60.0261),         // INPA
    'Platyrrhinus helleri': LatLng(-3.1045, -60.0261),    // Jardim Botânico
    'Glossophaga soricina': LatLng(-3.1301, -60.0238),    // Museu do Índio
    'Artibeus obscurus': LatLng(-3.0448, -60.0228),       // Centro de Manaus
    'Phyllostomus discolor': LatLng(-3.0935, -59.9825),   // Reserva Ducke
    'Chiroderma villosum': LatLng(-3.0816, -59.9947),     // Área de Preservação
    'Hsunycteris thomasi': LatLng(-3.0633, -60.0092),     // Bosque da Ciência
    'Anoura caudifer': LatLng(-3.0724, -60.0097),         // Parque dos Bilhares
  };

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    
    // Se um morcego foi selecionado, centraliza o mapa em sua localização
    if (widget.selectedBat != null) {
      final location = batLocations[widget.selectedBat!.name];
      if (location != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          mapController.move(location, 15.0);
        });
      }
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Morcegos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
            tooltip: isDarkMode ? 'Mudar para modo claro' : 'Mudar para modo escuro',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(-3.0448, -60.0228), // Manaus coordinates
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: isDarkMode
                    ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.batdex',
              ),
              MarkerLayer(
                markers: batLocations.entries.map((entry) {
                  final isSelected = widget.selectedBat?.name == entry.key;
                  return Marker(
                    point: entry.value,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(entry.key),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.red : Colors.blue,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                batdex.firstWhere((bat) => bat.name == entry.key).imagePath,
                                width: isSelected ? 70 : 60,
                                height: isSelected ? 70 : 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      ),
                    
                  );
                }).toList(),
              ),
              // Add markers here when you have bat location data
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
      ),
    );
  }
}