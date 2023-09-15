import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../pages/creditCard.dart';

Future<String?> showCreditCardModalBottomSheet(BuildContext context) {
  return showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (context) {
        return const CreditCardPage();
      });
}
