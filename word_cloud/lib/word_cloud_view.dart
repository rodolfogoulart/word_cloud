import 'dart:math';

import 'package:flutter/material.dart';
import 'package:word_cloud/word_cloud_data.dart';
import 'package:word_cloud/word_cloud_setting.dart';
import 'package:word_cloud/word_cloud_shape.dart';

class WordCloudView extends StatefulWidget {
  final WordCloudData data;
  final Color? mapcolor;
  final Decoration? decoration;
  final double mapwidth;
  final String? fontFamily;
  final FontStyle? fontStyle;
  final FontWeight? fontWeight;
  final double mapheight;
  final List<Color>? colorlist;
  final int attempt;
  final double mintextsize;
  final double maxtextsize;
  final WordCloudShape? shape;
  final Function(String word, double value, dynamic metaData)? onTap;
  final String Function(String word, double value, dynamic metaData)? tooltipMessage;

  const WordCloudView({
    super.key,
    required this.data,
    required this.mapwidth,
    required this.mapheight,
    this.mintextsize = 10,
    this.maxtextsize = 100,
    this.attempt = 30,
    this.shape,
    this.fontFamily,
    this.fontStyle,
    this.fontWeight,
    this.mapcolor,
    this.decoration,
    this.colorlist,
    this.onTap,
    this.tooltipMessage,
  });
  @override
  State<WordCloudView> createState() => _WordCloudViewState();
}

class _WordCloudViewState extends State<WordCloudView> {
  late WordCloudShape wcshape;
  late WordCloudSetting wordcloudsetting;

  @override
  void initState() {
    super.initState();
    if (widget.shape == null) {
      wcshape = WordCloudShape();
    } else {
      wcshape = widget.shape!;
    }

    wordcloudsetting = WordCloudSetting(
      data: widget.data.getData(),
      minTextSize: widget.mintextsize,
      maxTextSize: widget.maxtextsize,
      attempt: widget.attempt,
      shape: wcshape,
    );

    wordcloudsetting.setMapSize(widget.mapwidth, widget.mapheight);
    wordcloudsetting.setFont(widget.fontFamily, widget.fontStyle, widget.fontWeight);
    wordcloudsetting.setColorList(widget.colorlist);
    wordcloudsetting.setInitial();

    wordcloudsetting.drawTextOptimized();
  }

  @override
  Widget build(BuildContext context) {
    double denominator =
        (wordcloudsetting.data[0].value - wordcloudsetting.data[wordcloudsetting.data.length - 1].value).toDouble();
    var minTextSize = widget.mintextsize;
    var maxTextSize = widget.maxtextsize;
    return RepaintBoundary(
      child: Container(
          width: widget.mapwidth,
          height: widget.mapheight,
          color: widget.mapcolor,
          decoration: widget.decoration,
          child: Stack(children: [
            for (var i = 0; i < wordcloudsetting.getDataLength(); i++) ...[
              if (wordcloudsetting.isdrawed[i])
                Positioned(
                    left: wordcloudsetting.getWordPoint()[i][0],
                    top: wordcloudsetting.getWordPoint()[i][1],
                    child: Builder(builder: (context) {
                      //
                      double getTextSize;
                      if (denominator != 0) {
                        getTextSize = (minTextSize * (wordcloudsetting.data[0].value - wordcloudsetting.data[i].value) +
                                maxTextSize *
                                    (wordcloudsetting.data[i].value -
                                        wordcloudsetting.data[wordcloudsetting.data.length - 1].value)) /
                            denominator;
                      } else {
                        getTextSize = (minTextSize + maxTextSize) / 2;
                      }
                      var textStyle = TextStyle(
                        color: wordcloudsetting.data[i].color,
                        fontSize: getTextSize,
                      );

                      ValueNotifier onHouver = ValueNotifier(null);
                      return GestureDetector(
                        onTap: () {
                          widget.onTap?.call(wordcloudsetting.data[i].word, wordcloudsetting.data[i].value.toDouble(),
                              wordcloudsetting.data[i].metaData);
                        },
                        child: MouseRegion(
                          child: ValueListenableBuilder(
                              valueListenable: onHouver,
                              builder: (context, value, child) {
                                // textStyle = textStyle.copyWith(fontSize: onHouver.value ?? getTextSize);
                                Widget text = Text(
                                  wordcloudsetting.data[i].word,
                                  style: textStyle.copyWith(fontWeight: onHouver.value != null ? FontWeight.bold : null),
                                  // textScaler: TextScaler.linear(onHouver.value ?? 1.toDouble()),
                                );
                                if (widget.tooltipMessage != null) {
                                  text = Tooltip(
                                      message: widget.tooltipMessage!(wordcloudsetting.data[i].word,
                                          wordcloudsetting.data[i].value.toDouble(), wordcloudsetting.data[i].metaData),
                                      child: text);
                                }
                                return text;
                              }),
                          onHover: (event) {
                            onHouver.value = 1.1;
                          },
                          onExit: (event) {
                            onHouver.value = null;
                          },
                        ),
                      );
                    }))
            ]
          ])
          // child: CustomPaint(
          //   painter: WCpaint(wordcloudpaint: wordcloudsetting),
          // ),
          ),
    );
  }
}

// class WCpaint extends CustomPainter {
//   final WordCloudSetting wordcloudpaint;
//   WCpaint({
//     required this.wordcloudpaint,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (var i = 0; i < wordcloudpaint.getDataLength(); i++) {
//       if (wordcloudpaint.isdrawed[i]) {
//         wordcloudpaint
//             .getTextPainter()[i]
//             .paint(canvas, Offset(wordcloudpaint.getWordPoint()[i][0], wordcloudpaint.getWordPoint()[i][1]));
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
