// import 'package:flutter/rendering.dart';

// // void convertWidgetToImage() async {
// //   RenderRepaintBoundary repaintBoundary =
// //       _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
// //   ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1);
// //   ByteData? byteData =
// //       await boxImage.toByteData(format: ui.ImageByteFormat.png);
// //   Uint8List uint8list = byteData!.buffer.asUint8List();

// //   Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //           builder: (context) => EditImageScreen(widget._image, uint8list)));
// //   // var image = MemoryImage(uint8list);
// //   // Navigator.of(_repaintKey.currentContext!)
// //   // .push(MaterialPageRoute(builder: (context) => EditImageScreen(image)));
// // }

import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> compressImageFunc(File file, String targetPath) async {
  var result;
  result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    minWidth: 600,
    minHeight: 600,
    quality: 60,
  );

  return result;
}
