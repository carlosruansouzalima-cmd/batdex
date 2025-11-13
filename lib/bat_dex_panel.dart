import 'package:flutter/material.dart';
import 'bat_detail_screen.dart';
import 'main.dart';

/// Painel da BatDex (lista de morcegos)
class BatDexPanel extends StatelessWidget {
  final bool showAll;
  final Set<String> selectedBats;
  final Color Function(String) colorForBat;
  final Function(String, bool) onBatSelectionChanged;
  final Function(bool) onShowAllChanged;
  final bool isInDrawer;

  const BatDexPanel({
    super.key,
    required this.showAll,
    required this.selectedBats,
    required this.colorForBat,
    required this.onBatSelectionChanged,
    required this.onShowAllChanged,
    this.isInDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    // Categoriza as espécies por função ecológica
    final dispersores = batdex.where((bat) => 
      ['Artibeus lituratus', 'Artibeus obscurus', 'Carollia perspicillata', 
       'Sturnira lilium', 'Platyrrhinus helleri', 'Phyllostomus discolor', 
       'Chiroderma villosum'].contains(bat.name)
    ).toList();
    
    final polinizadores = batdex.where((bat) => 
      ['Glossophaga soricina', 'Hsunycteris thomasi', 'Anoura caudifer'].contains(bat.name)
    ).toList();

    final content = Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                Text(
                  'BatDex',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Morcegos da Amazônia',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Mostrar todos no mapa', style: TextStyle(color: Colors.white, fontSize: 12)),
            value: showAll,
            onChanged: onShowAllChanged,
            activeThumbColor: Colors.blue,
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView(
              children: [
                // Seção Dispersores
                _buildCategoryHeader('🍎 Dispersores de Sementes', Colors.red[300]!),
                ...dispersores.map((bat) => _buildBatTile(context, bat)),
                
                const SizedBox(height: 8),
                
                // Seção Polinizadores
                _buildCategoryHeader('🌸 Polinizadores', Colors.blue[300]!),
                ...polinizadores.map((bat) => _buildBatTile(context, bat)),
              ],
            ),
          ),
        ],
      ),
    );

    return isInDrawer ? content : SizedBox(width: 350, child: content);
  }

  Widget _buildCategoryHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[850],
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatTile(BuildContext context, Bat bat) {
    final index = batdex.indexOf(bat);
    final isChecked = showAll || selectedBats.contains(bat.name);
    
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        dense: true,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge com index e cor do morcego
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: colorForBat(bat.name),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!showAll)
              Checkbox(
                value: isChecked,
                onChanged: (value) {
                  onBatSelectionChanged(bat.name, value ?? false);
                },
                activeColor: colorForBat(bat.name),
                checkColor: Colors.white,
              ),
            Image.asset(
              bat.imagePath,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ],
        ),
        title: Text(
          bat.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          bat.commonName,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BatDetailScreen(bat: bat),
            ),
          );
        },
      ),
    );
  }
}
