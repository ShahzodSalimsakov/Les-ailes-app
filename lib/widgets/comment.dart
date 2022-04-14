import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';

import '../models/delivery_notes.dart';

class OrderCommentWidget extends HookWidget {
  const OrderCommentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 20, bottom: 60, right: 5, left: 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           Text(
            tr("commentToOrder"),
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            maxLines: 4,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(23),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              hintText: tr("comment"),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onChanged: (value) {
              DeliveryNotes deliveryNotes = DeliveryNotes();
              deliveryNotes.deliveryNotes = value;
              Hive.box<DeliveryNotes>('deliveryNotes')
                  .put('deliveryNotes', deliveryNotes);
            },
            scrollPadding: const EdgeInsets.only(bottom: 200),
          )
        ]));
  }
}
