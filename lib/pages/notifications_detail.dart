import 'dart:convert';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:les_ailes/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

@RoutePage()
class NotificationDetailPage extends StatefulWidget {
  final String id;
  late Map<String, dynamic>? notification;
  NotificationDetailPage(
      {Key? key, @PathParam() required this.id, this.notification})
      : super(key: key);

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  late Map<String, dynamic>? notification;
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.notification != null) {
      setState(() {
        notification = widget.notification;
        loading = false;
      });
    } else {
      fetchNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.mainColor),
          )
        : Scaffold(
            appBar: AppBar(
                title: Text(
                  notification?['title'] ?? '',
                  style: const TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => context.router.maybePop(),
                ),
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                )),
            body: Container(
              padding: const EdgeInsets.all(16),
              child: ListView(children: [
                Column(
                  children: [
                    // show image if asset exists
                    notification?['asset'] != null
                        ? Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              // Ink.image(
                              //   image: NetworkImage(
                              //     notification?['asset'][0]['link'],
                              //   ),
                              //   height: 200,
                              //   fit: BoxFit.cover,
                              // ),
                              CachedNetworkImage(
                                imageUrl: notification?['asset'][0]['link'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ],
                          )
                        : Container(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          notification?['title'] != null &&
                                  notification?['title'] != ''
                              ? Text(
                                  notification?['title'],
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                )
                              : Container(),
                          notification?['title'] != null
                              ? const SizedBox(height: 10)
                              : Container(),
                          // show truncated text if text is too long
                          notification?['text'] != null
                              ? Text(
                                  notification?['text'],
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          );
  }

  Future<void> fetchNotification() async {
    setState(() {
      loading = true;
    });
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    };

    var url =
        Uri.https('api.lesailes.uz', '/api/mobile_push_events/${widget.id}');
    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200 || response.statusCode == 201) {
      var json = jsonDecode(response.body);
      setState(() {
        // json data to list of Map<String, dynamic>
        notification = json['data'];
        loading = false;
      });
    }
  }
}
