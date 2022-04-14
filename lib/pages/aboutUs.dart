import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(tr("settings.aboutUs"),
            style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 290,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: AppColors.mainColor),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 62, vertical: 40),
                      child: Image.asset('images/whiteLogo.png'),
                    ),
                    Text(
                      tr("about.callCenter"),
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        launch("tel://71 200 42 42");
                      },
                      child: const Text(
                        "71 200 42 42",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      tr("about.followUs"),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20,
                        top: 10,
                        right: 100,
                        left: 100,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              launch(
                                'https://www.instagram.com/lesailesuz/',
                                forceSafariVC: false,
                                forceWebView: false,
                                headers: <String, String>{
                                  'my_header_key': 'my_header_value'
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                                color: Colors.white,
                              ),
                              child: Image.asset(
                                'images/instagram.png',
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              launch(
                                'https://www.facebook.com/lesailesuz/',
                                forceSafariVC: false,
                                forceWebView: false,
                                headers: <String, String>{
                                  'my_header_key': 'my_header_value'
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                                color: Colors.white,
                              ),
                              child: Image.asset(
                                'images/facebook.png',
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              launch(
                                '',
                                forceSafariVC: false,
                                forceWebView: false,
                                headers: <String, String>{
                                  'my_header_key': 'my_header_value'
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                                color: Colors.white,
                              ),
                              child: Image.asset(
                                'images/youtube.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.router.pushNamed('privacy');
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: AppColors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              // width: 180,
                              child: Text(tr("about.privacy"),
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios)
                      ],
                    )),
              ),
              GestureDetector(
                onTap: () {
                  context.router.pushNamed('terms');
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: AppColors.grey),
                        bottom: BorderSide(width: 1.0, color: AppColors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              // width: 180,
                              child: Text(tr("about.terms"),
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios)
                      ],
                    )),
              ),
              GestureDetector(
                onTap: () {
                  context.router.pushNamed('franchise');
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: AppColors.grey),
                        bottom: BorderSide(width: 1.0, color: AppColors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              // width: 180,
                              child: Text(tr("about.franchise"),
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios)
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
