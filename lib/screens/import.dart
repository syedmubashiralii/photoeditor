import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/theme.dart';
import '../screens/editor.dart';

class ImportScreen extends StatefulWidget {
  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  File? _image;
  final picker = ImagePicker();

  Future _pickImage(ImageSource source) async {
    final pickedImage = await picker.pickImage(source: source);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
        print("Picker: Image loaded.");
      } else {
        print("Picker: No image selected.");
      }
    });

    if (_image != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EditorScreen(_image)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Image'),
      ),
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          // ignore: sized_box_for_whitespace
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: InkWell(
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Gallery',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: subtitleFontSize, color: kTextColor),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2, color: kTextColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: InkWell(
                    onTap: () {
                      _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Camera',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: subtitleFontSize, color: kTextColor),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2, color: kTextColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                (_image == null)
                    ? const Text(
                        "No image selected.",
                        style: TextStyle(
                          fontSize: normalFontSize,
                          color: kTextColor,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
