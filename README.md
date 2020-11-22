# flutter_photo_uploader

Flutter Photo Uploader is a Flutter package which uses the Camera package to take a picture, crop it, and post the data to an endpoint. It's simple and lightweight! You can specify a target width and target height for the image during upload as well. It's currently a work in progress with tests being added in the near future. Functionality is also pretty limited right now but it is very easy to use. Images can only be cropped as squares with additional functionality being added to handle all types of cropping.


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
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:photo_uploader/photo_uploader.dart';
import 'package:photo_uploader/upload_helper.dart';

void main() {
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  UploadHelper helper = new UploadHelper();
  Future<bool> storedFuture;

  @override
  void initState() {
    super.initState();
    storedFuture = helper.available();
  }

  Future upload(ui.Image image) async {
    Uint8List bytes = await helper.getPngByteData(image: image);
    var response = await helper.uploadBytes(
        url: 'https://postman-echo.com/post', bytes: bytes, targetWidth: 100, targetHeight: 100);
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: storedFuture,
        builder: (context, snapshot) {
          // if we have access to cameras, show TakePictureScreen widget
          if (snapshot.hasData && snapshot.data == true) {
            return TakePictureScreen(onUpload: upload);
          } else {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.height,
              child: Center(
                  child: Text(
                'Cameras not found.',
                style: TextStyle(color: Colors.white, fontSize: 24),
              )),
            );
          }
        });
  }
}
```

## Issues

Please email any issues, bugs, or additional features you would like to see built to arindone@nubeer.io.

## Contributing

If you wish to contribute to this package you may fork the repository and make a pull request to this repository.