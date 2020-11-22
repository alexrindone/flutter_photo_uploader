import 'package:flutter/material.dart';

class CropPreview extends StatelessWidget {
  const CropPreview({Key key, this.image}) : super(key: key);
  final image;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: image.width.toDouble(),
              height: image.height.toDouble(),
              child: Stack(children: <Widget>[
                Container(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: image.width.toDouble(),
                      height: image.height.toDouble(),
                      child: CustomPaint(
                        painter: CropPainter(image),
                        child: Container(),
                      ),
                    ),
                  ),
                )
              ]),
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
                          border:
                              Border.all(width: 1, color: Colors.grey[500])),
                      child: Icon(Icons.arrow_back,
                          color: Colors.white, size: 28.0),
                    ),
                    onTap: () async {
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
                          border:
                              Border.all(width: 1, color: Colors.grey[500])),
                      child: Icon(Icons.cloud_upload,
                          color: Colors.white, size: 28.0),
                    ),
                    onTap: () async {
                      // pop the nav with the image selected
                      Navigator.pop(context, image);
                    },
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ));
  }
}

class CropPainter extends CustomPainter {
  CropPainter(this.image);
  final image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
