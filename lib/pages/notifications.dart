import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  Future<void> fetchNews() async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };

      var url = Uri.https(
          'api.lesailes.uz', '/api/');
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        // List<RelatedProduct> localRelatedProduct = List<RelatedProduct>.from(
        //     json['data'].map((m) => RelatedProduct.fromJson(m)).toList());
        // localRelatedProduct;
        // relatedData.value = localRelatedProduct;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
              onTap: () => Navigator.of(context).pop(),
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
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
                itemCount: 3,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Ink.image(
                                image: const NetworkImage(
                                  'https://placeimg.com/640/480/any',
                                ),
                                height: 244,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                    "Вкусный завтрак ждет вас с 8:00 до 11:00 в стационарных филиалах Заходите, заряжайтесь и окрыляйтесь вместе с LES❤️",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        height: 1.6))
                              ],
                            ),
                          )
                        ],
                      ));
                })),
      ),
    );
  }
}
