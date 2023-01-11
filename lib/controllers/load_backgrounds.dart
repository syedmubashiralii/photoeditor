import 'dart:convert';
import '../models/background_image.dart';
import 'package:http/http.dart' as http;

Future<List<BackgroundImage>> fetchBackgroundImagesFromServer(
    String apiURL) async {
  // list to store backgrounds retrieved from server
  List<BackgroundImage> backgroundImages = [];

  // send get request
  final response =
      await http.get(Uri.parse(apiURL)).timeout(const Duration(seconds: 60));

  if (response.statusCode == 200) {
    // response OK
    print("Response OK: Downloading images");

    // decode response
    var responseData = json.decode(response.body);

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

      // add background to list
      backgroundImages.add(bgImg);
    }
  } else {
    print("Bad Response: Connection Error");
  }

  return backgroundImages;
}
