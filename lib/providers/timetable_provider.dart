import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nextride2/service/api_client.dart';

import '../constants.dart' as constants;
import '../models/departue_data_store.dart';

class TimetableProvider extends ChangeNotifier {
  DepartureDataStore? timetable;

  late Timer _updateTimer;
  late Timer _maintainanceTimer;

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
    if (timetable != null) {
      timetable!.cleanup();
    }
  }

  void maintainance() {
    if (timetable == null) {
      return;
    }

    DateTime now = DateTime.now();

    for (int i = timetable!.items.length - 1; i >= 0; i--) {
      if (now.isAfter(timetable!.items[i].fullTimeDT)) {
        timetable!.items.removeAt(i);
      }
    }

    notifyListeners();
  }

  Future<void> fetch() async {
    /*
    constants.requestStations.forEach((key, value) {
      await fetchStation(key, value);
    });
    */
    await Future.wait(List.generate(constants.requestStations.length, (index) {
      return fetchStation(constants.requestStations.keys.elementAt(index),
          constants.requestStations.values.elementAt(index));
    }));

    notifyListeners();
  }

  Future<void> fetchStation(int id, String name) async {
    APIClientResponse response = await APIClient.post(
        'backend/api/stations/table', _requestBody(id, name));

    if (timetable == null) {
      timetable = DepartureDataStore.fromJson(
          jsonDecode(response.item1.body)['departureData']);
    } else {
      timetable!.addFromJson(jsonDecode(response.item1.body)['departureData']);
    }
    //notifyListeners();
  }
}
