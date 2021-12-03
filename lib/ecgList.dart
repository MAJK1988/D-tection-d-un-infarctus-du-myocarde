import 'package:file_txt_database/bluetooth/bluetooth_connect.dart';
import 'package:file_txt_database/plotingProssecing/plot_prossecing_ECG.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:date_format/date_format.dart';
import 'UI/futureListEcgFileView.dart';
import 'model/EcgFile.dart';
import 'model/readWriteFileText.dart';

class EcgList extends StatefulWidget {
  @override
  _StateEcgList createState() => _StateEcgList();
}

class _StateEcgList extends State<EcgList> {
  //Future<List<EcgFile>> ecgF;
  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Myocardial infarction"),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(bottom: 15, top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SafeArea(
                    child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'ECG Signal List',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink[50]),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BluetoothApp();
                                    },
                                  ),
                                );
                              },
                              icon:
                                  Icon(Icons.add, color: Colors.pink, size: 20),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text('Add new',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                //PlotProssecing(),
                FutureListEcgFileView(fileName: 'my_file.txt'),
              ],
            ),
          ),
        ));
  }
}
