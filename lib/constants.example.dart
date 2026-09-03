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

// Ohne abschliessenden Slash - die Pfade werden mit '/api/...' angehaengt.
String hassioBaseURI = 'http://1.2.3.4:8123';
String hassioAuthToken = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
String hassioTimerEntity = 'timer.bestelltimer';
String hassioTextEntity = 'input_text.displaytext';
String hassioWCBusy = 'input_boolean.wc_busy';
String hassioLeistung = 'sensor.leistung_total';

String rocketLaunchEndpoint = 'https://fdo.rocketlaunch.live/json/launches/next/5';
