import 'dart:convert';

import '../../models/departure_data.dart';
import '../api_client.dart';
import '../departure_source.dart';

/// EFA `XML_DM_REQUEST` (rapidJSON), z.B. von Westfalenfahrplan.
class EfaDepartureSource implements DepartureSource {
  final String endpoint;

  EfaDepartureSource(this.endpoint);

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

  @override
  Future<List<DepartureData>> fetchStation(String stationId, String stationName) async {
    APIClientResponse response = await APIClient.get(endpoint, 'XML_DM_REQUEST', _requestParameters(stationId));

    final decoded = jsonDecode(response.item1.body);
    final List<dynamic> stopEvents = (decoded['stopEvents'] as List<dynamic>?) ?? const [];

    return stopEvents
        .whereType<Map<String, dynamic>>()
        .map(DepartureData.tryFromEfa)
        .whereType<DepartureData>()
        .toList();
  }
}
