import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import '../../constants/stickers.dart';
import '../../constants/theme.dart';

class StickersScreen extends StatefulWidget {
  @override
  State<StickersScreen> createState() => _StickersScreenState();

  File? _image;
  Uint8List? imgData;

  StickersScreen(this._image, [this.imgData]);
}

class _StickersScreenState extends State<StickersScreen> {
  File? imageFile;

  List<Map<String, dynamic>> spawnedStickers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Stickers'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  //uploadFileToServer(widget._image!);
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
          //mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  print("\n\nhit print spawn");
                  print(spawnedStickers);
                  print(spawnedStickers[0]['path']);
                },
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
            ),
            // const SizedBox(height: 100),
            // Container(child: _stickerView),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                padding: const EdgeInsets.all(5),
                color: kPrimaryColor.withOpacity(0.1),
                alignment: Alignment.center,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: stickersList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        print(stickersList[index]);

                        setState(() {
                          spawnedStickers.add(
                            {
                              'path': stickersList[index],
                              'top': MediaQuery.of(context).size.height * 0.4,
                              'left': MediaQuery.of(context).size.width * 0.4,
                            },
                          );
                        });

                        print(spawnedStickers);
                      },
                      child: Card(
                        // constraints: const BoxConstraints(
                        //   maxWidth: 100,
                        //   maxHeight: 100,
                        // ),
                        margin: const EdgeInsets.all(5),
                        child: Image.asset(stickersList[index]),
                        // decoration: BoxDecoration(
                        //   border: Border.all(width: 2, color: kPrimaryColor),
                        // ),
                      ),
                    );
                  },
                ),
              ),
            ),
            (spawnedStickers.length >= 1)
                ? Positioned(
                    top: spawnedStickers[0]['top'],
                    left: spawnedStickers[0]['left'],
                    child: GestureDetector(
                      onTap: () {
                        print('clicked ' + spawnedStickers[0]['path']);
                      },
                      onVerticalDragUpdate: (DragUpdateDetails dud) {
                        setState(() {
                          spawnedStickers[0]['top'] = dud.globalPosition.dy;
                          spawnedStickers[0]['left'] = dud.globalPosition.dx;
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image.asset(spawnedStickers[0]['path']),
                      ),
                    ),
                  )
                : Container(),
            (spawnedStickers.length >= 2)
                ? Positioned(
                    top: spawnedStickers[1]['top'],
                    left: spawnedStickers[1]['left'],
                    child: GestureDetector(
                      onTap: () {
                        print('clicked ' + spawnedStickers[1]['path']);
                      },
                      onVerticalDragUpdate: (DragUpdateDetails dud) {
                        setState(() {
                          spawnedStickers[1]['top'] = dud.globalPosition.dy;
                          spawnedStickers[1]['left'] = dud.globalPosition.dx;
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image.asset(spawnedStickers[1]['path']),
                      ),
                    ),
                  )
                : Container(),
            (spawnedStickers.length >= 3)
                ? Positioned(
                    top: spawnedStickers[2]['top'],
                    left: spawnedStickers[2]['left'],
                    child: GestureDetector(
                      onTap: () {
                        print('clicked ' + spawnedStickers[2]['path']);
                      },
                      onVerticalDragUpdate: (DragUpdateDetails dud) {
                        setState(() {
                          spawnedStickers[2]['top'] = dud.globalPosition.dy;
                          spawnedStickers[2]['left'] = dud.globalPosition.dx;
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image.asset(spawnedStickers[2]['path']),
                      ),
                    ),
                  )
                : Container(),

            // Stack(
            //   children: List.generate(spawnedStickers.length, (index) {
            //     return GestureDetector(
            //       onTap: () {
            //         print('clicked ' + spawnedStickers[index]['path']);
            //       },
            //       onVerticalDragUpdate: (DragUpdateDetails dud) {
            //         setState(() {
            //           spawnedStickers[index]['top'] = dud.globalPosition.dy;
            //           spawnedStickers[index]['left'] = dud.globalPosition.dx;
            //         });
            //       },
            //       child: Positioned(
            //         child: Container(
            //           width: 100,
            //           height: 100,
            //           child: Image.asset(spawnedStickers[index]['path']),
            //         ),
            //       ),
            //     );
            //   }),
            // ),
            // ListView.builder(
            //   itemCount: spawnedStickers.length,
            //   itemBuilder: (context, index) {
            //     return Positioned(
            //       top: spawnedStickers[index]['top'],
            //       left: spawnedStickers[index]['left'],
            //       child: Card(
            //         child: Image.asset(spawnedStickers[index]['path']),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
