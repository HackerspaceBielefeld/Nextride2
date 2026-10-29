import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nextride2/service/api_client.dart';

import '../constants.dart' as constants;
import '../models/departue_data_store.dart';
import '../models/departure_data.dart';

class TimetableProvider extends ChangeNotifier {
  DepartureDataStore? timetable;

  late final Timer _updateTimer;
  late final Timer _maintainanceTimer;

  TimetableProvider() {
    _updateTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      fetch();
    });

    _maintainanceTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      maintainance();
    });
  }

  Map<String, String> _requestParameters(String stationId) {
    //TODO: Konfigurierbar machen
    return {
      'outputFormat': 'rapidJSON',
      'language': 'de',
      'type_dm': 'any',
      'name_dm': stationId,
      'mode': 'direct',
      // Beide noetig, damit onwardLocations (fuer den Ziel-Kurznamen) kommen.
      'depType': 'stopEvents',
      'includeCompleteStopSeq': '1',
      'useRealtime': '1',
      'limit': '10',
      'useAllStops': '1',
    };
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
      await Future.wait(constants.requestStations.keys.map(fetchStation));
    } catch (e) {
      // Timer-Callback: eine Exception waere hier unbehandelt. Vorhandene
      // Abfahrten bleiben stehen, beim naechsten Durchlauf wird neu versucht.
      debugPrint('Timetable fetch failed: $e');
    }

    notifyListeners();
  }

  Future<void> fetchStation(String stationId) async {
    APIClientResponse response = await APIClient.get('XML_DM_REQUEST', _requestParameters(stationId));

    final decoded = jsonDecode(response.item1.body);
    final List<dynamic> stopEvents = (decoded['stopEvents'] as List<dynamic>?) ?? const [];

    final List<DepartureData> departures = stopEvents
        .whereType<Map<String, dynamic>>()
        .map(DepartureData.tryFromEfa)
        .whereType<DepartureData>()
        .toList();

    (timetable ??= DepartureDataStore()).replaceStation(stationId, departures);
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _maintainanceTimer.cancel();
    super.dispose();
  }
}
