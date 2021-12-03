import 'package:flutter/cupertino.dart';

class EcgFile {
  String name;
  String date;
  double length;
  bool state;
  EcgFile(
      {@required this.name,
      @required this.date,
      @required this.length,
      @required this.state});
}
