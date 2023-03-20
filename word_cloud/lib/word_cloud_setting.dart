import 'dart:math';

import 'package:flutter/material.dart';
import 'package:word_cloud/word_cloud_shape.dart';

class WordCloudSetting {
  double mapX = 0;
  double mapY = 0;
  String? fontFamily;
  FontStyle? fontStyle;
  FontWeight? fontWeight;
  List<Map> data = [];
  List map = [[]];
  List textCenter = [];
  List textPoints = [];
  List textlist = [];
  double centerX = 0;
  double centerY = 0;
  double minTextSize;
  double maxTextSize;
  WordCloudShape shape;
  int attempt;
  List<Color>? colorList = [Colors.black];

  WordCloudSetting({
    Key? key,
    required this.data,
    required this.minTextSize,
    required this.maxTextSize,
    required this.attempt,
    required this.shape,
  });

  void setMapSize(double x, double y) {
    mapX = x;
    mapY = y;
  }

  void setColorList(List<Color>? colors) {
    colorList = colors;
  }

  void setFont(String? family, FontStyle? style, FontWeight? weight) {
    fontFamily = family;
    fontStyle = style;
    fontWeight = weight;
  }

  List setMap(WordCloudShape shape) {
    List makemap = [[]];
    switch (shape.getType()) {
      case 'normal':
        for (var i = 0; i < mapX; i++) {
          for (var j = 0; j < mapY; j++) {
            makemap[i].add(0);
          }
          makemap.add([]);
        }
        break;
      case 'circle':
        break;
    }
    return makemap;
  }

  void setInitial() {
    map = [[]];
    textCenter = [];
    textPoints = [];
    textlist = [];

    centerX = mapX / 2;
    centerY = mapY / 2;

    for (var i = 0; i < mapX; i++) {
      for (var j = 0; j < mapY; j++) {
        map[i].add(0);
      }
      map.add([]);
    }

    // for (var i = 0; i < mapX; i++) {
    //   for (var j = 0; j < mapY; j++) {
    //     if (pow(i - (mapX / 2), 2) + pow(j - (mapY / 2), 2) > pow(250, 2)) {
    //       map[i].add(1);
    //     } else {
    //       map[i].add(0);
    //     }
    //   }
    //   map.add([]);
    // }

    for (var i = 0; i < data.length; i++) {
      double getTextSize =
          (minTextSize * (data[0]['value'] - data[i]['value']) +
                  maxTextSize *
                      (data[i]['value'] - data[data.length - 1]['value'])) /
              (data[0]['value'] - data[data.length - 1]['value']);

      final textSpan = TextSpan(
        text: data[i]['word'],
        style: TextStyle(
          color: colorList?[Random().nextInt(colorList!.length)],
          fontSize: getTextSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          fontStyle: fontStyle,
        ),
      );

      final textPainter = TextPainter()
        ..text = textSpan
        ..textDirection = TextDirection.ltr
        ..textAlign = TextAlign.center
        ..layout();

      textlist.add(textPainter);

      double centerCorrectionX = centerX - textlist[i].width / 2;
      double centerCorrectionY = centerY - textlist[i].height / 2;
      textCenter.add([centerCorrectionX, centerCorrectionY]);
      textPoints.add([]);
    }
  }

  void setTextStyle(List<TextStyle> newstyle) {
    //only support color, weight, family, fontstyle
    textlist = [];
    textCenter = [];
    textPoints = [];

    for (var i = 0; i < data.length; i++) {
      double getTextSize =
          (minTextSize * (data[0]['value'] - data[i]['value']) +
                  maxTextSize *
                      (data[i]['value'] - data[data.length - 1]['value'])) /
              (data[0]['value'] - data[data.length - 1]['value']);

      final textSpan = TextSpan(
        text: data[i]['word'],
        style: TextStyle(
          color: newstyle[i].color,
          fontSize: getTextSize,
          fontWeight: newstyle[i].fontWeight,
          fontFamily: newstyle[i].fontFamily,
          fontStyle: newstyle[i].fontStyle,
        ),
      );

      final textPainter = TextPainter()
        ..text = textSpan
        ..textDirection = TextDirection.ltr
        ..textAlign = TextAlign.center
        ..layout();

      textlist.add(textPainter);

      double centerCorrectionX = centerX - textlist[i].width / 2;
      double centerCorrectionY = centerY - textlist[i].height / 2;
      textCenter.add([centerCorrectionX, centerCorrectionY]);
      textPoints.add([]);
    }
  }

