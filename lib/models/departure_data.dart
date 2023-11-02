import 'package:flutter/material.dart';

class DepartureData {
  final String name;
  final String lineNumber;
  final String lineCode;
  final String subname;
  final String direction;
  final String directionCode;
  final String route;
  final int type;
  final int day;
  final int month;
  final int year;
  final int hour;
  final int minute;
  final int orgDay;
  final int orgHour;
  final int orgMinute;
  final int? delay;
  final int fullTime;
  final int orgFullTime;
  final String key;

  DepartureData(
      {required this.name,
      required this.lineNumber,
      required this.lineCode,
      required this.subname,
      required this.direction,
      required this.directionCode,
      required this.route,
      required this.type,
      required this.day,
      required this.month,
      required this.year,
      required this.hour,
      required this.minute,
      required this.orgDay,
      required this.orgHour,
      required this.orgMinute,
      this.delay,
      required this.fullTime,
      required this.orgFullTime,
      required this.key});

  static String _processDirection(String? name) {
    String result = name ?? '';

    // Komplett dämlich, aber die API liefert manchmal Daten ohne Bielefeld, vorran
    /*
    if (result == "Sieker") {
      result = "Bielefeld, Sieker";
    }

    if (result == "Altenhagen") {
      result = "Bielefeld, Altenhagen";
    }
    */
    if (result.startsWith('Bielefeld, ')) {
      result = result.substring(11);
    }

    return result;
  }

  factory DepartureData.fromJson(Map<String, dynamic> json) {
    return DepartureData(
      name: json['name'],
      lineNumber: json['lineNumber'],
      lineCode: json['lineCode'],
      subname: json['subname'],
      direction: _processDirection(json['direction']),
      directionCode: json['directionCode'],
      route: _processDirection(json['route']),
      type: json['type'],
      day: int.parse(json['day']),
      month: int.parse(json['month']),
      year: int.parse(json['year']),
      hour: int.parse(json['hour']),
      minute: int.parse(json['minute']),
      orgDay: int.parse(json['orgDay']),
      orgHour: int.parse(json['orgHour']),
      orgMinute: int.parse(json['orgMinute']),
      delay: json['delay'] == null || json['delay'] == ""
          ? null
          : int.parse(json['delay']),
      fullTime: int.parse(json['fullTime']),
      orgFullTime: int.parse(json['orgFullTime']),
      key: json['key'],
    );
  }

  DateTime get orgFullTimeDT =>
      DateTime.fromMillisecondsSinceEpoch(orgFullTime * 1000);

  DateTime get fullTimeDT =>
      DateTime.fromMillisecondsSinceEpoch(fullTime * 1000);
}
