import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:niku/niku.dart' as n;

import '../models/additional_phone_number.dart';
import '../models/user.dart';

class AdditionalPhoneNumberWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: '');
    final _isValid = useState<bool>(false);

    final additionalPhones = useState<List<String>>([]);
    final selectedAdditionalPhone = useState<String?>(null);
    final phoneNumber = useState<String>('');

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
        additionalPhones.value = List<String>.from(json.map((m) => m).toList());
      }
    }

    useEffect(() {
      getAdditionalPhones();
      controller.text = selectedAdditionalPhone.value ?? '';
      return null;
    }, [selectedAdditionalPhone.value]);

    return Container(
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
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text(
                    "+998",
                    style: TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey,
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 16),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: "90 123 45 67",
                    ),
                    onChanged: (value) {
                      if (value.length == 9) {
                        phoneNumber.value = "+998$value";
                        _isValid.value = true;
                        AdditionalPhoneNumber additionalPhone =
                            AdditionalPhoneNumber();
                        additionalPhone.additionalPhoneNumber =
                            phoneNumber.value;
                        Hive.box<AdditionalPhoneNumber>('additionalPhoneNumber')
                            .put('additionalPhoneNumber', additionalPhone);
                      } else {
                        _isValid.value = false;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
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
