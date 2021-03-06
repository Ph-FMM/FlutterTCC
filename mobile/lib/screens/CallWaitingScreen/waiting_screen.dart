import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:SOS_Brasil/controllers/notification_controller.dart';
import 'package:SOS_Brasil/controllers/call_controller.dart';

import 'package:SOS_Brasil/models/call.dart';

import 'package:SOS_Brasil/screens/CallTrackingScreen/call_tracking_screen.dart';

final storage = new FlutterSecureStorage();

class WaitingScreen extends StatefulWidget {
  final Call call;
  final Color color;
  final String url;

  const WaitingScreen({Key key, this.call, this.color, this.url})
      : super(key: key);

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  Call call;
  String token;
  String stringfiedCall;

  String bgImg = "assets/images/ambulancia_car.png";
  String service = "ambulance";

  String _status = "Conectando ao servidor...";

  IO.Socket socket;

  @override
  void initState() {
    call = widget.call;

    _sendData();

    print(widget.color);

    if (widget.color == Color(0xffef5350)) {
      bgImg = "assets/images/ambulancia_car.png";
      service = "ambulance";
    } else if (widget.color == Color(0xffff7043)) {
      bgImg = "assets/images/bombeiro_car.png";
      service = "fireman";
    } else {
      bgImg = "assets/images/police_car.png";
      service = "police";
    }

    super.initState();
  }

  _sendData() {
    //Get user token in localStorage
    storage.read(key: "token").then((value) {
      setState(() {
        token = value;
      });

      socket = IO.io(widget.url + "/user", <String, dynamic>{
        'transports': ['websocket'],
        'extraHeaders': {'token': token}
      });
      socket.connect();

      socket.on("change_call_status", (status) {
        NotificationController.cancellAll();
        NotificationController.showStatusNotification(status);
      });

      socket.on("connect", (_) {
        if (_status != "Solicitação enviada com sucesso" &&
            _status != "Tempo limite de conexão atingido" &&
            _status != "Erro ao conectar ao servidor") {
          setState(() {
            _status = "Enviando o chamado...";
          });
        }
        print("conectou");
      });

      socket.on("connect_error", (data) {
        setState(() {
          _status = "Erro ao conectar ao servidor";
        });
      });

      socket.on("connect_timeout", (data) {
        setState(() {
          _status = "Erro ao conectar ao servidor";
        });
      });

      socket.on("connecting", (_) => print("conectando"));

      // Send data to the server
      CallController.create(call, value, widget.url).then((returnedCall) {
        if (returnedCall.isNotEmpty) {
          NotificationController.showSendNotification();
          setState(() {
            _status = "Solicitação enviada com sucesso";
            call = callFromJson(returnedCall);
          });
          socket.emit("create_call", returnedCall);
        } else {
          _status = "Tempo limite de conexão atingido";
        }
      });
    });
  }

  _trackCall() {
    // CustomSnackbar.showBuildInProgress(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallTrackingScreen(
          color: widget.color,
          service: service,
          call: call,
        ),
      ),
    );
  }

  @override
  void dispose() async {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Stack(
            children: [
              buildImage(),
              buildLog(context),
            ],
          ),
        ),
      ),
    );
  }

  Positioned buildLog(BuildContext context) {
    return Positioned(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: 270,
                height: 50,
                child: FlatButton(
                  onPressed: _trackCall,
                  child: Text(
                    "Acompanhar solicitação",
                    style: TextStyle(fontSize: 16),
                  ),
                  color: widget.color,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Positioned buildImage() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Image.asset(bgImg),
        ),
      ),
    );
  }
}
