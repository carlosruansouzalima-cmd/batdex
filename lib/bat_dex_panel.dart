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
    final content = Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'BatDex',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Mostrar todos no mapa', style: TextStyle(color: Colors.white, fontSize: 12)),
            value: showAll,
            onChanged: onShowAllChanged,
            activeColor: Colors.blue,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: batdex.length,
              itemBuilder: (context, index) {
                final bat = batdex[index];
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
                        Checkbox(
                          value: isChecked,
                          onChanged: showAll
                              ? null
                              : (bool? value) {
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
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    subtitle: Text(
                      "Tipo: ${bat.types.join(', ')}",
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    onTap: () {
                      // Fecha o drawer se estiver aberto antes de navegar
                      if (isInDrawer) {
                        Navigator.of(context).pop();
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BatDetailScreen(bat: bat),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    // Se estiver no drawer, retorna apenas o conteúdo
    if (isInDrawer) {
      return content;
    }

    // Se estiver no layout lado a lado, adiciona a largura fixa
    return SizedBox(
      width: 300,
      child: content,
    );
  }
}
