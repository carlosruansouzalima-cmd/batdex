import 'package:flutter/material.dart';
import 'main_screen.dart';

/// Modelo representando cada morcego da BatDex.
class Bat {
  final int id;
  final String name;
  final String commonName;
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
    required this.commonName,
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
    commonName: "Morcego das frutas",
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
    commonName: "Morcego de cauda curta",
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
    commonName: "Morcego-fruteiro",
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
    commonName: "Morcego de Heller",
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
    commonName: "Morcego Beija-Flor",
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
    commonName: "Morcego Frugívoro Escuro",
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
    commonName: "Morcego de Nariz de Lança Pálido",
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
    commonName: "Morcego dos Olhos Grandes Peludo",
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
    commonName: "Morcego Néctar de Thomas",
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
    commonName: "Morcego focinhudo",
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

/// Aplicação principal da BatDex
class BatDexApp extends StatelessWidget {
  const BatDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BatDex",
      theme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}

void main() {
  runApp(const BatDexApp());
}
