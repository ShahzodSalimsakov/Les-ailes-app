import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:les_ailes/widgets/orders/track.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';
import '../models/registered_review.dart';
import '../models/user.dart';
import '../utils/colors.dart';
import 'package:intl/intl.dart';

@RoutePage()
class OrderDetailPage extends HookWidget {
  final String orderId;

  const OrderDetailPage({Key? key, @PathParam() required this.orderId})
      : super(key: key);

  Widget renderProductImage(BuildContext context, OrderLines lineItem) {
    var locale = context.locale.toString();
    final formatter = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: locale == 'uz'
          ? "so'm"
          : locale == 'en'
              ? 'sum'
              : 'сум',
      decimalDigits: 0,
    );

    // Get product names
    String mainProductName =
        lineItem.variant?.product?.attributeData?.name?.chopar?.ru ?? '';
    String childProductName = '';
    bool isChildBonus = false;

    if (lineItem.child != null &&
        lineItem.child!.isNotEmpty &&
        lineItem.child![0].variant?.product?.id !=
            lineItem.variant?.product?.boxId) {
      childProductName = lineItem
              .child![0].variant?.product?.attributeData?.name?.chopar?.ru ??
          '';
      // Check if child product is a bonus (price is 0)
      isChildBonus = double.parse(lineItem.child![0].total) == 0;
    }

    // Combine product names if there's a child product
    String displayName = childProductName.isNotEmpty
        ? '$mainProductName + $childProductName'
        : mainProductName;

