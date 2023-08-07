import 'dart:math';
import 'package:card_scanner/card_scanner.dart';
import 'package:flutter/material.dart';

class OptionConfigureWidget extends StatefulWidget {
  final void Function(CardScanOptions scanOptions) onScanOptionChanged;
  final CardScanOptions initialOptions;

  const OptionConfigureWidget(
      {required this.onScanOptionChanged, required this.initialOptions});

  @override
  _OptionConfigureWidgetState createState() => _OptionConfigureWidgetState();
}

class _OptionConfigureWidgetState extends State<OptionConfigureWidget> {
  bool scanExpiryDate = true;
  bool scanCardHolderName = true;

  int initialScansToDrop = 1;
  int validCardsToScanBeforeFinishingScan = 6;
  List<String> cardHolderNameBlackListedWords = [];

  bool considerPastDatesInExpiryDateScan = false;

  int maxCardHolderNameLength = 26;

  bool enableLuhnCheck = true;

  int cardScannerTimeOut = 0;

  bool enableDebugLogs = false;

  Set<CardHolderNameScanPosition> possibleCardHolderNamePositions = {
    CardHolderNameScanPosition.belowCardNumber
  };

  @override
  void initState() {
    if (widget.initialOptions != null) {
      final options = widget.initialOptions;
      scanExpiryDate = options.scanExpiryDate;
      scanCardHolderName = options.scanCardHolderName;
      initialScansToDrop = options.initialScansToDrop;
      validCardsToScanBeforeFinishingScan =
          options.validCardsToScanBeforeFinishingScan;
      cardHolderNameBlackListedWords = options.cardHolderNameBlackListedWords;
      considerPastDatesInExpiryDateScan =
          options.considerPastDatesInExpiryDateScan;
      maxCardHolderNameLength = options.maxCardHolderNameLength;
      enableLuhnCheck = options.enableLuhnCheck;
      cardScannerTimeOut = options.cardScannerTimeOut;
      enableDebugLogs = options.enableDebugLogs;
      possibleCardHolderNamePositions =
          options.possibleCardHolderNamePositions.toSet();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildCheckBox('enable Luhn Check', enableLuhnCheck,
              (newValue) => enableLuhnCheck = newValue),
          buildCheckBox('scan expiry date', scanExpiryDate,
              (newValue) => scanExpiryDate = newValue),
          buildCheckBox('scan card holder name', scanCardHolderName,
              (newValue) => scanCardHolderName = newValue),
          buildCheckBox(
              'consider past dates in expiry scan',
              considerPastDatesInExpiryDateScan,
              (newValue) => considerPastDatesInExpiryDateScan = newValue),
          buildCheckBox('enable debug logs', enableDebugLogs,
              (newValue) => enableDebugLogs = newValue),
          buildIntegerEditWidget(
              'min frames to scan before finish',
              validCardsToScanBeforeFinishingScan,
              (newValue) => validCardsToScanBeforeFinishingScan = newValue),
          buildIntegerEditWidget(
              'max card holder name length',
              maxCardHolderNameLength,
              (newValue) => maxCardHolderNameLength = newValue),
          buildIntegerEditWidget('scanner timeout seconds (0 = infinite)',
              cardScannerTimeOut, (newValue) => cardScannerTimeOut = newValue),
          buildCheckBox(
              'expect card holder ABOVE card number',
              possibleCardHolderNamePositions.contains(
                  CardHolderNameScanPosition.aboveCardNumber), (newValue) {
            if (newValue == true) {
              possibleCardHolderNamePositions
                  .add(CardHolderNameScanPosition.aboveCardNumber);
            } else {
              possibleCardHolderNamePositions
                  .remove(CardHolderNameScanPosition.aboveCardNumber);
            }
            setState(() {});
          }),
          buildCheckBox(
              'expect card holder BELOW card number',
              possibleCardHolderNamePositions.contains(
                  CardHolderNameScanPosition.belowCardNumber), (newValue) {
            if (newValue == true) {
              possibleCardHolderNamePositions
                  .add(CardHolderNameScanPosition.belowCardNumber);
            } else {
              possibleCardHolderNamePositions
                  .remove(CardHolderNameScanPosition.belowCardNumber);
            }
            setState(() {});
          }),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('black listed card holder names (comma separated)'),
                TextField(
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) =>
                      cardHolderNameBlackListedWords = value.split(','),
                  onEditingComplete: () {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCheckBox(String key, bool value, onChanged) {
    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(key),
            Checkbox(
                onChanged: (newValue) {
                  onChanged?.call(newValue);
                  setState(() {});
                },
                value: value),
          ],
        ),
      ],
    );
  }

  Widget buildIntegerEditWidget(String key, int value, onChanged) {
    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(key),
            Text(value.toString()),
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: () {
                onChanged(value + 1);
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () {
                onChanged(max(0, value - 1));
                setState(() {});
              },
            )
          ],
        ),
      ],
    );
  }

  @override
  void setState(fn) {
    widget.onScanOptionChanged(CardScanOptions(
        possibleCardHolderNamePositions:
            possibleCardHolderNamePositions.toList(),
        cardHolderNameBlackListedWords: cardHolderNameBlackListedWords,
        enableDebugLogs: enableDebugLogs,
        scanCardHolderName: scanCardHolderName,
        enableLuhnCheck: enableLuhnCheck,
        cardScannerTimeOut: cardScannerTimeOut,
        considerPastDatesInExpiryDateScan: considerPastDatesInExpiryDateScan,
        initialScansToDrop: initialScansToDrop,
        maxCardHolderNameLength: maxCardHolderNameLength,
        scanExpiryDate: scanExpiryDate,
        validCardsToScanBeforeFinishingScan:
            validCardsToScanBeforeFinishingScan));
    super.setState(fn);
  }
}
