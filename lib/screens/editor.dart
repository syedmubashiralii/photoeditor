import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/rendering.dart';
import '../constants/filter_presets.dart';
import '../constants/theme.dart';
import '../controllers/image_functions.dart';
import '../screens/album.dart';
import '../screens/editor/stickers.dart';
import '../screens/editor/beautify.dart';
import '../screens/editor/future_face.dart';
import '../screens/editor/remove_bg.dart';
import 'package:image/image.dart' as imageLib;
import 'package:photofilters/photofilters.dart';

class EditorScreen extends StatefulWidget {
  @override
  State<EditorScreen> createState() => _EditorScreenState();

  File? _image;
  Uint8List? imgData;

  EditorScreen(this._image, [this.imgData]);
}

class _EditorScreenState extends State<EditorScreen> {
  Future cropAndResizeImage(File imageFileToCrop) async {
    // File? croppedImage = await ImageCropper.cropImage(
    //     sourcePath: imageFileToCrop.path,
    //     aspectRatioPresets: Platform.isAndroid
    //         ? [
    //             CropAspectRatioPreset.original,
    //             CropAspectRatioPreset.square,
    //             CropAspectRatioPreset.ratio3x2,
    //             CropAspectRatioPreset.ratio4x3,
    //             CropAspectRatioPreset.ratio16x9
    //           ]
    //         : [
    //             CropAspectRatioPreset.original,
    //             CropAspectRatioPreset.square,
    //             CropAspectRatioPreset.ratio3x2,
    //             CropAspectRatioPreset.ratio4x3,
    //             CropAspectRatioPreset.ratio16x9
    //           ],
    //     androidUiSettings: const AndroidUiSettings(
    //         toolbarTitle: 'Resize Image',
    //         toolbarColor: kPrimaryColor,
    //         toolbarWidgetColor: Colors.white,
    //         activeControlsWidgetColor: kPrimaryColor,
    //         statusBarColor: kPrimaryColor,
    //         initAspectRatio: CropAspectRatioPreset.original,
    //         lockAspectRatio: false),
    //     iosUiSettings: const IOSUiSettings(
    //       title: 'Resize Image',
    //     ));

    // setState(() {
    //   if (croppedImage != null) {
    //     print("Cropper: Image cropped.");
    //     widget._image = croppedImage;
    //   } else {
    //     print("Cropper: Operation discarded.");
    //   }
    // });
  }

  Future openPhotoFilters(BuildContext context, File image) async {
    var filteredImage = imageLib.decodeImage(image.readAsBytesSync());

    File? imagefile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
          title: const Text("Add Effects"),
          appBarColor: Colors.blue,
          image: filteredImage!,
          filters: customFiltersPreset,
          // filters: presetConvolutionFiltersList,
          filename: widget._image!.path,
          loader: const Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );

    // retrieve image file from filters and set it as image
    // if (imagefile != null && imagefile.containsKey('image_filtered')) {
    //   print("hit imagefile check");
    //   setState(() {
    //     print("hit image_filtered key setstate");
    //     widget._image = imagefile['image_filtered'];
    //   });
    //   print(imageFile!.path);
    // }
  }

  Future<void> compressImageFile() async {
    final targetPath = widget._image!.absolute.path + "temp.jpg";
    final imageFile = await compressImageFunc(widget._image!, targetPath);

    setState(() {
      widget._image = imageFile;
    });
  }

  @override
  void initState() {
    super.initState();
    compressImageFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture Editor'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AlbumScreen(widget._image)));
                },
                icon: const Icon(Icons.check, size: 30),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.width,
                ),
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(10),
                child: (widget._image != null)
                    ? Image.file(widget._image!)
                    : const Text(
                        "Error loading image file.\nPlease try again.",
                        style: TextStyle(
                          color: kTextColor,
                          fontSize: normalFontSize,
                        ),
                      ),
                decoration: BoxDecoration(
                  border: Border.all(width: 3, color: kPrimaryColor),
                ),
              ),
            ),

            // Align(
            //   alignment: Alignment.center,
            //   child: loadInteractivePhotoViewer(context, widget._image),
            // ),
            // const SizedBox(height: 100),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: kPrimaryColor.withOpacity(0.1),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          cropAndResizeImage(widget._image!);
                        },
                        child: buildMenuItem('Resize', Icons.crop),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RemoveBackgroundScreen(widget._image)));
                        },
                        child: buildMenuItem('Background', Icons.image),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FutureFaceScreen(widget._image)));
                        },
                        child: buildMenuItem('Age', Icons.face),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BeautifyScreen(widget._image)));
                        },
                        child: buildMenuItem('Beautify', Icons.brush),
                      ),
                      InkWell(
                        onTap: () async {
                          openPhotoFilters(context, widget._image!);
                        },
                        child: buildMenuItem('Filters', Icons.filter),
                      ),
                      // InkWell(
                      //   onTap: () {},
                      //   child: buildMenuItem('Text', Icons.font_download),
                      // ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      StickersScreen(widget._image)));
                        },
                        child: buildMenuItem('Stickers', Icons.celebration),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(String title, IconData iconData) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 80,
      ),
      width: 110,
      margin: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: kPrimaryColor,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: menuFontSize,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 2,
          color: kPrimaryColor,
        ),
      ),
    );
  }
}
