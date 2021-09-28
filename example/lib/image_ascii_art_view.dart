import 'dart:typed_data';
import 'dart:ui';

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
  String _imageURL =
      // "https://lh3.googleusercontent.com/bvEP9G3wSVCy-K5dkVbF-SX6Dwo7_2zkkkg3n12Xna7zQ7ahRmbq8hf7-9hM_qQbfMbkNV8R5Zkepdwc1CM27i4lYBmNQ5Nvdg=s0";
      "https://www.pngitem.com/pimgs/m/276-2760759_iu-on-last-fantasy-cover-iu-last-fantasy.png";
  Uint8List? _imageData;
  AsciiImage? asciiArt;

  double _scale = 1;
  double _scaleBuffer = 0;
  bool _scaleMode = false;

  void initState() {
    super.initState();
    _loadImage();
  }

  AppBar _appBar() {
    return AppBar(
      title: Text("ImageAsciiArt"),
    );
  }

  Widget _imageURLTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: TextField(
          onSubmitted: (value) {
            _imageURL = value;
            _loadImage();
          },
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: "input image URL"),
        ),
      ),
    );
  }

  Widget originImage() {
    return Image.network(
      _imageURL,
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future _loadImage() async {
    print("LoadImage..");
    final _res = await http.get(Uri.parse(_imageURL));
    _imageData = _res.bodyBytes;
    print("Load Completed!");
    asciiArt = await ImageAsciiArt(
      imageData: _imageData!,
      pixelRatio: 0.4,
    ).toAscii();
    setState(() {});
  }

  Widget _asciiImage() {
    return Image(
      image: AsciiImageProvider(
          imageProvider: NetworkImage(_imageURL), pixelRatio: 0.8),
    );
  }

  Widget _rawAsciiImage() {
    if (asciiArt == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    return GestureDetector(
      onScaleStart: (_) {
        _scaleMode = true;
      },
      onScaleUpdate: (_details) {
        _scaleBuffer = (_details.scale - 1);
        setState(() {});
      },
      onScaleEnd: (_) {
        _scale += _scaleBuffer;
        _scaleMode = false;
      },
      child: Transform.scale(
        scale: _scaleMode ? _scale + _scaleBuffer : _scale,
        child: Center(
          child: Text.rich(
            TextSpan(
              children: asciiArt!.asciiList.map((e) {
                return TextSpan(text: e + "\n");
              }).toList(),
              style: GoogleFonts.robotoMono(
                  color: Colors.black, fontSize: 2, height: 0.75),
            ),
          ),
        ),
      ),
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
        body: ListView(
          children: [
            _imageURLTextField(),
            Divider(),
            originImage(),
            Divider(),
            // _asciiImage(),
            // Divider(),
            _rawAsciiImage(),
            Divider(),
            SizedBox(
              height: kToolbarHeight,
            )
          ],
        ),
      ),
    );
  }
}
