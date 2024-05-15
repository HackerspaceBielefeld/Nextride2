import 'package:nextride2/providers/clock_provider.dart';
import 'package:nextride2/providers/network_provider.dart';
import 'package:nextride2/providers/rocket_launch_provider.dart';
import 'package:nextride2/widgets/htmlrichtext.dart';

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
            leistungName: constants.hassioLeistung)),
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

    if (constants.withHassio) {
      Provider.of<HassioProvider>(context, listen: false).updateHassioText();
      Provider.of<HassioProvider>(context, listen: false).updateHassioTimer();
    }

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

      return MaterialApp(
        title: 'Nextride 2',
        themeMode: ThemeMode.light,
        theme: ThemeData(
          primarySwatch: Colors.red,
          useMaterial3: false,
          //brightness: Brightness.dark,

          textTheme: Theme.of(context).textTheme.apply(
                //fontSizeFactor: 0.9,
                fontSizeFactor: fontSizeFactor,
                fontSizeDelta: fontSizeDelta,
              ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.red,
          textTheme: Theme.of(context).textTheme.apply(
                //fontSizeFactor: 0.9,
                fontSizeFactor: fontSizeFactor,
                fontSizeDelta: fontSizeDelta,
              ),
        ),
        home: true
            ? const NextrideScreen()
            : Scaffold(
                body: HtmlRichTextWidget(
                  html: """
          <body>
          <p style="font-size: 24px; font-weight: bold; color: #ff0000;">Nextride 2</p>
          <br />
          <p style="font-size: 18px; font-weight: bold; color: #ff0000;">Nächste Abfahrten</p>
          <hr />
          <p style="font-size: 18px; font-weight: bold; color: #ff0000;">Kalender</p>
          <br />
          <button icon="star" style="color: orange; background-color: white">Test - MOEP</button>
          <icon name="bus" color="#00fe00" size="90" />
          <p style="font-size: 18px; font-weight: bold; color: blue;">Test</p>
          <br />
          <img src="http://bjoernweis.de/icons/ubuntu-logo.png" width="100" height="100" />
          <br />
          <center><p style="font-size: 18px; font-weight: bold; color: #ff0000;">Uhrzeit</p></center>
          <p style="font-size: 12px; color: #aadd44;">Wetter</p>
          <center>
          <button type="outlined" icon="star" style="color: orange; background-color: white">Test - MOEP</button>
          <vr />
          <button type="text" icon="star" style="color: orange; background-color: white">Test - MOEP</button>
          </center>
          <center>
          <button icon="star" style="color: orange; background-color: white">Test - MOEP</button>
          </center>
          <br />
          <p style="color: black; font-size:18px">Tescht</p> <a style="font-size:18px" href="https://www.google.de">Google</a> <p>Link</p>
          </body>
        """,
                ),
              ),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
