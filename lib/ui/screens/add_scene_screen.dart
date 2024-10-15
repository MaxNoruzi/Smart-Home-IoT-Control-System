import 'package:flutter/material.dart';

import 'package:iot_project/ui/widgets/scene_device_widget.dart';
import 'package:iot_project/utils/enums.dart';
import 'package:iot_project/utils/utils.dart';
// Assuming this is where DeviceWidget is

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
                      // onTap: () {
                      //   setState(() {
                      //     // Toggle the state for this device when tapped
                      //     if (device.keys.first == -1) {
                      //       // It's offline, do nothing or show a message
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //             content: Text('${device.nodeID} is offline!')),
                      //       );
                      //     } else {
                      //       // Here you can handle state changes for devices
                      //       device.keys[0] =
                      //           device.keys[0] == 1 ? 0 : 1; // Toggle the state
                      //     }
                      //   });
                      // },
                    ),
                  );
                },
              ),
            ),

            // Save Button
            ElevatedButton(
              onPressed: () {
                // Handle saving scene logic
                print('Scene Name: $sceneName');
                Utils.deviceList.forEach((device) {
                  print(
                      '${device.nodeID}: ${device.keys.first == 1 ? 'On' : 'Off'}');
                });
              },
              child: const Text('Save Scene'),
            ),
          ],
        ),
      ),
    );
  }
}
