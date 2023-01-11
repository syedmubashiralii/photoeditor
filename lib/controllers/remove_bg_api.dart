import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/processed_image.dart';

Future<String?> removeBGPostRequest(File imageFile, String postURI) async {
  String? base64String;

  // initialize multipart post request
  var request = http.MultipartRequest("POST", Uri.parse(postURI));

  // add image file to request
  request.files.add(await http.MultipartFile.fromPath('img', imageFile.path,
      filename: imageFile.path));

  // send request
  request.send().then((response) {
    print("Uploading image: $postURI");
    // listen for response stream
    http.Response.fromStream(response).then((value) {
      print("receive response");
      // print response on OK
      if (value.statusCode == 200) {
        print("response ok");
        ProcessedImage imgResponse;

        // print("Response Headers:");
        // print(value.headers);

        Map<String, dynamic> imgResponseMap = json.decode(value.body);
        imgResponse = ProcessedImage.fromJson(imgResponseMap);

        // print("Response (Base64):");
        // print(imgResponse.s0);

        base64String = imgResponse.s0!;
      }
    });
  });

  return base64String;
}
