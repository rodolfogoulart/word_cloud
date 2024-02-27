// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:word_cloud/word_cloud_data.dart';
import 'package:word_cloud/word_cloud_setting.dart';
import 'package:word_cloud/word_cloud_shape.dart';

class WordCloudView extends StatefulWidget {
  final WordCloudData data;
  final Color? mapcolor;
  final Decoration? decoration;
  final double mapwidth;
  final double mapheight;
  final String? fontFamily;
  final FontStyle? fontStyle;
  final FontWeight? fontWeight;
  final List<Color>? colorlist;
  final int attempt;
  final double mintextsize;
  final double maxtextsize;
  final WordCloudShape? shape;
  final Function(String word, double value, dynamic metaData)? onTap;
  final Function(String word, double value, dynamic metaData)? onHouver;
  final TextStyle onHouverStyle;
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
    this.tooltipMessage,
    this.onTap,
    this.onHouverStyle = const TextStyle(fontWeight: FontWeight.w900),
    this.onHouver,
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
    return RepaintBoundary(
      child: Container(
          width: widget.mapwidth,
          height: widget.mapheight,
          color: widget.mapcolor,
          decoration: widget.decoration,
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (var i = 0; i < wordcloudsetting.getDataLength(); i++) ...[
                if (wordcloudsetting.isdrawed[i])
                  Positioned(
                      left: wordcloudsetting.getWordPoint()[i][0],
                      top: wordcloudsetting.getWordPoint()[i][1],
                      child: Builder(builder: (context) {
                        var textStyle = TextStyle(
                          color: wordcloudsetting.dataSetting[i].color,
                          fontSize: wordcloudsetting.dataSetting[i].fontSize,
                          fontWeight: wordcloudsetting.dataSetting[i].fontWeight,
                          fontFamily: wordcloudsetting.dataSetting[i].fontFamily,
                          fontStyle: wordcloudsetting.dataSetting[i].fontStyle,
                        );

                        ValueNotifier onHouver = ValueNotifier(false);
                        return GestureDetector(
                          onTap: () {
                            widget.onTap?.call(wordcloudsetting.data[i].word, wordcloudsetting.data[i].value.toDouble(),
                                wordcloudsetting.data[i].metaData);
                          },
                          child: MouseRegion(
                            child: ValueListenableBuilder(
                                valueListenable: onHouver,
                                builder: (context, value, child) {
                                  Widget text = Text(
                                    wordcloudsetting.data[i].word,
                                    maxLines: 1,
                                    style: onHouver.value ? textStyle.merge(widget.onHouverStyle) : textStyle,
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
                              if (onHouver.value) return;
                              onHouver.value = true;
                              widget.onHouver?.call(wordcloudsetting.data[i].word, wordcloudsetting.data[i].value.toDouble(),
                                  wordcloudsetting.data[i].metaData);
                            },
                            onExit: (event) {
                              onHouver.value = false;
                            },
                          ),
                        );
                      }))
              ]
            ],
          )
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
