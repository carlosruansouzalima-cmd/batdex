import 'package:latlong2/latlong.dart';

/// Coordenadas sintéticas distribuídas pela região urbana de Manaus (atualização 2025-11)
/// Cada lista possui pontos únicos para evitar sobreposição no mapa
class BatLocations {
  /// Mapa de localizações por espécie de morcego
  /// Cada chave é o nome da espécie, cada valor é uma lista de coordenadas
  static final Map<String, List<LatLng>> locations = {
    'Artibeus lituratus': [
      // Urbano/Periurbano - Ficus spp. (figueiras)
      LatLng(-3.1319, -60.0217), // Centro - Praça São Sebastião
      LatLng(-3.0527, -60.0256), // Parque do Mindu
      LatLng(-3.0890, -60.0217), // Campus UFAM
      LatLng(-3.0636, -60.0139), // Bosque da Ciência
      LatLng(-3.1137, -60.0261), // Jardim Botânico
      LatLng(-3.0590, -60.0148), // INPA
      LatLng(-3.0895, -60.0580), // Ponta Negra (área verde)
      LatLng(-3.0823, -60.0283), // Parque 10 de Novembro
    ],

    'Carollia perspicillata': [
      // Urbano/Periurbano - Piperaceae (bordas de mata)
      LatLng(-3.0510, -60.0265), // Parque do Mindu (lado oeste)
      LatLng(-3.0625, -60.0125), // Bosque da Ciência (entrada)
      LatLng(-3.1350, -60.0235), // Parque Sumaúma (norte)
      LatLng(-3.0885, -60.0590), // Ponta Negra (praia)
      LatLng(-3.0990, -60.0250), // Parque Cidade da Criança (sul)
      LatLng(-3.0600, -60.0160), // INPA (trilha)
      LatLng(-3.1300, -60.0230), // Centro (Av. 7 de Setembro)
      LatLng(-3.0875, -60.0205), // UFAM (Faculdade de Ciências)
    ],

    'Sturnira lilium': [
      // Urbano/Periurbano - Solanaceae
      LatLng(-3.0545, -60.0245), // Parque do Mindu (leste)
      LatLng(-3.0650, -60.0155), // Bosque da Ciência (centro)
      LatLng(-3.1325, -60.0255), // Parque Sumaúma (sul)
      LatLng(-3.0905, -60.0230), // UFAM (Instituto de Ciências Biológicas)
      LatLng(-3.0965, -60.0275), // Parque Cidade da Criança (oeste)
      LatLng(-3.0810, -60.0295), // Parque 10 (leste)
      LatLng(-3.1125, -60.0245), // Jardim Botânico (trilha)
      LatLng(-3.0880, -60.0595), // Ponta Negra (sul)
    ],

    'Platyrrhinus helleri': [
      // Urbano/Periurbano - Frugívoro generalista (plantas pioneiras)
      LatLng(-3.0515, -60.0240), // Parque do Mindu (sul)
      LatLng(-3.0620, -60.0120), // Bosque da Ciência (oeste)
      LatLng(-3.1360, -60.0260), // Parque Sumaúma (leste)
      LatLng(-3.0955, -60.0240), // Parque Cidade da Criança (norte)
      LatLng(-3.0870, -60.0195), // UFAM (Mini Campus)
      LatLng(-3.0835, -60.0270), // Parque 10 (centro)
      LatLng(-3.1335, -60.0200), // Centro (Largo de São Sebastião)
      LatLng(-3.0910, -60.0565), // Ponta Negra (norte)
    ],

    'Glossophaga soricina': [
      // Urbano/Periurbano - Nectarívoro (Passiflora spp., flores noturnas)
      LatLng(-3.1120, -60.0275), // Jardim Botânico (orquidário)
      LatLng(-3.0540, -60.0270), // Parque do Mindu (jardim sensorial)
      LatLng(-3.0615, -60.0145), // Bosque da Ciência (viveiro)
      LatLng(-3.1155, -60.0250), // Jardim Botânico (lago)
      LatLng(-3.0880, -60.0235), // UFAM (jardim botânico)
      LatLng(-3.0805, -60.0265), // Parque 10 (praça)
      LatLng(-3.0870, -60.0600), // Ponta Negra (calçadão)
      LatLng(-3.1315, -60.0265), // Parque Sumaúma (entrada)
    ],

    'Artibeus obscurus': [
      // Florestal - Figueiras e espécies arbóreas
      LatLng(-2.9550, -59.9715), // Reserva Ducke (trilha oeste)
      LatLng(-2.9635, -59.9435), // Reserva Ducke (platô)
      LatLng(-2.9455, -59.9315), // Reserva Ducke (baixio)
      LatLng(-3.0535, -60.0248), // Parque do Mindu (mata ciliar)
      LatLng(-3.0645, -60.0128), // Bosque da Ciência (mata preservada)
      LatLng(-2.9385, -59.9665), // Reserva Ducke (vertente norte)
      LatLng(-3.1345, -60.0238), // Parque Sumaúma (floresta secundária)
      LatLng(-2.9515, -59.9250), // Reserva Ducke (torre)
    ],

    'Phyllostomus discolor': [
      // Florestal - Frugívoro/Nectarívoro oportunista
      LatLng(-2.9525, -59.9740), // Reserva Ducke (trilha leste)
      LatLng(-3.0622, -60.0152), // Bosque da Ciência (interior)
      LatLng(-2.9600, -59.9465), // Reserva Ducke (campinarana)
      LatLng(-3.0508, -60.0262), // Parque do Mindu (borda florestal)
      LatLng(-2.9490, -59.9285), // Reserva Ducke (igarapé)
      LatLng(-3.1320, -60.0252), // Parque Sumaúma (dossel)
      LatLng(-2.9415, -59.9635), // Reserva Ducke (transecto)
      LatLng(-3.0575, -60.0135), // INPA (fragmento)
    ],

    'Chiroderma villosum': [
      // Florestal - Frutos de florestas maduras
      LatLng(-2.9560, -59.9700), // Reserva Ducke (floresta primária oeste)
      LatLng(-2.9605, -59.9470), // Reserva Ducke (sub-bosque denso)
      LatLng(-2.9445, -59.9330), // Reserva Ducke (vale)
      LatLng(-3.0518, -60.0242), // Parque do Mindu (floresta madura)
      LatLng(-2.9370, -59.9680), // Reserva Ducke (área núcleo)
      LatLng(-3.0610, -60.0165), // Bosque da Ciência (área protegida)
      LatLng(-2.9545, -59.9220), // Reserva Ducke (platô sul)
      LatLng(-3.1355, -60.0228), // Parque Sumaúma (mata ciliar)
    ],

    'Hsunycteris thomasi': [
      // Florestal - Nectarívoro especializado (Inga spp., flores tubulares)
      LatLng(-2.9570, -59.9685), // Reserva Ducke (área de Inga)
      LatLng(-2.9590, -59.9485), // Reserva Ducke (clareiras com Inga)
      LatLng(-2.9430, -59.9345), // Reserva Ducke (baixio com leguminosas)
      LatLng(-2.9360, -59.9695), // Reserva Ducke (floresta de igapó)
      LatLng(-3.1110, -60.0280), // Jardim Botânico (coleção de Inga)
      LatLng(-2.9505, -59.9265), // Reserva Ducke (área experimental)
    ],

    'Anoura caudifer': [
      // Florestal - Nectarívoro (Passiflora spp., flores noturnas)
      LatLng(-2.9580, -59.9670), // Reserva Ducke (trepadeiras)
      LatLng(-2.9640, -59.9420), // Reserva Ducke (bordas com Passiflora)
      LatLng(-2.9495, -59.9270), // Reserva Ducke (clareiras)
      LatLng(-3.1165, -60.0240), // Jardim Botânico (área de lianas)
      LatLng(-2.9425, -59.9620), // Reserva Ducke (transição)
      LatLng(-3.0655, -60.0130), // Bosque da Ciência (trepadeiras)
      LatLng(-2.9560, -59.9205), // Reserva Ducke (borda sul)
      LatLng(-2.9350, -59.9710), // Reserva Ducke (área norte)
    ],
  };

  /// Retorna todas as entradas de localização como pares espécie/coordenada
  /// Cada entrada agora inclui o índice da localização para identificação única.
  static Iterable<MapEntry<String, ({LatLng location, int index})>> getAllEntries(Map<String, List<LatLng>> currentLocations) {
    final List<MapEntry<String, ({LatLng location, int index})>> entries = [];
    currentLocations.forEach((species, coords) {
      for (int i = 0; i < coords.length; i++) {
        entries.add(MapEntry(species, (location: coords[i], index: i)));
      }
    });
    return entries;
  }

  /// Retorna entradas filtradas por espécies selecionadas
  static Iterable<MapEntry<String, ({LatLng location, int index})>> getFilteredEntries(
      Map<String, List<LatLng>> currentLocations, Set<String> selectedSpecies) {
    final List<MapEntry<String, ({LatLng location, int index})>> entries = [];
    currentLocations.forEach((species, coords) {
      if (selectedSpecies.contains(species)) {
        for (int i = 0; i < coords.length; i++) {
          entries.add(MapEntry(species, (location: coords[i], index: i)));
        }
      }
    });
    return entries;
  }
}
