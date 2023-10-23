import 'package:flutter/material.dart';

String buildInfo = "Nextride v2.0.0";

String endpoint = "https://haltestellenmonitor.vrr.de";

Map<String, Color> mobielLineColors = {
  '1': Colors.blue,
  '2': Colors.lightGreen,
  '3': Colors.yellow,
  '4': Colors.red
};

Map<int, String> requestStations = {
  //23005500: 'Bielefeld HBF',
  //23005001: 'Adenauerplatz',
  23005614: 'Bielefeld+Ziegelstraße',
};

String openWeatherAPIKey = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
String weatherCityName = 'Bielefeld';

String hassioBaseURI = 'http://1.2.3.4:8123/';
String hassioAuthToken = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
String hassioTimerEntity = 'timer.bestelltimer';
String hassioTextEntity = 'input_text.displaytext';
