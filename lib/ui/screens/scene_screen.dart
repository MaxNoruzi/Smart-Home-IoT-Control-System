import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iot_project/ui/screens/add_scene_screen.dart';

class SceneScreen extends StatefulWidget {
  const SceneScreen({super.key});

  @override
  State<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends State<SceneScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scene"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => AddSceneScreen(),
                ));
              },
              icon: const Icon(
                Icons.add_circle_rounded,
                size: 32,
              ))
        ],
      ),
    );
  }
}
