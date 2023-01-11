import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../constants/theme.dart';
import '../../constants/urls.dart';
import '../../controllers/check_connectivity.dart';
import '../../controllers/check_uri.dart';
import '../../controllers/remove_bg_api.dart';
import '../../models/background_image.dart';
import '../../models/processed_image.dart';
import 'package:http/http.dart' as http;

import '../editor.dart';

class RemoveBackgroundScreen extends StatefulWidget {
  @override
  State<RemoveBackgroundScreen> createState() => _RemoveBackgroundScreenState();

  final File? _image;
  RemoveBackgroundScreen(this._image);
}

class _RemoveBackgroundScreenState extends State<RemoveBackgroundScreen> {
  // display status of ongoing actions
  String statusMessage = "";
  bool hasRequestError = false;
  // data type for storing image bytes
  Uint8List? imgBytes;

  CachedNetworkImage? backgroundImage;

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

    // enable it after testing done
    // if there's an error, navigate to previous screen
    // if (isErrorMsg) navigateBack(context);
  }

  void uploadImageToServer(File image) async {
    String activePostServerURI = "";
    bool isAnyServerOnline = false;

    updateStatusDisplay(context, "Removing background.\nPlease wait...", false);

    if (await isDeviceConnected()) {
      if (await isURIALive(removeBgAPI)) {
        if (mounted) {
          setState(() {
            isAnyServerOnline = true;
            activePostServerURI = removeBgPostAPI;
          });
        }
      } else if (await isURIALive(altRemoveBgAPI)) {
        if (mounted) {
          setState(() {
            isAnyServerOnline = true;
            activePostServerURI = removeBgPostAPI;
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
        print("server down");
        if (mounted) {
          updateStatusDisplay(
              context, "Resource server is down.\nPlease try later.", true);
        }
      }
    } else {
      print("no internet");
      if (mounted) {
        updateStatusDisplay(
            context,
            "No internet connectivity.\nPlease ensure your device is connected to the internet.",
            true);
      }
    }
  }

  Future<List<BackgroundImage>> getRequest() async {
    final response = await http.get(Uri.parse(backgroundImagesAPI)).timeout(
          const Duration(seconds: 60),
        );

    if (response.statusCode == 200) {
      print("Response OK: Downloading images");
    } else {
      print("Bad Response: Connection Error");
    }

    var responseData = json.decode(response.body);

    //Creating a list to store input data;
    List<BackgroundImage> backgroundImages = [];
    for (var entry in responseData) {
      BackgroundImage bgImg = BackgroundImage(
        id: entry['id'],
        name: entry['name'],
        category: entry['category'],
        template_json_link: entry['template_json_link'],
        thumbnail_link: entry['thumbnail_link'],
        created_at: entry['created_at'],
        updated_at: entry['updated_at'],
      );

      //Adding user to the list.
      backgroundImages.add(bgImg);
    }
    return backgroundImages;
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
        title: const Text('Change Background'),
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
                  // implement repaintboundary with key over background container
                  // save repaintboundary to file and return it to editor screen's constructor
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
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.width,
                ),
                margin: const EdgeInsets.all(40),
                child: FutureBuilder(
                  future: removeBGPostRequest(widget._image!, removeBgPostAPI),
                  builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: (hasRequestError) ? kErrorColor : kTextColor,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            statusMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  (hasRequestError) ? kErrorColor : kTextColor,
                              fontSize: smallFontSize,
                            ),
                          ),
                        ],
                      );
                    } else {
                      print(snapshot.data);
                      return Image.memory(snapshot.data);
                    }
                  },
                ),
                // (imgBytes != null)
                //     ? Image.memory(imgBytes!)
                //     : Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: [
                //           CircularProgressIndicator(
                //             color: (hasRequestError) ? kErrorColor : kTextColor,
                //           ),
                //           const SizedBox(height: 20),
                //           Text(
                //             statusMessage,
                //             textAlign: TextAlign.center,
                //             style: TextStyle(
                //               color:
                //                   (hasRequestError) ? kErrorColor : kTextColor,
                //               fontSize: smallFontSize,
                //             ),
                //           ),
                //         ],
                //       ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 3,
                    color: (hasRequestError) ? kErrorColor : kPrimaryColor,
                  ),
                  image: (backgroundImage != null)
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                              backgroundImage!.imageUrl),
                          fit: BoxFit.fill,
                        )
                      : const DecorationImage(
                          image: AssetImage(
                            'assets/images/no_bg.png',
                          ),
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ),
            (imgBytes != null)
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 100,
                      ),
                      color: kPrimaryColor.withOpacity(0.1),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: FutureBuilder(
                          future: getRequest(),
                          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                            if (snapshot.data == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: snapshot.data.length,
                                itemBuilder: (ctx, index) =>
                                    buildBackgroundItem(
                                        snapshot.data[index].thumbnail_link,
                                        snapshot
                                            .data[index].template_json_link),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  String buildBackgroundThumbnailURL(String itemThumbnailURL) {
    return backgroundImagesBaseURL + itemThumbnailURL;
  }

  String buildBackgroundImageURL(String itemImageURL) {
    return backgroundImagesBaseURL + itemImageURL;
  }

  Widget buildBackgroundItem(String itemThumbnailURL, String itemImageURL) {
    String _backgroundThumbnailPath = buildBackgroundImageURL(itemThumbnailURL);
    String _backgroundImagePath = buildBackgroundImageURL(itemImageURL);

    return InkWell(
      onTap: () {
        setState(() {
          backgroundImage = CachedNetworkImage(
            imageUrl: _backgroundImagePath,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        });
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.all(10),
        child: Image.network(
          _backgroundThumbnailPath,
          fit: BoxFit.fill,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: kPrimaryColor,
          ),
        ),
      ),
    );
  }
}
