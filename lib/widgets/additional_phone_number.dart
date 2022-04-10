import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../models/additional_phone_number.dart';

class AdditionalPhoneNumberWidget extends HookWidget {
  final number = PhoneNumber(isoCode: 'UZ');

  @override
  Widget build(BuildContext context) {
    final _isValid = useState<bool>(false);
    return Container(
        // color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Дополнительный номер телефона',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                color: Colors.grey.shade200),
            width: double.infinity,
            alignment: Alignment.center,
            child: InternationalPhoneNumberInput(
              scrollPadding: EdgeInsets.only(bottom: 150),
              maxLength: 12,
              onInputChanged: (number) {
                AdditionalPhoneNumber additionalPhone =
                    AdditionalPhoneNumber();
                additionalPhone.additionalPhoneNumber =
                    number.phoneNumber ?? '';
                Hive.box<AdditionalPhoneNumber>('additionalPhoneNumber')
                    .put('additionalPhoneNumber', additionalPhone);
              },
              onInputValidated: (bool value) {
                _isValid.value = value;
              },
              countries: ['UZ'],
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                showFlags: false,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: Colors.black, fontSize: 24.0),
              initialValue: number,
              formatInput: true,
              countrySelectorScrollControlled: false,
              keyboardType: TextInputType.number,
              inputBorder: InputBorder.none,
              hintText: '',
              errorMessage: 'Неверный номер',
              spaceBetweenSelectorAndTextField: 0,
              textStyle: const TextStyle(color: Colors.black, fontSize: 24.0),
              // inputDecoration: InputDecoration(border: ),
              onSaved: (PhoneNumber number) {},
            ),
          ),
        ]));
  }
}
