import 'package:file_txt_database/plotingProssecing/plot_prossecing_ECG.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:date_format/date_format.dart';

class EcgSignalView extends StatefulWidget {
  String name;
  String date;
  double length;
  bool state;
  EcgSignalView(
      {@required this.name,
      @required this.date,
      @required this.length,
      @required this.state,
      Null Function() onTap});
  @override
  _StateEcgSignalView createState() => _StateEcgSignalView();
}

class _StateEcgSignalView extends State<EcgSignalView> {
  @override
  Widget build(BuildContext context) {
    String states = 'critical';
    if (widget.state) {
      states = 'good';
    }
    return InkWell(
        onTap: () {
          //Navigator.pushNamed(context, '/plot');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlotProssecing(fileName: widget.name)),
          );
        },
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
          child: Column(children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.favorite_border,
                  color: widget.state ? Colors.blue : Colors.red,
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.name,
                          style: TextStyle(
                              fontSize: 19,
                              color: widget.state ? Colors.blue : Colors.red,
                              fontWeight: widget.state
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          widget.date,
                          style: TextStyle(
                              color: widget.state ? Colors.blue : Colors.red,
                              fontWeight: widget.state
                                  ? FontWeight.normal
                                  : FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                Text(
                  '$states',
                  style: TextStyle(
                      color: widget.state ? Colors.blue : Colors.red,
                      fontSize: 12,
                      fontWeight:
                          widget.state ? FontWeight.normal : FontWeight.bold),
                ),
              ],
            ),
            Divider(
              color: Colors.black,
              height: 5,
            )
          ]),
        ));
  }
}
