import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nextride2/models/line_color.dart';

class LineColorProvider with ChangeNotifier {
  static const Duration _retryInterval = Duration(minutes: 5);
  static const Duration _refreshInterval = Duration(hours: 24);

  final String endpoint;
  LineColorTable table = LineColorTable.fallback;

  Timer? _timer;
  bool _loaded = false;

  LineColorProvider({required this.endpoint});

  Future<void> fetch() async {
    try {
      http.Response response = await http.get(Uri.parse(endpoint), headers: {"Cache-Control": "no-store"});

      if (response.statusCode != 200) {
        throw Exception('Failed to load line colors (${response.statusCode})');
      }

      final LineColorTable fetched = LineColorTable.fromStadtbahnLive(jsonDecode(response.body) as List<dynamic>);

      // Ohne globale IDs in der Antwort wuerde die leere Tabelle auch die
      // eingebauten Stadtbahnfarben verdraengen - dann lieber weiter versuchen.
      if (fetched.isEmpty) {
        throw Exception('Line color response contains no usable entries');
      }

      table = fetched;
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Line color update failed: $e');
    }

    _schedule();
  }

  /// Bis zum ersten Erfolg alle 5 Minuten, danach taeglich.
  void _schedule() {
    _timer?.cancel();
    _timer = Timer(_loaded ? _refreshInterval : _retryInterval, fetch);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
