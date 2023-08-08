import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:card_scanner/card_scanner.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hex/hex.dart';
import 'package:hive/hive.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../utils/random.dart';

@RoutePage()
class CreditCardPage extends StatefulWidget {
  const CreditCardPage({super.key});

  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  CardDetails? _cardDetails;
  CardScanOptions scanOptions = const CardScanOptions(
    scanCardHolderName: true,
    // enableDebugLogs: true,
    validCardsToScanBeforeFinishingScan: 5,
    possibleCardHolderNamePositions: [
      CardHolderNameScanPosition.aboveCardNumber,
    ],
  );
  final myCardNumberController = TextEditingController();
  final myCardExpireController = TextEditingController();
  bool _isLoadingAddCard = false;

  var maskFormatter = MaskTextInputFormatter(
      mask: '#### #### #### ####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  var maskExpire = MaskTextInputFormatter(
      mask: '##/##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  void initState() {
    super.initState();

    myCardNumberController.addListener(() {
      String formattedText = maskFormatter
          .formatEditUpdate(
            TextEditingValue(text: myCardNumberController.text),
            TextEditingValue(text: myCardNumberController.text),
          )
          .text;

      // To prevent infinite loops, only update if the text is different.
      if (formattedText != myCardNumberController.text) {
        myCardNumberController.text = formattedText;
        myCardNumberController.selection =
            TextSelection.collapsed(offset: formattedText.length);
      }
    });
  }

  @override
  void dispose() {
    myCardNumberController.dispose();
    super.dispose();
  }

  Future<void> scanCard() async {
    final CardDetails? cardDetails =
        await CardScanner.scanCard(scanOptions: scanOptions);
    if (!mounted || cardDetails == null) return;

    myCardNumberController.text = cardDetails!.cardNumber;
    myCardExpireController.text = cardDetails!.expiryDate;
    setState(() {
      _cardDetails = cardDetails;
      print(_cardDetails?.cardNumber);
    });
  }

  Future<void> addCard() async {
    setState(() {
      _isLoadingAddCard = true;
    });

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

      var url = Uri.https('api.lesailes.uz', 'api/payment_cards');
      var expiryDate = _cardDetails?.expiryDate.toString().split('/');
      var response = await http.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            'cardNumber': _cardDetails?.cardNumber.toString(),
            'validity': '${expiryDate![1]}${expiryDate[0]}',
            'locale': context.locale.languageCode
          }));
      setState(() {
        _isLoadingAddCard = false;
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);

        if (json['success']) {
          context.router.replaceNamed('/my_creditCardOtp');
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

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.back(),
        ),
        title: Text(tr("addCard"), style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 1),
                    colors: <Color>[
                      Color.fromARGB(255, 230, 3, 52),
                      Color.fromARGB(255, 231, 20, 55),
                      Color(0xffffb56b),
                    ],
                    tileMode: TileMode.mirror,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Theme(
                                data: ThemeData(
                                  primaryColor: Colors.white,
                                  primaryColorDark: Colors.white,
                                  colorScheme: const ColorScheme.light(
                                      primary: Colors.white),
                                  cardColor: Colors.white,
                                ),
                                child: TextField(
                                    decoration: InputDecoration(
                                      labelText: tr('cardNumber'),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      prefixIcon: IconButton(
                                          onPressed: () async {
                                            scanCard();
                                          },
                                          icon: const FaIcon(
                                            FontAwesomeIcons.camera,
                                            color: Colors.white,
                                          )),
                                      hintText: '0000 0000 0000 0000',
                                      suffixIconColor: Colors.white,
                                      labelStyle: const TextStyle(
                                          color: Colors.white, fontSize: 16.0),
                                      hintStyle: const TextStyle(
                                          color: Colors.white, fontSize: 16.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    inputFormatters: [maskFormatter],
                                    keyboardType: TextInputType.number,
                                    controller: myCardNumberController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 150,
                            child: Theme(
                              data: ThemeData(
                                primaryColor: Colors.white,
                                primaryColorDark: Colors.white,
                                colorScheme: const ColorScheme.light(
                                    primary: Colors.white),
                                cardColor: Colors.white,
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: tr("expireDate"),
                                  border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 2)),
                                  hintText: 'ММ/ГГ',
                                  labelStyle: const TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                  hintStyle: const TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                inputFormatters: [maskExpire],
                                keyboardType: TextInputType.number,
                                controller: myCardExpireController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            // Text('$_cardDetails'),
            // Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addCard();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20.0)),
                child: _isLoadingAddCard
                    ? const CircularProgressIndicator()
                    : Text(tr('cards.continue')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
