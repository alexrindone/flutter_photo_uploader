import 'package:flutter/material.dart';

class CropPreview extends StatelessWidget {
  const CropPreview({ Key key, this.image }) : super(key: key);
  final image;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
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
    );
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