    // Calculate total price (quantity * price)
    double totalPrice = double.parse(lineItem.total) * lineItem.quantity;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formatter.format(totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Product image and quantity controls
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product image with quantity overlay
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: lineItem.variant?.product?.assets != null &&
                            lineItem.variant!.product!.assets!.isNotEmpty
                        ? Image.network(
                            'https://api.lesailes.uz/storage/${lineItem.variant?.product?.assets![0].location}/${lineItem.variant?.product?.assets![0].filename}',
                            fit: BoxFit.contain,
                          )
                        : SvgPicture.network(
                            'https://lesailes.uz/no_photo.svg',
                            fit: BoxFit.contain,
                          ),
                  ),
                  // Quantity overlay
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${lineItem.quantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Child product image if exists
              if (childProductName.isNotEmpty)
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 60,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          lineItem.child![0].variant?.product?.assets != null &&
                                  lineItem.child![0].variant!.product!.assets!
                                      .isNotEmpty
                              ? Image.network(
                                  'https://api.lesailes.uz/storage/${lineItem.child![0].variant!.product!.assets![0].location}/${lineItem.child![0].variant!.product!.assets![0].filename}',
                                  fit: BoxFit.contain,
                                  width: 80,
                                  height: 60,
                                )
                              : SvgPicture.network(
                                  'https://lesailes.uz/no_photo.svg',
                                  fit: BoxFit.contain,
                                  width: 80,
                                  height: 60,
                                ),
                    ),
                    // Bonus label if child product is free
                    if (isChildBonus)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            locale == 'uz'
                                ? 'bonus'
                                : locale == 'en'
                                    ? 'bonus'
                                    : 'бонус',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Quantity overlay for child product (if not a bonus)
                    if (!isChildBonus)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${lineItem.quantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

              const Spacer(),

              // Remove the quantity controls since we now show it on the image
            ],
          ),

          const SizedBox(height: 8),

          // Product labels
          Row(
            children: [
              // Main product label
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  mainProductName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Child product label if exists
              if (childProductName.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    childProductName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = useState<Order?>(null);
    final product = useState(0.0);
    final equipment = useState(0.0);
    final delivery = useState(0.0);
    final deliveryPrice = useState<int?>(0);

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
        var localOrder = Order.fromJson(json);
        order.value = localOrder;
        deliveryPrice.value = localOrder.deliveryPrice;
      }
    }

    useEffect(() {
      loadOrder();
      return null;
    }, []);

    int deliveryPriceReady = useMemoized(() {
      int result = 0;
      if (deliveryPrice.value != null) {
        result = deliveryPrice.value!;
      }
      return result;
    }, [deliveryPrice.value]);

    if (order.value == null) {
      return Scaffold(
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => context.router.back(),
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
      var locale = context.locale.toString();
      DateTime createdAt =
          DateTime.parse(order.value!.createdAt ?? '').toLocal();
      // createdAt = createdAt.toLocal();
      DateFormat createdAtFormat = DateFormat('d MMMM. HH:mm', 'ru');
      final formatCurrency = NumberFormat.currency(
          locale: 'ru_RU',
          symbol: locale == 'uz'
              ? "so'm"
              : locale == 'en'
                  ? 'sum'
                  : 'сум',
          decimalDigits: 0);

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
          '${order.value!.billingAddress}$house$flat$entrance$doorCode';

      var terminal = order.value?.terminalData;
      var terminalName = '';
      var addressDesc = '';
      var paymentType = '';
      switch (locale) {
        case 'en':
          addressDesc = terminal?.descEn ?? '';
          break;
        case 'uz':
          addressDesc = terminal?.descUz ?? '';
          terminalName = terminal?.nameUz ?? '';
          break;
        default:
          addressDesc = terminal?.desc ?? '';
          terminalName = terminal?.name ?? '';
          break;
      }

      switch (order.value?.type) {
        case 'card':
          paymentType = locale == 'uz'
              ? 'Karta orqali to\'lov'
              : locale == 'en'
                  ? 'Payment by card'
                  : 'Картой';
          break;
        case 'offline':
          paymentType = locale == 'uz'
              ? 'Naqd pul orqali to\'lov'
              : locale == 'en'
                  ? 'Cash'
                  : 'Наличными';
          break;
        case 'click':
          paymentType = 'Click';
          break;
        case 'payme':
          paymentType = 'Payme';
          break;
      }
      return Scaffold(
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => context.router.back(),
            ),
            title: Text('${tr("order")} № ${order.value!.id}',
                style: const TextStyle(color: Colors.black)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                Column(
                  children: [
                    Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${tr("order")}\n№ ${order.value!.id}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 20),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: order.value!.status == 'cancelled'
                                        ? AppColors.mainColor
                                        : AppColors.green),
                                child: SizedBox(
                                  width: 100,
                                  child: Text(
                                    tr(order.value?.deliveryType == 'pickup' &&
                                            order.value?.status == 'done'
                                        ? 'takenAway'
                                        : order.value?.status ?? ''),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 17,
                          ),
                          Column(
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
                    // Container(
                    //     width: double.infinity,
                    //     decoration: BoxDecoration(
                    //       color: AppColors.plum,
                    //       borderRadius:
                    //           const BorderRadius.all(Radius.circular(26)),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.grey.withOpacity(0.5),
                    //           spreadRadius: 2,
                    //           blurRadius: 7,
                    //           offset: const Offset(
                    //               0, 3), // changes position of shadow
                    //         ),
                    //       ],
                    //     ),
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 20, vertical: 16),
                    //     margin: const EdgeInsets.symmetric(
                    //         vertical: 10, horizontal: 15),
                    //     child: const Text("")),
                    Container(
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
                          horizontal: 20, vertical: 30),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              tr(order.value?.deliveryType == 'deliver'
                                  ? "delivery-address"
                                  : 'deliveryOrPickup.pickup'),
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(
                            height: 25,
                          ),
                          order.value?.terminalData != null
                              ? Row(
                                  children: [
                                    Image.asset('images/restaurant.png',
                                        width: 38, height: 38),
                                    const SizedBox(width: 16),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6,
                                            child: Text(
                                              terminalName,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            )),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6,
                                            child: Text(
                                              addressDesc,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            )),
                                      ],
                                    )
                                  ],
                                )
                              : const SizedBox(
                                  width: double.infinity,
                                ),
                          order.value?.deliveryType == 'deliver'
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                          'images/delivery_location.png',
                                          width: 38,
                                          height: 38),
                                      const SizedBox(width: 16),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: Text(
                                                address,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              )),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              : const SizedBox(
                                  width: double.infinity,
                                ),
                          const SizedBox(
                            height: 25,
                          ),
                          order.value?.deliveryType == 'deliver'
                              ? ElevatedButton(
                                  onPressed: () {
                                    showMaterialModalBottomSheet(
                                        context: context,
                                        enableDrag: false,
                                        bounce: true,
                                        builder: (context) => TrackOrder(
                                            orderId: order.value!.id));
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              AppColors.green),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          tr('trackingOrder').toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ))
                              : const SizedBox(
                                  width: double.infinity,
                                )
                        ],
                      ),
                    ),
                    Container(
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
                          horizontal: 15, vertical: 16),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Column(
                        children: [
                          ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                OrderLines lineItem =
                                    order.value!.basket!.lines![index];
                                return ListTile(
                                  title: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      renderProductImage(context, lineItem),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const Divider(
                                  thickness: 0.5,
                                );
                              },
                              itemCount:
                                  order.value!.basket?.lines?.length ?? 0),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${order.value!.basket?.lines?.fold<int>(0, (sum, line) {
                                        // Count the main product
                                        int count = line.quantity;

                                        // Count all child products, including bonuses
                                        if (line.child != null &&
                                            line.child!.isNotEmpty) {
                                          for (var childItem in line.child!) {
                                            // Count all child products regardless of price
                                            count += line.quantity;
                                          }
                                        }

                                        return sum + count;
                                      }) ?? 0} ${tr("goods-amount")} : ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                  )),
                              Text(
                                  formatCurrency
                                      .format(order.value!.orderTotal / 100),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                  ))
                            ],
                          ),
                          const SizedBox(height: 10),
                          order.value?.deliveryType == 'deliver'
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${tr('shippingAmount')} : ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                        )),
                                    Text(
                                        formatCurrency
                                            .format((deliveryPrice.value)),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                        ))
                                  ],
                                )
                              : const SizedBox(),
                          const SizedBox(height: 10),
                          order.value?.deliveryType == 'deliver'
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${tr('total')} : ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                        )),
                                    Text(
                                        formatCurrency.format(
                                            (deliveryPriceReady +
                                                order.value!.orderTotal / 100)),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                        ))
                                  ],
                                )
                              : const SizedBox(),
                          const SizedBox(height: 10),
                          order.value?.type != null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                      Text('${tr("orderCreate.payType")} :',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20,
                                          )),
                                      Text(paymentType,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20,
                                          ))
                                    ])
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    ValueListenableBuilder<Box<RegisteredReview>>(
                        valueListenable:
                            Hive.box<RegisteredReview>('registeredReview')
                                .listenable(),
                        builder: (context, box, _) {
                          RegisteredReview? registeredView =
                              box.get(order.value!.id);
                          if (registeredView == null) {
                            return Container(
                              // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              width: double.infinity,
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
                                  Align(
                                    heightFactor: 2,
                                    alignment: Alignment.topLeft,
                                    child: Text(tr("leaveAReview"),
                                        style: const TextStyle(fontSize: 20)),
                                  ),
                                  Text(tr("product"),
                                      style: const TextStyle(fontSize: 18)),
                                  RatingBar.builder(
                                    initialRating: 0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: AppColors.mainColor,
                                    ),
                                    onRatingUpdate: (rating) {
                                      product.value = rating;
                                    },
                                  ),
                                  Text(tr("equipment"),
                                      style: const TextStyle(fontSize: 18)),
                                  RatingBar.builder(
                                    initialRating: 0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: AppColors.mainColor,
                                    ),
                                    onRatingUpdate: (rating) {
                                      equipment.value = rating;
                                    },
                                  ),
                                  order.value?.deliveryType == 'deliver'
                                      ? Text(tr("delivery"),
                                          style: const TextStyle(fontSize: 18))
                                      : const SizedBox(),
                                  order.value?.deliveryType == 'deliver'
                                      ? RatingBar.builder(
                                          initialRating: 0,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: false,
                                          itemCount: 5,
                                          itemPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 4.0),
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                            Icons.star,
                                            color: AppColors.mainColor,
                                          ),
                                          onRatingUpdate: (rating) {
                                            delivery.value = rating;
                                          },
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (product.value == 0.0 ||
                                          equipment.value == 0.0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text(tr("selectFirst"))));
                                      } else {
                                        Map<String, String> requestHeaders = {
                                          'Content-type': 'application/json',
                                          'Accept': 'application/json',
                                        };
                                        var url = Uri.https(
                                            'crm.choparpizza.uz',
                                            '/rest/1/5boca3dtup3vevqk/new.review.neutral');
                                        var response = await http.post(url,
                                            headers: requestHeaders,
                                            body: jsonEncode({
                                              "phone":
                                                  order.value!.billingPhone,
                                              "order_id": order.value!.id,
                                              "project": "les",
                                              "product": product.value,
                                              "service": equipment.value,
                                              "courier": delivery.value
                                            }));
                                        if (response.statusCode == 200) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      tr("reviewSended"))));
                                          RegisteredReview newRegisteredView =
                                              RegisteredReview();
                                          newRegisteredView.orderId =
                                              order.value!.id;
                                          box.put(order.value!.id,
                                              newRegisteredView);
                                        }
                                      }
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 73, vertical: 20),
                                        decoration: const BoxDecoration(
                                          color: AppColors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                        child: Text(
                                          tr('send'),
                                          style: const TextStyle(fontSize: 20),
                                        )),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container(
                              width: double.infinity,
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
                              child: Center(
                                child: Text(tr('reviewSaved')),
                              ),
                            );
                          }
                        }),
                    Container(
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
                          horizontal: 20, vertical: 30),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset('images/chat.png',
                                  width: 24, height: 24),
                              const SizedBox(width: 16),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text(
                                        tr('leftMenu.writeUs'),
                                        style: const TextStyle(fontSize: 22),
                                      )),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 260,
                            child: Text(
                              tr('leftMenu.writeUsDesc'),
                              style: TextStyle(
                                  fontSize: 17, color: Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 73, vertical: 20),
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Text(
                                      tr('write'),
                                      style: const TextStyle(fontSize: 20),
                                    )),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  launch("tel:712004242");
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(17),
                                  decoration: const BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Image.asset('images/calling.png',
                                      width: 25, height: 25),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]));
    }
  }
}
