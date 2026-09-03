import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

/// Akzeptiert '0xAARRGGBB', '#RRGGBB' und 'RRGGBB'. Bei einem unbekannten
/// Format wird nicht geworfen (das lief frueher bis ins build() durch), sondern
/// [fallback] geliefert.
Color hexToColor(String? code, {Color fallback = const Color(0xff000000)}) {
  if (code == null || code.isEmpty) {
    return fallback;
  }

  String value = code.trim();
  if (value.startsWith('#')) {
    value = value.substring(1);
  }
  if (value.length == 6) {
    value = 'ff$value';
  }
  if (!value.startsWith('0x') && !value.startsWith('0X')) {
    value = '0x$value';
  }

  final int? parsed = int.tryParse(value);
  return parsed == null ? fallback : Color(parsed);
}

// 0 ist kein Wochentag
const List<String> weekdaynames = [
  "-",
  "Mo",
  "Di",
  "Mi",
  "Do",
  "Fr",
  "Sa",
  "So"
];
const Map<String, IconData> iconLib = {
  'account-group': MdiIcons.accountGroup,
  'ballot-outline': MdiIcons.ballotOutline,
  'cake': MdiIcons.cake,
  'chip': MdiIcons.chip,
  'shield-lock-open-outline': MdiIcons.shieldLockOpenOutline,
  'snake': MdiIcons.snake,
};

IconData summaryIcon(String? iconname) {
  if (iconname != null) {
    if (iconLib.containsKey(iconname)) {
      return iconLib[iconname]!;
    }
  }

  return MdiIcons.helpRhombusOutline;
}

class CalendarItemVisualMarker {
  final IconData itemicon;
  final Color itemcolor;

  CalendarItemVisualMarker({required this.itemicon, required this.itemcolor});

  factory CalendarItemVisualMarker.fromJson(Map<String, dynamic> json) {
    return CalendarItemVisualMarker(
        itemicon: summaryIcon(json['name'] as String?),
        itemcolor: hexToColor(json['color'] as String?));
  }
}

class CalendarItem {
  final String summary;
  final int tsstart;
  final int tsend;
  final List<dynamic> categories;
  final Color color;
  final CalendarItemVisualMarker icon;
  final bool cancelled;

  DateTime get start => DateTime.fromMillisecondsSinceEpoch(tsstart * 1000);
  DateTime get end => DateTime.fromMillisecondsSinceEpoch(tsend * 1000);

  String get weekday => weekdaynames[start.weekday];
  int get day => start.day;
  int get month => start.month;
  int get hour => start.hour;
  int get minute => start.minute;

  CalendarItem(
      {required this.summary,
      required this.tsstart,
      required this.tsend,
      required this.categories,
      required this.color,
      required this.icon,
      required this.cancelled});

  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    const defaultIcon = {'name': 'none', 'color': '0xff000000'};

    return CalendarItem(
        summary: json['summary'] as String? ?? '',
        tsstart: json['tsstart'] as int? ?? 0,
        tsend: json['tsend'] as int? ?? 0,
        categories: (json['categories'] as List<dynamic>?) ?? const [],
        color: hexToColor(json['color'] as String?),
        icon: CalendarItemVisualMarker.fromJson(
            (json['icon'] as Map<String, dynamic>?) ?? defaultIcon),
        cancelled: json['cancelled'] == true);
  }
}

class CalendarItems {
  final List<CalendarItem> items;

  CalendarItems({required this.items});

  factory CalendarItems.fromJson(List<dynamic> json) {
    List<CalendarItem> items = [];

    for (var value in json) {
      items.add(CalendarItem.fromJson(value));
    }

    return CalendarItems(items: items);
  }
}
