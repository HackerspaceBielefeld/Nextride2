import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextride2/models/departue_data_store.dart';
import 'package:nextride2/models/departure_data.dart';
import 'package:nextride2/models/line_color.dart';

/// Gekuerztes stopEvent aus dem echten DM_REQUEST fuer Bielefeld, Ziegelstrasse.
Map<String, dynamic> stopEvent({
  String disassembledName = '2',
  String? number = '2',
  String globalId = 'de:NWL:05711|Stadtbahn|2:',
  String transportationId = 'owl:31002: :R:6_0',
  String destinationName = 'Bielefeld, Sieker',
  List<Map<String, dynamic>>? onwardLocations,
  String planned = '2026-10-16T07:50:00Z',
  String? estimated = '2026-10-16T07:53:12Z',
  List<String> realtimeStatus = const ['MONITORED'],
  bool? isCancelled,
}) {
  return {
    'realtimeStatus': realtimeStatus,
    'isRealtimeControlled': true,
    if (isCancelled != null) 'isCancelled': isCancelled,
    'location': {
      'id': 'de:05711:5614:81:81',
      'name': 'Bielefeld, Ziegelstraße',
      'disassembledName': 'Gleis 1',
      'type': 'platform',
      'properties': {'stopId': '23005614', 'platformName': 'Gleis 1'},
      'parent': {
        'id': 'de:05711:5614',
        'name': 'Bielefeld, Ziegelstraße',
        'disassembledName': 'Ziegelstraße',
        'type': 'stop',
        'parent': {'name': 'Bielefeld', 'type': 'locality'},
      },
    },
    'departureTimePlanned': planned,
    if (estimated != null) 'departureTimeEstimated': estimated,
    'transportation': {
      'id': transportationId,
      'name': 'Stadtbahn $disassembledName',
      'disassembledName': disassembledName,
      if (number != null) 'number': number,
      'product': {'id': 1, 'class': 3, 'name': 'Stadtbahn', 'iconId': 4},
      'destination': {'id': '23005081', 'name': destinationName, 'type': 'stop'},
      'properties': {'globalId': globalId},
    },
    'onwardLocations': onwardLocations ??
        [
          lastStop('de:05711:5001', 'Bielefeld, Kesselbrink', 'Kesselbrink', 'Bielefeld'),
          lastStop('de:05711:5081', 'Bielefeld, Sieker', 'Sieker', 'Bielefeld'),
        ],
  };
}

Map<String, dynamic> lastStop(String id, String name, String? disassembledName, String locality) => {
      'name': name,
      'disassembledName': 'Gleis 1',
      'type': 'platform',
      'parent': {
        'id': id,
        'name': name,
        if (disassembledName != null) 'disassembledName': disassembledName,
        'type': 'stop',
        'parent': {'name': locality, 'type': 'locality'},
      },
    };

DepartureData departure({
  required DateTime planned,
  DateTime? estimated,
  bool monitored = true,
  String key = 'k',
}) =>
    DepartureData(
      lineName: '2',
      destination: 'Sieker',
      planned: planned,
      estimated: estimated,
      isMonitored: monitored,
      isCancelled: false,
      key: key,
    );

