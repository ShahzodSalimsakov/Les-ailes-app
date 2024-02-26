import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hex/hex.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:les_ailes/models/pay_type.dart';
import 'package:les_ailes/utils/colors.dart';

import '../../models/basket.dart';
import '../../models/payment_card_model.dart';
import '../../models/user.dart';
import '../../utils/random.dart';
import '../credit_card_add_sheet.dart';

class OrderCardList extends HookWidget {
  const OrderCardList({super.key});

  get box => null;

  @override
  Widget build(BuildContext context) {
    final _isLoading = useState<bool>(false);
    final _cards = useState<List<PaymentCardModel>>([]);
    final _basketTotal = useState<int>(0);
    final formatCurrency =
        NumberFormat.currency(locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);

    Future<void> _loadCards() async {
      _isLoading.value = true;
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

        _isLoading.value = false;
        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);
          List<PaymentCardModel> localCards = List<PaymentCardModel>.from(
              json['data'].map((m) => PaymentCardModel.fromMap(m)).toList());
          _cards.value = localCards;
        }
      }
    }

    useEffect(() {
      _loadCards();

      final Box<Basket> box = Hive.box<Basket>('basket');
      Basket? basket = box.get('basket');
      if (basket != null) {
        _basketTotal.value = basket.totalPrice ?? 0;
      }
    }, []);

    return _isLoading.value
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.mainColor,
            ),
          )
        : _cards.value.isNotEmpty
            ? ValueListenableBuilder<Box<PaymentCardModel>>(
                valueListenable:
                    Hive.box<PaymentCardModel>('paymentCardModel').listenable(),
                builder: (context, box, _) {
                  PaymentCardModel? selectedPaymentCard =
                      box.get('paymentCardModel');
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _cards.value.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          var item = _cards.value[index];
                          var expDate = item.expireDate;
                          var month = expDate.substring(2);
                          var year = expDate.substring(0, 2);
                          var balance = item.balance ?? 0;

                          return Stack(children: [
                            GestureDetector(
                              onTap: () {
                                if (selectedPaymentCard != null &&
                                    selectedPaymentCard.id == item.id) {
                                  box.delete('paymentCardModel');
                                } else {
                                  box.put('paymentCardModel', item);
                                }
                              },
                              child: Container(
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
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: selectedPaymentCard != null &&
                                                selectedPaymentCard.id ==
                                                    item.id
                                            ? const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                            : const SizedBox(),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.number.toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 25),
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
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    '${month}/${year}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 25),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                            balance < _basketTotal.value
                                ? Positioned(
                                    left: 0,
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                        height: 130,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 20),
                                        margin: const EdgeInsets.all(2.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tr('cards.insufficientFunds'),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25),
                                            ),
                                            const Spacer(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      tr('cards.balance'),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      formatCurrency
                                                          .format(balance),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 25),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        )))
                                : const SizedBox()
                          ]);
                        },
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                                backgroundColor: selectedPaymentCard != null
                                    ? MaterialStateProperty.all<Color>(
                                        AppColors.mainColor)
                                    : MaterialStateProperty.all<Color>(
                                        Colors.grey),
                              ),
                              onPressed: () {
                                if (selectedPaymentCard != null) {
                                  final Box<PayType> box =
                                      Hive.box<PayType>('payType');
                                  PayType newPayType = PayType();
                                  newPayType.value = 'card';
                                  box.put('payType', newPayType);
                                  Navigator.of(context)
                                    ..pop()
                                    ..pop();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  tr('cards.choose'),
                                  style: const TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  );
                })
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
              );
  }
}
