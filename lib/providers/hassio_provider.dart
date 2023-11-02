import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nextride2/models/hassio_state.dart';

class HassioProvider extends ChangeNotifier {
  bool loading = true;

  HassioInputTextState? hassioText;
  HassioTimerState? hassioTimer;

  final String baseURI;
  final String authToken;
  final String timerName;
  final String textName;

  late Timer _updateTimer;
  Timer? _displayRefreshTimer;

  HassioProvider(
      {required this.baseURI,
      required this.authToken,
      required this.timerName,
      required this.textName}) {
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      //updateHassioText();
      //updateHassioTimer();
    });
  }

  Future<void> updateHassioText() async {
    loading = true;
    Map<String, dynamic> hassioState = await getHassioState(textName);
    hassioText =
        HassioInputTextState.fromHassioState(HassioState.fromJson(hassioState));
    loading = false;
    notifyListeners();
  }

  Future<void> updateHassioTimer() async {
    loading = true;
    Map<String, dynamic> hassioState = await getHassioState(timerName);
    hassioTimer =
        HassioTimerState.fromHassioState(HassioState.fromJson(hassioState));

    if (hassioTimer!.runState == HassioTimerStateRunState.active) {
      _displayRefreshTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        notifyListeners();
      });
    } else {
      if (_displayRefreshTimer != null) {
        _displayRefreshTimer!.cancel();
        _displayRefreshTimer = null;
      }
    }

    loading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getHassioState(String entity) async {
    Map<String, String> headers = {
      "Cache-Control": "no-store",
      "Authorization": "Bearer $authToken",
      "content-type": "application/json"
    };

    Uri reqUri = Uri.parse('$baseURI/api/states/$entity');

    http.Response response = await http.get(reqUri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to load hassio data (${response.statusCode}) - ${reqUri.toString()} - ${response.body}');
    }
  }
}
