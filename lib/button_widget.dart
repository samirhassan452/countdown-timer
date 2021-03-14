import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final Function onPressed;
  final Color iconColor;
  final Color backgroundColor;
  final IconData icon;
  final double size;
  final Size boxSize;

  const ButtonWidget({
    Key key,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.icon,
    this.size,
    this.boxSize,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: boxSize.height,
      width: boxSize.width,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: onPressed,
          child: Icon(
            icon,
            color: iconColor,
            size: size,
          ),
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
