import 'package:flutter/material.dart';
import 'package:ocean_view/shared/constants.dart';

class CustomShapeClassTop extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height / 17); //4.25
    var firstControlPoint = new Offset(size.width / 4, size.height / 9);
    var firstEndPoint = new Offset(size.width / 2, size.height / 6 - 80);
    var secondControlPoint =
        new Offset(size.width - (size.width / 4), size.height / 9 - 75);
    var secondEndPoint = new Offset(size.width, size.height / 5 - 70);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height / 3);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

class CustomPainterWidgets {
  static Widget buildTopShape() {
    return ClipPath(
      clipper: CustomShapeClassTop(),
      child: Container(
        color: topBarColor,
      ),
    );
  }
}
