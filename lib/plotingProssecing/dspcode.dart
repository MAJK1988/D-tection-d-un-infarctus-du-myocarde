import 'package:powerdart/powerdart.dart' show PsdResult, psd, linspace;
import 'dart:math';
import 'package:stats_probability_utils/stats_probability_utils.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:async';
import 'plotECGPeakR.dart';

/*---------------------------------------------------------------------------- */

List<ECG> dsp(double fs, List<double> x) {
  // Compute his PSD
  var psd2 = psd(x, fs);
  List<ECG> output = [];
  List<double> f = psd2.f;
  List<double> pxx = psd2.pxx;

  for (int i = 0; i < pxx.length; i++) {
    output.add(new ECG(f[i], pxx[i]));
  }

  return output;
}
/*---------------------------------------------------------------------------- */

List<double> arrayNormalisation(List<double> inputArray) {
  double mAX;
  if (inputArray.reduce(max).abs() < inputArray.reduce(min).abs()) {
    mAX = inputArray.reduce(min).abs();
  } else {
    mAX = inputArray.reduce(max).abs();
  }
  var output = inputArray.map((e) => e / mAX).toList();
  return output;
}
/*---------------------------------------------------------------------------- */

List<int> indexGeaterThan(List<double> testArray, double thershold) {
  // ignore: unused_local_variable
  List<int> index = [];
  for (var i = 0; i < testArray.length; i++) {
    if (testArray[i] > thershold) {
      index.add(i);
    }
  }
  return index;
}
/*---------------------------------------------------------------------------- */

List<double> diffArray(List<double> inputArray) {
  List<double> diff = [0];

  for (int i = 1; i < inputArray.length; i++) {
    diff.add(inputArray[i] - inputArray[i - 1]);
  }
  return diff;
}
/*---------------------------------------------------------------------------- */

double getMean(List<double> inputArray) {
  Stats s = Stats(inputArray);
  return s.getMeanOfGroupedData();
}
/*---------------------------------------------------------------------------- */

double getStandardDeviation(List<double> inputArray) {
  Stats s = Stats(inputArray);

  return s.getStandardDeviationGrouped()[0];
}
/*---------------------------------------------------------------------------- */

List<double> highPassFilter(List<double> inputArray) {
  List<double> outputArray = linspace(0, 0, num: 13, endpoint: false);

  for (var i = 13; i < inputArray.length; i++) {
    outputArray.add((1 / 32) *
        (2 * outputArray[i - 1] -
            outputArray[i - 2] +
            inputArray[i] -
            2 * inputArray[i - 6] +
            inputArray[i - 12]));
  }
  return outputArray;
}
/*---------------------------------------------------------------------------- */

List<double> lowPassFilter(List<double> inputArray) {
  List<double> outputArray = [0, 0];
  for (var i = 2; i < (inputArray.length - 2); i++) {
    outputArray.add(0.125 *
        (-inputArray[i - 2] -
            2 * inputArray[i - 1] +
            2 * inputArray[i + 1] +
            inputArray[i + 2]));
  }
  outputArray.add(0);
  outputArray.add(0);
  return outputArray;
}
/*---------------------------------------------------------------------------- */

List<double> powerTwo(List<double> inputArray) {
  List<double> outputArray = [];
  for (var i = 0; i < inputArray.length; i++) {
    outputArray.add(inputArray[i] * inputArray[i]);
  }
  return outputArray;
}
/*---------------------------------------------------------------------------- */

List<double> excludeShift(List<double> inputArray, mean) {
  List<double> outputArray = [];
  for (var i = 0; i < inputArray.length; i++) {
    outputArray.add(inputArray[i] - mean);
  }
  return outputArray;
}

/*---------------------------------------------------------------------------- */
// Find the Documents path
Future<String> _getDirPath() async {
  final _dir = await getApplicationDocumentsDirectory();
  return _dir.path;
}

// This function is triggered when the "Read" button is pressed
Future<String> _readData(String fileName) async {
  final _dirPath = await _getDirPath();
  final _myFile = File('$_dirPath/$fileName');
  final _data = await _myFile.readAsString(encoding: utf8);
  return _data.toString();
}

List<double> readECGSignal(String path) {
  List<double> powerECG = [];
  //File f = File(path);
  String contents = path; //  _readData(path);
  print(contents);

  String data = '';
  for (var i = 1; i < contents.length; i++) {
    if (contents[i] != ',' &&
        contents[i] != ' ' &&
        contents[i] != '[' &&
        contents[i] != ']') {
      String c = contents[i];
      if (c != null) {
        data = '$data$c';
      }
    } else if (contents[i] == ',') {
      powerECG.add(double.parse(data));
      data = '';
    }

    //print(powerECG);

  }
  return powerECG;
}

