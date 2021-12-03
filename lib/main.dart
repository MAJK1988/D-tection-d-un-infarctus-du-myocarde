import 'package:file_txt_database/ecgList.dart';

import 'package:file_txt_database/model/readWrite.dart';
import 'package:file_txt_database/plotingProssecing/plot_prossecing_ECG.dart';
import 'package:flutter/material.dart';

//import 'model/readWrite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Myocardial infarction',
      // initialRoute: '/',
      /*routes: {
        '/': (context) => EcgList(),
        '/plot': (context) => PlotProssecing(), //ReadWriteFileTxt(),
      },*/
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: EcgList(), //PlotProssecing(), //  ReadWriteFileTxt(),
    );
  }
}