void main() {
  group('DepartureData.tryFromEfa', () {
    test('parst eine Stadtbahn-Abfahrt', () {
      final d = DepartureData.tryFromEfa(stopEvent())!;

      expect(d.lineName, '2');
      expect(d.globalId, 'de:NWL:05711|Stadtbahn|2:');
      expect(d.productClass, 3);
      expect(d.destination, 'Sieker');
      expect(d.platform, 'Gleis 1');
      expect(d.planned, DateTime.utc(2026, 10, 16, 7, 50).toLocal());
      expect(d.estimated, DateTime.utc(2026, 10, 16, 7, 53, 12).toLocal());
      expect(d.time, d.estimated);
      expect(d.delayMinutes, 3);
      expect(d.isMonitored, isTrue);
      expect(d.isCancelled, isFalse);
      expect(d.key, 'owl:31002: :R:6_0|de:05711:5614:81:81|2026-10-16T07:50:00Z');
    });

    test('zeigt lange Liniennamen unveraendert', () {
      final d = DepartureData.tryFromEfa(stopEvent(disassembledName: '2 SEV', number: '2 SEV'))!;
      expect(d.lineName, '2 SEV');
    });

    test('nimmt fuer ICE ohne disassembledName die Zugnummer', () {
      final event = stopEvent(number: '845');
      (event['transportation'] as Map<String, dynamic>).remove('disassembledName');
      expect(DepartureData.tryFromEfa(event)!.lineName, '845');
    });

    test('Ziel ausserhalb des Ortes behaelt den vollen Namen', () {
      final d = DepartureData.tryFromEfa(stopEvent(
        destinationName: 'Osnabrück Hbf',
        onwardLocations: [lastStop('de:03404:12345', 'Osnabrück Hbf', 'Hbf', 'Osnabrück')],
      ))!;
      expect(d.destination, 'Osnabrück Hbf');
    });

    test('Kurzname auch bei abweichendem Ortsnamen in derselben Gemeinde', () {
      // Echte EFA-Daten: Altenhagen liegt in Bielefeld (05711), der Ort heisst
      // aber "Altenhagen (Bielef)".
      final d = DepartureData.tryFromEfa(stopEvent(
        destinationName: 'Altenhagen (Bielef), Altenhagen',
        onwardLocations: [lastStop('de:05711:10456', 'Altenhagen (Bielef), Altenhagen', 'Altenhagen', 'Altenhagen (Bielef)')],
      ))!;
      expect(d.destination, 'Altenhagen');
    });

    test('ohne onwardLocations wird "Bielefeld, " abgeschnitten', () {
      final d = DepartureData.tryFromEfa(stopEvent(destinationName: 'Bielefeld, Altenhagen', onwardLocations: []))!;
      expect(d.destination, 'Altenhagen');
    });

    test('ohne Kurzname der Endhaltestelle wird "Bielefeld, " abgeschnitten', () {
      final d = DepartureData.tryFromEfa(stopEvent(
        destinationName: 'Bielefeld, Senne',
        onwardLocations: [lastStop('de:05711:5503', 'Bielefeld, Senne', null, 'Senne')],
      ))!;
      expect(d.destination, 'Senne');
    });

    test('erkennt Ausfaelle ueber isCancelled und realtimeStatus', () {
      expect(DepartureData.tryFromEfa(stopEvent(isCancelled: true))!.isCancelled, isTrue);
      expect(
          DepartureData.tryFromEfa(stopEvent(realtimeStatus: ['MONITORED', 'TRIP_CANCELLED']))!.isCancelled, isTrue);
    });

    test('ohne Echtzeit gibt es keine Verspaetung', () {
      final d = DepartureData.tryFromEfa(stopEvent(estimated: null, realtimeStatus: []))!;
      expect(d.isMonitored, isFalse);
      expect(d.delayMinutes, isNull);
      expect(d.time, d.planned);
    });

    test('ueberspringt Eintraege ohne Planzeit', () {
      final event = stopEvent()..remove('departureTimePlanned');
      expect(DepartureData.tryFromEfa(event), isNull);
    });
  });

  group('formatDepartureTime', () {
    final now = DateTime(2026, 10, 16, 8, 0);

    test('"jetzt" unter einer Minute', () {
      expect(formatDepartureTime(departure(planned: now.add(const Duration(seconds: 30))), now), 'jetzt');
    });

    test('"jetzt" auch knapp nach Abfahrt', () {
      expect(formatDepartureTime(departure(planned: now.subtract(const Duration(seconds: 10))), now), 'jetzt');
    });

    test('"in X min" mit abgerundeten Minuten', () {
      expect(formatDepartureTime(departure(planned: now.add(const Duration(minutes: 5, seconds: 40))), now),
          'in 5 min');
    });

    test('nutzt die voraussichtliche Zeit', () {
      expect(
          formatDepartureTime(
              departure(planned: now.add(const Duration(minutes: 2)), estimated: now.add(const Duration(minutes: 7))),
              now),
          'in 7 min');
    });

    test('Uhrzeit ohne Echtzeitdaten', () {
      expect(formatDepartureTime(departure(planned: DateTime(2026, 10, 16, 8, 12), monitored: false), now), '08:12');
    });
  });

  group('DepartureDataStore', () {
    test('replaceStation verwirft nicht mehr gelieferte Fahrten', () {
      final soon = DateTime.now().add(const Duration(minutes: 5));
      final later = DateTime.now().add(const Duration(minutes: 15));
      final store = DepartureDataStore()
        ..replaceStation('a', [departure(planned: later, key: 'x'), departure(planned: soon, key: 'y')]);

      expect(store.items.map((d) => d.key), ['y', 'x']);

      store.replaceStation('a', [departure(planned: later, key: 'x')]);
      expect(store.items.map((d) => d.key), ['x']);
    });

    test('cleanup entfernt abgefahrene Verbindungen', () {
      final store = DepartureDataStore()
        ..replaceStation('a', [
          departure(planned: DateTime.now().subtract(const Duration(minutes: 1)), key: 'gone'),
          departure(planned: DateTime.now().add(const Duration(minutes: 5)), key: 'stays'),
        ]);

      store.cleanup();
      expect(store.items.map((d) => d.key), ['stays']);
    });
  });

  group('LineColorTable', () {
    // Echte Antwort von stadtbahn.live/api/v1/lines (gekuerzt, Stand 2026-10-16).
    final List<dynamic> response = [
      {
        'line': '2',
        'name': null,
        'color': '#009037',
        'text_color': null,
        'vtype': 'tram',
        'efa_id': 'owl:31002::H:6_0',
        'global_id': 'de:NWL:05711|Stadtbahn|2:',
      },
      {
        'line': '3',
        'name': null,
        'color': '#ffec00',
        'text_color': '#000000',
        'vtype': 'tram',
        'efa_id': 'owl:31003::H:6_0',
        'global_id': 'de:NWL:05711|Stadtbahn|3:',
      },
      {
        'line': '32',
        'name': null,
        'color': '#97bf0d',
        'text_color': '#ffffff',
        'vtype': 'bus',
        'efa_id': null,
        'global_id': 'de:NWL:05711|Bus|32:',
      },
      {
        'line': '48',
        'name': null,
        'color': '#39a9dc',
        'text_color': '#ffffff',
        'vtype': 'bus',
        'efa_id': null,
        'global_id': 'de:NWL:05754|Bus|48:',
      },
      {
        'line': '901',
        'name': 'N1',
        'color': '#0f2c68',
        'text_color': '#ffffff',
        'vtype': 'bus',
        'efa_id': null,
        'global_id': 'de:NWL:05711|Bus|N1:N',
      },
      {
        'line': '992',
        'name': 'SEV2',
        'color': '#009037',
        'text_color': '#ffffff',
        'vtype': 'bus',
        'efa_id': 'owl:32002: :H:6_0',
        'global_id': null,
      },
      {
        'line': '101',
        'name': null,
        'color': null,
        'text_color': null,
        'vtype': 'bus',
        'efa_id': null,
        'global_id': 'de:NWL:05758024|Bus|101:',
      },
    ];

    final table = LineColorTable.fromStadtbahnLive(response);

    test('findet Linien exakt ueber die globale ID', () {
      expect(table.lookup('de:NWL:05711|Stadtbahn|2:')!.background, const Color(0xFF009037));
      expect(table.lookup('de:NWL:05754|Bus|48:')!.background, const Color(0xFF39A9DC));
      expect(table.lookup('de:NWL:05711|Bus|N1:N')!.background, const Color(0xFF0F2C68));
    });

    test('Textfarbe kommt aus text_color', () {
      expect(table.lookup('de:NWL:05711|Stadtbahn|3:')!.foreground, const Color(0xFF000000));
      // Heller Hintergrund, aber die API sagt Weiss - die API gewinnt.
      expect(table.lookup('de:NWL:05711|Bus|32:')!.foreground, const Color(0xFFFFFFFF));
    });

    test('ohne text_color wird die Textfarbe aus der Helligkeit bestimmt', () {
      expect(table.lookup('de:NWL:05711|Stadtbahn|2:')!.foreground, Colors.white);
    });

    test('ueberspringt Eintraege ohne Farbe', () {
      expect(table.lookup('de:NWL:05758024|Bus|101:'), isNull);
    });

    test('unbekannte Linien, Zuege und fehlende IDs liefern null', () {
      expect(table.lookup('de:nrw:re6:'), isNull);
      expect(table.lookup('de:db:FLX'), isNull);
      expect(table.lookup(null), isNull);
      expect(LineColor.unknown.background, const Color(0xFF000080));
      expect(LineColor.unknown.foreground, Colors.white);
    });

    test('Antwort ohne global_id ergibt eine leere Tabelle', () {
      final withoutIds = response.map((e) => Map<String, dynamic>.of(e)..remove('global_id')).toList();
      expect(LineColorTable.fromStadtbahnLive(withoutIds).isEmpty, isTrue);
    });

    test('Fallback kennt die Stadtbahnlinien', () {
      expect(LineColorTable.fallback.lookup('de:NWL:05711|Stadtbahn|1:')!.background, const Color(0xFF009EDF));
      expect(LineColorTable.fallback.lookup('de:NWL:05711|Stadtbahn|3:')!.foreground, const Color(0xFF000000));
    });
  });
}
