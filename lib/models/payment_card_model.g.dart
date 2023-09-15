// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentCardModelAdapter extends TypeAdapter<PaymentCardModel> {
  @override
  final int typeId = 20;

  @override
  PaymentCardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentCardModel(
      id: fields[0] as int,
      expireDate: fields[1] as String,
      number: fields[2] as String,
      balance: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentCardModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.expireDate)
      ..writeByte(2)
      ..write(obj.number)
      ..writeByte(3)
      ..write(obj.balance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentCardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
