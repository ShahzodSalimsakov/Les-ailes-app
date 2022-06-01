import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';

class Cashback extends HookWidget {
  const Cashback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final balance = useState(0);
    final loading = useState(true);
    Future<void> getCash() async {
      const iikoCardApiUrl = "upbiz.iiko.ru:9900";
      const iikoCardUser = "lesalies";
      const iikoCardPassword = "Lesalies2018";
      const iikoCardOrgId = "c7dfe002-70a0-11e8-80e1-d8d38565926f";
      int res = 0;
      Box box = Hive.box<User>('user');
      User currentUser = box.get('user');

      var rsAuth = Uri.https(iikoCardApiUrl, '/api/0/auth/access_token',
          {"user_id": iikoCardUser, "user_secret": iikoCardPassword});
      var response = await http.get(rsAuth);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        final accesToken = json.replaceAll('"', '');
        rsAuth = Uri.https(
            iikoCardApiUrl, '/api/0/customers/get_customer_by_phone', {
          "access_token": accesToken,
          "organization": iikoCardOrgId,
          "phone": currentUser.phone
        });
        var authResponse = await http.get(rsAuth);
        if (authResponse.statusCode == 200) {
          var json = jsonDecode(authResponse.body);

          if (json["walletBalances"] != null) {
            json["walletBalances"].forEach((b) {
              if (b['wallet']['programType'] == 'Bonus' &&
                  b['wallet']['name'] == 'CashBack') {
                res += int.parse(b['balance'].toStringAsFixed(0));
                res;
              }
            });
          }
        } else {
          rsAuth =
              Uri.https(iikoCardApiUrl, '/api/0/customers/create_or_update', {
            "access_token": accesToken,
            "organization": iikoCardOrgId,
          });
          await http.post(rsAuth, body: {
            'organization': iikoCardOrgId,
            'customer': {
              'name': currentUser.name,
              'phone': currentUser.phone,
              'magnetCardTrack': currentUser.phone
            }
          });
        }
        loading.value = false;
      }

      balance.value = res;
    }

    useEffect(() {
      getCash();
      return;
    }, []);

    return Container(
      height: 70,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
          onPressed: () {
            context.router.pushNamed('cashback_detail');
          },
          child: loading.value == true
              ? const CircularProgressIndicator(color: AppColors.mainColor)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${tr("youHave")} ${balance.value} ${tr("sum")}",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    )
                  ],
                ),
          style: ButtonStyle(
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 30)),
              backgroundColor: MaterialStateProperty.all(AppColors.green),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.0),
              )))),
    );
  }
}
