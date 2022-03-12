import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class WayToReceiveAnOrder extends StatelessWidget {
  const WayToReceiveAnOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 220,
            child: Text(
              tr("main.deliveryOrPickup"),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Image.asset("images/rocket.png")
        ]),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: AppColors.green),
        height: 75,
        width: double.infinity,
      ),
      onTap: () {
        showBarModalBottomSheet(
            expand: false,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 37),
                      child: Text(tr("deliveryOrPickup.chooseType"),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500)),
                    ),
                    GridView.count(
                      padding: const EdgeInsets.only(
                        top: 0,
                        bottom: 70,
                        left: 16,
                        right: 16,
                      ),
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 164,
                            height: 164,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              color: AppColors.grey,
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('images/car.png',
                                      height: 92, width: 92),
                                  const SizedBox(height: 36),
                                  Text(
                                    tr("deliveryOrPickup.delivery"),
                                    style: const TextStyle(fontSize: 20),
                                  )
                                ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 164,
                            height: 164,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              color: AppColors.grey,
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('images/bag.png',
                                      height: 92, width: 92),
                                  const SizedBox(height: 36),
                                  Text(
                                    tr("deliveryOrPickup.takeAway"),
                                    style: const TextStyle(fontSize: 20),
                                  )
                                ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 164,
                            height: 164,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              color: AppColors.grey,
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('images/inrestourant.png',
                                      height: 92, width: 92),
                                  const SizedBox(height: 36),
                                  Text(
                                    tr("deliveryOrPickup.AtTheRestaurant"),
                                    style: const TextStyle(fontSize: 20),
                                  )
                                ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 164,
                            height: 164,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              color: AppColors.grey,
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('images/parking.png',
                                      height: 92, width: 92),
                                  const SizedBox(height: 36),
                                  Text(
                                    tr("deliveryOrPickup.toTheParkingLot"),
                                    style: const TextStyle(fontSize: 20),
                                  )
                                ]),
                          ),
                        )
                      ],
                      shrinkWrap: true,
                    ),
                  ],
                ));
      },
    );
  }
}