/*---------------------------------------------------------------------------- */
List<int> getRpeakIndex(
    List<double> ecgSignal, List<int> index, String signalType, double fs) {
  double deltaTime = 0.75 * fs;
  List<int> rPeakIndex = [];
  List<int> rangePeak = [];
  rangePeak.add(index[0]);
  int len = index.length;

  for (var i = 1; i < len; i++) {
    if ((index[i] - index[i - 1]) > 200) {
      List<int> trueRange = indexRange(rangePeak, ecgSignal.length);
      List<double> ecgTest = setEcgTest(trueRange, ecgSignal);
      int indexMax;
      if (signalType == 'max') {
        indexMax = whereMax(ecgTest);
      } else {
        indexMax = whereMin(ecgTest);
      }
      rPeakIndex.add(trueRange[indexMax]);
      rangePeak = [];
    } else {
      rangePeak.add(index[i]);
    }
  }
  //Last range
  List<int> trueRange = indexRange(rangePeak, ecgSignal.length);
  List<double> ecgTest = setEcgTest(trueRange, ecgSignal);

  int indexMax;
  if (signalType == 'max') {
    indexMax = whereMax(ecgTest);
  } else {
    indexMax = whereMin(ecgTest);
  }
  rPeakIndex.add(trueRange[indexMax]);

  return rPeakIndex;
}
/*---------------------------------------------------------------------------- */

List<double> setEcgTest(List<int> trueRange, List<double> ecgSignal) {
  List<double> ecgTest = [];
  for (var i = trueRange[0]; i < trueRange[trueRange.length - 1]; i++) {
    ecgTest.add(ecgSignal[i]);
  }
  return ecgTest;
}
/*---------------------------------------------------------------------------- */

List<int> indexRange(List<int> rangePeak, int len) {
  List<int> range = [];
  int deltaplus = 20;
  int deltaminus = 20;
  if (rangePeak.length > 1) {
    if ((rangePeak[rangePeak.length - 1] + deltaplus) > len) {
      deltaplus = len - rangePeak[rangePeak.length - 1] - 1;
    }
    if ((rangePeak[rangePeak.length - 1] - deltaminus) < 0) {
      deltaminus = 0;
    }

    for (var i = rangePeak[0] - deltaminus;
        i < rangePeak[rangePeak.length - 1] + deltaplus;
        i++) {
      range.add(i);
    }
  } else {
    if ((rangePeak[0] + deltaplus) > len) {
      deltaplus = len - rangePeak[0] - 1;
    }
    if ((rangePeak[0] - deltaminus) < 0) {
      deltaminus = 0;
    }
    for (var i = rangePeak[0] - deltaminus; i < rangePeak[0] + deltaplus; i++) {
      range.add(i);
    }
  }
  return range;
}
/*---------------------------------------------------------------------------- */

int whereMax(List<double> ecgSignal) {
  int indexMax = -1;
  for (var i = 0; i < ecgSignal.length; i++) {
    if (ecgSignal[i] == ecgSignal.reduce(max)) {
      indexMax = i;
    }
  }
  return indexMax;
}
/*---------------------------------------------------------------------------- */

int whereMin(List<double> ecgSignal) {
  int indexMax = -1;
  for (var i = 0; i < ecgSignal.length; i++) {
    if (ecgSignal[i] == ecgSignal.reduce(min)) {
      indexMax = i;
    }
  }
  return indexMax;
}

/*---------------------------------------------------------------------------- */
String checkTypeSignal(List<double> ecgSignal, double fs) {
  int nubMax = 0, nubMin = 0;
  int numberPart = (ecgSignal.length / fs).toInt();

  for (var i = 1; i < numberPart; i++) {
    List<double> ecgTest = [];
    for (int j = ((i - 1) * fs).toInt(); j < (i) * fs; j++) {
      ecgTest.add(ecgSignal[j]);
    }

    double mi = ecgTest.reduce(min);
    double ma = ecgTest.reduce(max);

    if (ecgTest.reduce(max).abs() < ecgTest.reduce(min).abs()) {
      nubMin++;
    } else {
      nubMax++;
    }
  }

  if (nubMax > nubMin) {
    return 'max';
  } else {
    return 'min';
  }
}

