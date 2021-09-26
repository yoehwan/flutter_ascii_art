import 'package:example/text_asii_art_view.dart';
import 'package:flutter/material.dart';

import 'image_ascii_art_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascii Art',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AsciiArtView(),
    );
  }
}


class AsciiArtView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppBar _appBar() {
      return AppBar(
        title: Text("AsciiArt"),
      );
    }

    Widget _body() {
      Widget _item({required String title, required Widget to}) {
        return Card(
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return to;
                  },
                ),
              );
            },
            title: Text(title),
          ),
        );
      }
      return Column(
        children: [
          _item(title: "Image to AsciiArt", to: ImageAsciiArtView()),
          _item(title: "Text to AsciiArt", to: TextAsciiArtView()),
        ],
      );
    }

    return Scaffold(
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _body(),
      ),
    );
  }
}
