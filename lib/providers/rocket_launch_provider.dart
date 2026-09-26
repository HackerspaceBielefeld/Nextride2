import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nextride2/models/rocket_launch_data_store.dart';

class RocketLaunchProvider with ChangeNotifier {
  late final Timer _updateTimer;
  final String endpoint;
  bool loading = false;
  RocketLaunchDataStore? rocketLaunchDataStore;

  RocketLaunchProvider({required this.endpoint}) {
    _updateTimer = Timer.periodic(const Duration(hours: 12), (timer) {
      fetch();
    });
  }

  Future<void> fetch() async {
    loading = true;

    try {
      http.Response response = await http.get(Uri.parse(endpoint), headers: {"Cache-Control": "no-store"});

      if (response.statusCode != 200) {
        throw Exception('Failed to load rocket launches (${response.statusCode})');
      }

      Map<String, dynamic> jsondata = jsonDecode(response.body);
      final List<dynamic> result = jsondata['result'] as List<dynamic>;

      if (rocketLaunchDataStore == null) {
        rocketLaunchDataStore = RocketLaunchDataStore.fromJson(result);
      } else {
        rocketLaunchDataStore!.addFromJson(result);
        rocketLaunchDataStore!.cleanup();
      }
    } catch (e) {
      debugPrint('Rocket launch update failed: $e');
    }

    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }
}
