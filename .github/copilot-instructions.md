# BatDex AI Coding Guidelines

## Project Overview
BatDex is a Flutter app showcasing bats from the Amazon region, featuring a split-screen layout with a bat encyclopedia panel and an interactive map. The app displays bat species data, allows selection and filtering, and visualizes bat locations using flutter_map.

## Architecture
- **Entry Point**: `lib/main.dart` contains the `Bat` model, hardcoded bat data list (`batdex`), and `BatDexApp` widget.
- **Main Screen**: `lib/main_screen.dart` manages app state (theme, selections, visualization mode) and coordinates between `BatDexPanel` and `BatMapPanel`.
- **Data Flow**: Bat data flows from `main.dart` → `MainScreen` → panels. Locations are managed in `MainScreen` state, sourced from `bat_mokeko_location.dart`.
- **State Management**: Centralized in `MainScreen` using StatefulWidget; no external state libraries used.

## Key Components
- **BatDexPanel** (`lib/bat_dex_panel.dart`): Displays categorized bat list (Dispersores/Polinizadores), handles selection via checkboxes.
- **BatMapPanel** (`lib/bat_map_panel.dart`): Renders flutter_map with draggable markers, supports individual/density visualization modes.
- **BatDetailScreen** (`lib/bat_detail_screen.dart`): Shows bat image, description, and stats in a scrollable view.

## Data Management
- **Bat Data**: Hardcoded in `main.dart` as `List<Bat> batdex`. Each `Bat` includes id, name, types, description, imagePath, and physical attributes.
- **Locations**: Stored in `bat_mokeko_location.dart` as `BatLocations.locations` (Map<String, List<LatLng>>). Generate using `tools/fetch_bat_coords.py` script that queries GBIF API for occurrence data.
- **Images**: Assets in `assets/images/`, referenced by `bat.imagePath` (e.g., "assets/images/artibeus_lituratus.jpg").

## UI Patterns
- **Theming**: Dark theme by default (`ThemeData.dark()`). Colors assigned by ecological role: warm tones for dispersors, cool for pollinators.
- **Layout**: Split-screen with flexible panels; responsive design with drawer on small screens.
- **Navigation**: Push to `BatDetailScreen` on bat tap; back navigation via AppBar.
- **Markers**: Custom flutter_map markers with species-specific colors; draggable for location editing.

## Development Workflows
- **Run App**: `flutter run` (supports web, Android, Windows).
- **Build**: `flutter build <platform>` (e.g., `flutter build web`).
- **Test**: `flutter test` for unit tests in `test/widget_test.dart`.
- **Lint**: `flutter analyze` and `flutter format .` for code quality.
- **Fetch Data**: Run `python tools/fetch_bat_coords.py` to generate location suggestions from GBIF; paste output into `bat_mokeko_location.dart`.
- **Dependencies**: Add via `flutter pub add <package>`; key packages: flutter_map, latlong2, geolocator.

## Conventions
- **Naming**: Portuguese for bat attributes (e.g., `commonName`, `description`); English for code.
- **Imports**: Relative imports within lib/; absolute for packages.
- **Widgets**: Prefer StatelessWidget where possible; use Stateful for interactive panels.
- **Async**: Use Geolocator for location permissions; handle in `initState`.
- **Error Handling**: Minimal; rely on Flutter's built-in error boundaries.

## Common Tasks
- **Add New Bat**: Append to `batdex` list in `main.dart`, add image to assets, update locations in `bat_mokeko_location.dart`.
- **Update Map**: Modify `BatMapPanel` for new visualization modes or marker styles.
- **Filter Logic**: Adjust in `MainScreen` based on `selectedBats` and `showAll` flags.