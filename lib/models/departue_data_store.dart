import 'departure_data.dart';

class DepartureDataStore {
  DepartureDataStore();

  // Pro Haltestelle die Abfahrten des letzten erfolgreichen Abrufs.
  final Map<String, List<DepartureData>> _byStation = {};
  List<DepartureData> _items = [];

  List<DepartureData> get items => _items;

  /// Ersetzt die Abfahrten einer Haltestelle komplett. Fahrten, die die EFA
  /// nicht mehr liefert, verschwinden so sofort statt bis zu ihrer
  /// Abfahrtszeit stehen zu bleiben.
  void replaceStation(String stationId, List<DepartureData> departures) {
    // Kopie: cleanup() entfernt daraus, die Liste des Aufrufers bleibt unberuehrt.
    _byStation[stationId] = List.of(departures);
    _rebuild();
  }

  /// Entfernt alle bereits abgefahrenen Verbindungen.
  void cleanup() {
    final DateTime now = DateTime.now();
    // removeWhere statt where().forEach(remove) - letzteres modifiziert die
    // Liste waehrend ueber ihre Lazy-View iteriert wird (ConcurrentModificationError).
    for (final departures in _byStation.values) {
      departures.removeWhere((element) => element.time.isBefore(now));
    }
    _rebuild();
  }

  void _rebuild() {
    // Doppelte Eintraege (z.B. dieselbe Fahrt an zwei abgefragten
    // Haltestellen-IDs) ueber den Schluessel zusammenfassen.
    final Map<String, DepartureData> unique = {};
    for (final departures in _byStation.values) {
      for (final departure in departures) {
        unique[departure.key] = departure;
      }
    }

    _items = unique.values.toList()..sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  String toString() {
    return _items.toString();
  }
}
