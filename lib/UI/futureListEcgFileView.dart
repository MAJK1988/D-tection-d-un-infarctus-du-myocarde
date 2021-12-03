import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:file_txt_database/model/EcgFile.dart';
import 'package:file_txt_database/model/readWriteFileText.dart';
import 'package:file_txt_database/UI/ecgSignalView.dart';

// ignore: must_be_immutable
class FutureListEcgFileView extends StatefulWidget {
  String fileName;
  FutureListEcgFileView({@required this.fileName});
  @override
  StateFutureListEcgFileView createState() => StateFutureListEcgFileView();
}

class StateFutureListEcgFileView extends State<FutureListEcgFileView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EcgFile>>(
        future: filetextToECG(widget.fileName),
        builder: (context, AsyncSnapshot<List<EcgFile>> snapshot) {
          if (snapshot.hasData) {
            var ecgFile = snapshot.data;
            return ListView.builder(
              itemCount: ecgFile.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 6),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Card(
                  // onTap: () => print('hello'),
                  child: EcgSignalView(
                      name: ecgFile[index].name,
                      date: ecgFile[index].date,
                      length: ecgFile[index].length,
                      state: ecgFile[index].state),
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
