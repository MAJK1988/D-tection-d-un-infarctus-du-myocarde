import 'dart:io';

import 'package:file_txt_database/model/readWriteFileText.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'r_peak_detection.dart';
import 'ECGSignal.dart';

class PlotECGPeakR extends StatefulWidget {
  final String title1;
  final String title2;
  final int figNumber;
  final double height;
  final String fileName;

  const PlotECGPeakR(
      {@required this.height,
      @required this.title1,
      @required this.title2,
      @required this.figNumber,
      @required this.fileName});

  @override
  _PlotECGPeakRState createState() => _PlotECGPeakRState();
}

class _PlotECGPeakRState extends State<PlotECGPeakR> {
  ZoomPanBehavior _zoomPanBehavior;
  List<double> e_cgSignal =
      ECGNormalisation(ECGSignalData); //readECGSignal('108m8.txt');
  List<int> r_Peak = RPeakDetection(ECGSignalData);
  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
        // Performs zooming on double tap
        enablePinching: true,
        zoomMode: ZoomMode.x,
        enablePanning: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: widget.figNumber == 2
            ? filetextToECGSignal(widget.fileName)
            : filetextToECGSignalUnique(widget.fileName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SfCartesianChart(
              zoomPanBehavior: _zoomPanBehavior,
              //primaryXAxis: NumericAxis(visibleMaximum: 4),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
              ),
              series: <ChartSeries>[
                LineSeries<ECG, double>(
                  name: widget.title1,
                  dataSource:
                      widget.figNumber == 2 ? snapshot.data[0] : snapshot.data,
                  xValueMapper: (ECG ecg, _) => ecg.time,
                  yValueMapper: (ECG ecg, _) => ecg.power,
                ),
                if (widget.figNumber == 2)
                  ScatterSeries<ECG, double>(
                    name: widget.title2,
                    dataSource: snapshot.data[1],
                    xValueMapper: (ECG ecg, _) => ecg.time,
                    yValueMapper: (ECG ecg, _) => ecg.power,
                  ),
              ],
            );
          } else {
            return Center(
                child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: CircularProgressIndicator(),
            ));
          }
        });
  }
}

class ECG {
  double power;
  double time;
  ECG(this.time, this.power);
}
