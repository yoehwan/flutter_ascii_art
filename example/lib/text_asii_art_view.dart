import 'package:flutter/material.dart';

class TextAsciiArtView extends StatefulWidget {
  @override
  _TextAsciiArtViewState createState() => _TextAsciiArtViewState();
}

class _TextAsciiArtViewState extends State<TextAsciiArtView> {
  AppBar _appBar() {
    return AppBar(
      title: Text("TextAsciiArt"),
    );
  }

  Widget _body() {
    return Image.network(
        "https://cdn140.picsart.com/275901115001201.gif?to=min&r=640");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }
}
