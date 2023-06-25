import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'globals.dart';

class Minimizer {
  Minimizer(this.x0, this.line, this.eigenVectors, this.g, this.side);
  late Vector x0;
  late List<List<double>> line;
  late Matrix eigenVectors;
  late Globals g;

  // false = right, true = left
  late bool side;
  Matrix reducedMatrix = Matrix.fromList([]);
  Vector reducedMean = Vector.fromList([]);

  List<List<double>> plottingData = [];

  /// performs Newton's Method
  Vector run() {
    double stepSize = 1;
    double loss = 1000000;
    Vector x = x0;
    int iter = 0;
    Stopwatch stopwatch = Stopwatch()..start();
    while (loss > 0 && iter < 100) {
      List<List<double>> breastLine = getBreastLine(x);
      List<double> dists = getDists(breastLine);
      loss = 0;
      for (int i = 0; i < dists.length / 3; i++) {
        loss += sqrt((dists[i] * dists[i]) +
            (dists[i + 1] * dists[i + 1]) +
            (dists[i + 2] * dists[i + 2]));
      }
      Vector derivation = getDerivation(dists);
      x = x - (derivation * stepSize);
      stepSize = stepSize * 0.99;
      iter++;
      //debugPrint('iteration $iter with loss $loss and stepSize $stepSize');
      if (iter % 10 == 0) {
        plottingData.add(x.toList());
      }
    }
    //debugPrint(plottingData.toString());
    debugPrint(plottingData.toString());
    return x;
  }

  /// calculates for each vertex the distance to the line
  List<double> getDists(List<List<double>> breastLine) {
    List<double> dists = [];
    for (var i = 0; i < breastLine.length; i++) {
      double minDist = 10000000;
      List<double> minPointA = [];
      List<double> minPointB = [];
      for (var j = 0; j < line.length; j++) {
        double dist = sqrt((breastLine[i][0] - line[j][0]) *
                (breastLine[i][0] - line[j][0]) +
            (breastLine[i][1] - line[j][1]) * (breastLine[i][1] - line[j][1]) +
            (breastLine[i][2] - line[j][2]) * (breastLine[i][2] - line[j][2]));
        if (dist < minDist) {
          minDist = dist;
          minPointA = breastLine[i];
          minPointB = line[j];
        }
      }
      dists.add(minPointA[0] - minPointB[0]);
      dists.add(minPointA[1] - minPointB[1]);
      dists.add(minPointA[2] - minPointB[2]);
    }
    return dists;
  }

  /// calculates the line of the breast defined by the breastLineIndicesLeft/Right.txt file
  List<List<double>> getBreastLine(Vector x) {
    Vector model = (reducedMatrix * x).toVector() + reducedMean;
    List<List<double>> breastLineList = [];
    for (var i = 0; i < model.length / 3; i++) {
      breastLineList.add([model[3 * i], model[3 * i + 1], model[3 * i + 2]]);
    }
    return breastLineList;
  }

  /// returns the relevant part of the eigen vectors and the mean
  Matrix getReducedMatrix() {
    List<List<double>> reducedMatrix = [];
    List<double> _reducedMean = [];
    if (!side) {
      for (int i = 0; i < g.breastLineIndicesRight.length; i++) {
        Vector row = eigenVectors.getRow(g.breastLineIndicesRight[i]);
        _reducedMean.add(g.meanVec[g.breastLineIndicesRight[i]]);
        reducedMatrix.add(row.toList());
      }
    } else {
      for (int i = 0; i < g.breastLineIndicesLeft.length; i++) {
        Vector row = eigenVectors.getRow(g.breastLineIndicesLeft[i]);
        _reducedMean.add(g.meanVec[g.breastLineIndicesLeft[i]]);
        reducedMatrix.add(row.toList());
      }
    }

    Matrix m = Matrix.fromList(reducedMatrix);
    reducedMean = Vector.fromList(_reducedMean);
    return m;
  }

  /// returns the derivation of the loss function
  Vector getDerivation(List<double> dists) {
    Vector derivation = reducedMatrix.getRow(0) * (2 * dists[0]);
    for (int i = 0; i < g.breastLineIndicesRight.length; i++) {
      Vector row = reducedMatrix.getRow(i);
      derivation += row * (2 * dists[i]);
    }
    //derivation = derivation.set(0, 0);
    for (int i = 8; i < derivation.length; i++) {
      derivation = derivation.set(i, 0);
    }
    derivation = derivation.set(4, 0);
    return derivation;
  }
}
