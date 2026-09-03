import 'departure_data.dart';

class DepartureDataStore {
  DepartureDataStore();

  final List<DepartureData> _items = [];

  List<DepartureData> get items => _items;

  factory DepartureDataStore.fromJson(List<dynamic> json) {
    DepartureDataStore result = DepartureDataStore();
    for (var element in json) {
      result.add(DepartureData.fromJson(element));
    }
    return result;
  }

  void add(DepartureData entry) {
    int oldIdx = _items.indexWhere((element) => element.key == entry.key);
    if (oldIdx >= 0) {
      // An Ort und Stelle ersetzen, danach neu einsortieren. Frueher wurde der
      // alte Eintrag geloescht und der neue angehaengt - dadurch ist jede
      // aktualisierte Abfahrt ans Listenende gerutscht und die Anzeige der
      // naechsten N Abfahrten zeigte die falschen Fahrten.
      _items[oldIdx] = entry;
    } else {
      _items.add(entry);
    }

    _items.sort((a, b) => a.fullTime.compareTo(b.fullTime));
  }

  void addFromJson(List<dynamic> json) {
    for (var element in json) {
      add(DepartureData.fromJson(element));
    }
  }

  /// Entfernt alle bereits abgefahrenen Verbindungen.
  void cleanup() {
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // removeWhere statt where().forEach(remove) - letzteres modifiziert die
    // Liste waehrend ueber ihre Lazy-View iteriert wird (ConcurrentModificationError).
    _items.removeWhere((element) => element.fullTime < now);
  }

  Set<String> getRouteNames() {
    Set<String> result = {};
    for (var element in _items) {
      result.add(element.route);
    }
    return result;
  }

  List<DepartureData> getByRouteName(String route) {
    return _items.where((element) => element.route == route).toList();
  }

  List<DepartureData> getByDirectionCode(String code) {
    return _items.where((element) => element.directionCode == code).toList();
  }

  @override
  String toString() {
    return _items.toString();
  }
}
