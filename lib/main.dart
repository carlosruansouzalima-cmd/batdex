import 'package:flutter/material.dart';
import 'map.dart';

/// Modelo representando cada morcego da BatDex.
class Bat {
  final int id;
  final String name;
  final List<String> types;
  final String description;
  final String imagePath;
  final String weight;
  final String wingspan;
  final String habitat;
  final String coloration;

  Bat({
    required this.id,
    required this.name,
    required this.types,
    required this.description,
    required this.imagePath,
    required this.weight,
    required this.wingspan,
    required this.habitat,
    required this.coloration,
  });
}

/// Lista completa da BatDex com 10 espécies.
final List<Bat> batdex = [
  Bat(
    id: 1,
    name: "Artibeus lituratus",
    types: ["Dispersor"],
    description:
        "Maior dos Artibeus, alimenta-se de frutos grandes como figos e goiabas. Também pode consumir néctar e insetos, auxiliando na regeneração de florestas.",
    imagePath: "assets/images/artibeus_lituratus.jpg",
    weight: "53–88 g",
    wingspan: "32–33 cm",
    habitat: "Florestas, áreas urbanas arborizadas",
    coloration: "Marrom-escuro com listras faciais claras",
  ),
  Bat(
    id: 2,
    name: "Carollia perspicillata",
    types: ["Dispersor", "Polinizador"],
    description:
        "Generalista, alimenta-se principalmente de frutos do gênero Piper, mas também consome néctar e insetos. Resiliente em áreas urbanas e florestais.",
    imagePath: "assets/images/carollia_perspicillata.jpg",
    weight: "15–22 g",
    wingspan: "28–35 cm",
    habitat: "Florestas secundárias, bordas, áreas urbanas",
    coloration: "Marrom-acinzentado uniforme",
  ),
  Bat(
    id: 3,
    name: "Sturnira lilium",
    types: ["Dispersor"],
    description:
        "Especialista em frutos de Solanum. Machos possuem glândulas odoríferas nos ombros, usadas na reprodução.",
    imagePath: "assets/images/sturnira_lilium.jpg",
    weight: "18–25 g",
    wingspan: "32–38 cm",
    habitat: "Florestas úmidas e secas, bordas de mata",
    coloration: "Marrom a cinza, coloração mais clara no ventre",
  ),
  Bat(
    id: 4,
    name: "Platyrrhinus helleri",
    types: ["Dispersor"],
    description:
        "Pequeno morcego de listras brancas na face e dorso. Constrói abrigos com folhas de palmeira.",
    imagePath: "assets/images/platyrrhinus_helleri.jpg",
    weight: "12–20 g",
    wingspan: "28–34 cm",
    habitat: "Florestas tropicais e bordas de mata",
    coloration: "Castanho com listras brancas marcantes",
  ),
  Bat(
    id: 5,
    name: "Glossophaga soricina",
    types: ["Polinizador"],
    description:
        "Conhecido como Morcego Beija-Flor, possui língua longa adaptada para o néctar. Importante polinizador de várias espécies vegetais tropicais.",
    imagePath: "assets/images/glossophaga_soricina.jpg",
    weight: "9–12 g",
    wingspan: "25–30 cm",
    habitat: "Florestas, áreas urbanas com flores",
    coloration: "Marrom-acinzentado com ventre mais claro",
  ),
  Bat(
    id: 6,
    name: "Artibeus obscurus",
    types: ["Dispersor"],
    description:
        "Morcego frugívoro escuro, consome principalmente figos e frutos silvestres.",
    imagePath: "assets/images/artibeus_obscurus.jpg",
    weight: "45–65 g",
    wingspan: "38–45 cm",
    habitat: "Florestas úmidas, clareiras e bordas",
    coloration: "Marrom a preto, uniforme",
  ),
  Bat(
    id: 7,
    name: "Phyllostomus discolor",
    types: ["Polinizador", "Dispersor"],
    description:
        "Onívoro versátil, consome frutos, insetos, pólen e néctar. Vocalização complexa, comparável à de alguns primatas.",
    imagePath: "assets/images/phyllostomus_discolor.jpg",
    weight: "30–45 g",
    wingspan: "35–40 cm",
    habitat: "Florestas primárias e secundárias",
    coloration: "Marrom pálido a acinzentado",
  ),
  Bat(
    id: 8,
    name: "Chiroderma villosum",
    types: ["Dispersor"],
    description:
        "Granívoro e frugívoro, com olhos grandes. Vive em colônias pequenas e ajuda na dispersão de figos.",
    imagePath: "assets/images/chiroderma_villosum.jpg",
    weight: "15–25 g",
    wingspan: "28–34 cm",
    habitat: "Florestas tropicais densas",
    coloration: "Castanho-acinzentado com ventre esbranquiçado",
  ),
  Bat(
    id: 9,
    name: "Hsunycteris thomasi",
    types: ["Polinizador"],
    description:
        "Especializado em néctar, possui língua com papilas em forma de esponja. Também consome pequenos frutos e insetos.",
    imagePath: "assets/images/hsunycteris_thomasi.jpg",
    weight: "9–11 g",
    wingspan: "24–28 cm",
    habitat: "Florestas úmidas, próximo a flores noturnas",
    coloration: "Marrom claro, focinho alongado",
  ),
  Bat(
    id: 10,
    name: "Anoura caudifer",
    types: ["Polinizador"],
    description:
        "Morcego focinhudo, alimenta-se de néctar de diversas espécies vegetais, além de pólen e insetos.",
    imagePath: "assets/images/anoura_caudifer.jpg",
    weight: "10–14 g",
    wingspan: "25–30 cm",
    habitat: "Florestas úmidas e bordas de mata",
    coloration: "Marrom-acinzentado com pelagem densa",
  ),
];

/// Tela inicial da BatDex
class BatDexApp extends StatelessWidget {
  const BatDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BatDex",
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("BatDex - Morcegos da Amazônia"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BatMap()),
                );
              },
              tooltip: 'Ver mapa',
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: batdex.length,
          itemBuilder: (context, index) {
            final bat = batdex[index];
            return Card(
              color: Colors.grey[900],
              child: ListTile(
                leading: Image.asset(
                  bat.imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  bat.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Tipo: ${bat.types.join(', ')}"),
                onTap: () {
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
    );
  }
}

/// Tela de detalhes de cada morcego
class BatDetailScreen extends StatelessWidget {
  final Bat bat;

  const BatDetailScreen({super.key, required this.bat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bat.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BatMap(selectedBat: bat)),
              );
            },
            tooltip: 'Ver no mapa',
          ),
        ],
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

void main() {
  runApp(BatDexApp());
}
