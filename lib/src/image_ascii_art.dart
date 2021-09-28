import 'dart:math';
import 'dart:typed_data';

import 'package:ascii_art/src/ascii_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as im;
import 'dart:ui' as ui;

/// byteData , network and *Text
/// 1. input src
/// 2. grayScale
/// 3. grayScaled Image change to Ascii char
/// 4. make Image

const Map<String, String> GrayTable = {
  "0.0": " ",
  "0.1": " ",
  "0.2": " ",
  "0.3": ".",
  "0.4": "'",
  "0.5": ",",
  "0.6": ";",
  "0.7": ":",
  "0.8": "c",
  "0.9": "l",
  "1.0": "o",
  "1.1": "d",
  "1.2": "x",
  "1.3": "k",
  "1.4": "O",
  "1.5": "0",
  "1.6": "K",
  "1.7": "X",
  "1.8": "N",
  "1.9": "W",
  "2.0": "M",
};

const Map<String, String> ReversedGrayTable = {
  "0.0": "M",
  "0.1": "W",
  "0.2": "N",
  "0.3": "X",
  "0.4": "K",
  "0.5": "0",
  "0.6": "O",
  "0.7": "k",
  "0.8": "x",
  "0.9": "d",
  "1.0": "o",
  "1.1": "l",
  "1.2": "c",
  "1.3": ":",
  "1.4": ";",
  "1.5": ",",
  "1.6": "'",
  "1.7": ".",
  "1.8": " ",
  "1.9": " ",
  "2.0": " ",
};

///for isolate resize Image
im.Image _resize(Map<String, dynamic> args) {
  final im.Image _image = args['image'];
  final double _pixelRatio = args['pixelRatio'];
  final _resized =
      im.copyResize(_image, width: (_image.width * _pixelRatio).toInt());
  return _resized;
}

///for isolate grayScale Image
im.Image _grayScale(im.Image image) {
  return im.grayscale(image);
}

/// [todo] refactoring..
List<String> _convertAsciiListFrom(im.Image image) {
  final  Uint32List byteData = image.data;
  final _imageWidth = image.width;
  final _imageHeight = image.height;
  final List<String> _list = [];
  final _data = byteData.buffer.asUint8List();
  for (int index = 0; index < _data.length; index += 4) {
    int byte = _data[index];
    String tableIndex = (byte / pow(2, 7)).toStringAsFixed(1);
    _list.add(ReversedGrayTable[tableIndex] ?? " ");
  }

  List<String> _col = [];
  String row;

  for (int index = 0; index < _imageHeight; index++) {
    row = _list.sublist(_imageWidth * index, _imageWidth * (index + 1)).join();
    _col.add(row);
  }

    return _col;
}

class ImageAsciiArt {
  ImageAsciiArt({
    required this.imageData,
    this.pixelRatio = 1.0,
  });

  final Uint8List imageData;
  im.Image? get image=>im.decodeImage(imageData);
  final double pixelRatio;

  bool get needResize => pixelRatio != 1.0;

  Future<AsciiImage?> toAscii() async {
    im.Image? _image = image;
    if (_image == null) return null;
    print("gray Scaling..");
    _image = await compute(_grayScale, _image);
    print("gray Scaled..");
    if (needResize) {
      print("Resizing..");
      _image = await compute(_resize, {
        'image': _image,
        'pixelRatio': pixelRatio,
      });
      print("Resized");
    }
    print("Ascii converting..");
    final _asciiList = await compute(_convertAsciiListFrom, _image);
    AsciiImage _asciiImage = AsciiImage(
      asciiList: _asciiList,
      width: _image.width,
      height: _image.height,
    );
    print("Ascii converted..");
    return _asciiImage;
  }

  Future<ui.Image?> toAsciiImage() async {
    final ascii = await toAscii();

    if(ascii==null)return null;
    final _imageWidth = ascii.width;
    final _imageHeight = ascii.height;

    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(pictureRecorder);

    print("drawing");
    TextPainter _tp = TextPainter(
      text: TextSpan(
        children: ascii.asciiList.map((e) {
          return TextSpan(text:e + "\n");
        }).toList(),
        style: GoogleFonts.robotoMono(
          color: Colors.black,
          fontSize: 1,
          letterSpacing: 0.35
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    _tp.layout();
    _tp.paint(canvas, Offset.zero);
    final _img = await pictureRecorder.endRecording().toImage(
          _imageWidth,
          _imageHeight,
        );
    print("draw completed");
    return _img;
  }
}
