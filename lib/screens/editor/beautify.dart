import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../constants/theme.dart';
import '../../constants/theme.dart';
import '../../constants/urls.dart';
import '../../controllers/check_connectivity.dart';
import '../../controllers/check_uri.dart';
import '../../models/processed_image.dart';
import 'package:http/http.dart' as http;

class BeautifyScreen extends StatefulWidget {
  @override
  State<BeautifyScreen> createState() => _BeautifyScreenState();

  final File? _image;
  BeautifyScreen(this._image);
}

class _BeautifyScreenState extends State<BeautifyScreen> {
  // display status of ongoing actions
  String statusMessage = "";
  bool hasRequestError = false;
  // data type for storing image bytes
  Uint8List? imgBytes;

  Color _currentColor = Colors.red;
  bool _needEyeliner = false;

  void changeColor(Color color) => setState(() => _currentColor = color);

  void navigateBack(BuildContext context) {
    Future.delayed(
       Duration(seconds: requestTimeoutSeconds),
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

  void uploadImageToServer(File image,
      {bool useEyeLiner = false, Color lipstickColor = Colors.red}) async {
    String activePostServerURI = "";
    bool isAnyServerOnline = false;

    updateStatusDisplay(context, "Beautifying face.\nPlease wait...", false);

    if (mounted) {
      setState(() {
        imgBytes = null;
      });
    }

    if (await isDeviceConnected()) {
      if (await isURIALive(makeupAPI)) {
        if (mounted) {
          setState(() {
            isAnyServerOnline = true;
            activePostServerURI = makeupPostAPI;
          });
        }
      } else {
        navigateBack(context);
      }

      if (isAnyServerOnline) {
        print("Uploading image: $activePostServerURI");

        // convert boolean to '1' or '0'
        String _eyeLiner = useEyeLiner ? '1' : '0';
        // convert to hex string
        String _lipstickColor = lipstickColor.value.toRadixString(16);
        // truncate first two characters to get proper string
        _lipstickColor =
            '#' + _lipstickColor.substring(2, _lipstickColor.length);
        print(_eyeLiner);
        print(_lipstickColor);

        // build multipart request and send
        var request =
            http.MultipartRequest("POST", Uri.parse(activePostServerURI));
        request.files.add(await http.MultipartFile.fromPath('img', image.path,
            filename: image.path));
        request.fields['eye_lyner'] = _eyeLiner;
        request.fields['color'] = _lipstickColor;

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
        title: const Text('Beautify'),
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
                  child: (imgBytes != null)
                      ? Image.memory(imgBytes!)
                      : Column(
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
                        ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 3,
                      color: (hasRequestError) ? kErrorColor : kPrimaryColor,
                    ),
                  ),
                ),
              ),
              (imgBytes != null)
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            child: const Text(
                              'Change Lipstick Color',
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: _currentColor,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Select a color',
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: normalFontSize,
                                      ),
                                    ),
                                    content: SingleChildScrollView(
                                      child: BlockPicker(
                                        pickerColor: _currentColor,
                                        onColorChanged: (color) {
                                          changeColor(color);
                                          Navigator.pop(context);
                                          uploadImageToServer(
                                            widget._image!,
                                            useEyeLiner: _needEyeliner,
                                            lipstickColor: _currentColor,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Use Eye Liner',
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: smallFontSize,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Switch(
                                value: _needEyeliner,
                                onChanged: (bool newValue) {
                                  setState(() {
                                    _needEyeliner = newValue;
                                  });
                                  Future.delayed(
                                    const Duration(seconds: 1),
                                    () => {
                                      uploadImageToServer(
                                        widget._image!,
                                        useEyeLiner: _needEyeliner,
                                        lipstickColor: _currentColor,
                                      ),
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
