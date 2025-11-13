import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
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

  // Localizações dos morcegos usando a nova estrutura com múltiplas ocorrências
  // Mantém compatibilidade com código existente através de getFlatLocations()

  @override
  void initState() {
    super.initState();
    // Inicializa todas as camadas como visíveis
    for (var species in BatLocations.locations.keys) {
      speciesLayerVisibility[species] = true;
    }
  }

  // Retorna uma cor única para cada morcego baseada em sua função ecológica
  // Polinizadores (nectarívoros) = tons frios (azul, verde, ciano)
  // Dispersores (frugívoros) = tons quentes (vermelho, laranja, rosa, amarelo)
  Color _colorForBat(String name) {
    // Mapa de cores por função ecológica
    final Map<String, Color> ecologicalColors = {
      // Frugívoros dispersores - tons quentes
      'Artibeus lituratus': const Color(0xFFE74C3C),        // Vermelho coral
      'Artibeus obscurus': const Color(0xFFC0392B),         // Vermelho escuro
      'Carollia perspicillata': const Color(0xFFE67E22),    // Laranja
      'Sturnira lilium': const Color(0xFFF39C12),           // Amarelo-laranja
      'Platyrrhinus helleri': const Color(0xFFD35400),      // Laranja queimado
      'Phyllostomus discolor': const Color(0xFFE91E63),     // Rosa
      'Chiroderma villosum': const Color(0xFF9B59B6),       // Roxo (frutas maduras)
      
      // Nectarívoros polinizadores - tons frios
      'Glossophaga soricina': const Color(0xFF3498DB),      // Azul
      'Hsunycteris thomasi': const Color(0xFF2ECC71),       // Verde
      'Anoura caudifer': const Color(0xFF1ABC9C),           // Ciano/turquesa
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

  void _onLocationUpdated(String batName, LatLng newLocation) {
    // Nota: Como agora temos múltiplas localizações por espécie,
    // atualizamos apenas a primeira para manter compatibilidade
    // Em uma versão futura, poderíamos permitir editar localizações específicas
    setState(() {
      // Esta funcionalidade pode ser expandida no futuro para gerenciar múltiplas localizações
    });
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
                ...BatLocations.locations.keys.map((species) {
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
        ? BatLocations.getAllEntries()
        : BatLocations.getFilteredEntries(selectedBats);
    
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
                "Distribuição geográfica de morcegos dispersores e polinizadores - Manaus/AM",
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
              visualizationMode: visualizationMode,
              useAdaptiveOffset: useAdaptiveOffset,
            ),
          );
        } else {
          // Layout para desktop/tablet: lado a lado
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Distribuição geográfica de morcegos dispersores e polinizadores da cidade de Manaus",
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
                BatDexPanel(
                  showAll: showAll,
                  selectedBats: selectedBats,
                  colorForBat: _colorForBat,
                  onBatSelectionChanged: _onBatSelectionChanged,
                  onShowAllChanged: _onShowAllChanged,
                ),
                // Painel direito: Mapa
                Expanded(
                  child: BatMapPanel(
                    filteredEntries: filteredEntries,
                    isDarkMode: isDarkMode,
                    colorForBat: _colorForBat,
                    onLocationUpdated: _onLocationUpdated,
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
