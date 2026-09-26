import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nextride2/models/hassio_state.dart';

class HassioProvider extends ChangeNotifier {
  bool loading = true;

  /// Auf true setzen, um ohne erreichbares Home Assistant zu entwickeln.
  bool useMockData = false;

  HassioInputTextState? hassioText;
  HassioTimerState? hassioTimer;
  HassioInputBooleanState? hassioWCBusy;
  HassioInputPowerState? hassioLeistung;

  final String baseURI;
  final String authToken;
  // Leere Entity-Namen (Umgebungsvariable nicht gesetzt) werden uebersprungen.
  final String timerName;
  final String textName;
  final String wcbusyName;
  final String leistungName;

  /// Wenn false, werden weder UDP-Socket noch Update-Timer gestartet - die
  /// Consumer im UI bleiben dann einfach bei ihren Null-Zustaenden.
  final bool enabled;

  Timer? _updateTimer;
  Timer? _displayRefreshTimer;
  RawDatagramSocket? _udpSocket;
  bool _disposed = false;

  HassioProvider(
      {required this.baseURI,
      required this.authToken,
      required this.timerName,
      required this.textName,
      required this.wcbusyName,
      required this.leistungName,
      this.enabled = true}) {
    if (!enabled) {
      return;
    }

    RawDatagramSocket.bind('0.0.0.0', 31338).then((RawDatagramSocket udpSocket) {
      if (_disposed) {
        udpSocket.close();
        return;
      }

      _udpSocket = udpSocket;
      udpSocket.listen((e) {
        Datagram? dg = udpSocket.receive();
        if (dg == null) {
          return;
        }
        debugPrint('Received UDP data: $dg');

        updateAll();
      });
    }).catchError((Object e) {
      // Port belegt o.ae. - der periodische Timer uebernimmt trotzdem.
      debugPrint('Hassio UDP bind on 31338 failed: $e');
    });

    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      updateAll();
    });
  }

  /// Holt alle Entities und benachrichtigt erst danach ein einziges Mal.
  Future<void> updateAll() async {
    if (!enabled) {
      return;
    }

    if (useMockData) {
      _fillWithMockData();
      _safeNotify();
      return;
    }

    loading = true;
    await Future.wait([
      updateHassioText(notify: false),
      updateHassioWCBusy(notify: false),
      updateHassioTimer(notify: false),
      updateHassioLeistung(notify: false),
    ]);
    loading = false;
    _safeNotify();
  }

  // Bei einem fehlgeschlagenen Update bleibt der zuletzt bekannte Wert stehen,
  // statt die Anzeige auf "unbekannt" zurueckzusetzen.
  Future<void> updateHassioText({bool notify = true}) async {
    final state = await _fetchState(textName, HassioInputTextState.fromHassioState);
    if (state != null) hassioText = state;
    if (notify) _safeNotify();
  }

  Future<void> updateHassioWCBusy({bool notify = true}) async {
    final state = await _fetchState(wcbusyName, HassioInputBooleanState.fromHassioState);
    if (state != null) hassioWCBusy = state;
    if (notify) _safeNotify();
  }

  Future<void> updateHassioLeistung({bool notify = true}) async {
    final state = await _fetchState(leistungName, HassioInputPowerState.fromHassioState);
    if (state != null) hassioLeistung = state;
    if (notify) _safeNotify();
  }

  Future<void> updateHassioTimer({bool notify = true}) async {
    final timerState = await _fetchState(timerName, HassioTimerState.fromHassioState);
    if (timerState != null) {
      hassioTimer = timerState;
    }

    // Waehrend ein Timer laeuft muss der Countdown jede Sekunde neu gezeichnet
    // werden. Ohne den Cancel-Zweig wuerde bei jedem Update ein weiterer
    // Sekundentimer entstehen.
    if (hassioTimer?.runState == HassioTimerStateRunState.active) {
      _displayRefreshTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
        _safeNotify();
      });
    } else {
      _displayRefreshTimer?.cancel();
      _displayRefreshTimer = null;
    }

    if (notify) _safeNotify();
  }

  /// Holt eine Entity und wandelt sie um. Gibt bei Fehlern null zurueck, damit
  /// ein einzelner Ausfall (Netzwerk, unbekanntes Attribut) nicht die ganze
  /// Anzeige mit einer unbehandelten Exception aus dem Timer-Callback killt.
  Future<T?> _fetchState<T extends HassioState>(String entity, T Function(HassioState) convert) async {
    if (entity.isEmpty) {
      return null;
    }
    try {
      final Map<String, dynamic> json = await getHassioState(entity);
      return convert(HassioState.fromJson(json));
    } catch (e) {
      debugPrint('Hassio update for "$entity" failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getHassioState(String entity) async {
    Map<String, String> headers = {
      "Cache-Control": "no-store",
      "Authorization": "Bearer $authToken",
      "content-type": "application/json"
    };

    // Trailing Slash in der Konfiguration wuerde sonst zu '//api/...' fuehren.
    final String base = baseURI.endsWith('/') ? baseURI.substring(0, baseURI.length - 1) : baseURI;
    Uri reqUri = Uri.parse('$base/api/states/$entity');
    debugPrint('Hassio request: $reqUri');

    http.Response response = await http.get(reqUri, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hassio data (${response.statusCode}) - $reqUri - ${response.body}');
    }
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _fillWithMockData() {
    hassioText = HassioInputTextState(
      entityId: 'sensor.test_text',
      state: 'Test Text',
      attributes: const {},
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
      attributes: const {},
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
      attributes: const {},
      lastChanged: DateTime.now(),
      lastUpdated: DateTime.now(),
      contextId: 'test',
      friendlyName: 'Test Leistung',
      deviceClass: 'none',
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _updateTimer?.cancel();
    _displayRefreshTimer?.cancel();
    _displayRefreshTimer = null;
    _udpSocket?.close();
    _udpSocket = null;
    super.dispose();
  }
}
