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
    ChangeNotifierProvider(
        create: (context) => HassioProvider(
            baseURI: constants.hassioBaseURI,
            authToken: constants.hassioAuthToken,
            timerName: constants.hassioTimerEntity,
            textName: constants.hassioTextEntity)),
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

    Provider.of<HassioProvider>(context, listen: false).updateHassioText();
    Provider.of<HassioProvider>(context, listen: false).updateHassioTimer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nextride 2',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: false,
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: 2,
              fontSizeDelta: 2.8,
            ),
      ),
      home: const NextrideScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
