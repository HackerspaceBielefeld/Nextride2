import 'package:flutter/foundation.dart';

import 'service/departure_source.dart';

/// Version fuer den User-Agent, keine Konfiguration.
const String buildInfo = "Nextride v2.0.0";

/// Laufzeitkonfiguration aus Umgebungsvariablen, siehe README.md und
/// nextride2.env.example. Auf dem Pi kommt sie aus /etc/nextride2.env, lokal
/// aus .env.local bzw. .vscode/settings.json.
class AppConfig {
  final DepartureSourceType departureSource;
  final String departureEndpoint;
  // Haltestellen-ID (Format je nach Quelle) -> Bezeichnung.
  final Map<String, String> departureStations;
  final String lineColorsEndpoint;

  // Leer: Wetter wird nicht abgefragt.
  final String openWeatherApiKey;
  final String weatherCity;

  final String rocketLaunchEndpoint;

  // Leere Werte schalten Home Assistant bzw. einzelne Entities ab.
  final String hassioBaseUri;
  final String hassioToken;
  final String hassioTimerEntity;
  final String hassioTextEntity;
  final String hassioWcBusyEntity;
  final String hassioLeistungEntity;

  const AppConfig({
    required this.departureSource,
    required this.departureEndpoint,
    required this.departureStations,
    required this.lineColorsEndpoint,
    required this.openWeatherApiKey,
    required this.weatherCity,
    required this.rocketLaunchEndpoint,
    required this.hassioBaseUri,
    required this.hassioToken,
    required this.hassioTimerEntity,
    required this.hassioTextEntity,
    required this.hassioWcBusyEntity,
    required this.hassioLeistungEntity,
  });

  // Oeffentliche Endpunkte ohne Zugangsdaten haben Standardwerte, alles
  // Standortspezifische (Haltestellen, Stadt, Keys, Home Assistant) nicht.
  static const Map<DepartureSourceType, String> defaultDepartureEndpoints = {
    DepartureSourceType.efa: 'https://www.westfalenfahrplan.de/nwl-efa',
    DepartureSourceType.vrr: 'https://haltestellenmonitor.vrr.de',
    DepartureSourceType.stadtbahnLive: 'https://stadtbahn.live',
  };
  static const String defaultLineColorsEndpoint = 'https://stadtbahn.live/api/v1/lines';
  static const String defaultRocketLaunchEndpoint = 'https://fdo.rocketlaunch.live/json/launches/next/5';

  factory AppConfig.fromEnvironment(Map<String, String> environment) {
    String env(String name) => (environment[name] ?? '').trim();
    String envOr(String name, String fallback) => env(name).isEmpty ? fallback : env(name);
    // Abschliessende Slashes weg, die Pfade werden mit '/...' angehaengt.
    String url(String value) => value.replaceAll(RegExp(r'/+$'), '');

    final DepartureSourceType source = parseDepartureSource(env('DEPARTURE_SOURCE'));

    return AppConfig(
      departureSource: source,
      departureEndpoint: url(envOr('DEPARTURE_ENDPOINT', defaultDepartureEndpoints[source]!)),
      departureStations: parseStations(env('DEPARTURE_STATIONS')),
      lineColorsEndpoint: envOr('LINE_COLORS_ENDPOINT', defaultLineColorsEndpoint),
      openWeatherApiKey: env('OPENWEATHER_API_KEY'),
      weatherCity: env('WEATHER_CITY'),
      rocketLaunchEndpoint: envOr('ROCKET_LAUNCH_ENDPOINT', defaultRocketLaunchEndpoint),
      hassioBaseUri: url(env('HASSIO_BASE_URI')),
      hassioToken: env('HASSIO_TOKEN'),
      hassioTimerEntity: env('HASSIO_TIMER_ENTITY'),
      hassioTextEntity: env('HASSIO_TEXT_ENTITY'),
      hassioWcBusyEntity: env('HASSIO_WCBUSY_ENTITY'),
      hassioLeistungEntity: env('HASSIO_LEISTUNG_ENTITY'),
    );
  }

  bool get hassioEnabled => hassioBaseUri.isNotEmpty && hassioToken.isNotEmpty;

  /// 'efa' (Standard), 'vrr' oder 'stadtbahnlive', Gross-/Kleinschreibung egal.
  static DepartureSourceType parseDepartureSource(String value) {
    final String normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    for (final type in DepartureSourceType.values) {
      if (type.name.toLowerCase() == normalized) {
        return type;
      }
    }

    if (normalized.isNotEmpty) {
      debugPrint('DEPARTURE_SOURCE "$value" unbekannt - nehme efa.');
    }
    return DepartureSourceType.efa;
  }

  /// 'id=Name;id=Name'. Die Bezeichnung ist optional, die ID darf
  /// Doppelpunkte enthalten ('de:05711:5614=Ziegelstraße').
  static Map<String, String> parseStations(String value) {
    final Map<String, String> result = {};

    for (final entry in value.split(';')) {
      final int eq = entry.indexOf('=');
      final String id = (eq < 0 ? entry : entry.substring(0, eq)).trim();
      if (id.isEmpty) {
        continue;
      }
      result[id] = eq < 0 ? id : entry.substring(eq + 1).trim();
    }

    return result;
  }
}
