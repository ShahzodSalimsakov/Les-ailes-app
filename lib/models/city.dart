import 'package:hive/hive.dart';
part 'city.g.dart';

@HiveType(typeId: 0)
class City extends HiveObject {
  @HiveField(0)
  late int id;
  @HiveField(1)
  late String xmlId;
  @HiveField(2)
  late String name;
  @HiveField(3)
  late String nameUz;
  @HiveField(4)
  late String mapZoom;
  @HiveField(5)
  late String lat;
  @HiveField(6)
  late String lon;
  @HiveField(7)
  late bool active;
  @HiveField(8)
  late int sort;
  @HiveField(9)
  late String? phone;
  @HiveField(10)
  late String? nameEn;

  City(
      {required this.id,
      required this.xmlId,
      required this.name,
      required this.nameUz,
      required this.nameEn,
      required this.mapZoom,
      required this.lat,
      required this.lon,
      required this.active,
      required this.sort,
      this.phone});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    xmlId = json['xml_id'];
    name = json['name'];
    nameUz = json['name_uz'];
    nameEn = json['name_en'];
    mapZoom = json['map_zoom'];
    lat = json['lat'];
    lon = json['lon'];
    active = json['active'];
    sort = json['sort'];
    phone = json['phone'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['xml_id'] = xmlId;
    data['name'] = name;
    data['name_uz'] = nameUz;
    data['name_en'] = nameEn;
    data['map_zoom'] = mapZoom;
    data['lat'] = lat;
    data['lon'] = lon;
    data['active'] = active;
    data['sort'] = sort;
    data['phone'] = phone;
    return data;
  }

  // String get cityPlaceholder {
  //   City? currentCity = Hive.box<City>('currentCity').get('currentCity');
  //   if (currentCity == null) {
  //     return 'Ваш город';
  //   }
  //
  //   return currentCity!.name;
  // }
  //
  // void setCurrentCity(City c) {
  //   Box<City> transaction = Hive.box<City>('currentCity');
  //   transaction.put('currentCity', c);
  // }
}
