import 'dart:async';

import 'package:http/http.dart' as http;

Future<bool> isURIALive(String uri) async {
  try {
    var response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      print("URL is alive: " + uri);
      return true;
    }
  } on Exception {
    print("URL is not alive: " + uri);
    return false;
  }

  print("URL is not alive: " + uri);
  return false;
}