/*---------------------------------------------------------------------------- */
List<int> checkMissDetection(List<int> index, List<double> ecgSignal,
    List<double> pFecgSignal, double deltaTime, double fs, String signalType) {
  int len = index.length;
  List<int> indexCorrected = [];
  for (var i = 0; i < len - 1; i++) {
    indexCorrected.add(index[i]);
    if ((index[i + 1] - index[i]) > deltaTime) {
      List<int> newIndex = getLinearArray(index[i] + 50, index[i + 1] - 50);
      List<double> ecgTest = setEcgTest(newIndex, ecgSignal);
      List<double> pFecgTest = setEcgTest(newIndex, pFecgSignal);
      List<int> iNdex = indexGeaterThan(pFecgTest, 0.2 * pFecgTest.reduce(max));
      List<int> rPeakIndex = getRpeakIndex(ecgTest, iNdex, signalType, fs);

      for (int k = 0; k < rPeakIndex.length; k++) {
        if (k == 0) {
          if ((newIndex[rPeakIndex[k]] - index[i]) > 0.75 * fs) {
            indexCorrected.add(newIndex[rPeakIndex[k]]);
          }
        } else if (k == rPeakIndex.length - 1) {
          if ((index[i + 1] - newIndex[rPeakIndex[k]]) > 0.75 * fs) {
            indexCorrected.add(newIndex[rPeakIndex[k]]);
          }
        } else {
          if ((newIndex[rPeakIndex[k]] - newIndex[rPeakIndex[k - 1]]) >
              0.75 * fs) {
            indexCorrected.add(newIndex[rPeakIndex[k]]);
          }
        }
      }
    }
  }
  indexCorrected.add(index[len - 1]);
  return indexCorrected;
}

/*---------------------------------------------------------------------------- */

List<int> getLinearArray(int start, int strop) {
  List<int> linearArray = [];
  for (var i = start; i < strop; i++) {
    linearArray.add(i);
  }
  return linearArray;
}

/*---------------------------------------------------------------------------- */
List<double> toDouble(List<int> array) {
  List<double> output = [];
  for (var i = 0; i < array.length; i++) {
    output.add(array[i].toDouble());
  }
  return output;
}

List<ECG> interpolation(List<int> rIndex, double fs, double timeSampling) {
  List<double> indexTime = arrayDivide(toDouble(rIndex), fs);
  int nubSampling = (indexTime[indexTime.length - 2] / timeSampling).toInt();
  List<double> rToRPeak = diffArray(indexTime);
  rToRPeak = excludeShift(rToRPeak, rToRPeak[0]);
  rToRPeak.remove(rToRPeak[0]);
  int k = 0;
  double delta = 0;
  List<double> output = [];
  List<double> outputTime = [];
  List<ECG> outputECG = [];

  for (int i = 0; i < nubSampling; i++) {
    if ((timeSampling * i < indexTime[k]) && i != 0) {
      output
          .add(rToRPeak[k - 1] + delta * (timeSampling * i - indexTime[k - 1]));
      outputTime.add(timeSampling * i);
      outputECG.add(new ECG(timeSampling * i,
          rToRPeak[k - 1] + delta * (timeSampling * i - indexTime[k - 1])));
    } else {
      k++;
      delta =
          (rToRPeak[k] - rToRPeak[k - 1]) / (indexTime[k] - indexTime[k - 1]);
      output
          .add(rToRPeak[k - 1] + delta * (timeSampling * i - indexTime[k - 1]));
      outputTime.add(timeSampling * i);
      outputECG.add(new ECG(timeSampling * i,
          rToRPeak[k - 1] + delta * (timeSampling * i - indexTime[k - 1])));
    }
  }
  return outputECG;
}
/*---------------------------------------------------------------------------- */

List<double> interpolationPeak(
    List<int> rIndex, double fs, double timeSampling) {
  List<double> indexTime = arrayDivide(toDouble(rIndex), fs);
  int nubSampling = (indexTime[indexTime.length - 2] / timeSampling).toInt();
  List<double> rToRPeak = diffArray(indexTime);
  rToRPeak = excludeShift(rToRPeak, rToRPeak[0]);
  rToRPeak.remove(rToRPeak[0]);
  int k = 0;
  double delta = 0;
  List<double> output = [];

  for (int i = 0; i < nubSampling; i++) {
    if ((timeSampling * i < indexTime[k]) && i != 0) {
      output
          .add(rToRPeak[k - 1] + delta * (timeSampling * i - indexTime[k - 1]));
    } else {
      k++;
      delta =
          (rToRPeak[k] - rToRPeak[k - 1]) / (indexTime[k] - indexTime[k - 1]);
      output
          .add(rToRPeak[k - 1] + delta * (timeSampling * i - indexTime[k - 1]));
    }
  }
  return output;
}
/*---------------------------------------------------------------------------- */

List<double> arrayDivide(List<double> inputArray, double div) {
  List<double> output = [];
  for (int i = 0; i < inputArray.length; i++) {
    output.add(inputArray[i] / div);
  }
  return output;
}
