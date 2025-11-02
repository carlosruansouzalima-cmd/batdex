import 'package:flutter/material.dart';
import 'main.dart';

/// Tela de detalhes de cada morcego
class BatDetailScreen extends StatelessWidget {
  final Bat bat;

  const BatDetailScreen({super.key, required this.bat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bat.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(bat.imagePath, height: 200),
            SizedBox(height: 16),
            Text(
              bat.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("Tipo(s): ${bat.types.join(', ')}"),
            SizedBox(height: 16),
            Text(
              bat.description,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey),
            SizedBox(height: 10),
            _buildStatRow("Peso médio", bat.weight),
            _buildStatRow("Envergadura", bat.wingspan),
            _buildStatRow("Habitat", bat.habitat),
            _buildStatRow("Coloração", bat.coloration),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
