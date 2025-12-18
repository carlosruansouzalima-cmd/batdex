import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'bat_dex_panel.dart';
import 'bat_map_panel.dart';
import 'bat_mokeko_location.dart';

/// Modo de visualização do mapa
enum MapVisualizationMode {
  individual, // Marcadores individuais com offset
  density,    // Tamanho variável por densidade
}

/// Tela principal com layout dividido (BatDex + Mapa)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isDarkMode = false;
  bool showAll = true;
  final Set<String> selectedBats = <String>{};
  MapVisualizationMode visualizationMode = MapVisualizationMode.individual;
  final Map<String, bool> speciesLayerVisibility = {};
  bool useAdaptiveOffset = true;

  // As localizações agora são parte do estado para permitir modificações
  late Map<String, List<LatLng>> _batLocations;

  @override
  void initState() {
    super.initState();
    // Inicializa as localizações dos morcegos como um estado mutável,
    // fazendo uma cópia profunda dos dados originais.
    _batLocations = Map.from(BatLocations.locations.map(
      (key, value) => MapEntry(key, List<LatLng>.from(value)),
    ));

    // Inicializa todas as camadas como visíveis
    for (var species in _batLocations.keys) {
      speciesLayerVisibility[species] = true;
    }

    // Carrega localizações salvas
    Future.microtask(() => _loadLocations());
  }

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('bat_locations');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      setState(() {
        _batLocations = decoded.map((key, value) => MapEntry(
          key,
          (value as List).map((item) => LatLng((item as Map)['lat'], (item as Map)['lng'])).toList(),
        ));
      });
    }
  }

  Future<void> _saveLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final locationsJson = _batLocations.map((key, value) => MapEntry(
      key,
      value.map((latlng) => {'lat': latlng.latitude, 'lng': latlng.longitude}).toList(),
    ));
    final jsonString = jsonEncode(locationsJson);
    await prefs.setString('bat_locations', jsonString);
  }

  // Retorna uma cor única para cada morcego baseada em sua função ecológica
  // Polinizadores (nectarívoros) = tons frios (azul, verde, ciano)
  // Dispersores (frugívoros) = tons quentes (vermelho, laranja, rosa, amarelo)
  Color _colorForBat(String name) {
    // Mapa de cores por função ecológica
    const Map<String, Color> ecologicalColors = {
      // Frugívoros dispersores - tons quentes
      'Artibeus lituratus': Color(0xFFE53935), // Vermelho Forte
      'Artibeus obscurus': Color(0xFFD84315), // Laranja Escuro
      'Carollia perspicillata': Color(0xFFEF6C00), // Laranja
      'Sturnira lilium': Color(0xFFF9A825), // Amarelo
      'Platyrrhinus helleri': Color(0xFFFF8F00), // Âmbar
      'Phyllostomus discolor': Color(0xFFE57373), // Vermelho Claro
      'Chiroderma villosum': Color(0xFFFFB300), // Amarelo Ouro
      
      // Nectarívoros polinizadores - tons frios
      'Glossophaga soricina': Color(0xFF1E88E5), // Azul
      'Hsunycteris thomasi': Color(0xFF43A047), // Verde
      'Anoura caudifer': Color(0xFF00ACC1), // Ciano
    };
    
    return ecologicalColors[name] ?? const Color(0xFF95A5A6); // Cinza neutro para desconhecidos
  }

  void _onBatSelectionChanged(String batName, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedBats.add(batName);
      } else {
        selectedBats.remove(batName);
      }
    });
  }

  void _onShowAllChanged(bool value) {
    setState(() {
      showAll = value;
      if (showAll) selectedBats.clear();
    });
  }

  // Atualiza a localização de um marcador específico
  void _onLocationUpdated(String batName, int locationIndex, LatLng newLocation) {
    setState(() {
      if (_batLocations.containsKey(batName) &&
          locationIndex < _batLocations[batName]!.length) {
        _batLocations[batName]![locationIndex] = newLocation;
      }
    });
    _saveLocations();
  }

  // Reseta as localizações para os valores originais
  void _resetLocations() {
    setState(() {
      _batLocations = Map.from(BatLocations.locations.map(
        (key, value) => MapEntry(key, List<LatLng>.from(value)),
      ));
    });
    _saveLocations();
  }

  void _onLocationAdded(String species, LatLng location) {
    setState(() {
      _batLocations[species]!.add(location);
    });
    _saveLocations();
  }

  void _showLayerControl(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Controle de Camadas'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Offset Adaptativo'),
                  subtitle: const Text('Evita sobreposição visual'),
                  value: useAdaptiveOffset,
                  onChanged: (value) {
                    setState(() {
                      useAdaptiveOffset = value;
                    });
                    Navigator.pop(context);
                    _showLayerControl(context);
                  },
                ),
                const Divider(),
                const Text(
                  'Visibilidade por Espécie:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._batLocations.keys.map((species) {
                  return CheckboxListTile(
                    title: Text(species),
                    secondary: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _colorForBat(species),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                    value: speciesLayerVisibility[species] ?? true,
                    onChanged: (value) {
                      setState(() {
                        speciesLayerVisibility[species] = value ?? true;
                      });
                      Navigator.pop(context);
                      _showLayerControl(context);
                    },
                  );
                }).toList(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var key in speciesLayerVisibility.keys) {
                            speciesLayerVisibility[key] = true;
                          }
                        });
                        Navigator.pop(context);
                        _showLayerControl(context);
                      },
                      child: const Text('Mostrar Todas'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var key in speciesLayerVisibility.keys) {
                            speciesLayerVisibility[key] = false;
                          }
                        });
                        Navigator.pop(context);
                        _showLayerControl(context);
                      },
                      child: const Text('Ocultar Todas'),
                    ),
                  ],
                ),
                const Divider(),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _resetLocations();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Resetar Posições'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtra entradas baseado na seleção E visibilidade das camadas
    final baseEntries = showAll
        ? BatLocations.getAllEntries(_batLocations)
        : BatLocations.getFilteredEntries(_batLocations, selectedBats);
    
    final filteredEntries = baseEntries.where((entry) => 
        speciesLayerVisibility[entry.key] ?? true
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800; // Considera mobile se largura < 800px

        if (isMobile) {
          // Layout para mobile: BatDex no drawer
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Figura 11 - Distribuição geográfica de morcegos dispersores e polinizadores - Manaus/AM",
                style: TextStyle(fontSize: 14),
              ),
              centerTitle: true,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Abrir BatDex',
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.layers),
                  onPressed: () => _showLayerControl(context),
                  tooltip: 'Controle de camadas',
                ),
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
            drawer: Drawer(
              child: BatDexPanel(
                showAll: showAll,
                selectedBats: selectedBats,
                colorForBat: _colorForBat,
                onBatSelectionChanged: _onBatSelectionChanged,
                onShowAllChanged: _onShowAllChanged,
                isInDrawer: true,
              ),
            ),
            body: BatMapPanel(
              filteredEntries: filteredEntries,
              isDarkMode: isDarkMode,
              colorForBat: _colorForBat,
              onLocationUpdated: _onLocationUpdated,
              onLocationAdded: _onLocationAdded,
              visualizationMode: visualizationMode,
              useAdaptiveOffset: useAdaptiveOffset,
            ),
          );
        } else {
          // Layout para desktop/tablet: lado a lado
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Figura 11 - Distribuição geográfica de morcegos dispersores e polinizadores da cidade de Manaus",
                style: TextStyle(fontSize: 15),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.layers),
                  onPressed: () => _showLayerControl(context),
                  tooltip: 'Controle de camadas',
                ),
                PopupMenuButton<MapVisualizationMode>(
                  icon: const Icon(Icons.visibility),
                  tooltip: 'Modo de visualização',
                  onSelected: (mode) {
                    setState(() {
                      visualizationMode = mode;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: MapVisualizationMode.individual,
                      child: Row(
                        children: [
                          Icon(
                            visualizationMode == MapVisualizationMode.individual 
                                ? Icons.radio_button_checked 
                                : Icons.radio_button_unchecked,
                          ),
                          const SizedBox(width: 8),
                          const Text('Marcadores individuais'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: MapVisualizationMode.density,
                      child: Row(
                        children: [
                          Icon(
                            visualizationMode == MapVisualizationMode.density 
                                ? Icons.radio_button_checked 
                                : Icons.radio_button_unchecked,
                          ),
                          const SizedBox(width: 8),
                          const Text('Densidade adaptativa'),
                        ],
                      ),
                    ),
                  ],
                ),
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
            body: Row(
              children: [
                // Painel esquerdo: BatDex
                SizedBox(
                  width: 350,
                  child: BatDexPanel(
                    showAll: showAll,
                    selectedBats: selectedBats,
                    colorForBat: _colorForBat,
                    onBatSelectionChanged: _onBatSelectionChanged,
                    onShowAllChanged: _onShowAllChanged,
                  ),
                ),
                // Painel direito: Mapa
                Expanded(
                  child: BatMapPanel(
                    filteredEntries: filteredEntries,
                    isDarkMode: isDarkMode,
                    colorForBat: _colorForBat,
                    onLocationUpdated: _onLocationUpdated,
                    onLocationAdded: _onLocationAdded,
                    visualizationMode: visualizationMode,
                    useAdaptiveOffset: useAdaptiveOffset,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
