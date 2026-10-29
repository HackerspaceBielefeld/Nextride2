import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'package:weather/weather.dart';

class WeatherProvider extends ChangeNotifier {
  bool loading = true;

  late final WeatherFactory _wf;
  List<Weather> forecast = [];
  // Hinweistext fuer die Anzeige, wenn das letzte Update fehlgeschlagen ist.
  String? error;
  late final Timer _updateTimer;

  static const Map<String, IconData> weatherIcons = {
    '01d': MdiIcons.weatherSunny,
    '02d': MdiIcons.weatherPartlyCloudy,
    '03d': MdiIcons.weatherCloudy,
    '04d': MdiIcons.weatherCloudy,
    '09d': MdiIcons.weatherPouring,
    '10d': MdiIcons.weatherRainy,
    '11d': MdiIcons.weatherLightningRainy,
    '13d': MdiIcons.weatherSnowy,
    '50d': MdiIcons.weatherFog,
    '01n': MdiIcons.weatherNight,
    '02n': MdiIcons.weatherPartlyCloudy,
    '03n': MdiIcons.weatherCloudy,
    '04n': MdiIcons.weatherCloudy,
    '09n': MdiIcons.weatherPouring,
    '10n': MdiIcons.weatherRainy,
    '11n': MdiIcons.weatherLightningRainy,
    '13n': MdiIcons.weatherSnowy,
    '50n': MdiIcons.weatherFog,
  };

  final String apiKey;
  final String cityName;

  WeatherProvider({required this.apiKey, required this.cityName}) {
    _wf = WeatherFactory(apiKey, language: Language.GERMAN);

    _updateTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      update();
    });
  }

  static IconData getWeatherIcon(String iconname) {
    if (weatherIcons.containsKey(iconname)) {
      return weatherIcons[iconname]!;
    }

    return MdiIcons.helpRhombusOutline;
  }

  Map<DateTime, List<Weather>> groupAndSortWeatherByDate() {
    Map<DateTime, List<Weather>> weatherByDate = {};
    for (Weather weather in forecast) {
      if (weather.date == null) {
        continue;
      }

      DateTime date = DateTime(weather.date!.year, weather.date!.month, weather.date!.day);
      if (!weatherByDate.containsKey(date)) {
        weatherByDate[date] = [];
      }
      weatherByDate[date]!.add(weather);
    }

    List<DateTime> dates = weatherByDate.keys.toList();
    dates.sort();

    Map<DateTime, List<Weather>> result = {};
    for (DateTime date in dates) {
      result[date] = weatherByDate[date]!;
    }

    return result;
  }

  Future<void> update() async {
    // Ohne Key keine Anfrage, die waere sowieso mit 401 abgelehnt worden.
    if (apiKey.isEmpty || cityName.isEmpty) {
      error = 'Wetter nicht konfiguriert (OPENWEATHER_API_KEY, WEATHER_CITY)';
      loading = false;
      notifyListeners();
      return;
    }

    loading = true;

    // Bei einem Fehler bleibt der letzte Forecast stehen statt zu verschwinden.
    try {
      forecast = await _wf.fiveDayForecastByCityName(cityName);
      error = null;
    } on OpenWeatherAPIException catch (e) {
      // Die Exception liefert keinen Statuscode, nur den Antworttext.
      error = e.toString().contains('401')
          ? 'Wetter kann nicht geladen werden: API-Key ungültig'
          : 'Wetter kann nicht geladen werden';
      debugPrint('Weather update failed: $e');
    } catch (e) {
      error = 'Wetter kann nicht geladen werden';
      debugPrint('Weather update failed: $e');
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
