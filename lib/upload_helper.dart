import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:ui' as ui;
import 'package:camera/camera.dart' as cam;
import 'package:meta/meta.dart';

class UploadHelper extends http.BaseClient {
  Map<String, String> requestHeaders;

  static UploadHelper _instance;

  factory UploadHelper() => _instance ??= new UploadHelper._();

  UploadHelper._();

  final client = http.Client();

  Map get headers {
    return this.requestHeaders;
  }

  set headers(Map values) {
    this.requestHeaders = values;
  }

  // wrapper for camera available cameras method
  Future<bool> available() async {
    return await cam.availableCameras().then((value) {
      // return true if we have a cameras array with camera otherwise false
      return value != null && value.length > 0 ? true : false;
    }).catchError((err) {
      return false;
    });
  }

  void resetHeaders() {
    this.headers = this.headers = new Map<String, String>();
  }

  // add a header key value pair
  void addHeader(String key, String value) {
    // if headers is null, set it to an the string and value
    if (this.headers == null) {
      this.headers = new Map<String, String>();
    }

    Map tempHeaders = this.headers;

    // update temp headers with key value
    tempHeaders.update(
      key,
      (existingValue) => value,
      ifAbsent: () => value,
    );

    // set headers from temp headers
    this.headers = tempHeaders;
  }

  Future<dynamic> uploadJSON({String url, String byteString}) async {
    if (byteString == null) {
      throw Exception('ByteString missing for image');
    }
    if (url == null) {
      throw Exception('Url missing for request');
    }

    Map body = new Map<String, String>();
    body['image_data'] = byteString;
    final response = await this.client.post(url,
        headers: this.headers, body: jsonEncode(body), encoding: Utf8Codec());
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response then parse the JSON.
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<dynamic> uploadBytes(
      {@required String url,
      @required Uint8List bytes,
      targetWidth = 600,
      targetHeight = 600}) async {
    // this is where we can cap the size to be uploaded
    var imageCodec = await ui.instantiateImageCodec(bytes,
        targetHeight: targetHeight, targetWidth: targetWidth);

    // get the next frame of the image (should be the new size now specified from above)
    ui.FrameInfo frameInfo = await imageCodec.getNextFrame();

    // get the image from the frame info
    ui.Image newImage = frameInfo.image;

    // get byte data from the new image and give it a png format
    ByteData newByteData = await newImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    // take the byte data and make it a Uint8List
    Uint8List newByteList = newByteData.buffer.asUint8List();

    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(url));
    http.MultipartFile file = http.MultipartFile.fromBytes(
      'image_data',
      newByteList,
      filename: 'image.png',
      contentType: new MediaType('image', 'png'),
    );

    request.files.add(file);

    // if headers aren't null, use them
    if (this.headers != null) request.headers.addAll(this.headers);

    http.Response response;

    try {
      http.StreamedResponse streamedResponse = await request.send();

      response = await http.Response.fromStream(streamedResponse);
    } catch (e) {
      print(e);
    } finally {
      // release the resource
      newImage.dispose();
    }

    return response;
  }

  Future<String> getBase64PngByteData({ui.Image image}) async {
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    return base64Encode(pngBytes);
  }

  Future<Uint8List> getPngByteData({ui.Image image}) async {
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
  }

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return this.client.send(request);
  }
}
