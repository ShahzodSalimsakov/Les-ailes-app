import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:les_ailes/utils/colors.dart';

class Lang {
  late String value;
  late String name;
  Lang({required this.value, required this.name});
}

class ChangeLang extends HookWidget {

  List<Lang> supportedLanguages = [
    Lang(name: 'Русский', value: 'ru'),
    Lang(name: 'O\'zbekcha', value: 'uz'),
    Lang(name: 'English', value: 'en'),
  ];
  ChangeLang({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentLanguage = useState(context.locale.toString());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(tr("settings.changeLang"),
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
              GestureDetector(
                onTap: () {},
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: AppColors.grey),
                        bottom: BorderSide(width: 1.0, color: AppColors.grey),
                      ),
                    ),
                    child:
                        ListView.separated(itemBuilder: (context, index) {
                          return GestureDetector(
                            child: ListTile(
                              title: Text(supportedLanguages[index].name),
                              leading: Radio(
                                value: supportedLanguages[index].value,
                                groupValue: currentLanguage.value,
                                fillColor: MaterialStateProperty.all(AppColors.green),
                                onChanged: (value) async {
                                  currentLanguage.value = supportedLanguages[index].value;
                                  await context.setLocale(Locale(supportedLanguages[index].value));
                                  context.router.popUntilRoot();
                                },
                              ),
                            ),
                            onTap: () async {
                              currentLanguage.value = supportedLanguages[index].value;
                              await context.setLocale(Locale(supportedLanguages[index].value));
                              context.router.popUntilRoot();
                            },
                          );
                        }, separatorBuilder: (BuildContext context, int index) {
                          return Divider();
                        }, itemCount: supportedLanguages.length, shrinkWrap: true)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
