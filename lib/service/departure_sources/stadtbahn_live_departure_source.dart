import 'dart:convert';

import '../../models/departure_data.dart';
import '../api_client.dart';
import '../departure_source.dart';

/// Anzeigetafeln (DFI) von stadtbahn.live (`api/v1/dfi`). Die API liefert alle
/// Tafeln auf einmal; eine Haltestelle kann mehrere haben (Bahnsteig, Bruecke).
class StadtbahnLiveDepartureSource implements DepartureSource {
  final String endpoint;

  StadtbahnLiveDepartureSource(this.endpoint);

  @override
  Future<List<DepartureData>> fetchStation(String stationId, String stationName) async {
    APIClientResponse response = await APIClient.get(endpoint, 'api/v1/dfi');

    final List<dynamic> boards = (jsonDecode(response.item1.body) as List<dynamic>?) ?? const [];
    final List<DepartureData> result = [];

    for (final board in boards.whereType<Map<String, dynamic>>()) {
      if (board['stop'] != stationId) {
        continue;
      }

      final List<dynamic> rows = (board['rows'] as List<dynamic>?) ?? const [];
      result.addAll(rows
          .whereType<Map<String, dynamic>>()
          .map((row) => DepartureData.tryFromStadtbahnLiveDfi(board, row))
          .whereType<DepartureData>());
    }

    return result;
  }
}
