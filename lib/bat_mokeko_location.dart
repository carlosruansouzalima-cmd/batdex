import 'package:latlong2/latlong.dart';

class BatLocations {
  static const Map<String, List<LatLng>> locations = {
    'Artibeus lituratus': [],
    'Carollia perspicillata': [],
    'Sturnira lilium': [],
    'Platyrrhinus helleri': [],
    'Glossophaga soricina': [],
    'Artibeus obscurus': [],
    'Phyllostomus discolor': [],
    'Chiroderma villosum': [],
    'Hsunycteris thomasi': [],
    'Anoura caudifer': [],
  };

  static Iterable<MapEntry<String, ({LatLng location, int index})>> getAllEntries(Map<String, List<LatLng>> batLocations) {
    return batLocations.entries.expand((entry) {
      return entry.value.asMap().entries.map((e) => MapEntry(entry.key, (location: e.value, index: e.key)));
    });
  }

  static Iterable<MapEntry<String, ({LatLng location, int index})>> getFilteredEntries(Map<String, List<LatLng>> batLocations, Set<String> selectedBats) {
    return batLocations.entries.where((entry) => selectedBats.contains(entry.key)).expand((entry) {
      return entry.value.asMap().entries.map((e) => MapEntry(entry.key, (location: e.value, index: e.key)));
    });
  }
}