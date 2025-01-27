import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:hive/hive.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../utils/random.dart';
import 'creditCardOtp.dart';

@RoutePage()
class CreditCardPage extends StatefulWidget {
  const CreditCardPage({super.key});

  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  String cardNumber = '';
  String expiryDate = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoadingAddCard = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_onCardNumberChanged);
    _expiryController.addListener(_onExpiryChanged);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged() {
    var text = _cardNumberController.text.replaceAll(' ', '');
    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    final newString = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        newString.write(' ');
      }
      newString.write(text[i]);
    }

    if (_cardNumberController.text != newString.toString()) {
      _cardNumberController.text = newString.toString();
      _cardNumberController.selection = TextSelection.fromPosition(
        TextPosition(offset: _cardNumberController.text.length),
      );
    }
    setState(() {
      cardNumber = text;
    });
  }

  void _onExpiryChanged() {
    var text = _expiryController.text.replaceAll('/', '');
    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    final newString = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) newString.write('/');
      newString.write(text[i]);
    }

    if (_expiryController.text != newString.toString()) {
      _expiryController.text = newString.toString();
      _expiryController.selection = TextSelection.fromPosition(
        TextPosition(offset: _expiryController.text.length),
      );
    }
    setState(() {
      expiryDate = _expiryController.text;
    });
  }

  bool _validateUzbekCard(String number) {
    number = number.replaceAll(RegExp(r'\D'), '');
    if (number.length != 16) return false;
    return true;
  }

  Future<void> addCard() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!_validateUzbekCard(cardNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('cards.invalidUzbekCard')),
          backgroundColor: AppColors.mainColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingAddCard = true;
    });

    try {
      final Box<User> userBox = Hive.box<User>('user');
      final User? currentUser = userBox.get('user');

      final buff = utf8.encode('X79PC6D4bKzW');
      final base64data = base64.encode(buff);
      final randomString = randomAlphaNumeric(6);
      final hexBuffer = utf8.encode('$randomString$base64data');
      final hexString = HEX.encode(hexBuffer);

      if (currentUser != null) {
        Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${currentUser.userToken}',
          'X-OTP-TOKEN': hexString
        };

        var url = Uri.https('api.lesailes.uz', 'api/payment_cards');
        var arExpireDate = expiryDate.split('/');
        var formattedExpiryDate = '${arExpireDate[1]}${arExpireDate[0]}';

        var response = await http.post(url,
            headers: requestHeaders,
            body: jsonEncode({
              'cardNumber': cardNumber.replaceAll(' ', ''),
              'validity': formattedExpiryDate,
              'locale': context.locale.languageCode
            }));

        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);

          if (json['success']) {
            if (mounted) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return CreditCardOtpPage();
              }));
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    json['message'],
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: AppColors.mainColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        } else {
          var json = jsonDecode(response.body);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(json['message']),
                backgroundColor: AppColors.mainColor,
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddCard = false;
        });
      }
    }
  }

  InputDecoration _getInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[50],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.mainColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
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
          onPressed: () => context.back(),
        ),
        title: Text(tr("addCard"),
            style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: _getInputDecoration(
                      tr('cardNumber'), 'xxxx xxxx xxxx xxxx'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    CardNumberInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('cards.enterCardNumber');
                    }
                    String cleanNumber = value.replaceAll(RegExp(r'\D'), '');
                    if (cleanNumber.length != 16) {
                      return tr('cards.invalidCardLength');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _expiryController,
                  decoration: _getInputDecoration(tr('expireDate'), 'MM/YY'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    ExpiryDateInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('cards.enterExpiryDate');
                    }
                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                      return tr('cards.invalidExpiryFormat');
                    }
                    List<String> parts = value.split('/');
                    int month = int.parse(parts[0]);
                    if (month < 1 || month > 12) {
                      return tr('cards.invalidMonth');
                    }
                    // Проверка года
                    int year = int.parse(parts[1]);
                    int currentYear = DateTime.now().year % 100;
                    if (year < currentYear) {
                      return tr('cards.expiredCard');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoadingAddCard ? null : addCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoadingAddCard
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            tr('cards.continue'),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      // Добавляем первую цифру месяца
      if (i == 0 && int.parse(text[i]) > 1) {
        buffer.write('0');
        buffer.write(text[i]);
        if (text.length > 1) buffer.write('/');
      }
      // Добавляем вторую цифру месяца
      else if (i == 1) {
        if (int.parse(text[0]) == 1 && int.parse(text[1]) > 2) {
          buffer.write('2');
        } else {
          buffer.write(text[i]);
        }
        buffer.write('/');
      }
      // Добавляем остальные цифры
      else if (i > 1) {
        buffer.write(text[i]);
      } else {
        buffer.write(text[i]);
        if (i == 1) {
          buffer.write('/');
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}
