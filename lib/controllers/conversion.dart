import 'dart:convert';
import 'dart:typed_data';

Uint8List convertBase64ToUint(String base64String) {
  Uint8List imgBytes = const Base64Decoder().convert(base64String);
  imgBytes = Uint8List.fromList(imgBytes);
  print("Response (Unsigned Int8 List):");
  print(imgBytes);

  return imgBytes;
}

// Uint8List convertImageFileToUint(File imageFile) {
//   Uint8List imgBytesList;

//   return imgBytes;
// }
