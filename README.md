# flutter_photo_uploader

Flutter Photo Uploader is a Flutter package which uses the Camera package to take a picture, crop it, and post the data to an endpoint. It's simple and lightweight! It's currently a work in progress with tests being added in the near future. Functionality is also pretty limited right now but it is very easy to use. Images can only be cropped as squares with additional functionality being added to handle all types of cropping.


## Usage

To use this package, add flutter_photo_uploader as a dependency in your pubsec.yaml file. 
For android, You must have to update minSdkVersion to 21 (or higher). On iOS, lines below have to be added inside ios/Runner/Info.plist in order the access the camera.
```
<key>NSCameraUsageDescription</key>
<string>Explanation on why the camera access is needed.</string>
```

## Example
```
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

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
        cameras: cameras,
        onUpload: (ui.Image image) async {
          UploadHelper _uploadHelper = new UploadHelper();
          Uint8List bytes = await _uploadHelper.getPngByteData(image: image);
          var response = await _uploadHelper.uploadBytes(url: 'https://postman-echo.com/post', bytes: bytes);
          print(response);
        }),
      ),
  );
}
```

## Issues

Please email any issues, bugs, or additional features you would like to see built to arindone@nubeer.io.

## Contributing

If you wish to contribute to this package you may fork the repository and make a pull request to this repository.
<br><br>**Note**: Testing by running `flutter test --coverage` will generate `coverage/lcov.info`. Running `bash test-coverage.sh` will parse the `lcov.info` file into JSON format. This happens automatically within the CI/CD pipeline on a pull request to master but it is always good to test locally.
