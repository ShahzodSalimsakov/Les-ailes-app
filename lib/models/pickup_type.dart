import 'package:hive/hive.dart';

part 'pickup_type.g.dart';

@HiveType(typeId: 17)
enum PickupTypeEnum {
  @HiveField(0)
  list,
  @HiveField(1)
  map
}

@HiveType(typeId: 16)
class PickupType {
  @HiveField(0)
  late PickupTypeEnum value;
}