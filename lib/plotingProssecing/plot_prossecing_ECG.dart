import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'plotECGPeakR.dart';

class PlotProssecing extends StatefulWidget {
  final String fileName;
  PlotProssecing({@required this.fileName});
  @override
  _StatelPotProssecing createState() => _StatelPotProssecing();
}

class _StatelPotProssecing extends State<PlotProssecing> {
  ZoomPanBehavior _zoomPanBehavior;
  List<double> ecgSignal = []; //readECGSignal('108m8.txt');
  List<int> rPeak = [];
  List<ECG> rPeakInter = [];
  List<ECG> rPeakSpect = [];
  List<ECG> ecgSpect = [];
  List<double> rPeakInterPeak = [];

  @override
  void initState() {
    //rPeakSpect=dsp(360, );

    _zoomPanBehavior = ZoomPanBehavior(
        // Performs zooming on double tap
        enablePinching: true,
        zoomMode: ZoomMode.x,
        enablePanning: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*double ts = 0.2;
    ecgSignal = ECGNormalisation(ECGSignalData);
    rPeak = RPeakDetection(ecgSignal);
    rPeakInter = interpolation(rPeak, 360, 0.2);
    rPeakInterPeak = interpolationPeak(rPeak, 360, ts);
    rPeakSpect = dsp(1 / ts, rPeakInterPeak);
    ecgSpect = dsp(360, ecgSignal);*/
    return Scaffold(
        appBar: AppBar(
          title: Text("ECG Signals"),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            //snapshot.data=[outECG, outRpeak, outRpeakInter, outRpeakSpec, outECGSpec]
            //300, 'ECG', 'R Peak', 2, 'outECG.txt'
            Padding(
                padding: EdgeInsets.all(10),
                child: SafeArea(
                    child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.lightBlue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: 300,
                  child: PlotECGPeakR(
                      height: 300,
                      figNumber: 2,
                      fileName: widget.fileName + 'e.txt',
                      title1: 'ECG',
                      title2: 'R Peak'),
                ))),

            Container(
              height: 200.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: SafeArea(
                          child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 200,
                        child: PlotECGPeakR(
                            height: 200,
                            title1: 'Heart rate',
                            title2: '',
                            figNumber: 1,
                            fileName: widget.fileName + 'i.txt'),
                      ))),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: SafeArea(
                          child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 200,
                        child: PlotECGPeakR(
                            height: 200,
                            title1: 'Power spectral Heart rate',
                            title2: '',
                            fileName: widget.fileName + 's.txt',
                            figNumber: 1),
                      ))),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: SafeArea(
                          child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 200,
                        child: PlotECGPeakR(
                            height: 200,
                            title1: 'Power spectral ECG',
                            title2: '',
                            figNumber: 1,
                            fileName: widget.fileName + 'f.txt'),
                      )))
                ],
              ),
            )
          ],
        ));

    /**/
  }
}
