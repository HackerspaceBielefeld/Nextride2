import 'package:flutter/material.dart';

String buildInfo = "Nextride v2.0.0";

String endpoint = "https://haltestellenmonitor.vrr.de";

Map<String, Color> mobielLineColors = {'1': Colors.blue, '2': Colors.lightGreen, '3': Colors.yellow, '4': Colors.red};

Map<int, String> requestStations = {
  //23005500: 'Bielefeld HBF',
  //23005001: 'Adenauerplatz',
  23005614: 'Bielefeld+Ziegelstraße',
};

String openWeatherAPIKey = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
String weatherCityName = 'Bielefeld';

// Home-Assistant-Anbindung komplett deaktivieren (wird in main.dart geprueft).
bool withHassio = true;

// Endpunkt, Token und Entity-Namen kommen zur Laufzeit aus der Umgebung,
// siehe README.md. Fehlt HASSIO_BASE_URI oder HASSIO_TOKEN, bleibt die
// Anbindung deaktiviert; nicht gesetzte Entities werden uebersprungen.

String rocketLaunchEndpoint = 'https://fdo.rocketlaunch.live/json/launches/next/5';
