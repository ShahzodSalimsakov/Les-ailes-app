import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';

// import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../models/user.dart';
import '../utils/colors.dart';

class SignInPage extends HookWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();

  // final TextEditingController controller = TextEditingController();
  final TextEditingController nameFieldController = TextEditingController();
  final initialCountry = 'UZ';
  final number = PhoneNumber(isoCode: 'UZ');
  late OTPTextEditController controller;

  SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isValid = useState<bool>(false);
    final _isVerifyPage = useState<bool>(false);
    final _isSendingPhone = useState<bool>(false);
    final _isShowNameField = useState<bool>(false);
    final phoneNumber = useState<String>('');
    final otpCode = useState<String>('');
    final otpToken = useState<String>('');
    final _isFinishedTimer = useState<bool>(false);
    final signature = useState<String>('');

    Future<void> trySignIn() async {
      _isSendingPhone.value = true;
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${otpToken.value}'
      };
      String? token = await FirebaseMessaging.instance.getToken();
      var url = Uri.https('api.lesailes.uz', '/api/auth_otp');
      var formData = {'phone': phoneNumber.value, 'code': otpCode.value};
      if (token != null) {
        formData['token'] = token;
      }
      var response = await http.post(url,
          headers: requestHeaders, body: jsonEncode(formData));
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        Codec<String, String> stringToBase64 = utf8.fuse(base64);
        String decoded = stringToBase64.decode(json['result']);
        // print(jsonDecode(decoded));
        if (jsonDecode(decoded) == false) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(tr("incorrectCode"))));
        } else {
          var result = jsonDecode(decoded);
          User authorizedUser = User.fromJson(result['user']);
          Box<User> transaction = Hive.box<User>('user');
          transaction.put('user', authorizedUser);
          Navigator.of(context).pop();
        }
      }
      _isSendingPhone.value = false;
    }

    Future<void> tryResendCode() async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      var url = Uri.https('api.lesailes.uz', '/api/send_otp');
      var formData = {'phone': phoneNumber.value};
      if (_isShowNameField.value) {
        formData['name'] = nameFieldController.text;
      }
      var response = await http.post(url,
          headers: requestHeaders, body: jsonEncode(formData));
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['success'] != null) {
          Codec<String, String> stringToBase64 = utf8.fuse(base64);
          String decoded = stringToBase64.decode(json['success']);
          otpToken.value = jsonDecode(decoded)['user_token'];
        }
        _isFinishedTimer.value = false;
      }
    }

    void listenForCode() async {
      // Timer(const Duration(milliseconds: 700),  ()
      // async  {
      await SmsAutoFill().listenForCode;
      print('listen for code');
      // });
    }

    useEffect(() {
      // listenForCode();

      controller = OTPTextEditController(
        codeLength: 4,
        onCodeReceive: (code) => print('Your Application receive code - $code'),
      )..startListenUserConsent(
          (code) {
            print(code);
            final exp = RegExp(r'(\d{4})');
            return exp.stringMatch(code ?? '') ?? '';
          },
          // strategies: [
          //   SampleStrategy(),
          // ],
        );

      return () {
        // SmsAutoFill().unregisterListener();
        controller.stopListen();
        print('Unregistered');
      };
    }, const []);

    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    padding: const EdgeInsets.all(30),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ))
              ],
            ),
            _isVerifyPage.value
                ? Expanded(
                    child: Form(
                      key: otpFormKey,
                      child: Container(
                        // height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                                width: 217,
                                child: Text(
                                  tr("signIn.typeOtp"),
                                  style: const TextStyle(fontSize: 30),
                                  textAlign: TextAlign.center,
                                )),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tr("sentCodeToNumber"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  phoneNumber.value,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 26),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                                height: 150,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: PinCodeTextField(
                                  controller: controller,
                                  enablePinAutofill: true,
                                  autoFocus: true,
                                  length: 4,
                                  onChanged: (String value) {},
                                  appContext: context,
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.black,
                                  cursorHeight: 30,
                                  textStyle: const TextStyle(fontSize: 40, fontWeight: FontWeight.w100),
                                  onCompleted: (String code) {
                                    if (code!.length == 4) {
                                      otpCode.value = code;
                                      trySignIn();
                                    }
                                  },
                                  pinTheme: PinTheme(
                                      borderRadius: BorderRadius.circular(10),
                                      fieldWidth: 55,
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
                            _isFinishedTimer.value
                                ? InkWell(
                                    child: Text(
                                      tr("getNewCode"),
                                      style: const TextStyle(
                                          color: AppColors.mainColor,
                                          decoration: TextDecoration.underline),
                                    ),
                                    onTap: () {
                                      tryResendCode();
                                    },
                                  )
                                : Countdown(
                                    // controller: _controller,
                                    seconds: 60,
                                    build: (_, double time) => Row(
                                      children: [
                                        Text(
                                          'Код не пришел\n получить новый код через ${time.ceil().toString()} сек.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        )
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    ),
                                    interval:
                                        const Duration(milliseconds: 1000),
                                    onFinished: () {
                                      _isFinishedTimer.value = true;
                                    },
                                  ),
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
                                      if (_isSendingPhone.value) {
                                        return;
                                      }
                                      if (otpCode.value.length == 4) {
                                        trySignIn();
                                      }
                                    },
                                    child: Text(tr("signIn.signIn")),
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              AppColors.mainColor),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: Form(
                      key: formKey,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 217,
                                child: Text(
                                  tr("signIn.enterNumber"),
                                  style: const TextStyle(fontSize: 30),
                                  textAlign: TextAlign.center,
                                )),
                            const SizedBox(
                              height: 38,
                            ),
                            Text(
                              tr("signIn.getConfirmationCode"),
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40.0),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                      width: 1.0, color: Colors.grey),
                                  color: AppColors.grey),
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: InternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber number) {
                                    phoneNumber.value =
                                        number.phoneNumber ?? '';
                                  },
                                  onInputValidated: (bool value) {
                                    _isValid.value = value;
                                  },
                                  countries: ['UZ'],
                                  selectorConfig: const SelectorConfig(
                                    selectorType:
                                        PhoneInputSelectorType.BOTTOM_SHEET,
                                    showFlags: false,
                                  ),
                                  ignoreBlank: false,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  selectorTextStyle: const TextStyle(
                                      color: Colors.black, fontSize: 24.0),
                                  initialValue: number,
                                  formatInput: true,
                                  countrySelectorScrollControlled: false,
                                  keyboardType: TextInputType.number,
                                  inputBorder: InputBorder.none,
                                  hintText: '',
                                  errorMessage: tr("wrongNumber"),
                                  spaceBetweenSelectorAndTextField: 0,
                                  textStyle: const TextStyle(
                                      color: Colors.black, fontSize: 24.0),
                                  // inputDecoration: InputDecoration(border: ),
                                  onSaved: (PhoneNumber number) {},
                                  autoFocus: true,
                                ),
                              ),
                            ),
                            _isShowNameField.value
                                ? Container(
                                    height: 300,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 20),
                                    child: TextFormField(
                                      controller: nameFieldController,
                                      validator: (String? val) {
                                        if (val == null || val.isEmpty) {
                                          return tr("enterYourName");
                                        }
                                      },
                                      decoration: InputDecoration(
                                          labelText: tr("yourName"),
                                          floatingLabelStyle: TextStyle(
                                              color: Colors.yellow.shade600),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color:
                                                      Colors.yellow.shade600)),
                                          contentPadding:
                                              const EdgeInsets.only(left: 40),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40))),
                                      keyboardType: TextInputType.name,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  )
                                : const SizedBox(),
                            const Spacer(),
                            Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 20.0),
                                child: SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_isSendingPhone.value) {
                                        return;
                                      }

                                      if (formKey.currentState != null &&
                                          formKey.currentState!.validate()) {
                                        _isSendingPhone.value = true;
                                        Map<String, String> requestHeaders = {
                                          'Content-type': 'application/json',
                                          'Accept': 'application/json'
                                        };
                                        var url = Uri.https(
                                            'api.lesailes.uz', '/api/keldi');
                                        var response = await http.get(url,
                                            headers: requestHeaders);
                                        if (response.statusCode == 200) {
                                          var json = jsonDecode(response.body);
                                          Codec<String, String> stringToBase64 =
                                              utf8.fuse(base64);
                                          String decoded = stringToBase64
                                              .decode(json['result']);

                                          Map<String, String> requestHeaders = {
                                            'Content-type': 'application/json',
                                            'Accept': 'application/json'
                                          };
                                          url = Uri.https('api.lesailes.uz',
                                              '/api/send_otp');
                                          var formData = {
                                            'phone': phoneNumber.value
                                          };
                                          if (_isShowNameField.value) {
                                            formData['name'] =
                                                nameFieldController.text;
                                          }
                                          response = await http.post(url,
                                              headers: requestHeaders,
                                              body: jsonEncode(formData));
                                          if (response.statusCode == 200) {
                                            json = jsonDecode(response.body);
                                            if (json['error'] != null) {
                                              if (json['error'] ==
                                                  'name_field_is_required') {
                                                _isShowNameField.value = true;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'Мы Вас не нашли в нашей системе. Просьба указать своё имя.')));
                                              }
                                            } else if (json['success'] !=
                                                null) {
                                              Codec<String, String>
                                                  stringToBase64 =
                                                  utf8.fuse(base64);
                                              String decoded = stringToBase64
                                                  .decode(json['success']);

                                              otpToken.value = jsonDecode(
                                                  decoded)['user_token'];
                                              _isVerifyPage.value = true;
                                              listenForCode();
                                              // signature.value = await SmsAutoFill().getAppSignature;
                                            }
                                          }
                                        }
                                        _isSendingPhone.value = false;
                                      }
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              AppColors.mainColor),
                                    ),
                                    child: Text(tr("signIn.proceed")),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),

            // Visibility(
            //   visible: _isVerifyPage.value,
            //   child: Expanded(
            //     child: Form(
            //       key: otpFormKey,
            //       child: Container(
            //         // height: 200,
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             const SizedBox(
            //               height: 20,
            //             ),
            //             SizedBox(
            //                 width: 217,
            //                 child: Text(
            //                   tr("signIn.typeOtp"),
            //                   style: const TextStyle(fontSize: 30),
            //                   textAlign: TextAlign.center,
            //                 )),
            //             const SizedBox(
            //               height: 20,
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Text(
            //                   tr("sentCodeToNumber"),
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(color: Colors.grey),
            //                 )
            //               ],
            //             ),
            //             const SizedBox(
            //               height: 10,
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Text(
            //                   phoneNumber.value,
            //                   textAlign: TextAlign.center,
            //                   style: const TextStyle(fontSize: 26),
            //                 )
            //               ],
            //             ),
            //             const SizedBox(
            //               height: 30,
            //             ),
            //             Container(
            //                 height: 150,
            //                 margin: const EdgeInsets.symmetric(horizontal: 40),
            //                 child: PinFieldAutoFill(
            //                   decoration: UnderlineDecoration(
            //                     textStyle: const TextStyle(
            //                         fontSize: 20, color: Colors.black),
            //                     colorBuilder: FixedColorBuilder(
            //                         Colors.black.withOpacity(0.3)),
            //                   ),
            //                   // currentCode: otpCode.value,
            //                   autoFocus: true,
            //                   cursor: Cursor(
            //                     width: 2,
            //                     height: 40,
            //                     color: AppColors.mainColor,
            //                     radius: Radius.circular(1),
            //                     enabled: true,
            //                   ),
            //                   keyboardType: TextInputType.number,
            //                   codeLength: 4,
            //                   onCodeSubmitted: (code) {
            //                     print(code);
            //                   },
            //                   onCodeChanged: (code) {
            //                     if (code!.length == 4) {
            //                       otpCode.value = code;
            //                       trySignIn();
            //                     }
            //                   },
            //                 )
            //                 // PinCodeTextField(
            //                 //   controller: controller,
            //                 //   enablePinAutofill: true,
            //                 //   autoFocus: true,
            //                 //   length: 4,
            //                 //   onChanged: (String value) {},
            //                 //   appContext: context,
            //                 //   keyboardType: TextInputType.number,
            //                 //   onCompleted: (String code) {
            //                 //     otpCode.value = code;
            //                 //     trySignIn();
            //                 //   },
            //                 //   pinTheme: PinTheme(
            //                 //       borderRadius: BorderRadius.circular(20),
            //                 //       fieldWidth: 60,
            //                 //       fieldHeight: 70,
            //                 //       shape: PinCodeFieldShape.box,
            //                 //       inactiveColor: Colors.grey,
            //                 //       activeColor: AppColors.mainColor,
            //                 //       selectedColor: AppColors.mainColor,
            //                 //       inactiveFillColor: Colors.grey,
            //                 //       activeFillColor: Colors.grey),
            //                 // )
            //                 ),
            //             const Spacer(flex: 1),
            //             _isFinishedTimer.value
            //                 ? InkWell(
            //                     child: Text(
            //                       tr("getNewCode"),
            //                       style: const TextStyle(
            //                           color: AppColors.mainColor,
            //                           decoration: TextDecoration.underline),
            //                     ),
            //                     onTap: () {
            //                       tryResendCode();
            //                     },
            //                   )
            //                 : Countdown(
            //                     // controller: _controller,
            //                     seconds: 60,
            //                     build: (_, double time) => Row(
            //                       children: [
            //                         Text(
            //                           'Код не пришел\n получить новый код через ${time.ceil().toString()} сек.',
            //                           textAlign: TextAlign.center,
            //                           style:
            //                               const TextStyle(color: Colors.grey),
            //                         )
            //                       ],
            //                       mainAxisAlignment: MainAxisAlignment.center,
            //                     ),
            //                     interval: const Duration(milliseconds: 1000),
            //                     onFinished: () {
            //                       _isFinishedTimer.value = true;
            //                     },
            //                   ),
            //             Container(
            //                 height: 60,
            //                 width: double.infinity,
            //                 margin: const EdgeInsets.symmetric(
            //                     horizontal: 15.0, vertical: 20.0),
            //                 child: SizedBox(
            //                   height: 50,
            //                   width: 144,
            //                   child: ElevatedButton(
            //                     onPressed: () async {
            //                       if (_isSendingPhone.value) {
            //                         return;
            //                       }
            //                       if (otpCode.value.length == 4) {
            //                         trySignIn();
            //                       }
            //                     },
            //                     child: Text(tr("signIn.signIn")),
            //                     style: ButtonStyle(
            //                       shape: MaterialStateProperty.all<
            //                               RoundedRectangleBorder>(
            //                           RoundedRectangleBorder(
            //                         borderRadius: BorderRadius.circular(20.0),
            //                       )),
            //                       backgroundColor:
            //                           MaterialStateProperty.all<Color>(
            //                               AppColors.mainColor),
            //                     ),
            //                   ),
            //                 ))
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // Visibility(
            //   visible: !_isVerifyPage.value,
            //   child: Expanded(
            //     child: Form(
            //       key: formKey,
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           SizedBox(
            //               width: 217,
            //               child: Text(
            //                 tr("signIn.enterNumber"),
            //                 style: const TextStyle(fontSize: 30),
            //                 textAlign: TextAlign.center,
            //               )),
            //           const SizedBox(
            //             height: 38,
            //           ),
            //           Text(
            //             tr("signIn.getConfirmationCode"),
            //             style: const TextStyle(fontSize: 16),
            //             textAlign: TextAlign.center,
            //           ),
            //           const SizedBox(height: 40.0),
            //           Container(
            //             margin: const EdgeInsets.symmetric(horizontal: 30.0),
            //             decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(20.0),
            //                 border: Border.all(width: 1.0, color: Colors.grey),
            //                 color: AppColors.grey),
            //             width: double.infinity,
            //             alignment: Alignment.center,
            //             child: SizedBox(
            //               width: MediaQuery.of(context).size.width * 0.8,
            //               child: InternationalPhoneNumberInput(
            //                 onInputChanged: (PhoneNumber number) {
            //                   phoneNumber.value = number.phoneNumber ?? '';
            //                 },
            //                 onInputValidated: (bool value) {
            //                   _isValid.value = value;
            //                 },
            //                 countries: ['UZ'],
            //                 selectorConfig: const SelectorConfig(
            //                   selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            //                   showFlags: false,
            //                 ),
            //                 ignoreBlank: false,
            //                 autoValidateMode: AutovalidateMode.disabled,
            //                 selectorTextStyle: const TextStyle(
            //                     color: Colors.black, fontSize: 24.0),
            //                 initialValue: number,
            //                 formatInput: true,
            //                 countrySelectorScrollControlled: false,
            //                 keyboardType: TextInputType.number,
            //                 inputBorder: InputBorder.none,
            //                 hintText: '',
            //                 errorMessage: tr("wrongNumber"),
            //                 spaceBetweenSelectorAndTextField: 0,
            //                 textStyle: const TextStyle(
            //                     color: Colors.black, fontSize: 24.0),
            //                 // inputDecoration: InputDecoration(border: ),
            //                 onSaved: (PhoneNumber number) {},
            //                 autoFocus: true,
            //               ),
            //             ),
            //           ),
            //           _isShowNameField.value
            //               ? Container(
            //                   height: 300,
            //                   margin: const EdgeInsets.symmetric(
            //                       horizontal: 15.0, vertical: 20),
            //                   child: TextFormField(
            //                     controller: nameFieldController,
            //                     validator: (String? val) {
            //                       if (val == null || val.isEmpty) {
            //                         return tr("enterYourName");
            //                       }
            //                     },
            //                     decoration: InputDecoration(
            //                         labelText: tr("yourName"),
            //                         floatingLabelStyle: TextStyle(
            //                             color: Colors.yellow.shade600),
            //                         focusedBorder: OutlineInputBorder(
            //                             borderRadius: BorderRadius.circular(40),
            //                             borderSide: BorderSide(
            //                                 width: 1,
            //                                 color: Colors.yellow.shade600)),
            //                         contentPadding:
            //                             const EdgeInsets.only(left: 40),
            //                         border: OutlineInputBorder(
            //                             borderRadius:
            //                                 BorderRadius.circular(40))),
            //                     keyboardType: TextInputType.name,
            //                     textInputAction: TextInputAction.done,
            //                   ),
            //                 )
            //               : const SizedBox(),
            //           const Spacer(),
            //           Container(
            //               width: double.infinity,
            //               margin: const EdgeInsets.symmetric(
            //                   horizontal: 15.0, vertical: 20.0),
            //               child: SizedBox(
            //                 height: 60,
            //                 child: ElevatedButton(
            //                   onPressed: () async {
            //                     if (_isSendingPhone.value) {
            //                       return;
            //                     }
            //
            //                     if (formKey.currentState != null &&
            //                         formKey.currentState!.validate()) {
            //                       _isSendingPhone.value = true;
            //                       Map<String, String> requestHeaders = {
            //                         'Content-type': 'application/json',
            //                         'Accept': 'application/json'
            //                       };
            //                       var url = Uri.https(
            //                           'api.lesailes.uz', '/api/keldi');
            //                       var response = await http.get(url,
            //                           headers: requestHeaders);
            //                       if (response.statusCode == 200) {
            //                         var json = jsonDecode(response.body);
            //                         Codec<String, String> stringToBase64 =
            //                             utf8.fuse(base64);
            //                         String decoded =
            //                             stringToBase64.decode(json['result']);
            //
            //                         Map<String, String> requestHeaders = {
            //                           'Content-type': 'application/json',
            //                           'Accept': 'application/json'
            //                         };
            //                         url = Uri.https(
            //                             'api.lesailes.uz', '/api/send_otp');
            //                         var formData = {'phone': phoneNumber.value};
            //                         if (_isShowNameField.value) {
            //                           formData['name'] =
            //                               nameFieldController.text;
            //                         }
            //                         response = await http.post(url,
            //                             headers: requestHeaders,
            //                             body: jsonEncode(formData));
            //                         if (response.statusCode == 200) {
            //                           json = jsonDecode(response.body);
            //                           if (json['error'] != null) {
            //                             if (json['error'] ==
            //                                 'name_field_is_required') {
            //                               _isShowNameField.value = true;
            //                               ScaffoldMessenger.of(context)
            //                                   .showSnackBar(const SnackBar(
            //                                       content: Text(
            //                                           'Мы Вас не нашли в нашей системе. Просьба указать своё имя.')));
            //                             }
            //
            //                             if (json['error'] ==
            //                                 'user_is_blocked') {
            //                               ScaffoldMessenger.of(context)
            //                                   .showSnackBar(const SnackBar(
            //                                       content: Text(
            //                                           'Вы удаляли свой аккаунт. Просьба связаться с нами.')));
            //                             }
            //                           } else if (json['success'] != null) {
            //                             Codec<String, String> stringToBase64 =
            //                                 utf8.fuse(base64);
            //                             String decoded = stringToBase64
            //                                 .decode(json['success']);
            //
            //                             otpToken.value =
            //                                 jsonDecode(decoded)['user_token'];
            //                             _isVerifyPage.value = true;
            //                             // listenForCode();
            //
            //                           }
            //                         }
            //                       }
            //                       _isSendingPhone.value = false;
            //                     }
            //                   },
            //                   style: ButtonStyle(
            //                     shape: MaterialStateProperty.all<
            //                             RoundedRectangleBorder>(
            //                         RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.circular(20.0),
            //                     )),
            //                     backgroundColor:
            //                         MaterialStateProperty.all<Color>(
            //                             AppColors.mainColor),
            //                   ),
            //                   child: Text(tr("signIn.proceed")),
            //                 ),
            //               ))
            //         ],
            //       ),
            //     ),
            //   ),
            // )
          ],
        )),
      ),
    );
  }
}
