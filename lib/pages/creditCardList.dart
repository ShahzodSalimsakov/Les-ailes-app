import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:card_scanner/card_scanner.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:les_ailes/pages/creditCard.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../models/user.dart';
import '../services/user_repository.dart';

@RoutePage()
class CreditCardListPage extends StatefulWidget {
  const CreditCardListPage({super.key});

  @override
  State<CreditCardListPage> createState() => _CreditCardListPageState();
}

class _CreditCardListPageState extends State<CreditCardListPage> {
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
              onPressed: () {
                context.router.pushNamed('/my_creditCard');
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
      body: ListView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              margin: const EdgeInsets.all(2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '0000 0000 0000 0000',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          const Text(
                            '00/00',
                            style: TextStyle(color: Colors.white, fontSize: 25),
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
                                  title: const Text('Удаление карты'),
                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text('Вы точно хотите удалить карту?'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Нет'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Да'),
                                      onPressed: () {
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
      ),
    );
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
