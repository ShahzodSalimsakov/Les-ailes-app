import 'package:hive/hive.dart';

part 'registered_review.g.dart';

@HiveType(typeId: 18)
class RegisteredReview {
  @HiveField(0)
  late int orderId;
}