import 'package:nextride2/models/rocket_launch.dart';

class RocketLaunchDataStore {
  RocketLaunchDataStore();

  final List<RocketLaunch> _items = [];

  List<RocketLaunch> get items => _items;

  factory RocketLaunchDataStore.fromJson(List<dynamic> json) {
    RocketLaunchDataStore result = RocketLaunchDataStore();
    for (var element in json) {
      result.add(RocketLaunch.fromJson(element));
    }
    return result;
  }

  void add(RocketLaunch entry) {
    int oldIdx = _items.indexWhere((element) => element.id == entry.id);
    if (oldIdx >= 0) {
      _items.removeAt(oldIdx);
    }

    _items.add(entry);
  }

  void addFromJson(List<dynamic> json) {
    for (var element in json) {
      add(RocketLaunch.fromJson(element));
    }
  }

  @override
  String toString() {
    return _items.toString();
  }
}
