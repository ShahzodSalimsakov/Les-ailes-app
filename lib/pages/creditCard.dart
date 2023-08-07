import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:card_scanner/card_scanner.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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

  void _printLatestValue() {
    print('Number text field: ${myCardNumberController.text}');
    print('Expire text field: ${myCardExpireController.text}');
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    myCardNumberController.addListener(_printLatestValue);
    myCardExpireController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myCardNumberController.dispose();
    myCardExpireController.dispose();
    super.dispose();
  }

  Future<void> scanCard() async {
    final CardDetails? cardDetails =
        await CardScanner.scanCard(scanOptions: scanOptions);
    if (!mounted || cardDetails == null) return;
    setState(() {
      _cardDetails = cardDetails;
      myCardNumberController.text = _cardDetails!.cardNumber;
      myCardExpireController.text = _cardDetails!.expiryDate;
      print(_cardDetails?.cardNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormBuilderState>();
    var maskFormatter = MaskTextInputFormatter(
        mask: '#### #### #### ####',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);
    var maskExpire = MaskTextInputFormatter(
        mask: '##/##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);

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
                    context.router.pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20.0)),
                child: const Text('Продолжить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
