import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:ascii_art/ascii_art.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as im;
import 'package:flutter/foundation.dart';

class AsciiImage {
  const AsciiImage({
    required this.asciiList,
    required this.width,
    required this.height,
  });

  final List<String> asciiList;
  final int width;
  final int height;

  Map<String, dynamic> toMap() {
    return {
      'asciiList': this.asciiList,
      'width': this.width,
      'height': this.height,
    };
  }

  @override
  String toString() {
    return 'AsciiImage{asciiList: asciiData, width: $width, height: $height}';
  }

  factory AsciiImage.fromMap(Map<String, dynamic> map) {
    return AsciiImage(
      asciiList: map['asciiList'] as List<String>,
      width: map['width'] as int,
      height: map['height'] as int,
    );
  }
}

@immutable
class AsciiImageKey {
  // Private constructor so nobody from the outside can poison the image cache
  // with this key. It's only accessible to [ResizeImage] internally.
  const AsciiImageKey._(this._providerCacheKey, this._width, this._height);

  final Object _providerCacheKey;
  final int? _width;
  final int? _height;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AsciiImageKey &&
        other._providerCacheKey == _providerCacheKey &&
        other._width == _width &&
        other._height == _height;
  }

  @override
  int get hashCode => hashValues(_providerCacheKey, _width, _height);
}

class AsciiImageProvider extends ImageProvider<AsciiImageKey> {
  const AsciiImageProvider({
    required this.imageProvider,
    this.pixelRatio = 0.8,
    this.width,
    this.height,
    this.allowUpscaling = false,
  });

  final ImageProvider imageProvider;

  final double pixelRatio;

  /// The width the image should decode to and cache.
  final int? width;

  /// The height the image should decode to and cache.
  final int? height;

  /// Whether the [width] and [height] parameters should be clamped to the
  /// intrinsic width and height of the image.
  ///
  /// In general, it is better for memory usage to avoid scaling the image
  /// beyond its intrinsic dimensions when decoding it. If there is a need to
  /// scale an image larger, it is better to apply a scale to the canvas, or
  /// to use an appropriate [Image.fit].
  final bool allowUpscaling;

  @override
  ImageStreamCompleter load(AsciiImageKey key, DecoderCallback decode) {
    Future<ui.Codec> decoder(Uint8List bytes,
        {int? cacheWidth, int? cacheHeight, bool? allowUpscaling}) async {
      assert(
        cacheWidth == null && cacheHeight == null && allowUpscaling == null,
        'ResizeImage cannot be composed with another ImageProvider that applies '
        'cacheWidth, cacheHeight, or allowUpscaling.',
      );
      ui.Image? _asciiImage =
          await ImageAsciiArt(imageData: bytes, pixelRatio: pixelRatio)
              .toAsciiImage();
      final _byteData =
          await _asciiImage!.toByteData(format: ui.ImageByteFormat.png);
      return decode(
        _byteData!.buffer.asUint8List(),
        cacheWidth: width,
        cacheHeight: height,
        allowUpscaling: this.allowUpscaling,
      );
    }

    final ImageStreamCompleter completer =
        imageProvider.load(key._providerCacheKey, decoder);
    if (!kReleaseMode) {
      completer.debugLabel =
          '${completer.debugLabel} - Ascii(${key._width}×${key._height})';
    }
    return completer;
  }

  Future _grayScale(Uint8List bytes) async {
    im.Image? _image = im.decodeImage(bytes);
    if (_image == null) return bytes;
    _image = im.grayscale(_image);
    return im.encodePng(_image);
  }

  @override
  Future<AsciiImageKey> obtainKey(ImageConfiguration configuration) {
    Completer<AsciiImageKey>? completer;
    // If the imageProvider.obtainKey future is synchronous, then we will be able to fill in result with
    // a value before completer is initialized below.
    SynchronousFuture<AsciiImageKey>? result;
    imageProvider.obtainKey(configuration).then((Object key) {
      if (completer == null) {
        // This future has completed synchronously (completer was never assigned),
        // so we can directly create the synchronous result to return.
        result = SynchronousFuture<AsciiImageKey>(
            AsciiImageKey._(key, width, height));
      } else {
        // This future did not synchronously complete.
        completer.complete(AsciiImageKey._(key, width, height));
      }
    });
    if (result != null) {
      return result!;
    }
    // If the code reaches here, it means the imageProvider.obtainKey was not
    // completed sync, so we initialize the completer for completion later.
    completer = Completer<AsciiImageKey>();
    return completer.future;
  }
}
