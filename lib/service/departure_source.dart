import '../models/departure_data.dart';
import 'departure_sources/efa_departure_source.dart';
import 'departure_sources/stadtbahn_live_departure_source.dart';
import 'departure_sources/vrr_departure_source.dart';

/// Woher die Abfahrten kommen, Auswahl in `constants.dart`.
enum DepartureSourceType {
  /// EFA von Westfalenfahrplan (NWL), Haltestellen als DHID ('de:05711:5614').
  efa,

  /// VRR-Haltestellenmonitor, Haltestellen numerisch ('23005614').
  vrr,

  /// Anzeigetafeln von stadtbahn.live (experimentell): nur Haltestellen mit
  /// Tafel, Haltestellen als DHID, Ziele fehlen oft.
  stadtbahnLive,
}

/// Eine Abfahrtsquelle. Neue Quellen implementieren [fetchStation] und
/// bekommen einen Eintrag in [DepartureSourceType] und [DepartureSource.create].
abstract class DepartureSource {
  /// Abfahrten einer Haltestelle. Wirft bei Netzwerk- oder HTTP-Fehlern, der
  /// TimetableProvider behaelt dann die zuletzt geladenen Abfahrten.
  Future<List<DepartureData>> fetchStation(String stationId, String stationName);

  static DepartureSource create(DepartureSourceType type, {required String endpoint}) {
    switch (type) {
      case DepartureSourceType.efa:
        return EfaDepartureSource(endpoint);
      case DepartureSourceType.vrr:
        return VrrDepartureSource(endpoint);
      case DepartureSourceType.stadtbahnLive:
        return StadtbahnLiveDepartureSource(endpoint);
    }
  }
}
