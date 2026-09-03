import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/calendar_item.dart';

class CalendarProvider extends ChangeNotifier {
  CalendarItems? items;
  bool loading = true;

  final String baseURI = 'https://status.space.bi/calendar.json';
  late final Timer _updateTimer;

  CalendarProvider() {
    _updateTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      update();
    });
  }

  Future<void> update() async {
    loading = true;

    // Alles abfangen: der Aufrufer ist ein Timer-Callback, eine Exception waere
    // dort unbehandelt und wuerde 'loading' dauerhaft auf true stehen lassen.
    try {
      http.Response response = await http.get(Uri.parse(baseURI), headers: {"Cache-Control": "no-store"});

      if (response.statusCode != 200) {
        throw Exception('Failed to load calendar (${response.statusCode})');
      }

      Map<String, dynamic> jsondata = jsonDecode(response.body);
      items = CalendarItems.fromJson(jsondata['items'] as List<dynamic>);
    } catch (e) {
      debugPrint('Calendar update failed: $e');
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
