import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:typed_data';
import 'package:file_txt_database/bluetooth/realTimePlot.dart';
import 'package:file_txt_database/plotingProssecing/plotECGPeakR.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'bluetooth_connect.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PlotPage extends StatefulWidget {
  final BluetoothDevice server;

  const PlotPage({this.server});

  @override
  StateChatPage createState() => new StateChatPage();
}

class StateChatPage extends State<PlotPage> {
  List<ECG> ecgSignal = [];
  List<ECG> instantaneousECGSignal = [];
  static final clientID = 0;
  BluetoothConnection connection;

  double _progress = 0;

  double startTimer() {
    new Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          if (_progress == 1) {
            timer.cancel();
          } else {
            _progress = ecgSignal.length / 1200;
          }
          return _progress;
        },
      ),
    );
  }

  String _messageBuffer = '';
  String instanteMessage = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  String keyText = 'MK';
  bool getData = false;
  bool allDataSended = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      show('Cannot connect, exception occured');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return BluetoothApp();
          },
        ),
      );

      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: (Text('ECG signal acquisition'))),
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SafeArea(
                child: getData
                    ? lienarProgress()
                    : SizedBox(
                        height: 1,
                      )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 24,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    isConnecting
                        ? 'Wait until connected...'
                        : isConnected
                            ? getData
                                ? 'Connected.'
                                : 'Wait until tested...'
                            : 'Chat got disconnected',
                    style: TextStyle(
                      fontWeight: getData ? FontWeight.bold : FontWeight.w200,
                      fontSize: 22,
                      fontStyle: getData ? FontStyle.italic : null,
                      color: getData ? Colors.blue : null,
                    ),
                  ),
                ),
              ],
            ),
            /*SafeArea(
                child: Padding(
                    padding: EdgeInsets.all(10), child: Text(instanteMessage))),*/
            Container(
              width: MediaQuery.of(context).size.width * .9,
              child: getData
                  ? RealTimePlot(
                      ecg: allDataSended ? ecgSignal : instantaneousECGSignal,
                      title: 'ECG Signal',
                      zooming: allDataSended,
                    )
                  : SizedBox(
                      width: 1,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // texting between arduino and flutter app
  void testRecievedMessage(String message) {
    /*message = message.replaceAll("\n", "");*/
    message = message.trim();

    bool a = (message == keyText);
    if (a) {
      print('getKey');
    }
    /*"ready"*/
    if (message == keyText) {
      allDataSended = false;
      ecgSignal = [];
      _sendMessage("data");
      getData = true;
    } else if (message == "data") {
      _sendMessage('data');
    } else if (message == "close") {
      print(ecgSignal);

      //getData = false;
      allDataSended = true;
    } else {
      //getData = false;
      //allDataSended = false;
      _sendMessage('key');
      //ecgSignal = [];
    }

    if (getData) {
      String ecgString = '';

      if (message.length > 40) {
        instantaneousECGSignal = [];
        for (int i = 0; i < message.length; i++) {
          if (message[i] != ',') {
            ecgString = ecgString + message[i];
          } else {
            ecgSignal.add(
                new ECG(ecgSignal.length * (1 / 360), double.parse(ecgString)));
            instantaneousECGSignal.add(
                new ECG(ecgSignal.length * (1 / 360), double.parse(ecgString)));

            ecgString = '';
          }
        }
      }
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        instanteMessage = backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, index);
        testRecievedMessage(instanteMessage);

        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  Widget lienarProgress() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: LinearProgressIndicator(
        backgroundColor: Colors.blue,
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
        value: startTimer(),
      ),
    );
  }
}
