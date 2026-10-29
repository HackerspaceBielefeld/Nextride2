import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/departue_data_store.dart';
import '../service/departure_source.dart';

class TimetableProvider extends ChangeNotifier {
  DepartureDataStore? timetable;

  final DepartureSource source;
  // Haltestellen-ID (Format je nach Quelle) -> Bezeichnung.
  final Map<String, String> stations;

  late final Timer _updateTimer;
  late final Timer _maintainanceTimer;

  TimetableProvider({required this.source, required this.stations}) {
    _updateTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      fetch();
    });

    _maintainanceTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      maintainance();
    });
  }

  void cleanup() {
    timetable?.cleanup();
  }

  void maintainance() {
    if (timetable == null) {
      return;
    }

    timetable!.cleanup();

    // Bewusst immer benachrichtigen: die relativen Zeiten ("in 3 min")
    // muessen auch ohne Datenaenderung regelmaessig neu gerendert werden.
    notifyListeners();
  }

  Future<void> fetch() async {
    try {
      await Future.wait(stations.keys.map(fetchStation));
    } catch (e) {
      // Timer-Callback: eine Exception waere hier unbehandelt. Vorhandene
      // Abfahrten bleiben stehen, beim naechsten Durchlauf wird neu versucht.
      debugPrint('Timetable fetch failed: $e');
    }

    notifyListeners();
  }

  Future<void> fetchStation(String stationId) async {
    final departures = await source.fetchStation(stationId, stations[stationId] ?? '');
    (timetable ??= DepartureDataStore()).replaceStation(stationId, departures);
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _maintainanceTimer.cancel();
    super.dispose();
  }
}
