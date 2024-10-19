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
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemBuilder: (context, index) => Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade500),
              gradient: LinearGradient(colors: [
                Colors.grey.shade400,
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade100
              ])),
          // child: ,
        ),
        itemCount: 1,
      ),
    );
  }
}