  bool checkMap(double x, double y, double w, double h) {
    if (mapX - x < w) {
      return false;
    }
    if (mapY - y < h) {
      return false;
    }
    for (int i = x.toInt(); i < x.toInt() + w; i++) {
      for (int j = y.toInt(); j < y.toInt() + h; j++) {
        if (map[i][j] == 1) {
          return false;
        }
      }
    }
    return true;
  }

  bool checkMapOptimized1(int x, int y, double w, double h) {
    if (mapX - x < w) {
      return false;
    }
    if (mapY - y < h) {
      return false;
    }
    for (int i = x.toInt(); i < x.toInt() + w; i++) {
      if (map[i][y + h - 1] == 1) {
        return false;
      }
    }
    return true;
  }

  bool checkMapOptimized2(int x, int y, double w, double h) {
    if (mapX - x < w) {
      return false;
    }
    if (mapY - y < h) {
      return false;
    }
    for (int i = x.toInt(); i < x.toInt() + w; i++) {
      if (map[i][y + 1] == 1) {
        return false;
      }
    }
    return true;
  }

  void drawIn(int index, double x, double y) {
    textPoints[index] = [x, y];
    for (int i = x.toInt(); i < x.toInt() + textlist[index].width; i++) {
      for (int j = y.toInt();
          j < y.toInt() + textlist[index].height.floor();
          j++) {
        map[i][j] = 1;
      }
    }
  }

  void drawTextOptimized() {
    drawIn(0, textCenter[0][0], textCenter[0][1]);
    for (var i = 1; i < textlist.length; i++) {
      double w = textlist[i].width;
      double h = textlist[i].height;
      int attempts = 0;

      bool isadded = false;

      while (!isadded) {
        int getX = Random().nextInt(mapX.toInt() - w.toInt());
        int direction = Random().nextInt(2);
        if (direction == 0) {
          for (int y = textCenter[i][1].toInt(); y > 0; y--) {
            if (checkMapOptimized1(getX, y, w, h)) {
              drawIn(i, getX.toDouble(), y.toDouble());
              isadded = true;
              break;
            }
          }
        } else if (direction == 1) {
          for (int y = textCenter[i][1].toInt(); y < mapY; y++) {
            if (checkMapOptimized2(getX, y, w, h)) {
              drawIn(i, getX.toDouble(), y.toDouble());
              isadded = true;
              break;
            }
          }
        }
        attempts += 1;
        if (attempts > attempt) {
          isadded = true;
        }
      }
    }
  }

  void drawText() {
    drawIn(0, textCenter[0][0], textCenter[0][1]);
    for (var i = 1; i < textlist.length; i++) {
      double w = textlist[i].width;
      double h = textlist[i].height;
      int attempts = 0;

      bool isadded = false;

      while (!isadded) {
        int getX = Random().nextInt(mapX.toInt() - w.toInt());
        int direction = Random().nextInt(2);
        if (direction == 0) {
          for (int y = textCenter[i][1].toInt(); y > 0; y--) {
            if (checkMap(getX.toDouble(), y.toDouble(), w, h)) {
              drawIn(i, getX.toDouble(), y.toDouble());
              isadded = true;
              break;
            }
          }
        } else if (direction == 1) {
          for (int y = textCenter[i][1].toInt(); y < mapY; y++) {
            if (checkMap(getX.toDouble(), y.toDouble(), w, h)) {
              drawIn(i, getX.toDouble(), y.toDouble());
              isadded = true;
              break;
            }
          }
        }
        attempts += 1;
        if (attempts > attempt) {
          isadded = true;
        }
      }
    }
  }

  List getWordPoint() {
    return textPoints;
  }

  List getTextPainter() {
    return textlist;
  }

  int getDataLength() {
    return data.length;
  }
}