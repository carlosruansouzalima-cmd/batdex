import 'package:latlong2/latlong.dart';

/// Coordenadas sintéticas distribuídas pela região urbana de Manaus (atualização 2025-11)
/// Cada lista possui pontos únicos para evitar sobreposição no mapa
class BatLocations {
  /// Mapa de localizações por espécie de morcego
  /// Cada chave é o nome da espécie, cada valor é uma lista de coordenadas
  static final Map<String, List<LatLng>> locations = {
    'Artibeus lituratus': [
      LatLng(-3.015000, -59.935000),
      LatLng(-3.016100, -59.936700),
      LatLng(-3.017200, -59.938400),
      LatLng(-3.018300, -59.940100),
      LatLng(-3.019400, -59.941800),
      LatLng(-3.020500, -59.943500),
      LatLng(-3.021600, -59.945200),
      LatLng(-3.022700, -59.946900),
    ],

    'Carollia perspicillata': [
      LatLng(-3.021500, -59.942500),
      LatLng(-3.022600, -59.944200),
      LatLng(-3.023700, -59.945900),
      LatLng(-3.024800, -59.947600),
      LatLng(-3.025900, -59.949300),
      LatLng(-3.027000, -59.951000),
      LatLng(-3.028100, -59.952700),
      LatLng(-3.029200, -59.954400),
    ],

    'Sturnira lilium': [
      LatLng(-3.028000, -59.950000),
      LatLng(-3.029100, -59.951700),
      LatLng(-3.030200, -59.953400),
      LatLng(-3.031300, -59.955100),
      LatLng(-3.032400, -59.956800),
      LatLng(-3.033500, -59.958500),
      LatLng(-3.034600, -59.960200),
      LatLng(-3.035700, -59.961900),
    ],

    'Platyrrhinus helleri': [
      LatLng(-3.034500, -59.957500),
      LatLng(-3.035600, -59.959200),
      LatLng(-3.036700, -59.960900),
      LatLng(-3.037800, -59.962600),
      LatLng(-3.038900, -59.964300),
      LatLng(-3.040000, -59.966000),
      LatLng(-3.041100, -59.967700),
      LatLng(-3.042200, -59.969400),
    ],

    'Glossophaga soricina': [
      LatLng(-3.041000, -59.965000),
      LatLng(-3.042100, -59.966700),
      LatLng(-3.043200, -59.968400),
      LatLng(-3.044300, -59.970100),
      LatLng(-3.045400, -59.971800),
      LatLng(-3.046500, -59.973500),
      LatLng(-3.047600, -59.975200),
      LatLng(-3.048700, -59.976900),
    ],

    'Artibeus obscurus': [
      LatLng(-3.047500, -59.972500),
      LatLng(-3.048600, -59.974200),
      LatLng(-3.049700, -59.975900),
      LatLng(-3.050800, -59.977600),
      LatLng(-3.051900, -59.979300),
      LatLng(-3.053000, -59.981000),
      LatLng(-3.054100, -59.982700),
      LatLng(-3.055200, -59.984400),
    ],

    'Phyllostomus discolor': [
      LatLng(-3.054000, -59.980000),
      LatLng(-3.055100, -59.981700),
      LatLng(-3.056200, -59.983400),
      LatLng(-3.057300, -59.985100),
      LatLng(-3.058400, -59.986800),
      LatLng(-3.059500, -59.988500),
      LatLng(-3.060600, -59.990200),
      LatLng(-3.061700, -59.991900),
    ],

    'Chiroderma villosum': [
      LatLng(-3.060500, -59.987500),
      LatLng(-3.061600, -59.989200),
      LatLng(-3.062700, -59.990900),
      LatLng(-3.063800, -59.992600),
      LatLng(-3.064900, -59.994300),
      LatLng(-3.066000, -59.996000),
      LatLng(-3.067100, -59.997700),
      LatLng(-3.068200, -59.999400),
    ],

    'Hsunycteris thomasi': [
      LatLng(-3.067000, -59.995000),
      LatLng(-3.068100, -59.996700),
      LatLng(-3.069200, -59.998400),
      LatLng(-3.070300, -60.000100),
      LatLng(-3.071400, -60.001800),
      LatLng(-3.072500, -60.003500),
      LatLng(-3.073600, -60.005200),
      LatLng(-3.074700, -60.006900),
    ],

    'Anoura caudifer': [
      LatLng(-3.073500, -60.002500),
      LatLng(-3.074600, -60.004200),
      LatLng(-3.075700, -60.005900),
      LatLng(-3.076800, -60.007600),
      LatLng(-3.077900, -60.009300),
      LatLng(-3.079000, -60.011000),
      LatLng(-3.080100, -60.012700),
      LatLng(-3.081200, -60.014400),
    ],
  };

  /// Retorna todas as localizações como um mapa plano (nome -> coordenada)
  /// Útil para compatibilidade com código existente
  static Map<String, LatLng> getFlatLocations() {
    final Map<String, LatLng> flat = {};
    locations.forEach((species, coords) {
      // Para cada espécie, adiciona apenas a primeira localização para compatibilidade
      if (coords.isNotEmpty) {
        flat[species] = coords.first;
      }
    });
    return flat;
  }

  /// Retorna todas as entradas de localização como pares espécie/coordenada
  static Iterable<MapEntry<String, LatLng>> getAllEntries() {
    final List<MapEntry<String, LatLng>> entries = [];
    locations.forEach((species, coords) {
      for (final coord in coords) {
        entries.add(MapEntry(species, coord));
      }
    });
    return entries;
  }

  /// Retorna entradas filtradas por espécies selecionadas
  static Iterable<MapEntry<String, LatLng>> getFilteredEntries(Set<String> selectedSpecies) {
    final List<MapEntry<String, LatLng>> entries = [];
    locations.forEach((species, coords) {
      if (selectedSpecies.contains(species)) {
        for (final coord in coords) {
          entries.add(MapEntry(species, coord));
        }
      }
    });
    return entries;
  }
}
