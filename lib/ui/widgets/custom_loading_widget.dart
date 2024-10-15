import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoadingWidget extends StatefulWidget {
  const CustomLoadingWidget({super.key});

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFoldingCube(
        color: Colors.grey.shade400,
      ),
    );
  }
}
// class CustomLoadingWidget extends StatelessWidget {
//   const CustomLoadingWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SpinkitWaveCustomPaint(color: Colors.red.shade200,trackColor: ,waveColor: ,hasChild: false,controller: AnimationController(vsync: vsync));
//   }
// }
