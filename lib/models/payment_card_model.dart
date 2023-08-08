import 'dart:convert';

import 'package:hive/hive.dart';
part 'payment_card_model.g.dart';

@HiveType(typeId: 20)
class PaymentCardModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String expireDate;
  @HiveField(2)
  final String number;
  @HiveField(3)
  final double? balance;
  PaymentCardModel({
    required this.id,
    required this.expireDate,
    required this.number,
    this.balance,
  });

  PaymentCardModel copyWith({
    int? id,
    String? expireDate,
    String? number,
    double? balance,
  }) {
    return PaymentCardModel(
      id: id ?? this.id,
      expireDate: expireDate ?? this.expireDate,
      number: number ?? this.number,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'expireDate': expireDate,
      'number': number,
      'balance': balance ?? '',
    };
  }

  factory PaymentCardModel.fromMap(Map<String, dynamic> map) {
    return PaymentCardModel(
      id: map['id'].toInt() as int,
      expireDate: map['expireDate'] as String,
      number: map['number'] as String,
      balance: map['balance'] as double?,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentCardModel.fromJson(String source) =>
      PaymentCardModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PaymentCardModel(id: $id, expireDate: $expireDate, number: $number, balance: $balance)';

  @override
  bool operator ==(covariant PaymentCardModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.expireDate == expireDate &&
        other.number == number &&
        other.balance == balance;
  }

  @override
  int get hashCode =>
      id.hashCode ^ expireDate.hashCode ^ number.hashCode ^ balance.hashCode;
}
