import 'package:flutter/material.dart';

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

  const LineColorTable._(this._byGlobalId);

  /// Eingebaute Stadtbahnfarben (Stand stadtbahn.live), damit vor dem ersten
  /// erfolgreichen Abruf bzw. offline zumindest die Bahnen stimmen.
  static const LineColorTable fallback = LineColorTable._({
    'de:NWL:05711|Stadtbahn|1:': LineColor(background: Color(0xFF009EDF), foreground: Colors.white),
    'de:NWL:05711|Stadtbahn|2:': LineColor(background: Color(0xFF009037), foreground: Colors.white),
    'de:NWL:05711|Stadtbahn|3:': LineColor(background: Color(0xFFFFEC00), foreground: Color(0xFF000000)),
    'de:NWL:05711|Stadtbahn|4:': LineColor(background: Color(0xFFE1001A), foreground: Colors.white),
  });

  /// Baut die Tabelle aus der Antwort von stadtbahn.live/api/v1/lines.
  /// Eintraege ohne globale ID oder ohne (gueltige) Farbe werden uebersprungen.
  factory LineColorTable.fromStadtbahnLive(List<dynamic> json) {
    final Map<String, LineColor> result = {};

    for (final entry in json) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }

      final String? globalId = (entry[_globalIdField] as String?)?.trim();
      final Color? background = _parseHex(entry['color']);
      if (globalId == null || globalId.isEmpty || background == null) {
        continue;
      }

      // text_color der API hat Vorrang; nur wenn sie fehlt, wird anhand der
      // Helligkeit des Hintergrunds Schwarz oder Weiss gewaehlt.
      final Color foreground = _parseHex(entry['text_color']) ??
          (ThemeData.estimateBrightnessForColor(background) == Brightness.dark ? Colors.white : Colors.black);

      result[globalId] = LineColor(background: background, foreground: foreground);
    }

    return LineColorTable._(result);
  }

  bool get isEmpty => _byGlobalId.isEmpty;

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
