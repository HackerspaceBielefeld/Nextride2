import 'package:flutter_test/flutter_test.dart';
import 'package:nextride2/config.dart';
import 'package:nextride2/service/departure_source.dart';

void main() {
  group('AppConfig.fromEnvironment', () {
    test('ohne Variablen: efa, Standard-Endpunkte, alles Standortspezifische leer', () {
      final config = AppConfig.fromEnvironment(const {});
      expect(config.departureSource, DepartureSourceType.efa);
      expect(config.departureEndpoint, 'https://www.westfalenfahrplan.de/nwl-efa');
      expect(config.departureStations, isEmpty);
      expect(config.openWeatherApiKey, isEmpty);
      expect(config.weatherCity, isEmpty);
      expect(config.hassioEnabled, isFalse);
    });

    test('Endpunkt folgt der Quelle, eigener Endpunkt ohne Slash am Ende', () {
      expect(AppConfig.fromEnvironment(const {'DEPARTURE_SOURCE': 'vrr'}).departureEndpoint,
          'https://haltestellenmonitor.vrr.de');
      expect(
          AppConfig.fromEnvironment(const {'DEPARTURE_SOURCE': 'efa', 'DEPARTURE_ENDPOINT': 'https://efa.example/ '})
              .departureEndpoint,
          'https://efa.example');
    });

    test('Home Assistant nur mit URI und Token, Slash am Ende entfernt', () {
      final config = AppConfig.fromEnvironment(const {'HASSIO_BASE_URI': 'http://ha:8123//', 'HASSIO_TOKEN': ' t '});
      expect(config.hassioEnabled, isTrue);
      expect(config.hassioBaseUri, 'http://ha:8123');
      expect(config.hassioToken, 't');
      expect(AppConfig.fromEnvironment(const {'HASSIO_BASE_URI': 'http://ha:8123'}).hassioEnabled, isFalse);
    });
  });

  group('AppConfig.parseDepartureSource', () {
    test('akzeptiert Schreibweisen von stadtbahn.live', () {
      for (final value in ['stadtbahnlive', 'stadtbahnLive', 'stadtbahn.live', 'STADTBAHN_LIVE']) {
        expect(AppConfig.parseDepartureSource(value), DepartureSourceType.stadtbahnLive, reason: value);
      }
    });

    test('unbekannt oder leer ergibt efa', () {
      expect(AppConfig.parseDepartureSource('hafas'), DepartureSourceType.efa);
      expect(AppConfig.parseDepartureSource(''), DepartureSourceType.efa);
    });
  });

  group('AppConfig.parseStations', () {
    test('mehrere Haltestellen, IDs mit Doppelpunkten', () {
      expect(AppConfig.parseStations('de:05711:5614=Ziegelstraße; de:05711:5500 = Hbf'),
          {'de:05711:5614': 'Ziegelstraße', 'de:05711:5500': 'Hbf'});
    });

    test('ohne Bezeichnung gilt die ID, leere Eintraege werden ignoriert', () {
      expect(AppConfig.parseStations('23005614;;'), {'23005614': '23005614'});
      expect(AppConfig.parseStations(''), isEmpty);
    });
  });
}
