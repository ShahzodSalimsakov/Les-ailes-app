// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bonus.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BonusResponseAdapter extends TypeAdapter<BonusResponse> {
  @override
  final int typeId = 21;

  @override
  BonusResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BonusResponse(
      success: fields[0] as bool,
      data: (fields[1] as List).cast<BonusProduct>(),
      message: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BonusResponse obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.success)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonusResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BonusProductAdapter extends TypeAdapter<BonusProduct> {
  @override
  final int typeId = 21;

  @override
  BonusProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BonusProduct(
      id: fields[0] as int,
      title: fields[1] as String,
      price: fields[2] as String,
      image: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BonusProduct obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonusProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttributeDataAdapter extends TypeAdapter<AttributeData> {
  @override
  final int typeId = 22;

  @override
  AttributeData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttributeData(
      name: fields[0] as LanguageData?,
      xmlId: fields[1] as LanguageData?,
      description: fields[2] as LanguageData?,
    );
  }

  @override
  void write(BinaryWriter writer, AttributeData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.xmlId)
      ..writeByte(2)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LanguageDataAdapter extends TypeAdapter<LanguageData> {
  @override
  final int typeId = 23;

  @override
  LanguageData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LanguageData(
      chopar: fields[0] as Chopar?,
    );
  }

  @override
  void write(BinaryWriter writer, LanguageData obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.chopar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChoparAdapter extends TypeAdapter<Chopar> {
  @override
  final int typeId = 24;

  @override
  Chopar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chopar(
      ru: fields[0] as String?,
      uz: fields[1] as String?,
      en: fields[2] as String?,
      val: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Chopar obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.ru)
      ..writeByte(1)
      ..write(obj.uz)
      ..writeByte(2)
      ..write(obj.en)
      ..writeByte(3)
      ..write(obj.val);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChoparAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModifierAdapter extends TypeAdapter<Modifier> {
  @override
  final int typeId = 25;

  @override
  Modifier read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Modifier(
      id: fields[0] as int,
      createdAt: fields[1] as String,
      updatedAt: fields[2] as String,
      name: fields[3] as String,
      xmlId: fields[4] as String,
      price: fields[5] as int,
      weight: fields[6] as int,
      groupId: fields[7] as String,
      nameUz: fields[8] as dynamic,
      assets: (fields[9] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Modifier obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.xmlId)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.groupId)
      ..writeByte(8)
      ..write(obj.nameUz)
      ..writeByte(9)
      ..write(obj.assets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModifierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
