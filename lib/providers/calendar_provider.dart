import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/calendar_item.dart';

class CalendarProvider extends ChangeNotifier {
  CalendarItems? items;
  bool loading = true;

  final String baseURI = 'https://status.space.bi/calendar.json';
  late Timer _updateTimer;

  CalendarProvider() {
    _updateTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      update();
    });
  }

  Future<void> update() async {
    loading = true;

    http.Response response = await http
        .get(Uri.parse(baseURI), headers: {"Cache-Control": "no-store"});

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = jsonDecode(response.body);
      try {
        items = CalendarItems.fromJson(jsondata['items'] as List<dynamic>);
      } catch (e) {
        print("error parse calendar");
        print(e.toString());
      }
    } else {
      throw Exception('Failed to load status');
    }
    loading = false;
    notifyListeners();
  }
}
