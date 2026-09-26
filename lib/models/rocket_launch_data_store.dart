import 'package:nextride2/models/rocket_launch.dart';

class RocketLaunchDataStore {
  RocketLaunchDataStore();

  final List<RocketLaunch> _items = [];

  List<RocketLaunch> get items => _items;

  factory RocketLaunchDataStore.fromJson(List<dynamic> json) {
    RocketLaunchDataStore result = RocketLaunchDataStore();
    for (var element in json) {
      result.add(RocketLaunch.fromJson(element));
    }
    return result;
  }

  void add(RocketLaunch entry) {
    int oldIdx = _items.indexWhere((element) => element.id == entry.id);
    if (oldIdx >= 0) {
      // In-Place ersetzen, sonst wandert ein aktualisierter Start ans Ende und
      // die Anzeige der naechsten Starts stimmt nicht mehr.
      _items[oldIdx] = entry;
    } else {
      _items.add(entry);
    }

    _items.sort((a, b) => a.sortDate.compareTo(b.sortDate));
  }

  void addFromJson(List<dynamic> json) {
    for (var element in json) {
      add(RocketLaunch.fromJson(element));
    }
  }

  /// Entfernt Starts, die laenger als [maxAge] zurueckliegen. Ohne das waechst
  /// die Liste bei jedem Abruf weiter, weil die API nur neue Starts nachliefert.
  void cleanup({Duration maxAge = const Duration(hours: 12)}) {
    final DateTime cutoff = DateTime.now().subtract(maxAge);
    _items.removeWhere((element) => element.sortDt.isBefore(cutoff));
  }

  @override
  String toString() {
    return _items.toString();
  }
}
