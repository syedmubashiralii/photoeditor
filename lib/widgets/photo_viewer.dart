import 'dart:io';

import 'package:flutter/material.dart';
import '../constants/theme.dart';

Widget loadInteractivePhotoViewer(BuildContext context, File? imageFile) {
  return Container(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.width * 1.1,
    ),
    padding: const EdgeInsets.all(5),
    margin: const EdgeInsets.all(10),
    child: (imageFile != null)
        ? InteractiveViewer(
            child: Image.file(imageFile),
          )
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
  );
}
