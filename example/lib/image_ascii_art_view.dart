import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ascii_art/ascii_art.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageAsciiArtView extends StatefulWidget {
  @override
  _ImageAsciiArtViewState createState() => _ImageAsciiArtViewState();
}

class _ImageAsciiArtViewState extends State<ImageAsciiArtView> {
  final TextEditingController _textEditingController = TextEditingController();
  late ValueNotifier<ImageProvider?> imageProviderNotifier =
      ValueNotifier(null);
  ValueNotifier<AsciiImage?> asciiImageNotifier = ValueNotifier(null);
  double _scale = 1;
  double _scaleBuffer = 0;
  bool _scaleMode = false;

  void initState() {
    super.initState();
    imageProviderNotifier.addListener(imageProviderNotifierListener);
  }

  void imageProviderNotifierListener() {
    if (imageProviderNotifier.value == null) return;
    _loadImage(imageProviderNotifier.value!);
  }

  AppBar _appBar() {
    return AppBar(
      title: Text("ImageAsciiArt"),
    );
  }

  Widget originImage() {
    return ValueListenableBuilder<ImageProvider?>(
      valueListenable: imageProviderNotifier,
      builder: (_, value, __) {
        if (value == null) return SizedBox();
        return Image(image: value);
      },
    );
  }

  Future<AsciiImage?> _loadImage(ImageProvider imageProvider) async {
    final _asciiArt = await ImageAsciiArt.fromImageProvider(
      imageProvider: imageProvider,
      context: context,
      pixelRatio: 1,
    );
    asciiImageNotifier.value = await _asciiArt.toAscii();
  }

  Widget _textField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textEditingController,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            imageProviderNotifier.value =
                NetworkImage(_textEditingController.text);
          },
          child: Text("Search"),
        )
      ],
    );
  }

  // Widget _asciiImage() {
  //   return Image(
  //     image: AsciiImageProvider(
  //         imageProvider: AssetImage(imagePath), pixelRatio: 1),
  //   );
  // }

  Widget _rawAsciiImage() {
    return ValueListenableBuilder<AsciiImage?>(
      valueListenable: asciiImageNotifier,
      builder: (_, value, __) {
        final _asciiArt = value;
        if (_asciiArt == null) return SizedBox();
        return GestureDetector(
          onScaleStart: (_) {
            _scaleMode = true;
          },
          onScaleUpdate: (_details) {
            _scaleBuffer = (_details.scale - 1) * _scale;
            setState(() {});
          },
          onScaleEnd: (_) {
            _scale = max(1, _scale + _scaleBuffer);
            _scaleMode = false;
          },
          child: ClipRRect(
            child: Transform.scale(
              scale: _scaleMode ? _scale + _scaleBuffer : _scale,
              child: SizedBox(
                child: FittedBox(
                  child: Text.rich(
                    TextSpan(
                      children: _asciiArt.asciiList.map((e) {
                        return TextSpan(text: e + "\n");
                      }).toList(),
                      style: GoogleFonts.robotoMono(
                          color: Colors.black, fontSize: 10, height: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: _appBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _textField(),
              originImage(),
              _rawAsciiImage(),
              Divider(),
              SizedBox(
                height: kToolbarHeight * 3,
              )
            ],
          ),
        ),
      ),
    );
  }
}
