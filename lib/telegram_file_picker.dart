library telegram_file_picker;

import 'package:flutter/material.dart';

import 'gallery_picker.dart';

class TelegramFilePicker {
  static Future show({required BuildContext context}) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GalleryPicker();
      },
    );
  }
}
