import 'package:flutter/material.dart';

import 'package:iot_project/ui/widgets/scene_device_widget.dart';
import 'package:iot_project/utils/enums.dart';
import 'package:iot_project/utils/utils.dart';

class AddSceneScreen extends StatefulWidget {
  @override
  _AddSceneScreenState createState() => _AddSceneScreenState();
}

class _AddSceneScreenState extends State<AddSceneScreen> {
  String sceneName = ""; // To store the scene name To store a list of devices
  late List<List<switchMode>> keysList;
  // widget.device.keys.map((key) => key == 1).toList();
  @override
  void initState() {
    keysList = List.generate(
        Utils.deviceList.length,
        (index) => Utils.deviceList[index].keys
            .map((key) => switchMode.NONE)
            .toList());
    super.initState();
    // Add some dummy devices (replace with your actual data)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Scene'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Scene Name Input Field
            TextField(
              decoration: InputDecoration(
                labelText: 'Scene Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  sceneName = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // List of Devices using your custom DeviceWidget
            Expanded(
              child: ListView.builder(
                itemCount: Utils.deviceList.length,
                itemBuilder: (context, index) {
                  final device = Utils.deviceList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SceneDeviceWidget(
                      keyStates: keysList[index],
                      device: device,
                    ),
                  );
                },
              ),
            ),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // Handle saving scene logic
                Utils.deviceList.forEach((device) {});
              },
              child: const Text('Save Scene'),
            ),
          ],
        ),
      ),
    );
  }
}
