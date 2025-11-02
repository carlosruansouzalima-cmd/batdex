import 'package:latlong2/latlong.dart';

/// Coordenadas reais obtidas via API pública do GBIF (consulta 2025-10)
/// Cada lista prioriza registros em Manaus, depois Amazonas, com fallback brasileiro
/// Para atualizar, use o helper `tools/fetch_bat_coords.py`
class BatLocations {
  /// Mapa de localizações por espécie de morcego
  /// Cada chave é o nome da espécie, cada valor é uma lista de coordenadas
  static final Map<String, List<LatLng>> locations = {
    'Artibeus lituratus': [
      LatLng(-1.597135, -59.634881),
      LatLng(-20.740265, -41.273643),
      LatLng(-20.743781, -41.291531),
      LatLng(-19.936526, -43.937148),
      LatLng(-16.587069, -39.098075),
      LatLng(-23.529204, -46.704945),
      LatLng(-19.936459, -40.600536),
      LatLng(-19.936481, -40.600557),
    ],

    'Carollia perspicillata': [
      LatLng(-2.963344, -59.922833),
      LatLng(-1.502870, -59.823381),
      LatLng(-1.533474, -59.823580),
      LatLng(-1.633386, -56.362272),
      LatLng(-1.510795, -56.362857),
      LatLng(-1.500387, -56.378924),
      LatLng(-1.533282, -56.352279),
      LatLng(-1.504500, -56.367093),
    ],

    'Sturnira lilium': [
      LatLng(-3.101944, -60.025000),
      LatLng(-24.561679, -50.411054),
      LatLng(-22.029985, -47.907561),
      LatLng(-19.011716, -46.825830),
      LatLng(-19.011944, -46.825556),
      LatLng(-15.942132, -47.940001),
      LatLng(-7.253317, -37.386375),
      LatLng(-24.857450, -51.890227),
    ],

    'Platyrrhinus helleri': [
      LatLng(-1.660000, -45.370000),
      LatLng(-19.776054, -55.244710),
      LatLng(-14.033333, -48.300000),
      LatLng(-3.124010, -55.247440),
      LatLng(-4.885158, -43.418130),
      LatLng(-9.560000, -56.760000),
      LatLng(-0.970000, -47.110000),
      LatLng(-2.980000, -47.400000),
    ],

    'Glossophaga soricina': [
      LatLng(-1.523166, -59.821242),
      LatLng(-5.545593, -37.042127),
      LatLng(-5.544259, -37.040661),
      LatLng(-7.884132, -34.911574),
      LatLng(-5.492987, -37.054770),
      LatLng(-5.588169, -37.029046),
      LatLng(-5.545041, -37.017694),
      LatLng(-5.614715, -37.042936),
    ],

    'Artibeus obscurus': [
      LatLng(-1.696823, -59.613691),
      LatLng(-1.834000, -59.717400),
      LatLng(-1.830300, -59.686600),
      LatLng(-1.663788, -59.714260),
      LatLng(-1.591600, -59.429800),
      LatLng(-3.829314, -59.045780),
      LatLng(-11.508110, -42.561673),
      LatLng(-23.741714, -46.719127),
    ],

    'Phyllostomus discolor': [
      LatLng(-2.223970, -65.720836),
      LatLng(-2.766670, -57.816669),
      LatLng(-5.545593, -37.042127),
      LatLng(-5.541995, -37.020736),
      LatLng(-5.614715, -37.042936),
      LatLng(-5.545041, -37.017694),
      LatLng(-5.588169, -37.029046),
      LatLng(-12.061167, -55.517529),
    ],

    'Chiroderma villosum': [
      LatLng(-7.137206, -34.842047),
      LatLng(-7.137368, -34.842767),
      LatLng(-22.934294, -43.443056),
      LatLng(-19.014163, -50.478165),
      LatLng(-18.762700, -50.500044),
      LatLng(-18.967439, -50.550580),
      LatLng(-22.453521, -42.770316),
      LatLng(-18.873466, -50.348634),
    ],

    'Hsunycteris thomasi': [
      LatLng(-3.101944, -60.025000),
      LatLng(-1.570655, -59.374198),
      LatLng(-10.340489, -56.965199),
      LatLng(-3.650000, -52.366665),
      LatLng(-3.650000, -52.370000),
      LatLng(-3.650000, -52.366700),
    ],

    'Anoura caudifer': [
      LatLng(-3.101944, -60.025000),
      LatLng(-4.736028, -57.484379),
      LatLng(-19.011971, -46.825482),
      LatLng(-11.417082, -42.624619),
      LatLng(-28.246703, -49.517031),
      LatLng(-22.933875, -43.443099),
      LatLng(-28.237728, -49.499961),
      LatLng(-26.855700, -49.052130),
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
