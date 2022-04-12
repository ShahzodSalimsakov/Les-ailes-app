// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PickupTypeAdapter extends TypeAdapter<PickupType> {
  @override
  final int typeId = 16;

  @override
  PickupType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PickupType()..value = fields[0] as PickupTypeEnum;
  }

  @override
  void write(BinaryWriter writer, PickupType obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickupTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PickupTypeEnumAdapter extends TypeAdapter<PickupTypeEnum> {
  @override
  final int typeId = 17;

  @override
  PickupTypeEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PickupTypeEnum.list;
      case 1:
        return PickupTypeEnum.map;
      default:
        return PickupTypeEnum.list;
    }
  }

  @override
  void write(BinaryWriter writer, PickupTypeEnum obj) {
    switch (obj) {
      case PickupTypeEnum.list:
        writer.writeByte(0);
        break;
      case PickupTypeEnum.map:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickupTypeEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
