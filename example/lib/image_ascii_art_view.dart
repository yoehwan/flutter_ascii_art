import 'dart:typed_data';

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
  ImageAsciiArt? _imageAsciiArt;

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
    if (_imageData == null) return SizedBox();
    return Image.memory(_imageData!);
  }

  Future _loadImage() async {
    print("LoadImage..");
    final _res = await http.get(Uri.parse(_imageURL));
    _imageData = _res.bodyBytes;
    print("Load Completed!");
    _imageAsciiArt = ImageAsciiArt(
      imageData: _imageData!,
      pixelRatio: 1,
    );
    setState(() {});
  }

  Widget _asciiImage() {
    if (_imageAsciiArt == null) return SizedBox();

    return Image(
      image: AsciiImageProvider(
        imageProvider: NetworkImage(_imageURL),
        imageAsciiArt: _imageAsciiArt!,
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
            originImage(),
            _asciiImage(),
            SizedBox(
              height: kToolbarHeight,
            )
          ],
        ),
      ),
    );
  }
}
