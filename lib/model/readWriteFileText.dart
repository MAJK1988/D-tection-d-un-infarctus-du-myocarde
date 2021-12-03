import 'dart:io';
import 'package:file_txt_database/plotingProssecing/plotECGPeakR.dart';
import 'package:path_provider/path_provider.dart';
import 'EcgFile.dart';

Future<String> read(String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    String text = await file.readAsString();

    return text;
  } catch (e) {
    print("Couldn't read file");
    return '';
  }
}
/*---------------------------------------------------------------------------- */

Future<bool> testExistenceFile(String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName').exists();
  } catch (e) {
    print("Couldn't read file");
    return false;
  }
}
/*---------------------------------------------------------------------------- */

Future<bool> save(String data, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  String dataOld = '';
  try {
    dataOld = await file.readAsString();
  } on Exception catch (_) {
    print('not existing file');
  }

  data = dataOld + data;
  try {
    await file.writeAsString(data);
    print('saved');
    return true;
  } on Exception catch (_) {
    return false;
  }
}
/*---------------------------------------------------------------------------- */

Future<bool> cleanFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');

  try {
    await file.writeAsString('');
    return true;
  } on Exception catch (_) {
    return false;
  }
}
/*---------------------------------------------------------------------------- */

Future<bool> ECGToFileText(List<EcgFile> ecgs, String fileName) async {
  String ecgString = '';

  for (int i = 0; i < ecgs.length; i++) {
    ecgString = ecgString +
        '[${ecgs[i].name}, ${ecgs[i].date},${ecgs[i].length},${ecgs[i].state}]';
  }

  return save(ecgString, fileName);
}
/*---------------------------------------------------------------------------- */

Future<List<EcgFile>> filetextToECG(String fileName) async {
  String data = await read(fileName);
  List<EcgFile> ecgs = [];
  String getData = '';
  int flag = 0;
  String name = '', date = '';
  double length = 0;
  bool state;

  for (var i = 0; i < data.length; i++) {
    if (data[i] == '[') {
      flag = 0;
    }
    if (data[i] == ',') {
      if (flag == 0) {
        name = getData;
      }
      if (flag == 1) {
        date = getData;
      }
      if (flag == 2) {
        length = double.parse(getData);
      }

      flag++;
      getData = '';
    }
    if ((flag == 3) & (data[i] == ']')) {
      state = getData == 'true';
      ecgs.add(
          new EcgFile(name: name, date: date, length: length, state: state));
      getData = '';
    }
    if ((data[i] != '[') & (data[i] != ']') & (data[i] != ',')) {
      getData = getData + data[i];
    }
  }
  return ecgs;
}
/*---------------------------------------------------------------------------- */

List<ECG> getECGSignal(List<double> ecg, double fs) {
  List<ECG> outputECG = [];

  for (int i = 0; i < ecg.length; i++) {
    outputECG.add(new ECG(i * (1 / fs), ecg[i]));
  }
  return outputECG;
}
/*---------------------------------------------------------------------------- */

Future<bool> eCGSignalToFile(
    List<double> ecg, double fs, String fileName, String key) async {
  // key=e => ECGSignal
  // key=r => R peak signal
  // key=i => R peak signal inter
  String data = '$key{';
  for (int i = 0; i < ecg.length; i++) {
    data = data + '[${(i * (1 / fs)).toString()},${(ecg[i]).toString()}]';
  }
  data = data + '}';
  return save(data, fileName);
}
/*---------------------------------------------------------------------------- */

Future<bool> ECGSpectralToFile(
    List<ECG> ecg, String fileName, String key) async {
  // key=s=>rPeakSpect
  // key=t=>ECG Spect
  String data = '$key{';
  for (int i = 0; i < ecg.length; i++) {
    data = data + '[${ecg[i].time.toString()},${(ecg[i]).power.toString()}]';
  }
  data = data + '}';
  return save(data, fileName);
}
/*---------------------------------------------------------------------------- */

List<ECG> getRPeakPosition(List<double> ecg, double fs, List<int> rPeak) {
  List<ECG> outputECG = [];
  for (int i = 0; i < rPeak.length; i++) {
    outputECG.add(new ECG(rPeak[i] * (1 / fs), ecg[rPeak[i]]));
  }
  return outputECG;
}

List<ECG> getRpeakInter(List rPeak) {
  List<ECG> outputECG = [];
  List<double> t = rPeak[1];
  List<double> power = rPeak[0];

  for (int i = 0; i < rPeak.length; i++) {
    outputECG.add(new ECG(t[i], power[i]));
  }
  return outputECG;
}

/*---------------------------------------------------------------------------- */
Future<List> filetextToECGSignal(String fileName) async {
  // key=e => ECGSignal
  // key=r => R peak signal
  // key=i => R peak signal inter
  //  key=s=>rPeakSpect
  // key=t=>ECG Spect

  String data = await read(fileName);

  List<ECG> outECG = [];
  List<ECG> outRpeak = [];
  List<ECG> outRpeakInter = [];
  List<ECG> outRpeakSpec = [];

  List<ECG> outECGSpec = [];
  String signal_type = data[0];
  int getType = 0; //0=>time. 1=>power
  String time = '', power = '';
  for (int i = 1; i < data.length; i++) {
    if (data[i] == '}') {
      signal_type = '';
      //outRpeakSpec
      getType = 0;
      time = '';
      power = '';
    }
    if (data[i] == '{') {
      signal_type = data[i - 1];
      time = '';
      power = '';
      getType = 0;
    }
    if (signal_type != '') {
      if ((data[i] != ',') &
          (data[i] != '[') &
          (data[i] != ']') &
          (data[i] != '{') &
          (data[i] != '}')) {
        if (getType == 0) {
          time = time + data[i];
        } else {
          power = power + data[i];
        }
      }
      if (data[i] == ',') {
        getType = 1;
      }
      if (data[i] == ']') {
        if (signal_type == 'e') {
          outECG.add(new ECG(double.parse(time), double.parse(power)));
        } else if (signal_type == 'r') {
          outRpeak.add(new ECG(double.parse(time), double.parse(power)));
        } else if (signal_type == 'i') {
          outRpeakInter.add(new ECG(double.parse(time), double.parse(power)));
        } else if (signal_type == 's') {
          outRpeakSpec.add(new ECG(double.parse(time), double.parse(power)));
        } else if (signal_type == 't') {
          outECGSpec.add(new ECG(double.parse(time), double.parse(power)));
        }

        //outRpeakSpec
        getType = 0;
        time = '';
        power = '';
      }
    }
  }

  return [outECG, outRpeak, outRpeakInter, outRpeakSpec, outECGSpec];
}

/*----------------------------------------------------------------------------- */
Future<List<ECG>> filetextToECGSignalUnique(String fileName) async {
  String data = await read(fileName);

  List<ECG> outECG = [];
  int getType = 0; //0=>time. 1=>power
  String time = '', power = '';
  for (int i = 1; i < data.length; i++) {
    if ((data[i] != ',') &
        (data[i] != '[') &
        (data[i] != ']') &
        (data[i] != '{') &
        (data[i] != '}')) {
      if (getType == 0) {
        time = time + data[i];
      } else {
        power = power + data[i];
      }
    }
    if (data[i] == ',') {
      getType = 1;
    }
    if (data[i] == ']') {
      outECG.add(new ECG(double.parse(time), double.parse(power)));
      getType = 0;
      time = '';
      power = '';
    }
  }

  return outECG;
}
