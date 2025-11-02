import json
import math
import urllib.parse
import urllib.request

SPECIES = [
    "Artibeus lituratus",
    "Carollia perspicillata",
    "Sturnira lilium",
    "Platyrrhinus helleri",
    "Glossophaga soricina",
    "Artibeus obscurus",
    "Phyllostomus discolor",
    "Chiroderma villosum",
    "Hsunycteris thomasi",
    "Anoura caudifer",
]

BBOX_MANAUS = {
    "min_lat": -3.4,
    "max_lat": -2.8,
    "min_lon": -60.2,
    "max_lon": -59.4,
}

# Wider Amazon basin fallback
BBOX_AMAZONAS = {
    "min_lat": -6.5,
    "max_lat": 0.5,
    "min_lon": -66.5,
    "max_lon": -56.0,
}

GBIF_ENDPOINT = "https://api.gbif.org/v1/occurrence/search"


def fetch_occurrences(scientific_name: str, limit: int = 300) -> list[dict]:
    params = {
        "scientificName": scientific_name,
        "hasCoordinate": "true",
        "country": "BR",
        "limit": str(limit),
    }
    url = f"{GBIF_ENDPOINT}?{urllib.parse.urlencode(params)}"
    with urllib.request.urlopen(url) as response:
        payload = json.load(response)
    return payload.get("results", [])


def within_bbox(lat: float, lon: float, bbox: dict[str, float]) -> bool:
    return (
        bbox["min_lat"] <= lat <= bbox["max_lat"]
        and bbox["min_lon"] <= lon <= bbox["max_lon"]
    )


def dedupe_coords(coords: list[tuple[float, float]]) -> list[tuple[float, float]]:
    seen: set[tuple[int, int]] = set()
    unique: list[tuple[float, float]] = []
    for lat, lon in coords:
        key = (round(lat, 5), round(lon, 5))
        if key in seen:
            continue
        seen.add(key)
        unique.append((lat, lon))
    return unique


def gather_for_species(name: str) -> dict[str, list[tuple[float, float]]]:
    records = fetch_occurrences(name)
    manaus = []
    amazonas = []
    fallback = []

    for rec in records:
        lat = rec.get("decimalLatitude")
        lon = rec.get("decimalLongitude")
        if lat is None or lon is None:
            continue
        coords = (float(lat), float(lon))
        if within_bbox(coords[0], coords[1], BBOX_MANAUS):
            manaus.append(coords)
        if within_bbox(coords[0], coords[1], BBOX_AMAZONAS):
            amazonas.append(coords)
        fallback.append(coords)

    out = {
        "manaus": dedupe_coords(manaus),
        "amazonas": dedupe_coords(amazonas),
        "fallback": dedupe_coords(fallback),
    }
    return out


def main():
    report = {}
    for name in SPECIES:
        collected = gather_for_species(name)
        report[name] = collected

    print("// Auto-generated coordinate suggestions based on GBIF occurrences")
    print("// Priority: Manaus > Amazonas > Brazil-wide fallback")
    print("static final Map<String, List<LatLng>> gbifLocations = {")

    for name, buckets in report.items():
        desired = 8
        chosen: list[tuple[float, float]] = []

        def append_coords(source_list: list[tuple[float, float]]):
            for coord in source_list:
                if coord not in chosen:
                    chosen.append(coord)
                    if len(chosen) >= desired:
                        return True
            return False

        source_label = []

        if buckets["manaus"]:
            append_coords(buckets["manaus"])
            source_label.append("Manaus")
        if len(chosen) < desired and buckets["amazonas"]:
            append_coords(buckets["amazonas"])
            source_label.append("Amazonas")
        if len(chosen) < desired:
            append_coords(buckets["fallback"])
            source_label.append("Brazil-wide")

        source = ", ".join(source_label)

        print(f"  '{name}': [  // {source} ({len(chosen)} records)")
        for lat, lon in chosen:
            print(f"    LatLng({lat:.6f}, {lon:.6f}),")
        print("  ],")

    print("};")


if __name__ == "__main__":
    main()
