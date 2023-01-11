import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../constants/theme.dart';
import '../../constants/urls.dart';
import '../../controllers/check_connectivity.dart';
import '../../controllers/check_uri.dart';
import '../../models/processed_image.dart';
import 'package:http/http.dart' as http;

import '../editor.dart';

class FutureFaceScreen extends StatefulWidget {
  @override
  State<FutureFaceScreen> createState() => _FutureFaceScreenState();

  File? _image;

  FutureFaceScreen(this._image);
}

class _FutureFaceScreenState extends State<FutureFaceScreen> {
  // display status of ongoing actions
  String statusMessage = "";
  bool hasRequestError = false;
  // data type for storing image bytes
  Uint8List? imgBytes;

  // for controlling slider
  double _currentSliderValue = 65.0;

  void navigateBack(BuildContext context) {
    Future.delayed(
      const Duration(seconds: requestTimeoutSeconds),
      () => {
        Navigator.pop(context),
      },
    );
  }

  void updateStatusDisplay(
      BuildContext context, String message, bool isErrorMsg) {
    setState(() {
      statusMessage = message;
      if (isErrorMsg) hasRequestError = true;
    });

    // if there's an error, navigate to previous screen
    if (isErrorMsg) navigateBack(context);
  }

  void uploadImageToServer(File image, [double ageValue = 65.0]) async {
    String activePostServerURI = "";
    bool isAnyServerOnline = false;

    updateStatusDisplay(context, "Applying age filter.\nPlease wait...", false);

    if (await isDeviceConnected()) {
      if (await isURIALive(futureFaceAPI)) {
        if (mounted) {
          setState(() {
            isAnyServerOnline = true;
            activePostServerURI = futureFacePostAPI;
          });
        }
      } else {
        navigateBack(context);
      }

      if (isAnyServerOnline) {
        print("Uploading image: $activePostServerURI");

        // build multipart request and send
        var request =
            http.MultipartRequest("POST", Uri.parse(activePostServerURI));
        request.files.add(await http.MultipartFile.fromPath('img', image.path,
            filename: image.path));
        request.fields['age'] = ageValue.toInt().toString();

        request.send().then((response) {
          // listen for response stream
          http.Response.fromStream(response).then((value) {
            // response OK
            if (value.statusCode == 200) {
              print("Response Headers:");
              print(value.headers);

              print("Response (Base64):");
              Map<String, dynamic> imgResponseMap = json.decode(value.body);
              ProcessedImage imgResponse =
                  ProcessedImage.fromJson(imgResponseMap);
              print(imgResponse.s0);

              if (imgResponse.s0 != null) {
                if (mounted) {
                  setState(() {
                    imgBytes = const Base64Decoder().convert(imgResponse.s0!);
                    imgBytes = Uint8List.fromList(imgBytes!);
                    print("Response (Unsigned Int8 List):");
                    print(imgBytes);
                  });
                }
              } else {
                if (mounted) {
                  updateStatusDisplay(context,
                      "Error retrieving data.\nPlease try again.", true);
                }
              }
            } else {
              if (mounted) {
                updateStatusDisplay(
                    context, "Error uploading file.\nPlease try again.", true);
              }
            }
          });
        });
      } else {
        if (mounted) {
          updateStatusDisplay(
              context, "Resource server is down.\nPlease try later.", true);
        }
      }
    } else {
      if (mounted) {
        updateStatusDisplay(
            context,
            "No internet connectivity.\nPlease ensure your device is connected to the internet.",
            true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    uploadImageToServer(widget._image!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Future Face'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditorScreen(widget._image)));
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
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.width,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: (imgBytes == null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color:
                                  (hasRequestError) ? kErrorColor : kTextColor,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              statusMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: (hasRequestError)
                                    ? kErrorColor
                                    : kTextColor,
                                fontSize: smallFontSize,
                              ),
                            ),
                          ],
                        )
                      : Image.memory(imgBytes!),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 3,
                      color: (hasRequestError) ? kErrorColor : kPrimaryColor,
                    ),
                  ),
                ),
              ),
              // (imgBytes != null) ?
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Drag slider to adjust age',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: smallFontSize,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: _currentSliderValue,
                      min: 35,
                      max: 65,
                      divisions: 3,
                      label: _currentSliderValue.round().toString(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _currentSliderValue = value;
                          });
                        }
                      },
                      onChangeEnd: (value) {
                        if (mounted) {
                          setState(() {
                            imgBytes = null;
                          });
                        }
                        uploadImageToServer(
                            widget._image!, _currentSliderValue);
                      },
                    ),
                  ],
                ),
              )
              // : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
