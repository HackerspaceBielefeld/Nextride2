import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import '../constants.dart' as constants;

import 'package:weather/weather.dart';

class WeatherProvider extends ChangeNotifier {
  bool loading = true;

  late final WeatherFactory _wf;
  List<Weather> forecast = [];
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

  WeatherProvider() {
    _wf = WeatherFactory(constants.openWeatherAPIKey, language: Language.GERMAN);

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
    loading = true;

    // Bei einem Fehler bleibt der letzte Forecast stehen statt zu verschwinden.
    try {
      forecast = await _wf.fiveDayForecastByCityName(constants.weatherCityName);
    } catch (e) {
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
