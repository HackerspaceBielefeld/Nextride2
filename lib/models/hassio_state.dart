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

  factory HassioState.fromJson(Map<String, dynamic> json) {
    return HassioState(
      entityId: json['entity_id'],
      state: json['state'],
      attributes: json['attributes'],
      lastChanged: json['last_changed'] == null ? null : DateTime.parse(json['last_changed']),
      lastUpdated: json['last_updated'] == null ? null : DateTime.parse(json['last_updated']),
      contextId: json['context']['id'],
    );
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
        throw Exception('Unknown timer run state "$s"');
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
      duration: parseDuration(hs.attributes['duration']),
      editable: hs.attributes['editable'],
      finishesAt: hs.attributes['finishes_at'] == null ? null : DateTime.parse(hs.attributes['finishes_at']),
      icon: hs.attributes['icon'],
      friendlyName: hs.attributes['friendly_name'] ?? '',
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
      editable: hs.attributes['editable'],
      icon: hs.attributes['icon'],
      friendlyName: hs.attributes['friendly_name'] ?? '',
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
      editable: hs.attributes['editable'],
      icon: hs.attributes['icon'],
      friendlyName: hs.attributes['friendly_name'] ?? '',
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
      unitOfMeasurement: hs.attributes['unit_of_measurement'],
      deviceClass: hs.attributes['device_class'],
      friendlyName: hs.attributes['friendly_name'] ?? '',
    );
  }
}
