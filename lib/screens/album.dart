import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../constants/theme.dart';

class AlbumScreen extends StatefulWidget {
  @override
  State<AlbumScreen> createState() => _AlbumScreenState();

  File? _image;

  AlbumScreen(this._image);
}

class _AlbumScreenState extends State<AlbumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Album'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Share",
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: normalFontSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(40),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Image.file(widget._image!),
                decoration: BoxDecoration(
                  border: Border.all(width: 3, color: kPrimaryColor),
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 200,
                ),
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Save to Gallery',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: normalFontSize,
                    color: kTextColor,
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: kTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
