import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'crop_preview.dart';
import 'package:image_picker/image_picker.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  // passed in function for upload button
  final Function(ui.Image) onUpload;

  const TakePictureScreen({Key key, @required this.onUpload}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras;
  int selectedCameraIdx = 0; // set default front camera

  final picker = ImagePicker();

  String selectedImage;

  Future getImage() async {
    File pickedFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);

    setState(() {
      if (pickedFile != null) {
        selectedImage = pickedFile.path;
      }
    });
  }

  void setCameraState(int index) async {
    // get available cameras, and set the cameras with the result
    await availableCameras().then((result) {
      cameras = result;
    }).catchError((e) {
      throw Exception('Camera(s) not available');
    });

    if (cameras == null || cameras.length == 0) {
      throw Exception('Camera(s) not available');
    }

    // check for controller, if it's not null then dispose it
    if (_controller != null) {
      await _controller.dispose();
    }

    // set camera controller...eventually allow for different resolutions here
    CameraController _camCtrl = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras[index],
      // Define the resolution to use.
      ResolutionPreset.max,
    );

    // set state asyncronously
    setState(() {
      _controller = _camCtrl;
      selectedCameraIdx = index;
      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  void initState() {
    super.initState();
    // set the initial state of the cameras
    setCameraState(selectedCameraIdx);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!_controller.value.isInitialized) {
              return Container();
            }
            return Container(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Container(
                  width: size.width,
                  height: size.width / _controller.value.aspectRatio,
                  child: Stack(
                    children: <Widget>[
                      CameraPreview(_controller),
                      Positioned(
                        width: size.width,
                        bottom: 70, // probably needs to be fixed later
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              child: Icon(
                                Icons.switch_camera,
                                color: Colors.white,
                                size: 28.0,
                              ),
                              onTap: () async {
                                // toggle the state of the camera from front to back
                                // if it was 0, set it to 1, if it was 1, set it to 0
                                int toggleIndex =
                                    selectedCameraIdx == 0 ? 1 : 0;
                                setCameraState(toggleIndex);
                              },
                            ),
                            Center(
                                child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                ClipOval(
                                  child: Material(
                                    color: Colors.grey[100], // button color
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                ),
                                ClipOval(
                                  child: Material(
                                      color: Colors.grey[350], // button color
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                      )),
                                ),
                                Opacity(
                                  opacity: 0.1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black,
                                          blurRadius: 1.0,
                                          spreadRadius: 1.0,
                                        )
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Material(
                                          color:
                                              Colors.grey[100], // button color
                                          child: SizedBox(
                                            width: 36,
                                            height: 36,
                                          )),
                                    ),
                                  ),
                                ),
                                ClipOval(
                                  child: Material(
                                    color: Colors.grey[100], // button color
                                    child: InkWell(
                                      splashColor:
                                          Colors.grey[500], // inkwell color
                                      child: SizedBox(
                                        width: 36,
                                        height: 36,
                                      ),
                                      onTap: () async {
                                        // Take the Picture in a try / catch block. If anything goes wrong catch the error.
                                        try {
                                          // Ensure that the camera is initialized.
                                          await _initializeControllerFuture;

                                          // Construct the path where the image should be saved using the
                                          // pattern package.image
                                          final path = join(
                                            // Store the picture in the temp directory.
                                            // Find the temp directory using the `path_provider` plugin.
                                            (await getTemporaryDirectory())
                                                .path,
                                            '${DateTime.now()}.png',
                                          );

                                          // Attempt to take a picture and log where it's been saved.
                                          await _controller.takePicture(path);

                                          // If the picture was taken, display it on a new screen.
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DisplayPictureScreen(
                                                      imagePath: path,
                                                      onUpload:
                                                          widget.onUpload),
                                            ),
                                          );
                                        } catch (e) {
                                          // If an error occurs, log the error to the console.
                                          print(e);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            GestureDetector(
                              // or insert_photo instead of photo_library
                              child: Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: 28.0,
                              ),
                              onTap: () async {
                                await getImage();
                                if (selectedImage != null) {
                                  // If the picture was taken, display it on a new screen.
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DisplayPictureScreen(
                                                  imagePath: selectedImage,
                                                  onUpload: widget.onUpload)));
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            // Otherwise, display a loading indicator.
            return Material(child: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user
class DisplayPictureScreen extends StatelessWidget {
  final Function(ui.Image) onUpload;
  final String imagePath;
  final GlobalKey<_CustomPainterDraggableState> _globalKey = new GlobalKey();

  DisplayPictureScreen({Key key, this.imagePath, this.onUpload})
      : super(key: key);
  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
          future: _loadImage(File(imagePath)),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              ui.Image image = snapshot.data;
              return Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: image.width.toDouble(),
                        height: image.height.toDouble(),
                        child: Stack(
                          children: <Widget>[
                            CustomPainterDraggable(
                                image: image, globalKey: _globalKey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ClipOval(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.grey[500], // inkwell color
                              child: Container(
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        width: 1, color: Colors.grey[500])),
                                child: Icon(Icons.delete,
                                    color: Colors.white, size: 28.0),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        ClipOval(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.grey[500], // inkwell color
                              child: Container(
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        width: 1, color: Colors.grey[500])),
                                child: Icon(Icons.check,
                                    color: Colors.white, size: 28.0),
                              ),
                              onTap: () async {
                                final image = await this
                                    ._globalKey
                                    .currentState
                                    .croppedToImage;
                                final result = await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CropPreview(
                                            image: image,
                                          )),
                                );
                                // as long as we got an image, use the callback function
                                if (result != null) {
                                  // result is the ui.Image
                                  await onUpload(result);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Container(
                child: Text(snapshot.error),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class CustomPainterDraggable extends StatefulWidget {
  final globalKey;
  final ui.Image image;
  CustomPainterDraggable({this.image, this.globalKey}) : super(key: globalKey);

  @override
  _CustomPainterDraggableState createState() =>
      new _CustomPainterDraggableState();
}

class _CustomPainterDraggableState extends State<CustomPainterDraggable> {
  double xPos = 0.0;
  double yPos = 0.0;
  double width = 600.0;
  double height = 600.0;
  final pad = 10; // use this to prevent going over the edge
  double startingXPos = 0.0;
  double startingYPos = 0.0;
  double startingScale = 1.0;

  bool _dragging = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // makes it so that we show the cropper full width of the image from the get go
    width = widget.image.width.toDouble();
    height = widget.image.width.toDouble();
  }

  @override
  void dispose() {
    widget.image.dispose();
    super.dispose();
  }

  // this renders a cropped painter to an image
  Future<ui.Image> get croppedToImage {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);

    // take all of the properties set from the crop and pass to a new custom painter that will trim the image down
    // without the crop lines
    CroppedImagePainter painter =
        CroppedImagePainter(widget.image, xPos, yPos, height, width);

    painter.paint(canvas, context.size);

    return recorder.endRecording().toImage(height.floor(), width.floor());
  }

  /// Is the point (x, y) inside the rect?
  bool _insideRect() {
    bool inside =
        (xPos.ceil() <= (widget.image.width - width) && xPos.ceil() >= 0) &&
            (yPos.ceil() <= (widget.image.height - height) && yPos.ceil() >= 0);
    // set state if out of bounds
    if (!inside) {
      updatePositionState();
    }

    return inside;
  }

  void updatePositionState() {
    if (xPos.ceil() < 0.0) {
      setState(() {
        xPos = 0;
      });
    }

    if (xPos.ceil() > (widget.image.width - width)) {
      setState(() {
        xPos = widget.image.width - width;
      });
    }

    // set yPos if out of bounds
    if (yPos.ceil() < 0.0) {
      setState(() {
        yPos = 0;
      });
    }

    if (yPos.ceil() > (widget.image.height - height)) {
      setState(() {
        yPos = widget.image.height - height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        setState(() {
          _dragging = true;
          startingXPos = details.localFocalPoint.dx;
          startingYPos = details.localFocalPoint.dy;
          startingScale = 1.0;
        });
      },
      onScaleEnd: (details) {
        _insideRect(); // this will reset crop if it went out of bounds
        setState(() {
          _dragging = false;
          startingXPos = 0.0;
          startingYPos = 0.0;
          startingScale = 1.0;
        });
      },
      onScaleUpdate: (details) {
        if (_dragging && width < widget.image.width) {
          setState(() {
            // subtract the starting position from the localFocalPoint
            xPos += details.localFocalPoint.dx - startingXPos;
            // set the starting position to where the localFocalpoint.dx is
            startingXPos = details.localFocalPoint.dx;
            // subtract the starting position from the localFocalPoint
            yPos += details.localFocalPoint.dy - startingYPos;
            // set the starting position to where the localFocalpoint.dy is
            startingYPos = details.localFocalPoint.dy;
            // set the height and width using scale, the division by 2 makes it scale slower
            height = (details.scale / 2 - startingScale / 2 + 1.0) * height;
            width = (details.scale / 2 - startingScale / 2 + 1.0) * width;
            // set the starting scale for the delta based on where it ended
            startingScale = details.scale;
          });
        } else {
          // if user sets width to larger than the image width (which sets the canvas) make it so the width is the same as image minus the pad
          // do the same for the height since this is a square
          setState(() {
            width = (widget.image.width - pad).toDouble();
            height = (widget.image.width - pad).toDouble();
          });
        }
        // prevent the width from being less that 25% of the image
        if (width < widget.image.width / 4) {
          setState(() {
            width = widget.image.width / 4;
            height = widget.image.width / 4;
          });
        }
      },
      child: Container(
        color: Colors.white,
        child: CustomPaint(
          painter: CropImagePainter(
              Rect.fromLTWH(xPos, yPos, width, height), widget.image),
          child: Container(),
        ),
      ),
    );
  }
}

class CropImagePainter extends CustomPainter {
  CropImagePainter(this.rect, this.image);
  final Rect rect;
  final ui.Image image;
  final BorderSide borderSide = BorderSide(
      width: 10.0, color: Colors.lightBlue.shade50, style: BorderStyle.solid);

  @override
  void paint(Canvas canvas, Size size) {
    // draw the full size image onto the canvas
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());

    // draws an overlay that is opaque
    final paintOverlay = Paint()..color = Colors.black12.withOpacity(0.4);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRect(rect) // this rect is the crop
          ..close(),
      ),
      paintOverlay,
    );

    // create all the offsets to handle corners of the cropper
    final p1 = Offset(rect.left, rect.top);
    final p2 = Offset(rect.left, rect.top + rect.height / 6);
    final p3 = Offset(rect.left + (rect.width / 6), rect.top);
    final p4 = Offset((rect.width + rect.left) - (rect.width / 6), rect.top);
    final p5 = Offset(rect.left + rect.width, rect.top);
    final p6 = Offset(rect.left + rect.width, rect.top + (rect.height / 6));
    final p7 = Offset(rect.left, rect.top + rect.height - (rect.height / 6));
    final p8 = Offset(rect.left, rect.top + rect.height);
    final p9 = Offset(rect.left + (rect.width / 6), rect.top + rect.height);
    final p10 = Offset(
        rect.left + rect.width, rect.top + rect.height - (rect.height / 6));
    final p11 = Offset(rect.left + rect.width, rect.top + rect.height);
    final p12 = Offset(
        rect.left + rect.width - (rect.width / 6), rect.top + rect.height);

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8;
    // top left corner
    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p1, p3, paint);

    // top right corner
    canvas.drawLine(p4, p5, paint);
    canvas.drawLine(p5, p6, paint);

    // bottom left corner
    canvas.drawLine(p7, p8, paint);
    canvas.drawLine(p8, p9, paint);

    // bottom right corner
    canvas.drawLine(p10, p11, paint);
    canvas.drawLine(p11, p12, paint);
  }

  // TODO: set when this should actually repaint...really anytime any props change
  // xPos, yPos, width, height, or image?
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CroppedImagePainter extends CustomPainter {
  CroppedImagePainter(
      this.image, this.xPos, this.yPos, this.width, this.height);
  final image;
  final xPos;
  final yPos;
  final width;
  final height;

  @override
  void paint(Canvas canvas, Size size) {
    Rect src = Rect.fromLTWH(xPos, yPos, width, height);
    Rect dst = Rect.fromLTWH(0, 0, width, height);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
