import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:photo_uploader/photo_uploader.dart';
import 'package:photo_uploader/upload_helper.dart';
import 'dart:convert';

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

  // a future to pass in as the upload function
  Future upload(ui.Image image) async {
    try {
      Uint8List bytes = await helper.getPngByteData(image: image);

      var response = await helper.uploadBytes(
          url: 'https://postman-echo.com/post', bytes: bytes, targetWidth: 100, targetHeight: 100);

      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      print(decodedResponse);

      image.dispose();

    } catch(e) {
      print(e);
    }
  }

  // use a future to make sure we have access to camera before showing a screen
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: storedFuture,
        builder: (context, snapshot) {
          List<Widget> children;
          // if we have access to cameras, show TakePictureScreen widget
          if (snapshot.hasData && snapshot.data) {
            return TakePictureScreen(onUpload: upload);
          } else if (snapshot.hasError) {
            // if we got an error when trying to check cameras
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else if (snapshot.hasData && !snapshot.data) {
            children = <Widget>[
              Text(
                'Cameras not found.',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ];
          } else {
            children = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          // default return either cameras not found, error, or loading
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.height,
            child: Column(
              children: children,
            ),
          );
        });
  }
}
