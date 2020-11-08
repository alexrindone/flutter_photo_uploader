import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_uploader/photo_uploader.dart';
import 'dart:ui' as ui;
import 'package:photo_uploader/upload_helper.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

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
          // Pass the appropriate camera to the TakePictureScreen widget.
          camera: firstCamera,
          cameras: cameras,
          onUpload: upload
      ),
    ),
  );
}
