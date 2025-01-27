import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:niku/niku.dart' as n;
import 'package:http/http.dart' as http;
import '../models/basket.dart';
import '../models/basket_item_quantity.dart';
import '../models/user.dart';
import '../utils/colors.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  Future<void> logout() async {
    Box<User> transaction = Hive.box<User>('user');
    User currentUser = transaction.get('user')!;
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${currentUser.userToken}'
    };
    var url = Uri.https('api.lesailes.uz', '/api/logout');
    var formData = {};
    var response = await http.post(url,
        headers: requestHeaders, body: jsonEncode(formData));
    if (response.statusCode == 200) {
      await transaction.delete('user');
      Box<Basket> basketBox = Hive.box<Basket>('basket');
      await basketBox.delete('basket');
      Box<BasketItemQuantity> basketItemQuantityBox =
          Hive.box<BasketItemQuantity>('basketItemQuantity');
      await basketItemQuantityBox.clear();
    }
  }

  Future<void> _handleDelete(User currentUser) async {
    try {
      setState(() {
        isLoading = true;
      });

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      };
      var url = Uri.https('api.lesailes.uz', '/api/delete');

      var response = await http.post(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        await logout();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('profile.errorDeleteProfile')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('profile.errorDeleteProfile')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSave(User currentUser) async {
    try {
      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      _formKey.currentState!.save();
      var values = {..._formKey.currentState!.value};

      print('Form values: $values');

      // Обработка email
      if (values['email'] == null) {
        values['email'] = '';
      }

      // Добавляем текущий номер телефона пользователя
      values['phone'] = currentUser.phone;

      // Обработка даты рождения
      if (values['birth'] != null) {
        values['birth'] = DateFormat('yyyy-MM-dd').format(values['birth']);
      }

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${currentUser.userToken}'
      };

      print('Request headers: $requestHeaders');
      print('Request body: ${jsonEncode(values)}');

      var url = Uri.https('api.lesailes.uz', '/api/me');
      var response = await http.post(
        url,
        headers: requestHeaders,
        body: jsonEncode(values),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['data'] != null) {
          User authorizedUser = User.fromJson(result['data']);
          Box<User> transaction = Hive.box<User>('user');
          await transaction.put('user', authorizedUser);
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          print('No data in response: $result');
          throw Exception('No data in response');
        }
      } else {
        var errorBody = jsonDecode(response.body);
        print('Error response: $errorBody');
        throw Exception(
            'Update failed: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('Exception:')
                ? e.toString().split('Exception: ')[1]
                : tr('profile.updateError')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<User>>(
        valueListenable: Hive.box<User>('user').listenable(),
        builder: (context, box, _) {
          User? currentUser = box.get('user');
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
              title: Text(tr("profile.profile"),
                  style: const TextStyle(color: Colors.black)),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
                            child: FormBuilder(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormBuilderTextField(
                                    name: 'name',
                                    initialValue: currentUser?.name ?? '',
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(
                                          errorText:
                                              tr('profile.requiredField'))
                                    ]),
                                    style: const TextStyle(fontSize: 20),
                                    decoration: InputDecoration(
                                      labelText: tr("profile.name"),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20),
                                      fillColor: AppColors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  FormBuilderDateTimePicker(
                                    name: 'birth',
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
                                    initialValue: currentUser?.birth != null
                                        ? DateTime.parse(currentUser!.birth!)
                                        : null,
                                  ),
                                  const SizedBox(height: 20),
                                  FormBuilderTextField(
                                    name: 'email',
                                    initialValue: currentUser?.email ?? '',
                                    style: const TextStyle(fontSize: 20),
                                    decoration: InputDecoration(
                                      labelText: tr('profile.email'),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tr('profile.phone'),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              currentUser?.phone ?? '',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: CircularProgressIndicator(
                                color: AppColors.mainColor,
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: n.NikuButton.elevated(
                              Text(
                                tr('profile.deleteProfile'),
                                style: const TextStyle(fontSize: 20),
                              ),
                            )
                              ..bg = Colors.white
                              ..border = const BorderSide(
                                  color: AppColors.mainColor, width: 2)
                              ..color = AppColors.mainColor
                              ..rounded = 20
                              ..py = 20
                              ..my = 10
                              ..onPressed = isLoading
                                  ? null
                                  : () => _handleDelete(currentUser!),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: n.NikuButton.elevated(
                              Text(
                                tr('save'),
                                style: const TextStyle(fontSize: 20),
                              ),
                            )
                              ..bg = AppColors.mainColor
                              ..color = Colors.white
                              ..rounded = 20
                              ..py = 20
                              ..my = 10
                              ..onPressed = isLoading
                                  ? null
                                  : () => _handleSave(currentUser!),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
