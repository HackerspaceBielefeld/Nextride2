import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nextride2/service/api_client.dart';

import '../constants.dart' as constants;
import '../models/departue_data_store.dart';

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

  Map<String, dynamic> _requestBody(int id, String name) {
    //TODO: Konfigurierbar machen

    Map<String, dynamic> result = {};

    var departure = {
      'stationId': id,
      'stationName': name,
      'platformVisibility': 1,
      'transport': '0,1,2,3,4,15,6',
      'useAllLines': 1,
      'linesFilter': null,
      'optimizedForStation': 0,
      'rowCount': 10,
      'refreshInterval': 60,
      'distance': 0,
      'marquee': -1,
    };

    const model = {'sortBy': 0};

    departure.forEach((key, value) {
      result['table[departure][$key]'] = value.toString();
    });

    model.forEach((key, value) {
      result['table[$key]'] = value.toString();
    });

    return result;
  }

  void cleanup() {
    timetable?.cleanup();
  }

  void maintainance() {
    if (timetable == null) {
      return;
    }

    timetable!.cleanup();

    // Bewusst immer benachrichtigen: die relativen Zeiten ("in 3 Minuten")
    // muessen auch ohne Datenaenderung regelmaessig neu gerendert werden.
    notifyListeners();
  }

  Future<void> fetch() async {
    try {
      await Future.wait(List.generate(constants.requestStations.length, (index) {
        return fetchStation(
            constants.requestStations.keys.elementAt(index), constants.requestStations.values.elementAt(index));
      }));
    } catch (e) {
      // Timer-Callback: eine Exception waere hier unbehandelt. Vorhandene
      // Abfahrten bleiben stehen, beim naechsten Durchlauf wird neu versucht.
      debugPrint('Timetable fetch failed: $e');
    }

    notifyListeners();
  }

  Future<void> fetchStation(int id, String name) async {
    APIClientResponse response = await APIClient.post('backend/api/stations/table', _requestBody(id, name));

    final decoded = jsonDecode(response.item1.body);
    final List<dynamic> departureData = (decoded['departureData'] as List<dynamic>?) ?? const [];

    if (timetable == null) {
      timetable = DepartureDataStore.fromJson(departureData);
    } else {
      timetable!.addFromJson(departureData);
    }
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _maintainanceTimer.cancel();
    super.dispose();
  }
}
