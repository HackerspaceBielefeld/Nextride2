import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nextride2/constants.dart';
import 'package:nextride2/models/hassio_state.dart';

class HassioProvider extends ChangeNotifier {
  bool loading = true;

  HassioInputTextState? hassioText;
  HassioTimerState? hassioTimer;
  HassioInputBooleanState? hassioWCBusy;
  HassioInputPowerState? hassioLeistung;

  final String baseURI;
  final String authToken;
  final String timerName;
  final String textName;
  final String wcbusyName;
  final String leistungName;

  late Timer _updateTimer;
  Timer? _displayRefreshTimer;

  HassioProvider(
      {required this.baseURI,
      required this.authToken,
      required this.timerName,
      required this.textName,
      required this.wcbusyName,
      required this.leistungName}) {
    RawDatagramSocket.bind('0.0.0.0', 31338).then((RawDatagramSocket udpSocket) {
      udpSocket.listen((e) {
        Datagram? dg = udpSocket.receive();
        debugPrint('Received UDP data: $dg');

        updateHassioText(notify: false);
        updateHassioWCBusy(notify: false);
        updateHassioTimer(notify: false);
        updateHassioLeistung(notify: false);
        notifyListeners();
      });
    });

    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (false & kDebugMode) {
        hassioText = HassioInputTextState(
          entityId: 'sensor.test_text',
          state: 'Test Text',
          attributes: {},
          lastChanged: DateTime.now(),
          lastUpdated: DateTime.now(),
          contextId: 'test',
          editable: true,
          icon: 'mdi:clock',
          friendlyName: 'Test Text',
        );
        hassioWCBusy = HassioInputBooleanState(
          entityId: 'sensor.test_wc_busy',
          state: Random().nextBool() ? 'on' : 'off',
          attributes: {},
          lastChanged: DateTime.now(),
          lastUpdated: DateTime.now(),
          contextId: 'test',
          editable: true,
          icon: 'mdi:clock',
          friendlyName: 'Test WC Busy',
        );
        hassioTimer = HassioTimerState(
          entityId: 'sensor.test_timer',
          state: Random().nextBool() ? 'active' : 'idle',
          attributes: {
            'duration': '00:01:00',
            'editable': true,
            'finishes_at': DateTime.now().toIso8601String(),
            'icon': 'mdi:clock',
            'friendly_name': 'Test Timer',
          },
          lastChanged: DateTime.now(),
          lastUpdated: DateTime.now(),
          contextId: 'test',
          duration: Duration.zero,
          editable: true,
          finishesAt: DateTime.now(),
          icon: 'mdi:clock',
          friendlyName: 'Test Timer',
        );
        hassioLeistung = HassioInputPowerState(
          unitOfMeasurement: 'W',
          entityId: 'sensor.test_leistung',
          state: Random().nextDouble().toString(),
          attributes: {},
          lastChanged: DateTime.now(),
          lastUpdated: DateTime.now(),
          contextId: 'test',
          friendlyName: 'Test Leistung',
          deviceClass: 'none',
        );
      } else {
        updateHassioText(notify: false);
        updateHassioWCBusy(notify: false);
        updateHassioTimer(notify: false);
        updateHassioLeistung(notify: false);
        notifyListeners();
      }
    });
  }

  Future<void> updateHassioText({bool notify = true}) async {
    loading = true;
    Map<String, dynamic> hassioState = await getHassioState(textName);
    debugPrint(hassioState.toString());
    hassioText = HassioInputTextState.fromHassioState(HassioState.fromJson(hassioState));
    loading = false;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> updateHassioWCBusy({bool notify = true}) async {
    loading = true;
    Map<String, dynamic> hassioState = await getHassioState(wcbusyName);
    debugPrint(hassioState.toString());

    hassioWCBusy = HassioInputBooleanState.fromHassioState(HassioState.fromJson(hassioState));
    loading = false;
    if (notify) notifyListeners();
  }

  Future<void> updateHassioLeistung({bool notify = true}) async {
    loading = true;
    Map<String, dynamic> hassioState = await getHassioState(leistungName);
    debugPrint(hassioState.toString());

    hassioLeistung = HassioInputPowerState.fromHassioState(HassioState.fromJson(hassioState));
    loading = false;
    if (notify) notifyListeners();
  }

  Future<void> updateHassioTimer({bool notify = true}) async {
    loading = true;
    Map<String, dynamic> hassioState = await getHassioState(timerName);
    debugPrint(hassioState.toString());

    hassioTimer = HassioTimerState.fromHassioState(HassioState.fromJson(hassioState));

    if (hassioTimer!.runState == HassioTimerStateRunState.active) {
      _displayRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        notifyListeners();
      });
    } else {
      if (_displayRefreshTimer != null) {
        _displayRefreshTimer!.cancel();
        _displayRefreshTimer = null;
      }
    }

    loading = false;
    if (notify) notifyListeners();
  }

  Future<Map<String, dynamic>> getHassioState(String entity) async {
    Map<String, String> headers = {
      "Cache-Control": "no-store",
      "Authorization": "Bearer $authToken",
      "content-type": "application/json"
    };

    Uri reqUri = Uri.parse('$baseURI/api/states/$entity');
    debugPrint('Hassio request: ${reqUri.toString()}');

    http.Response response = await http.get(reqUri, headers: headers);
    debugPrint('Hassio response: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hassio data (${response.statusCode}) - ${reqUri.toString()} - ${response.body}');
    }
  }
}
