import 'package:flutter/material.dart';
import 'dspcode.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';

List<int> RPeakDetection(List<double> inputECG) {
  List<double> outputECG = [];

  //preprocessing Normalisation
  outputECG = excludeShift(inputECG, getMean(inputECG));
  outputECG = arrayNormalisation(outputECG);
  //high pass filter
  List<double> hecgSignal = highPassFilter(outputECG);
  //low pass filter
  hecgSignal = lowPassFilter(hecgSignal);
  //power 2 signal
  List<double> pecgSignal = powerTwo(hecgSignal);

  //preprocessing Normalisation
  pecgSignal = excludeShift(pecgSignal, getMean(pecgSignal));
  pecgSignal = arrayNormalisation(pecgSignal);

  // select index greater then threshold
  List<int> index = indexGeaterThan(pecgSignal, 0.2 * pecgSignal.reduce(max));
  String signalType = checkTypeSignal(outputECG, 360);

  List<int> rPeakIndex = getRpeakIndex(outputECG, index, signalType, 360);

  double deltaTime = getMean(diffArray(toDouble(rPeakIndex))) +
      2 * getStandardDeviation(diffArray(toDouble(rPeakIndex)));
  double maxDiff = diffArray(toDouble(rPeakIndex)).reduce(max);

  if (maxDiff > deltaTime) {
    rPeakIndex = checkMissDetection(
        rPeakIndex, outputECG, pecgSignal, deltaTime, 360, signalType);
  }

  return rPeakIndex;
}

List<double> ECGNormalisation(List<double> inputECG) {
  List<double> outputECG = [];

  //preprocessing Normalisation
  outputECG = excludeShift(inputECG, getMean(inputECG));
  outputECG = arrayNormalisation(outputECG);
  return outputECG;
}
