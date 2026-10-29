import 'package:flutter/material.dart';

import 'departure_data.dart';

/// Feldname der globalen Linien-ID in der stadtbahn.live-Antwort. Entspricht
/// `transportation.properties.globalId` der EFA (z.B. 'de:NWL:05711|Stadtbahn|2:').
const String _globalIdField = 'global_id';

class LineColor {
  final Color background;
  final Color foreground;

  const LineColor({required this.background, required this.foreground});

  /// Fuer Linien ohne bekannte Farbe (Zuege, fremde Verbuende, ...).
  static const LineColor unknown = LineColor(background: Color(0xFF000080), foreground: Colors.white);
}

class LineColorTable {
  final Map<String, LineColor> _byGlobalId;
  // EFA-Liniennummer aus efa_id ('owl:31002::H:6_0' -> '31002'), fuer den VRR.
  final Map<String, LineColor> _byLineCode;
  // Linienkennung von stadtbahn.live ('line'), fuer die DFI-Abfahrten.
  final Map<String, LineColor> _byStadtbahnLiveLine;

  const LineColorTable._(this._byGlobalId, [this._byLineCode = const {}, this._byStadtbahnLiveLine = const {}]);

  /// Eingebaute Stadtbahnfarben (Stand stadtbahn.live), damit vor dem ersten
  /// erfolgreichen Abruf bzw. offline zumindest die Bahnen stimmen.
  static const LineColorTable fallback = LineColorTable._({
    'de:NWL:05711|Stadtbahn|1:': _line1,
    'de:NWL:05711|Stadtbahn|2:': _line2,
    'de:NWL:05711|Stadtbahn|3:': _line3,
    'de:NWL:05711|Stadtbahn|4:': _line4,
  }, {
    '31001': _line1,
    '31002': _line2,
    '31003': _line3,
    '31004': _line4,
  }, {
    '1': _line1,
    '2': _line2,
    '3': _line3,
    '4': _line4,
  });

  static const LineColor _line1 = LineColor(background: Color(0xFF009EDF), foreground: Colors.white);
  static const LineColor _line2 = LineColor(background: Color(0xFF009037), foreground: Colors.white);
  static const LineColor _line3 = LineColor(background: Color(0xFFFFEC00), foreground: Color(0xFF000000));
  static const LineColor _line4 = LineColor(background: Color(0xFFE1001A), foreground: Colors.white);

  /// Baut die Tabelle aus der Antwort von stadtbahn.live/api/v1/lines.
  /// Eintraege ohne (gueltige) Farbe werden uebersprungen.
  factory LineColorTable.fromStadtbahnLive(List<dynamic> json) {
    final Map<String, LineColor> result = {};
    final Map<String, LineColor> byLineCode = {};
    final Map<String, LineColor> byLine = {};

    for (final entry in json) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }

      final String? globalId = (entry[_globalIdField] as String?)?.trim();
      final Color? background = _parseHex(entry['color']);
      if (background == null) {
        continue;
      }

      // text_color der API hat Vorrang; nur wenn sie fehlt, wird anhand der
      // Helligkeit des Hintergrunds Schwarz oder Weiss gewaehlt.
      final Color foreground = _parseHex(entry['text_color']) ??
          (ThemeData.estimateBrightnessForColor(background) == Brightness.dark ? Colors.white : Colors.black);

      final LineColor color = LineColor(background: background, foreground: foreground);
      if (globalId != null && globalId.isNotEmpty) {
        result[globalId] = color;
      }
      final String? lineCode = _lineCodeFromEfaId(entry['efa_id']);
      if (lineCode != null) {
        byLineCode[lineCode] = color;
      }
      final String? line = (entry['line'] as String?)?.trim();
      if (line != null && line.isNotEmpty) {
        byLine[line] = color;
      }
    }

    return LineColorTable._(result, byLineCode, byLine);
  }

  /// Leer heisst hier: keine globalen IDs. Ohne die stimmen die Farben fuer die
  /// EFA nicht, dann bleibt besser die eingebaute Tabelle.
  bool get isEmpty => _byGlobalId.isEmpty;

  /// Farbe einer Abfahrt, je nachdem welchen Schluessel ihre Quelle liefert.
  LineColor? lookupDeparture(DepartureData departure) {
    return lookup(departure.globalId) ??
        _byLineCode[departure.lineCode] ??
        _byStadtbahnLiveLine[departure.stadtbahnLiveLine];
  }

  static String? _lineCodeFromEfaId(dynamic efaId) {
    if (efaId is! String) {
      return null;
    }
    final List<String> parts = efaId.split(':');
    return parts.length >= 2 && parts[1].trim().isNotEmpty ? parts[1].trim() : null;
  }

  /// Exakter Abgleich mit `transportation.properties.globalId` der EFA.
  LineColor? lookup(String? globalId) {
    if (globalId == null) {
      return null;
    }
    return _byGlobalId[globalId.trim()];
  }

  static Color? _parseHex(dynamic value) {
    if (value is! String) {
      return null;
    }

    final String hex = value.trim().replaceFirst('#', '');
    if (hex.length != 6) {
      return null;
    }

    final int? rgb = int.tryParse(hex, radix: 16);
    return rgb == null ? null : Color(0xFF000000 | rgb);
  }
}
