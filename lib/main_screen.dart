import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'bat_dex_panel.dart';
import 'bat_map_panel.dart';
import 'bat_mokeko_location.dart';
import 'main.dart';

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

  // Localizações dos morcegos usando a nova estrutura com múltiplas ocorrências
  // Mantém compatibilidade com código existente através de getFlatLocations()

  // Retorna uma cor única para cada morcego baseada em seu índice na `batdex`.
  // Usa HSV para espalhar as cores ao redor da roda de matiz.
  Color _colorForBat(String name) {
    final index = batdex.indexWhere((b) => b.name == name);
    final hue = (index >= 0 ? (index * 36) % 360 : 200).toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.65, 0.9).toColor();
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

  @override
  Widget build(BuildContext context) {
    final filteredEntries = showAll
        ? BatLocations.getAllEntries()
        : BatLocations.getFilteredEntries(selectedBats);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800; // Considera mobile se largura < 800px

        if (isMobile) {
          // Layout para mobile: BatDex no drawer
          return Scaffold(
            appBar: AppBar(
              title: const Text("BatDex - Morcegos da Amazônia"),
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
            ),
          );
        } else {
          // Layout para desktop/tablet: lado a lado
          return Scaffold(
            appBar: AppBar(
              title: const Text("BatDex - Morcegos da Amazônia"),
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
