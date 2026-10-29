import 'dart:convert';

import '../../models/departure_data.dart';
import '../api_client.dart';
import '../departure_source.dart';

/// VRR-Haltestellenmonitor (`backend/api/stations/table`).
class VrrDepartureSource implements DepartureSource {
  final String endpoint;

  VrrDepartureSource(this.endpoint);

  Map<String, String> _requestBody(String id, String name) {
    //TODO: Konfigurierbar machen

    Map<String, String> result = {};

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

  @override
  Future<List<DepartureData>> fetchStation(String stationId, String stationName) async {
    APIClientResponse response =
        await APIClient.post(endpoint, 'backend/api/stations/table', _requestBody(stationId, stationName));

    final decoded = jsonDecode(response.item1.body);
    final List<dynamic> departureData = (decoded['departureData'] as List<dynamic>?) ?? const [];

    return departureData
        .whereType<Map<String, dynamic>>()
        .map(DepartureData.tryFromVrr)
        .whereType<DepartureData>()
        .toList();
  }
}
