import 'package:hive/hive.dart';

import '../models/user.dart';

class UserRepository {

  bool isAuthorized() {
    User? currentUser = Hive.box<User>('user').get('user');
    return currentUser != null;
  }
}