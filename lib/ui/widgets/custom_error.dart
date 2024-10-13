import 'package:flutter/material.dart';
import 'package:iot_project/model/error_model.dart';

class CustomError extends StatelessWidget {
  const CustomError({super.key, required this.error, required this.onCall});
  final ErrorModel error;
  final Function onCall;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onCall(),
      child: Center(
        child: Container(
          decoration: const ShapeDecoration(shape: CircleBorder()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              Text(error.title),
            ],
          ),
          // color: Colors.red,
        ),
      ),
    );
  }
}
