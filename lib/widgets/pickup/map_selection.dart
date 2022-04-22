import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:les_ailes/utils/colors.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:niku/niku.dart' as n;

class MapSelection extends StatelessWidget {
  final latitude;
  final longitude;
  final desc;

  const MapSelection(
      {Key? key, required this.latitude, required this.longitude, required this.desc})
      : super(key: key);

  openMapsSheet(context) async {
    try {
      final coords = Coords(latitude, longitude);
      final title = desc;
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                        ),
                        title: Text(map.mapName),
                        leading: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Builder(
      builder: (context) {
        return n.NikuButton(Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.route,
              color: AppColors.plum,
            ),
            const SizedBox(
              width: 15,
            ),
            n.NikuText(
              tr('pickup.showRoute'),
              style: n.NikuTextStyle(color: AppColors.plum, fontSize: 20),
            )
          ],
        ))
          ..onPressed = () {
            openMapsSheet(context);
          };
      },
    ));
  }
}
