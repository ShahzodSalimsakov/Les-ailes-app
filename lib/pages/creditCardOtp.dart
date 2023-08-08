import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hex/hex.dart';
import 'package:hive/hive.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../utils/colors.dart';
import '../utils/random.dart';

@RoutePage()
class CreditCardOtpPage extends HookWidget {
  final GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();
  late OTPTextEditController controller;

  CreditCardOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      controller = OTPTextEditController(
        codeLength: 6,
        onCodeReceive: (code) => print('Your Application receive code - $code'),
      )..startListenUserConsent(
          (code) {
            print(code);
            final exp = RegExp(r'(\d{6})');
            return exp.stringMatch(code ?? '') ?? '';
          },
          // strategies: [
          //   SampleStrategy(),
          // ],
        );
    }, []);
    final otpCode = useState<String>('');
    final isOtpVerifing = useState<bool>(false);

    Future<void> tryConfirm() async {
      isOtpVerifing.value = true;
      final Box<User> userBox = Hive.box<User>('user');
      final User? currentUser = userBox.get('user');

      final buff = utf8.encode('X79PC6D4bKzW');
      final base64data = base64.encode(buff);
      final randomString = randomAlphaNumeric(6);
      final hexBuffer = utf8.encode('$randomString$base64data');
      final hexString = HEX.encode(hexBuffer);

      if (currentUser != null) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${currentUser.userToken}',
          'X-OTP-TOKEN': hexString
        };

        var url = Uri.https('api.lesailes.uz', 'api/payment_cards/verify');
        var response = await http.post(url,
            headers: requestHeaders,
            body: jsonEncode(
                {'otp': otpCode.value, 'locale': context.locale.languageCode}));
        isOtpVerifing.value = false;
        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);

          if (json['success']) {
            context.router.pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(json['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          var json = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(json['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('cards.otpPageTitle')),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Form(
          key: otpFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  tr("cards.otpPageText"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  height: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: PinCodeTextField(
                    controller: controller,
                    enablePinAutofill: true,
                    autoFocus: true,
                    length: 6,
                    onChanged: (String value) {},
                    appContext: context,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.black,
                    cursorHeight: 30,
                    textStyle: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.w100),
                    onCompleted: (String code) {
                      if (code!.length == 6) {
                        otpCode.value = code;
                        tryConfirm();
                      }
                    },
                    pinTheme: PinTheme(
                      borderRadius: BorderRadius.circular(10),
                      fieldWidth: 30,
                      fieldHeight: 100,
                      shape: PinCodeFieldShape.underline,
                      inactiveColor: Colors.black,
                      activeColor: AppColors.mainColor,
                      selectedColor: AppColors.mainColor,
                    ),
                  )
                  // PinCodeTextField(
                  //   controller: controller,
                  //   enablePinAutofill: true,
                  //   autoFocus: true,
                  //   length: 4,
                  //   onChanged: (String value) {},
                  //   appContext: context,
                  //   keyboardType: TextInputType.number,
                  //   onCompleted: (String code) {
                  //     otpCode.value = code;
                  //     trySignIn();
                  //   },
                  //   pinTheme: PinTheme(
                  //       borderRadius: BorderRadius.circular(20),
                  //       fieldWidth: 60,
                  //       fieldHeight: 70,
                  //       shape: PinCodeFieldShape.box,
                  //       inactiveColor: Colors.grey,
                  //       activeColor: AppColors.mainColor,
                  //       selectedColor: AppColors.mainColor,
                  //       inactiveFillColor: Colors.grey,
                  //       activeFillColor: Colors.grey),
                  // )
                  ),
              const Spacer(flex: 1),
              Container(
                  height: 60,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 20.0),
                  child: SizedBox(
                    height: 50,
                    width: 144,
                    child: ElevatedButton(
                      onPressed: () async {
                        // if (_isSendingPhone.value) {
                        //   return;
                        // }
                        if (otpCode.value.length == 6) {
                          tryConfirm();
                        }
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        )),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.mainColor),
                      ),
                      child: isOtpVerifing.value
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(tr("cards.otpApprove")),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
