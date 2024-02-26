import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../utils/colors.dart';
import 'package:http/http.dart' as http;

@RoutePage()
class CashbackDetailPage extends StatefulWidget {
  const CashbackDetailPage({Key? key}) : super(key: key);

  @override
  State<CashbackDetailPage> createState() => _CashbackDetailPageState();
}

class _CashbackDetailPageState extends State<CashbackDetailPage> {
  DateTimeRange dateRange = DateTimeRange(
      start: (DateTime.now().subtract(const Duration(days: 7))),
      end: DateTime.now());
  int balance = 0;
  bool loading = true;
  List transactionItems = [];

  Future<void> getCash() async {
    const iikoCardApiUrl = "upbiz.iiko.ru:9900";
    const iikoCardUser = "lesalies";
    const iikoCardPassword = "Lesalies2018";
    const iikoCardOrgId = "c7dfe002-70a0-11e8-80e1-d8d38565926f";
    final start = dateRange.start;
    final end = dateRange.end;
    var res = [];
    Box box = Hive.box<User>('user');
    User currentUser = box.get('user');

    setState(() {
      loading = true;
    });
    var rsAuth = Uri.https(iikoCardApiUrl, '/api/0/auth/access_token',
        {"user_id": iikoCardUser, "user_secret": iikoCardPassword});
    var response = await http.get(rsAuth);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      final accesToken = json.replaceAll('"', '');
      rsAuth =
          Uri.https(iikoCardApiUrl, '/api/0/customers/get_customer_by_phone', {
        "access_token": accesToken,
        "organization": iikoCardOrgId,
        "phone": currentUser.phone
      });

      var authResponse = await http.get(rsAuth);
      if (authResponse.statusCode == 200) {
        var userData = jsonDecode(authResponse.body);
        var transactionReport = Uri.https(iikoCardApiUrl,
            '/api/0/organization/$iikoCardOrgId/transactions_report', {
          "access_token": accesToken,
          "date_from": DateFormat('yyyy-MM-dd').format(start),
          "date_to": DateFormat('yyyy-MM-dd').format(end),
          "userId": userData["id"]
        });
        var transactionRes = await http.get(transactionReport);
        if (transactionRes.statusCode == 200) {
          var json = jsonDecode(transactionRes.body);
          json.forEach((item) {
            if (item["programName"] == "CashBack") {
              res.add(Map<String, dynamic>.from(item));
            }
          });
          setState(() {
            loading = false;
          });
        }
      }

      setState(() {
        transactionItems = res;
      });
    }
    setState(() {
      // balance = res;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCash();
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;
    final difference = dateRange.duration;

    final formatCurrency =
        NumberFormat.currency(locale: 'ru_RU', symbol: 'сум', decimalDigits: 0);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => context.router.navigateBack(),
          ),
          title:
              Text(tr("cashback"), style: const TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      pickDateRange();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(AppColors.mainColor),
                    ),
                    child: Text(DateFormat('dd.MM.yyyy').format(start)),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        pickDateRange();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.mainColor),
                      ),
                      child: Text(DateFormat('dd.MM.yyyy').format(end))),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(tr("cashbackHistory"), style: const TextStyle(fontSize: 20)),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: !loading
                    ? ListView.separated(
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => const Divider(
                              color: Colors.grey,
                            ),
                        itemCount: transactionItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      DateFormat('dd.MM.yyyy H:m:s').format(
                                          DateTime.parse(transactionItems[index]
                                              ['transactionCreateDate'])),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                          color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(
                                height: 17,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    transactionItems[index]
                                                ['transactionType'] ==
                                            'RefillWalletFromOrder'
                                        ? tr("accrued")
                                        : tr("decommissioned"),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20),
                                  ),
                                  Text(
                                      formatCurrency.format(
                                          transactionItems[index]
                                              ['transactionSum']),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                          color: transactionItems[index]
                                                      ['transactionType'] ==
                                                  'RefillWalletFromOrder'
                                              ? AppColors.green
                                              : Colors.red))
                                ],
                              ),
                            ],
                          );
                        })
                    : const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.mainColor)),
              ),
            ],
          ),
        )
            // const Center(child: CircularProgressIndicator(color: AppColors.mainColor,))
            ));
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.mainColor, // header background color
                onPrimary: Colors.white, // header text color
                onSurface: AppColors.mainColor, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));

    if (newDateRange == null) return;
    setState(() {
      dateRange = newDateRange;
    });

    getCash();
  }
}
