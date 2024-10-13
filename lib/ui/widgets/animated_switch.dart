import 'package:flutter/material.dart';

class PressableButton extends StatefulWidget {
  @override
  _PressableButtonState createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          width: 150,
          height: 200,
          decoration: BoxDecoration(
            color: isPressed ? Colors.blue[200] : Colors.red[400],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                offset: Offset(0, isPressed ? 2 : 12),

                // blurStyle: BlurStyle.solid,
                blurRadius: isPressed ? 1 : 4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            children: [Text("")],
          ),
        ));
  }
}
