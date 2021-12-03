import 'package:file_txt_database/plotingProssecing/ECGSignal.dart';
import 'package:file_txt_database/plotingProssecing/dspcode.dart';
import 'package:file_txt_database/plotingProssecing/plotECGPeakR.dart';
import 'package:file_txt_database/plotingProssecing/r_peak_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'EcgFile.dart';
import 'readWriteFileText.dart';

class ReadWriteFileTxt extends StatefulWidget {
  @override
  _StateReadWriteFileTxt createState() => _StateReadWriteFileTxt();
}

class _StateReadWriteFileTxt extends State<ReadWriteFileTxt> {
  TextEditingController controller = TextEditingController();

  String fileName = 'my_file.txt';
  String r = '';

  List<EcgFile> ecg = [
    EcgFile(name: '108m(5)', date: '12/3/2020', length: 10.1, state: true),
    EcgFile(name: '108m(4)', date: '12/3/2020', length: 10.1, state: true),
    EcgFile(name: '100m(0)', date: '12/3/2020', length: 10.1, state: true),
    EcgFile(name: '103m(2)', date: '12/3/2020', length: 10.1, state: true),
    EcgFile(name: '105m(1)', date: '12/3/2020', length: 10.1, state: true),
  ];

  @override
  Widget build(BuildContext context) {
    //eCGSignalToFile(
    // List<double> ecg, double fs, String fileName, String key) async {
    // key=e => ECGSignal
    // key=r => R peak signal
    // key=i => R peak signal inter
    // key=s=>rPeakSpect
    // key=t=>ECG Spect
    //
    toFile();
    //testsave();

    return Scaffold(
        appBar: AppBar(
          title: Text('Read save txt'),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Container(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Name'),
                  /*validator: (val) => val.length == 0 ? 'Enter Name' : null,
                  onSaved: (val) => setState(() {
                    print('val: $val');
                    name = val;
                  }),*/
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: RaisedButton(
                      child: Text('Read'),
                      onPressed: () async {
                        //print('data: ${await _read(fileName)}');
                        List<EcgFile> e = await filetextToECG(fileName);
                        String n = e[2].name;
                        print('data: ${n}');
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: RaisedButton(
                      child: Text('save'),
                      onPressed: () {
                        //_save(controller.text, fileName);
                        cleanFile(fileName);
                        ECGToFileText(ecg, fileName);
                      },
                    ),
                  )
                ],
              ),
            ]));
  }
}

String name = '105m(1)';
int k = 0;
void toFile() async {
  List<double> ecgSignal = []; //readECGSignal('108m8.txt');
  List<int> rPeak = [];
  List<ECG> rPeakInter = [];
  List<ECG> rPeakSpect = [];
  List<ECG> ecgSpect = [];
  List<double> rPeakInterPeak = [];
  List<ECG> rUsed = [];
  double ts = 0.2;
  ecgSignal = ECGNormalisation(ECGSignalData);
  rPeak = RPeakDetection(ecgSignal);
  rUsed = getRPeakPosition(ecgSignal, 360, rPeak);
  rPeakInter = interpolation(rPeak, 360, 0.2);
  rPeakInterPeak = interpolationPeak(rPeak, 360, ts);
  rPeakSpect = dsp(1 / ts, rPeakInterPeak);
  ecgSpect = dsp(360, ecgSignal);
  //snapshot.data=[outECG, outRpeak, outRpeakInter, outRpeakSpec, outECGSpec]
  bool t = false;
  bool clean = await cleanFile(name + 'e.txt');

  if (clean & !t & (k == 0)) {
    k++;
    t = await eCGSignalToFile(ecgSignal, 360, name + 'e.txt', 'e');
  }
  if (clean & t & (k == 1)) {
    k++;
    await ECGSpectralToFile(rUsed, name + 'e.txt', 'r');
  }

  if (await cleanFile(name + 'i.txt') & (k == 2)) {
    k++;
    await eCGSignalToFile(rPeakInterPeak, 1 / 0.2, name + 'i.txt', '');
  }
  if (await cleanFile(name + 's.txt') & (k == 3)) {
    k++;
    await ECGSpectralToFile(rPeakSpect, name + 's.txt', '');
  }
  if (await cleanFile(name + 'f.txt') & (k == 4)) {
    k++;
    await ECGSpectralToFile(ecgSpect, name + 'f.txt', '');
  }

  /*---------------------------------------------------------------------------- */
}

void testsave() async {
  if (await testExistenceFile(name + 'e.txt')) {
    print('file exist');

    List ecgSignal = await filetextToECGSignal(name + 'e.txt');
    List<ECG> r = await filetextToECGSignalUnique(name + 'i.txt');

    //String data = await read('ecgsignal.txt');
    print(ecgSignal.length);
  } else {
    print('not exist');
  }
}
