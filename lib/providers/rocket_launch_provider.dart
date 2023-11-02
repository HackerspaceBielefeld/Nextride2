import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nextride2/models/rocket_launch_data_store.dart';

class RocketLaunchProvider with ChangeNotifier {
  late Timer _updateTimer;
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

    http.Response response = await http
        .get(Uri.parse(endpoint), headers: {"Cache-Control": "no-store"});

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = jsonDecode(response.body);
      try {
        if (rocketLaunchDataStore == null) {
          rocketLaunchDataStore =
              RocketLaunchDataStore.fromJson(jsondata['result']);
        } else {
          rocketLaunchDataStore!.addFromJson(jsondata['result']);
        }
      } catch (e) {
        print("error parse rocket launch");
        print(e.toString());
      }
    } else {
      throw Exception('Failed to load status');
    }
    loading = false;
    notifyListeners();
  }
}
