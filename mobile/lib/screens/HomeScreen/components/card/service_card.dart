import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mobile/animations/transitions.dart';
import 'package:mobile/components/snackbar.dart';
import 'package:mobile/models/service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/screens/ServiceScreen/service_dialog.dart';
import 'package:mobile/screens/ServiceScreen/service_screen.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, double> location;
  final Service service;
  final bool hasInternet;
  final BuildContext context;

  const ServiceCard(
      {Key key, this.service, this.hasInternet, this.context, this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        return ServiceDialog().showServiceDialog(context, service, location);
      },
      child: Stack(
        children: <Widget>[
          buildCard(context),
          buildCardName(context),
          buildCardImage(),
        ],
      ),
    );
  }

  Container buildCard(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 4.8,
      decoration: buildBoxDecoration(),
    );
  }

  Positioned buildCardName(BuildContext context) {
    return Positioned(
      right: 20,
      top: 15,
      child: Container(
        width: MediaQuery.of(context).size.height / 4.8,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 1,
            color: Colors.white.withOpacity(.85),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            service.name,
            style: TextStyle(
              color: Colors.white.withOpacity(.85),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Positioned buildCardImage() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: SvgPicture.asset(
            service.imageUrl,
            height: 90,
          ),
        ),
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      color: service.color,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 6,
          offset: Offset(0, 3),
        )
      ],
    );
  }
}
