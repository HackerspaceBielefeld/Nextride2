class RocketLaunch {
  final int id;
  final int sortDate;
  final String name;
  final String providerName;
  final String vehicleName;
  final String padName;
  final String launchDescription;
  final String? t0;

  DateTime get sortDt => DateTime.fromMillisecondsSinceEpoch(sortDate * 1000);
  DateTime get t0Dt => t0 == null ? sortDt : DateTime.parse(t0!);

  RocketLaunch({
    required this.id,
    required this.sortDate,
    required this.name,
    required this.providerName,
    required this.vehicleName,
    required this.padName,
    required this.launchDescription,
    required this.t0,
  });

  factory RocketLaunch.fromJson(Map<String, dynamic> json) {
    return RocketLaunch(
      id: json['id'],
      sortDate: int.parse(json['sort_date']),
      name: json['name'],
      providerName: json['provider']['name'],
      vehicleName: json['vehicle']['name'],
      padName: json['pad']['name'],
      launchDescription: json['launch_description'],
      t0: json['t0'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sort_date': sortDate,
      'name': name,
      'provider': {'name': providerName},
      'vehicle': {'name': vehicleName},
      'pad': {'name': padName},
      'launch_description': launchDescription,
      't0': t0,
    };
  }
}
