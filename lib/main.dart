import 'package:nextride2/providers/clock_provider.dart';
import 'package:nextride2/providers/network_provider.dart';
import 'package:nextride2/providers/rocket_launch_provider.dart';

import '../constants.dart' as constants;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'providers/calendar_provider.dart';
import 'providers/hassio_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/nextride_screen.dart';

void main() {
  timeago.setLocaleMessages('de', timeago.DeMessages());

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => TimetableProvider()),
    ChangeNotifierProvider(create: (context) => CalendarProvider()),
    ChangeNotifierProvider(create: (context) => WeatherProvider()),
    ChangeNotifierProvider(create: (context) => ClockProvider()),
    ChangeNotifierProvider(create: (context) => NetworkProvider()),
    ChangeNotifierProvider(create: (context) => RocketLaunchProvider(endpoint: constants.rocketLaunchEndpoint)),
    ChangeNotifierProvider(
        create: (context) => HassioProvider(
            baseURI: constants.hassioBaseURI,
            authToken: constants.hassioAuthToken,
            timerName: constants.hassioTimerEntity,
            textName: constants.hassioTextEntity,
            wcbusyName: constants.hassioWCBusy,
            leistungName: constants.hassioLeistung,
            enabled: constants.withHassio)),
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

      final baseTextTheme = Theme.of(context).textTheme;

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
          // Auf dem Text-Theme des Dark-Themes aufsetzen, sonst waeren die
          // Textfarben die des hellen Fallback-Themes (unlesbar auf dunkel).
          textTheme: ThemeData.dark().textTheme.apply(
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
