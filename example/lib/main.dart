import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:photo_uploader/photo_uploader.dart';
import 'package:photo_uploader/upload_helper.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // A future that will call an endpoint, passing in your image byte data
  Future upload(ui.Image image) async {
    UploadHelper _uploadHelper = new UploadHelper();
    Uint8List bytes = await _uploadHelper.getPngByteData(image: image);
    var response = await _uploadHelper.uploadBytes(
        url: 'https://postman-echo.com/post', bytes: bytes);
    print(response);
  }

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
          onUpload: upload
      ),
    ),
  );
}
