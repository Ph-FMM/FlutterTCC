import 'package:flutter/material.dart';
import 'package:mobile/components/backdrop_close_bar.dart';
import 'package:mobile/components/custom_bottombar.dart';
import 'package:mobile/components/custom_fab.dart';
import 'package:mobile/models/service.dart';
import 'package:mobile/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/screens/HomeScreen/components/card/service_card.dart';
import 'package:mobile/screens/HomeScreen/components/custom_appbar.dart';
import 'package:mobile/screens/HomeScreen/components/user/user_screen.dart';
import 'package:mobile/screens/SosScreen/sos_screen.dart';
import 'package:mobile/utils/numbers_list.dart';
import 'package:mobile/utils/service_list.dart';
import 'package:url_launcher/url_launcher.dart';

// Create storage
final storage = new FlutterSecureStorage();

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<Service> services = getServiceList();

  User user;

  bool _isSOSActive = false;

  @override
  void initState() {
    super.initState();

    storage.read(key: "user").then((value) {
      setState(() {
        user = userFromJson(value);
      });
    });
  }

  toggleBackdrop() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[900], Colors.indigo[500]],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: <Widget>[
            CloseBar(),
            SizedBox(height: 10),
            Text(
              "Números de Emergência",
              style: TextStyle(
                fontSize: 25,
                color: Colors.grey[200],
              ),
            ),
            SizedBox(height: 50),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => ListTile(
                    onTap: () async {
                      String number = "tel: ${phonelist[index].number}";

                      if (await canLaunch(number)) {
                        await launch(number);
                      } else {
                        throw 'Could not launch $number';
                      }

                      print(number);
                    },
                    leading: Text(
                      phonelist[index].name,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[200],
                      ),
                    ),
                    trailing: Text(
                      phonelist[index].number,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) => SizedBox(height: 18),
                  itemCount: phonelist.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: CustomAppBar(
            appBar: AppBar(),
            context: context,
            user: user,
          ),
          body: buildContainer(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: CustomFAB(),
          bottomNavigationBar: CustomBottomBar(showPhone: toggleBackdrop),
        ),
        _isSOSActive ? Positioned(child: SOSScreen()) : SizedBox()
      ],
    );
  }

  Container buildContainer() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
        child: Column(
          children: <Widget>[
            ServiceCard(service: services[0]),
            SizedBox(height: 10),
            ServiceCard(service: services[1]),
            SizedBox(height: 10),
            ServiceCard(service: services[2]),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}