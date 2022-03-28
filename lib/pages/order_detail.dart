import 'dart:convert';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/user.dart';
import '../utils/colors.dart';

class OrderDetail extends HookWidget {
  final String orderId;

  const OrderDetail({Key? key, @PathParam() required this.orderId})
      : super(key: key);

  Widget renderProductImage(BuildContext context, Lines lineItem) {
    if (lineItem.child != null &&
        lineItem.child!.isNotEmpty &&
        lineItem.child![0].variant?.product?.id !=
            lineItem.variant?.product?.boxId) {
      return Container(
        height: 50.0,
        width: 50,
        // margin: EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
                child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                    left: 0,
                    child: Container(
                      child: Image.network(
                        'https://api.lesailes.uz/storage/${lineItem.variant?.product?.assets![0].location}/${lineItem.variant?.product?.assets![0].filename}',
                        height: 50,
                      ),
                      width: MediaQuery.of(context).size.width - 30,
                    ))
              ],
            )),
            Expanded(
                child: Stack(
              children: [
                Positioned(
                    right: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Image.network(
                        'https://api.lesailes.uz/storage/${lineItem.child![0].variant?.product?.assets![0].location}/${lineItem.child![0].variant?.product?.assets![0].filename}',
                        height: 50,
                      ),
                    ))
              ],
            ))
          ],
        ),
      );
    } else if (lineItem.variant?.product?.assets != null) {
      return Image.network(
        'https://api.lesailes.uz/storage/${lineItem.variant?.product?.assets![0].location}/${lineItem.variant?.product?.assets![0].filename}',
        width: 50.0,
        height: 50.0,
        // width: MediaQuery.of(context).size.width / 2.5,
      );
    } else {
      return SvgPicture.network(
        'https://lesailes.uz/no_photo.svg',
        width: 100.0,
        height: 73.0,
      );
    }
  }

  Widget build(BuildContext context) {
    final order = useState<Order?>(null);

    Future<void> loadOrder() async {
      Box<User> transaction = Hive.box<User>('user');
      User currentUser = transaction.get('user')!;
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      };
      var url = Uri.https('api.lesailes.uz', '/api/orders', {'id': orderId});
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        order.value = Order.fromJson(json);
      }
    }

    useEffect(() {
      loadOrder();
    }, []);

    if (order.value == null) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => context.router.navigateBack(),
            ),
            title: Text(tr('leftMenu.myOrders'),
                style: const TextStyle(color: Colors.black)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ));
    } else {
      DateTime createdAt =
          DateTime.parse(order.value!.createdAt ?? '').toLocal();
      // createdAt = createdAt.toLocal();
      DateFormat createdAtFormat = DateFormat('MMM d, y, H:m', 'ru');
      final formatCurrency = NumberFormat.currency(
          locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);

      String house =
          order.value!.house != null ? ', дом: ${order.value!.house}' : '';
      String flat =
          order.value!.flat != null ? ', кв.: ${order.value!.flat}' : '';
      String entrance = order.value!.entrance != null
          ? ', подъезд: ${order.value!.entrance}'
          : '';
      String doorCode = order.value!.doorCode != null
          ? ', код на двери: ${order.value!.doorCode}'
          : '';
      String address =
          '${order.value!.billingAddress}${house}${flat}${entrance}${doorCode}';

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => context.router.navigateBack(),
          ),
          title: Text('${tr("order")} № ${order.value!.id}',
              style: const TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tr("order")} № ${order.value!.id}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 22),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: order.value!.status == 'cancelled'
                                ? AppColors.mainColor
                                : AppColors.green),
                        child: Text(tr(order.value!.status),
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 17,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(createdAtFormat.format(createdAt),
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Colors.grey)),
                      Text(
                          '${tr("total")} : ${formatCurrency.format(order.value!.orderTotal / 100)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Colors.grey))
                    ],
                  ),
                ],
              ),
            ),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.plum,
                  borderRadius: const BorderRadius.all(Radius.circular(26)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: const Text("")),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr("delivery-address"),
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Image.asset('images/restaurant.png',
                          width: 38, height: 38),
                      const Text("Буюк Ипак Йули, 123")
                    ],
                  )
                ],
              ),
            ),
            Container(
              // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tr("order")} № ${order.value!.id}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 22),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: order.value!.status == 'cancelled'
                                ? AppColors.mainColor
                                : AppColors.green),
                        child: Text(tr(order.value!.status),
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 17,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(createdAtFormat.format(createdAt),
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Colors.grey)),
                      Text(
                          '${tr("total")} : ${formatCurrency.format(order.value!.orderTotal / 100)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Colors.grey))
                    ],
                  ),
                ],
              ),
            ),
            Container(
              // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tr("order")} № ${order.value!.id}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 22),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: order.value!.status == 'cancelled'
                                ? AppColors.mainColor
                                : AppColors.green),
                        child: Text(tr(order.value!.status),
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 17,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(createdAtFormat.format(createdAt),
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Colors.grey)),
                      Text(
                          '${tr("total")} : ${formatCurrency.format(order.value!.orderTotal / 100)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Colors.grey))
                    ],
                  ),
                ],
              ),
            )

            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: const BorderRadius.all(Radius.circular(20)),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.5),
            //         spreadRadius: 2,
            //         blurRadius: 7,
            //         offset: const Offset(0, 3), // changes position of shadow
            //       ),
            //     ],
            //   ),
            //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            //   margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            //   child: Column(
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             '№ ${order.value!.id}',
            //             style: const TextStyle(
            //                 fontWeight: FontWeight.w400, fontSize: 20),
            //           ),
            //           Text(tr('order_status_${order.value!.status}'),
            //               style: TextStyle(
            //                   fontWeight: FontWeight.w400,
            //                   fontSize: 14,
            //                   color: order.value!.status == 'cancelled'
            //                       ? Colors.red
            //                       : Colors.green))
            //         ],
            //       ),
            //       Row(
            //         children: [
            //           Text(createdAtFormat.format(createdAt),
            //               style: const TextStyle(
            //                   fontWeight: FontWeight.w400,
            //                   fontSize: 14,
            //                   color: Colors.grey)),
            //         ],
            //       ),
            //       const SizedBox(
            //         height: 10,
            //       ),
            //       const Divider(
            //         color: Colors.grey,
            //       ),
            //       Row(
            //         children: [
            //           Flexible(
            //               child: Text(address,
            //                   style: const TextStyle(
            //                     fontWeight: FontWeight.w400,
            //                     fontSize: 16,
            //                   ))),
            //         ],
            //       ),
            //       const SizedBox(
            //         height: 8,
            //       ),
            //       const Divider(
            //         color: Colors.grey,
            //       ),
            //       const SizedBox(
            //         height: 10,
            //       ),
            //       Expanded(
            //           child: ListView.separated(
            //               itemBuilder: (context, index) {
            //                 Lines lineItem = order.value!.basket!.lines![index];
            //                 return ListTile(
            //                   title: Text(lineItem.variant?.product?.attributeData
            //                           ?.name?.chopar?.ru ??
            //                       ''),
            //                   leading: renderProductImage(context, lineItem),
            //                   trailing: Text(
            //                       '${double.parse(order.value!.basket!.lines![index].total) > 0 ? lineItem.quantity.toString() + 'X' : ''} ${formatCurrency.format(double.parse(order.value!.basket!.lines![index].total))}'),
            //                 );
            //               },
            //               separatorBuilder: (context, index) {
            //                 return const Divider();
            //               },
            //               itemCount: order.value!.basket?.lines?.length ?? 0)),
            //       const SizedBox(
            //         height: 10,
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           const Text("Общая сумма:",
            //               style: TextStyle(
            //                 fontWeight: FontWeight.w600,
            //                 fontSize: 16,
            //               )),
            //           // Text(
            //           //   t!.prodCount(order.basket?.lines?.length ?? 0),
            //           //   style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            //           // ),
            //           Text(formatCurrency.format(order.value!.orderTotal / 100),
            //               style: const TextStyle(
            //                 fontWeight: FontWeight.w600,
            //                 fontSize: 16,
            //               ))
            //         ],
            //       ),
            //       const SizedBox(
            //         height: 10,
            //       ),
            //       const Divider(
            //         color: Colors.grey,
            //       )
            //     ],
            //   ),
            // ),
          ],
        ),
      );
    }
  }
}