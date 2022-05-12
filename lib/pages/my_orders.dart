import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hashids2/hashids2.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:les_ailes/models/order.dart';
import 'package:les_ailes/routes/router.gr.dart';
import 'package:les_ailes/utils/colors.dart';
import '../models/user.dart';
import 'order_detail.dart';

class MyOrders extends HookWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orders = useState<List<Order>>(List<Order>.empty());

    Future<void> getMyOrders() async {
      Box box = Hive.box<User>('user');
      User currentUser = box.get('user');
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      };
      var url = Uri.https('api.lesailes.uz', '/api/my-orders');
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<Order> orderList = List<Order>.from(
            json['data'].map((m) => Order.fromJson(m)).toList());
        orders.value = orderList;
      }
    }

    useEffect(() {
      initializeDateFormatting();
      getMyOrders();
    }, []);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => context.router.navigateBack(),
          ),
          title: Text(tr("leftMenu.myOrders"),
              style: const TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
            child: orders.value.isNotEmpty
                ? ListView.builder(
                    itemCount: orders.value.length,
                    itemBuilder: (BuildContext context, int index) {
                      DateTime createdAt =
                          DateTime.parse(orders.value[index].createdAt ?? '')
                              .toLocal();
                      DateFormat createdAtFormat =
                          DateFormat('d MMMM. H:m', 'ru');
                      Order order = orders.value[index];

                      final hashids = HashIds(
                        salt: 'order',
                        minHashLength: 15,
                        alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
                      );

                      final formatCurrency = NumberFormat.currency(
                          locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);
                      return GestureDetector(
                          onTap: () {
                            context.router.pushNamed(
                                'my_orders/${hashids.encode(order.id)}');
                          },
                          child: Container(
                            // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(26)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${tr("order")} № ${order.id}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: order.status == 'cancelled'
                                              ? AppColors.mainColor
                                              : AppColors.green),
                                      child: Text(tr(order.deliveryType == 'pickup' && order.status == 'done' ? 'takenAway' : order.status),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                              color: Colors.white)),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 17,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(createdAtFormat.format(createdAt),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                            color: Colors.grey)),
                                    Text(
                                        '${tr("total")} : ${formatCurrency.format(order.orderTotal / 100)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                            color: Colors.grey))
                                  ],
                                ),
                              ],
                            ),
                          ));
                    })
                : const Center(child: CircularProgressIndicator(color: AppColors.mainColor,))));
  }
}
