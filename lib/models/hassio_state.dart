class HassioState {
  final String entityId;
  final String state;
  final Map<String, dynamic> attributes;
  final DateTime? lastChanged;
  final DateTime? lastUpdated;
  final String contextId;

  HassioState(
      {required this.entityId,
      required this.state,
      required this.attributes,
      required this.lastChanged,
      required this.lastUpdated,
      required this.contextId});

  /// Home Assistant liefert bei fehlenden/kaputten Entities auch mal ein
  /// unvollstaendiges Objekt - deshalb ueberall Defaults statt harter Casts.
  factory HassioState.fromJson(Map<String, dynamic> json) {
    return HassioState(
      entityId: json['entity_id'] as String? ?? '',
      state: json['state'] as String? ?? 'unknown',
      attributes: (json['attributes'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      lastChanged: _parseDateTime(json['last_changed']),
      lastUpdated: _parseDateTime(json['last_updated']),
      contextId: (json['context'] as Map?)?['id'] as String? ?? '',
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is! String) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

Duration parseDuration(String input) {
  List<String> parts = input.split(':');

  if (parts.length != 3) {
    throw const FormatException('Ungültiges Eingabeformat. Erwartet wird STUNDE:MINUTEN:SEKUNDEN');
  }

  try {
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  } catch (e) {
    throw const FormatException('Ungültige Zahlen im Eingabeformat');
  }
}

enum HassioTimerStateRunState {
  active,
  idle,
  paused;

  factory HassioTimerStateRunState.fromString(String s) {
    switch (s) {
      case 'active':
        return HassioTimerStateRunState.active;
      case 'idle':
        return HassioTimerStateRunState.idle;
      case 'paused':
        return HassioTimerStateRunState.paused;
      default:
        // 'unavailable'/'unknown' liefert HA bei Neustarts. Kein Grund, im
        // build() eine Exception zu werfen - der Timer gilt dann als aus.
        return HassioTimerStateRunState.idle;
    }
  }

  @override
  String toString() {
    switch (this) {
      case HassioTimerStateRunState.active:
        return 'active';
      case HassioTimerStateRunState.idle:
        return 'idle';
      case HassioTimerStateRunState.paused:
        return 'paused';
    }
  }
}

class HassioTimerState extends HassioState {
  final Duration duration;
  final bool editable;
  final DateTime? finishesAt;
  //remaining is a false friend here
  final String? icon;
  final String friendlyName;

  HassioTimerStateRunState get runState => HassioTimerStateRunState.fromString(state);

  HassioTimerState(
      {required this.duration,
      required this.editable,
      required this.finishesAt,
      required this.icon,
      required this.friendlyName,
      required super.entityId,
      required super.state,
      required super.attributes,
      required super.lastChanged,
      required super.lastUpdated,
      required super.contextId});

  factory HassioTimerState.fromHassioState(HassioState hs) {
    return HassioTimerState(
      entityId: hs.entityId,
      state: hs.state,
      attributes: hs.attributes,
      lastChanged: hs.lastChanged,
      lastUpdated: hs.lastUpdated,
      contextId: hs.contextId,
      duration: parseDuration(hs.attributes['duration'] as String? ?? '00:00:00'),
      editable: hs.attributes['editable'] as bool? ?? false,
      finishesAt: HassioState._parseDateTime(hs.attributes['finishes_at']),
      icon: hs.attributes['icon'] as String?,
      friendlyName: hs.attributes['friendly_name'] as String? ?? '',
    );
  }
}

class HassioInputTextState extends HassioState {
  final bool editable;
  final String? icon;
  final String friendlyName;

  HassioInputTextState(
      {required this.editable,
      required this.icon,
      required this.friendlyName,
      required super.entityId,
      required super.state,
      required super.attributes,
      required super.lastChanged,
      required super.lastUpdated,
      required super.contextId});

  factory HassioInputTextState.fromHassioState(HassioState hs) {
    return HassioInputTextState(
      entityId: hs.entityId,
      state: hs.state,
      attributes: hs.attributes,
      lastChanged: hs.lastChanged,
      lastUpdated: hs.lastUpdated,
      contextId: hs.contextId,
      editable: hs.attributes['editable'] as bool? ?? false,
      icon: hs.attributes['icon'] as String?,
      friendlyName: hs.attributes['friendly_name'] as String? ?? '',
    );
  }
}

class HassioInputBooleanState extends HassioState {
  final bool editable;
  final String? icon;
  final String friendlyName;

  bool get isOn => state == 'on';

  HassioInputBooleanState(
      {required this.editable,
      required this.icon,
      required this.friendlyName,
      required super.entityId,
      required super.state,
      required super.attributes,
      required super.lastChanged,
      required super.lastUpdated,
      required super.contextId});

  factory HassioInputBooleanState.fromHassioState(HassioState hs) {
    return HassioInputBooleanState(
      entityId: hs.entityId,
      state: hs.state,
      attributes: hs.attributes,
      lastChanged: hs.lastChanged,
      lastUpdated: hs.lastUpdated,
      contextId: hs.contextId,
      editable: hs.attributes['editable'] as bool? ?? false,
      icon: hs.attributes['icon'] as String?,
      friendlyName: hs.attributes['friendly_name'] as String? ?? '',
    );
  }
}

class HassioInputPowerState extends HassioState {
  final String unitOfMeasurement;
  final String deviceClass;
  final String friendlyName;

  HassioInputPowerState(
      {required this.unitOfMeasurement,
      required this.deviceClass,
      required this.friendlyName,
      required super.entityId,
      required super.state,
      required super.attributes,
      required super.lastChanged,
      required super.lastUpdated,
      required super.contextId});

  factory HassioInputPowerState.fromHassioState(HassioState hs) {
    return HassioInputPowerState(
      entityId: hs.entityId,
      state: hs.state,
      attributes: hs.attributes,
      lastChanged: hs.lastChanged,
      lastUpdated: hs.lastUpdated,
      contextId: hs.contextId,
      unitOfMeasurement: hs.attributes['unit_of_measurement'] as String? ?? '',
      deviceClass: hs.attributes['device_class'] as String? ?? '',
      friendlyName: hs.attributes['friendly_name'] as String? ?? '',
    );
  }
}
