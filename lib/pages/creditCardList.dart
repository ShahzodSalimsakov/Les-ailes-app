import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:card_scanner/card_scanner.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hex/hex.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:les_ailes/models/payment_card_model.dart';
import 'package:les_ailes/pages/creditCard.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../services/user_repository.dart';
import '../utils/colors.dart';
import '../utils/random.dart';
import '../widgets/credit_card_add_sheet.dart';

@RoutePage()
class CreditCardListPage extends StatefulWidget {
  const CreditCardListPage({super.key});

  @override
  State<CreditCardListPage> createState() => _CreditCardListPageState();
}

class _CreditCardListPageState extends State<CreditCardListPage> {
  bool _isLoading = false;
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

  List<PaymentCardModel> _cards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await _loadCards();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
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
      var response = await http.get(url, headers: requestHeaders);
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        List<PaymentCardModel> localCards = List<PaymentCardModel>.from(
            json['data'].map((m) => PaymentCardModel.fromMap(m)).toList());
        setState(() {
          _cards = localCards;
        });
      }
    }
  }

  Future<void> _deleteCard(int cardId) async {
    setState(() {
      _isLoading = true;
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

      var url = Uri.https('api.lesailes.uz', 'api/payment_cards/${cardId}');
      var response = await http.delete(url, headers: requestHeaders);
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        _loadCards();
      }
    }
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
    // return ValueListenableBuilder<Box<User>>(
    //     valueListenable: Hive.box<User>('user').listenable(),
    //     builder: (context, box, _) {
    //       User? currentUser = box.get('user');
    //       print(currentUser!.id);
    var items = List<String>.generate(5, (i) => 'Item $i');
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => context.back(),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await showCreditCardModalBottomSheet(context);
                  _loadCards();
                  // context.router.pushNamed('/my_creditCard');
                },
                icon: const Icon(
                  Icons.add_card,
                  color: Colors.black,
                ))
          ],
          title: Text(tr("leftMenu.myCards"),
              style: const TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _cards.isNotEmpty
                ? ListView.builder(
                    itemCount: _cards.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      var item = _cards[index];
                      var expDate = item.expireDate;
                      var month = expDate.substring(2);
                      var year = expDate.substring(0, 2);
                      return Container(
                          height: 130,
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          margin: const EdgeInsets.all(2.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.number.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        tr('expireDate'),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '${month}/${year}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 25),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      padding: const EdgeInsets.all(0),
                                      onPressed: () {
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible:
                                              false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  tr('cards.deleteModalTitle')),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text(tr(
                                                        'cards.deleteModalText')),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(tr(
                                                      'cards.deleteModalCancel')),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(tr(
                                                      'cards.deleteModalDelete')),
                                                  onPressed: () {
                                                    _deleteCard(
                                                        _cards[index].id);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ))
                                ],
                              )
                            ],
                          ));
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tr('cards.noCards'),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              )),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  AppColors.mainColor),
                            ),
                            onPressed: () async {
                              // context.router.pushNamed('/my_creditCard');
                              await showCreditCardModalBottomSheet(context);
                              _loadCards();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                tr('cards.addCard'),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ))
                      ],
                    ),
                  ));
    // });

    // Scaffold(
    //   appBar: AppBar(
    //     leading: IconButton(
    //       icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
    //       onPressed: () => context.back(),
    //     ),
    //     title: Text(tr("leftMenu.myCards"),
    //         style: const TextStyle(color: Colors.black)),
    //     centerTitle: true,
    //     backgroundColor: Colors.transparent,
    //     elevation: 0,
    //   ),
    //   body: Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: [
    //         Container(
    //             padding: const EdgeInsets.all(10),
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(20),
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: Colors.grey.withOpacity(0.5),
    //                   spreadRadius: 5,
    //                   blurRadius: 7,
    //                   offset: Offset(0, 3), // changes position of shadow
    //                 ),
    //               ],
    //             ),
    //             child: Column(
    //               children: [
    //                 FormBuilder(
    //                   key: _formKey,
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Stack(
    //                         children: [
    //                           TextField(
    //                             decoration: InputDecoration(
    //                               labelText: 'Номер карты',
    //                               border: const OutlineInputBorder(
    //                                   borderRadius: BorderRadius.all(
    //                                       Radius.circular(20.0))),
    //                               prefixIcon: IconButton(
    //                                   onPressed: () async {
    //                                     scanCard();
    //                                   },
    //                                   icon: Image.asset(
    //                                       'images/scanCardIcon.png')),
    //                               hintText: '0000 0000 0000 0000',
    //                             ),
    //                             inputFormatters: [maskFormatter],
    //                             keyboardType: TextInputType.number,
    //                             controller: myCardNumberController,
    //                           ),
    //                         ],
    //                       ),
    //                       const SizedBox(height: 10),
    //                       SizedBox(
    //                         width: 150,
    //                         child: TextField(
    //                           decoration: const InputDecoration(
    //                               labelText: 'Дата окончания',
    //                               border: OutlineInputBorder(
    //                                   borderRadius: BorderRadius.all(
    //                                       Radius.circular(20.0))),
    //                               hintText: 'ММ/ГГ'),
    //                           inputFormatters: [maskExpire],
    //                           keyboardType: TextInputType.number,
    //                           controller: myCardExpireController,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ],
    //             )),
    //         Text('$_cardDetails'),
    //       ],
    //     ),
    //   ),
    // );
  }
}
