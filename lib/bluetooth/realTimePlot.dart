import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:file_txt_database/plotingProssecing/plotECGPeakR.dart';

class RealTimePlot extends StatefulWidget {
  List<ECG> ecg;
  String title;
  bool zooming;
  RealTimePlot(
      {@required this.ecg, @required this.title, @required this.zooming});
  @override
  _RealTimePlot createState() => _RealTimePlot();
}

class _RealTimePlot extends State<RealTimePlot> {
  ZoomPanBehavior _zoomPanBehavior;
  TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    // Enables pinch zooming
    _zoomPanBehavior = ZoomPanBehavior(
        enablePinching: true, zoomMode: ZoomMode.x, enablePanning: true);
    // Formatting trackball tooltip text
    _tooltipBehavior = TooltipBehavior(enable: true);

    super.initState();
    // you can use this.widget.foo here
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SfCartesianChart(
            zoomPanBehavior: widget.zooming ? _zoomPanBehavior : null,
            //primaryXAxis:
            //  widget.zooming ? NumericAxis(visibleMaximum: .15) : null,
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
            ),
            series: <ChartSeries>[
              LineSeries<ECG, double>(
                name: widget.title,
                dataSource: widget.ecg,
                xValueMapper: (ECG ecg, _) => ecg.time,
                yValueMapper: (ECG ecg, _) => ecg.power,
              ),
            ]));
  }
}
