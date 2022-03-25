import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:niku/niku.dart' as n;
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<User>>(
        valueListenable: Hive.box<User>('user').listenable(),
        builder: (context, box, _) {
          User? currentUser = box.get('user');
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(tr("profile.profile"),
                  style: const TextStyle(color: Colors.black)),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(top: 5),
                          // height: MediaQuery.of(context).size.height * 0.53,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FormBuilder(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.always,
                                  child: Column(
                                    children: [
                                      FormBuilderTextField(
                                        name: 'name',
                                        initialValue: currentUser?.name ?? '',
                                        // validator: (value) => value?.length == 0 ? 'Поле обязательно для заполнения' : '',
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(
                                              context,
                                              errorText:
                                                  'Поле обязательно для заполнения')
                                        ]),
                                        style: const TextStyle(fontSize: 20),
                                        decoration: InputDecoration(
                                            labelText: tr("profile.name"),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            fillColor: AppColors.grey),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      FormBuilderDateTimePicker(
                                        name: 'birth',
                                        // onChanged: _onChanged,
                                        inputType: InputType.date,
                                        style: const TextStyle(fontSize: 20),
                                        decoration: InputDecoration(
                                          labelText: tr('profile.birthDay'),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20),
                                        ),
                                        initialTime:
                                            const TimeOfDay(hour: 8, minute: 0),
                                        // initialValue: DateTime.now(),
                                        // enabled: true,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      FormBuilderTextField(
                                        style: const TextStyle(fontSize: 20),
                                        name: 'email',
                                        initialValue: currentUser?.email ?? '',
                                        decoration: InputDecoration(
                                          labelText: tr('profile.email'),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      FormBuilderPhoneField(
                                        style: const TextStyle(fontSize: 20),
                                        name: 'phone',
                                        initialValue: currentUser?.phone ?? '',
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(
                                              context,
                                              errorText:
                                                  'Поле обязательно для заполнения'),
                                          FormBuilderValidators.minLength(
                                              context, 13,
                                              errorText: 'Заполнено неверно')
                                        ]),
                                        decoration: InputDecoration(
                                          labelText: tr('profile.phone'),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20),
                                        ),
                                        // onChanged: _onChanged,
                                        priorityListByIsoCode: const ['UZ'],
                                        defaultSelectedCountryIsoCode: 'UZ',
                                        countryFilterByIsoCode: const ['Uz'],
                                        isSearchable: false,
                                        autocorrect: true,
                                        // validator: ,
                                        // validator: FormBuilderValidators.compose([
                                        //   FormBuilderValidators.numeric(context),
                                        //   FormBuilderValidators.required(context),
                                        // ]),
                                      ),
                                    ],
                                  )),
                            ],
                          )),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.white,
                            child: SizedBox(
                                width: double.infinity,
                                child: n.NikuButton.elevated(Text(
                                  tr('save'),
                                  style: const TextStyle(fontSize: 20),
                                ))
                                  ..bg = AppColors.mainColor
                                  ..color = Colors.white
                                  ..rounded = 20
                                  ..py = 20
                                  ..my = 10
                                  ..onPressed = () async {
                                    _formKey.currentState!.save();
                                    if (_formKey.currentState != null &&
                                        _formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      Map<String, String> requestHeaders = {
                                        'Content-type': 'application/json',
                                        'Accept': 'application/json',
                                        'Authorization':
                                            'Bearer ${currentUser!.userToken}'
                                      };
                                      var url = Uri.https(
                                          'api.lesailes.uz', '/api/me');
                                      var values = _formKey.currentState!.value;
                                      if (values['email'] == null) {
                                        values['email'] = '';
                                      }
                                      var response = await http.post(url,
                                          headers: requestHeaders,
                                          body: jsonEncode(values));
                                      if (response.statusCode == 200) {
                                        var result = jsonDecode(response.body);
                                        User authorizedUser =
                                            User.fromJson(result['data']);
                                        Box<User> transaction =
                                            Hive.box<User>('user');
                                        transaction.put('user', authorizedUser);
                                        Navigator.of(context).pop();
                                      }

                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  }),
                          )),
                    ],
                  )),
            ),
          );
        });
  }
}
