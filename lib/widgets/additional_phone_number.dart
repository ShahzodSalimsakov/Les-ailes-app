import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:niku/niku.dart' as n;
import 'package:http/http.dart' as http;

import '../models/additional_phone_number.dart';
import '../models/user.dart';

class AdditionalPhoneNumberWidget extends HookWidget {
  final number = PhoneNumber(isoCode: 'UZ');

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: '');
    final _isValid = useState<bool>(false);

    final additionalPhones = useState<List<String>>([]);
    final selectedAdditionalPhone = useState<String?>(null);

    print('davr');
    Future<void> getAdditionalPhones() async {
      Box userBox = Hive.box<User>('user');
      User? user = userBox.get('user');
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      requestHeaders['Authorization'] = 'Bearer ${user!.userToken}';

      var url = Uri.https('api.lesailes.uz', '/api/get_additional_phones');

      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        print(json);
        additionalPhones.value = List<String>.from(json.map((m) => m).toList());
      }
    }

    useEffect(() {
      getAdditionalPhones();
      controller.text = selectedAdditionalPhone.value ?? '';
      return null;
    }, [selectedAdditionalPhone.value]);

    return Container(
        // color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.only(
          top: 10,
          right: 5,
          left: 5,
          bottom: 0,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            tr("additionalPhoneNumber"),
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
              textFieldController: controller,
              scrollPadding: const EdgeInsets.only(bottom: 150),
              maxLength: 12,
              onInputChanged: (number) {
                AdditionalPhoneNumber additionalPhone = AdditionalPhoneNumber();
                additionalPhone.additionalPhoneNumber =
                    number.phoneNumber ?? '';
                Hive.box<AdditionalPhoneNumber>('additionalPhoneNumber')
                    .put('additionalPhoneNumber', additionalPhone);
              },
              onInputValidated: (bool value) {
                _isValid.value = value;
              },
              countries: const ['UZ'],
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                showFlags: false,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle:
                  const TextStyle(color: Colors.black, fontSize: 24.0),
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
          // SizedBox(height: additionalPhones.value.isNotEmpty ? 10 : 0,),
          additionalPhones.value.isNotEmpty
              ? Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return n.NikuButton(n.NikuText(
                        additionalPhones.value[index],
                        style: n.NikuTextStyle(color: Colors.grey.shade500),
                      ))
                        ..bg = Colors.grey.shade200
                        ..rounded = 15
                        ..p = 10
                        ..mx = 2
                        ..onPressed = () {
                          String myText = additionalPhones.value[index];
                          if (myText.contains('+998')) {
                            myText = myText.replaceAll('+998', '');
                          }
                          selectedAdditionalPhone.value = myText;
                        };
                    },
                    itemCount: additionalPhones.value.length,
                  ),
                )
              : const SizedBox(
                  width: 0,
                )
        ]));
  }
}
