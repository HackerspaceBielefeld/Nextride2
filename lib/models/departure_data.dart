import 'package:intl/intl.dart';

/// Eine Abfahrt aus dem EFA-DM_REQUEST (rapidJSON, `stopEvents[]`).
class DepartureData {
  final String lineName;
  final String? globalId;
  final int? productClass;
  final String destination;
  final String? platform;
  final DateTime planned;
  final DateTime? estimated;
  final bool isMonitored;
  final bool isCancelled;
  final String key;

  DepartureData(
      {required this.lineName,
      this.globalId,
      this.productClass,
      required this.destination,
      this.platform,
      required this.planned,
      this.estimated,
      required this.isMonitored,
      required this.isCancelled,
      required this.key});

  static String _processDirection(String? name) {
    String result = name ?? '';

    if (result.startsWith('Bielefeld, ')) {
      result = result.substring(11);
    }

    return result;
  }

  /// Kurzname des Ziels ("Sieker" statt "Bielefeld, Sieker"), sofern die
  /// Endhaltestelle in derselben Gemeinde liegt wie die Abfahrtshaltestelle.
  /// Sonst bleibt der volle Name, damit z.B. nicht nur "Hbf" statt
  /// "Osnabrueck Hbf" dasteht.
  static String _destination(Map<String, dynamic> stopEvent, Map<String, dynamic>? transportation) {
    final List<dynamic>? onward = stopEvent['onwardLocations'] as List<dynamic>?;
    if (onward != null && onward.isNotEmpty) {
      final Map<String, dynamic>? lastStop = onward.last['parent'] as Map<String, dynamic>?;
      final Map<String, dynamic>? hereStop = stopEvent['location']?['parent'] as Map<String, dynamic>?;
      final String? shortName = lastStop?['disassembledName'] as String?;

      if (shortName != null &&
          shortName.isNotEmpty &&
          lastStop != null &&
          hereStop != null &&
          _sameMunicipality(lastStop, hereStop)) {
        return shortName;
      }
    }

    return _processDirection(transportation?['destination']?['name'] as String?);
  }

  /// Vergleich ueber den Gemeindeschluessel der DHID ('de:05711:5081' ->
  /// '05711'). Die Ortsnamen taugen dafuer nicht: innerhalb Bielefelds heissen
  /// sie mal "Bielefeld", mal "Senne" oder "Altenhagen (Bielef)".
  static bool _sameMunicipality(Map<String, dynamic> a, Map<String, dynamic> b) {
    final String? codeA = _municipalityCode(a['id']);
    final String? codeB = _municipalityCode(b['id']);
    if (codeA != null && codeB != null) {
      return codeA == codeB;
    }

    final String? localityA = a['parent']?['name'] as String?;
    return localityA != null && localityA == b['parent']?['name'];
  }

  static String? _municipalityCode(dynamic id) {
    if (id is! String) {
      return null;
    }
    final List<String> parts = id.split(':');
    return parts.length >= 3 && parts[0] == 'de' ? parts[1] : null;
  }

  /// Liefert null fuer Eintraege ohne Linie oder Plan-Abfahrtszeit.
  static DepartureData? tryFromEfa(Map<String, dynamic> stopEvent) {
    final Map<String, dynamic>? transportation = stopEvent['transportation'] as Map<String, dynamic>?;
    final DateTime? planned = _parseTime(stopEvent['departureTimePlanned']);
    if (transportation == null || planned == null) {
      return null;
    }

    final String lineName = ((transportation['disassembledName'] ??
            transportation['number'] ??
            transportation['name'] ??
            '') as String)
        .trim();
    final List<dynamic> realtimeStatus = (stopEvent['realtimeStatus'] as List<dynamic>?) ?? const [];

    return DepartureData(
      lineName: lineName,
      globalId: transportation['properties']?['globalId'] as String?,
      productClass: transportation['product']?['class'] as int?,
      destination: _destination(stopEvent, transportation),
      platform: stopEvent['location']?['properties']?['platformName'] as String?,
      planned: planned,
      estimated: _parseTime(stopEvent['departureTimeEstimated']),
      isMonitored: realtimeStatus.contains('MONITORED'),
      isCancelled: stopEvent['isCancelled'] == true || realtimeStatus.contains('TRIP_CANCELLED'),
      key: '${transportation['id']}|${stopEvent['location']?['id']}|${stopEvent['departureTimePlanned']}',
    );
  }

  static DateTime? _parseTime(dynamic value) {
    if (value is! String) {
      return null;
    }
    return DateTime.tryParse(value)?.toLocal();
  }

  /// Voraussichtliche Abfahrt, sonst Plan.
  DateTime get time => estimated ?? planned;

  /// Verspaetung in Minuten, null ohne Echtzeitdaten.
  int? get delayMinutes => estimated?.difference(planned).inMinutes;
}

/// "jetzt" / "in X min" fuer Fahrten mit Echtzeitdaten, sonst die Uhrzeit (HH:mm).
String formatDepartureTime(DepartureData d, DateTime now) {
  if (!d.isMonitored) {
    return DateFormat('HH:mm').format(d.time);
  }

  final Duration until = d.time.difference(now);
  if (until < const Duration(minutes: 1)) {
    return 'jetzt';
  }

  return 'in ${until.inMinutes} min';
}
