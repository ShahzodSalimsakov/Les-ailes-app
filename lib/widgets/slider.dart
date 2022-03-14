import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:les_ailes/utils/colors.dart';
import 'dart:convert';
import '../models/mainSlider.dart';

class SliderCarousel extends HookWidget {
  final CarouselController _controller = CarouselController();

  SliderCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _current = useState<int>(0);
    final banner = useState<List<SalesBanner>>(List<SalesBanner>.empty());

    Future<void> getSalesBanner() async {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      };
      var url =
          Uri.https('api.lesailes.uz', '/api/sliders/public', {'locale': 'ru'});
      var response = await http.get(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<SalesBanner> bannerList = List<SalesBanner>.from(
            json['data'].map((b) => SalesBanner.fromJson(b)).toList());
        banner.value = bannerList;
      }
    }

    useEffect(() {
      getSalesBanner();
    }, []);

    return Column(children: [
      CarouselSlider(
        items: banner.value.map((SalesBanner slide) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                height: 240,
                margin: const EdgeInsets.only(top: 40),
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(
                            (slide.asset[1] != null
                                ? slide.asset[1].link
                                : slide.asset[0].link),
                            fit: BoxFit.cover,
                            width: 1000.0),
                      ],
                    )),
              );
            },
          );
        }).toList(),
        carouselController: _controller,
        options: CarouselOptions(
            height: 220,
            viewportFraction: 1.0,
            autoPlay: true,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              _current.value = index;
            }),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: banner.value.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 8,
              height: 8,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.green)
                      .withOpacity(_current.value == entry.key ? 0.9 : 0.2)),
            ),
          );
        }).toList(),
      ),
    ]);
  }
}
