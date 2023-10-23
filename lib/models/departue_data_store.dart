import 'departure_data.dart';

class DepartureDataStore {
  DepartureDataStore();

  final List<DepartureData> _items = [];

  List<DepartureData> get items => _items;

  factory DepartureDataStore.fromJson(List<dynamic> json) {
    DepartureDataStore result = DepartureDataStore();
    for (var element in json) {
      result.add(DepartureData.fromJson(element));
    }
    return result;
  }

  void add(DepartureData entry) {
    int oldIdx = _items.indexWhere((element) => element.key == entry.key);
    if (oldIdx >= 0) {
      _items.removeAt(oldIdx);
    }

    _items.add(entry);
  }

  void addFromJson(List<dynamic> json) {
    for (var element in json) {
      add(DepartureData.fromJson(element));
    }
  }

  void cleanup() {
    int now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    _items.where((element) => element.fullTime < now).forEach((element) {
      _items.remove(element);
    });
  }

  Set<String> getRouteNames() {
    Set<String> result = {};
    for (var element in _items) {
      result.add(element.route);
    }
    return result;
  }

  List<DepartureData> getByRouteName(String route) {
    return _items.where((element) => element.route == route).toList();
  }

  List<DepartureData> getByDirectionCode(String code) {
    return _items.where((element) => element.directionCode == code).toList();
  }

  @override
  String toString() {
    return _items.toString();
  }
}
