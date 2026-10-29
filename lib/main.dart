import 'dart:io';

import 'package:nextride2/providers/clock_provider.dart';
import 'package:nextride2/providers/network_provider.dart';
import 'package:nextride2/providers/rocket_launch_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'config.dart';
import 'providers/calendar_provider.dart';
import 'providers/hassio_provider.dart';
import 'providers/line_color_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/nextride_screen.dart';
import 'service/departure_source.dart';

void main() {
  timeago.setLocaleMessages('de', timeago.DeMessages());

  // Konfiguration und Zugangsdaten kommen aus der Umgebung, damit nichts davon
  // im Code oder im Asset-Bundle landet (siehe README.md).
  final config = AppConfig.fromEnvironment(Platform.environment);
  if (!config.hassioEnabled) {
    debugPrint('HASSIO_BASE_URI und/oder HASSIO_TOKEN nicht gesetzt - Home Assistant deaktiviert.');
  }
  if (config.departureStations.isEmpty) {
    debugPrint('DEPARTURE_STATIONS nicht gesetzt - keine Abfahrten.');
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (context) => TimetableProvider(
            source: DepartureSource.create(config.departureSource, endpoint: config.departureEndpoint),
            stations: config.departureStations)),
    ChangeNotifierProvider(create: (context) => CalendarProvider()),
    ChangeNotifierProvider(
        create: (context) => WeatherProvider(apiKey: config.openWeatherApiKey, cityName: config.weatherCity)),
    ChangeNotifierProvider(create: (context) => ClockProvider()),
    ChangeNotifierProvider(create: (context) => NetworkProvider()),
    ChangeNotifierProvider(create: (context) => RocketLaunchProvider(endpoint: config.rocketLaunchEndpoint)),
    ChangeNotifierProvider(create: (context) => LineColorProvider(endpoint: config.lineColorsEndpoint)),
    ChangeNotifierProvider(
        create: (context) => HassioProvider(
            baseURI: config.hassioBaseUri,
            authToken: config.hassioToken,
            timerName: config.hassioTimerEntity,
            textName: config.hassioTextEntity,
            wcbusyName: config.hassioWcBusyEntity,
            leistungName: config.hassioLeistungEntity,
            enabled: config.hassioEnabled)),
  ], child: const Nextride2App()));
}

class Nextride2App extends StatefulWidget {
  const Nextride2App({super.key});

  @override
  State<Nextride2App> createState() => _Nextride2AppState();
}

class _Nextride2AppState extends State<Nextride2App> {
  @override
  void initState() {
    super.initState();

    Provider.of<TimetableProvider>(context, listen: false).fetch();
    Provider.of<LineColorProvider>(context, listen: false).fetch();
    Provider.of<CalendarProvider>(context, listen: false).update();
    Provider.of<WeatherProvider>(context, listen: false).update();

    // updateAll() prueft selbst, ob die Hassio-Anbindung aktiv ist.
    Provider.of<HassioProvider>(context, listen: false).updateAll();

    Provider.of<RocketLaunchProvider>(context, listen: false).fetch();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var fontSizeFactor = 1.8;
      var fontSizeDelta = 2.2;

      if (constraints.maxHeight < 800) {
        fontSizeFactor = 1.0;
        fontSizeDelta = 1.2;
      }

      // Schriftgroessen (englishLike, 2021er Geometrie wie bisher) und Farben
      // explizit zusammenfuehren: ThemeData.dark().textTheme hat keine fontSize,
      // dann schlaegt die Assertion in TextStyle.apply zu.
      final typography = Typography.material2021();
      final baseTextTheme = typography.englishLike.merge(typography.black);
      final darkTextTheme = typography.englishLike.merge(typography.white);

      return MaterialApp(
        title: 'Nextride 2',
        themeMode: ThemeMode.light,
        theme: ThemeData(
          primarySwatch: Colors.red,
          useMaterial3: false,
          textTheme: baseTextTheme.apply(
            fontSizeFactor: fontSizeFactor,
            fontSizeDelta: fontSizeDelta,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.red,
          // Helle Textfarben, sonst waeren sie unlesbar auf dunkel.
          textTheme: darkTextTheme.apply(
                fontSizeFactor: fontSizeFactor,
                fontSizeDelta: fontSizeDelta,
              ),
        ),
        home: const NextrideScreen(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
