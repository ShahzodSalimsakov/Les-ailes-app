import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:les_ailes/utils/colors.dart';
import 'package:niku/niku.dart' as n;

import '../routes/router.dart';

@RoutePage()
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool isLoading = false;

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };

    var url = Uri.https('api.lesailes.uz', '/api/mobile_push_events', {
      'op_<=_start_date': DateFormat('yyyy-MM-dd H:m:s').format(DateTime.now())
    });
    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200 || response.statusCode == 201) {
      var json = jsonDecode(response.body);
      setState(() {
        // json data to list of Map<String, dynamic>
        _notifications = json['data'].cast<Map<String, dynamic>>();
        isLoading = false;
      });
    }
  }

  @override
  initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                context.router.maybePop();
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 28),
                child: Center(
                    child: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 30,
                )),
              ))
        ],
        title: Text(tr("main.newsAndPromotions"),
            style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.mainColor),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
                  child: ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                // show image if asset exists
                                _notifications[index]['asset'] != null
                                    ? Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          // Ink.image(
                                          //   image: NetworkImage(
                                          //     _notifications[index]['asset'][0]
                                          //         ['link'],
                                          //   ),
                                          //   height: 200,
                                          //   fit: BoxFit.cover,
                                          // ),
                                          CachedNetworkImage(
                                            width: double.infinity,
                                            imageUrl: _notifications[index]
                                                ['asset'][0]['link'],
                                            height: 200,
                                            fit: BoxFit.cover,
                                          )
                                        ],
                                      )
                                    : Container(),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _notifications[index]['title'] != null &&
                                              _notifications[index]['title'] !=
                                                  ''
                                          ? Text(
                                              _notifications[index]['title'],
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          : Container(),
                                      _notifications[index]['title'] != null
                                          ? const SizedBox(height: 10)
                                          : Container(),
                                      // show truncated text if text is too long
                                      _notifications[index]['text'] != null
                                          ? Text(
                                              _notifications[index]['text'],
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          : Container(),
                                      // router push to detail page widget
                                      _notifications[index]['title'] != null
                                          ? const SizedBox(height: 10)
                                          : Container(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          n.NikuButton(n.NikuText(
                                            tr("main.readMore"),
                                            style: n.NikuTextStyle(
                                                color: AppColors.mainColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ))
                                            ..onPressed = () => context.router
                                                .push(NotificationDetailRoute(
                                                    id: _notifications[index]
                                                            ['id']
                                                        .toString(),
                                                    notification:
                                                        _notifications[index])),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ));
                      })),
        ),
      ),
    );
  }
}
