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
        url: 'https://postman-echo.com/post', bytes: bytes);
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
