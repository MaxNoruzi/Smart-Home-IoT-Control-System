import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/utils/enums.dart';

class SceneDeviceWidget extends StatefulWidget {
  SceneDeviceWidget({super.key, required this.device, required this.keyStates});
  final Device device;
  List<switchMode> keyStates;
  @override
  _SceneDeviceWidgetState createState() => _SceneDeviceWidgetState();
}

class _SceneDeviceWidgetState extends State<SceneDeviceWidget> {
  // Keep track of the state of the keys (on/off)

  @override
  void initState() {
    super.initState();
    // Initialize key states based on the device's current keys
    // keyStates = widget.device.keys.map((key) => key == 1).toList();
  }

  Future<String?> _showOptionModal(
      {required BuildContext context, required String title}) async {
    // Variable to store the selected option
    String? selectedOption;

    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Option buttons (On, Off, No Change)
                      ListTile(
                        leading: Radio<String>(
                          value: 'On',
                          groupValue: selectedOption,
                          onChanged: (value) {
                            selectedOption = value;
                          },
                        ),
                        title: Text('On'),
                        onTap: () {
                          selectedOption = 'On';
                          setState(
                            () {},
                          );
                        },
                      ),
                      ListTile(
                        leading: Radio<String>(
                          value: 'Off',
                          groupValue: selectedOption,
                          onChanged: (value) {
                            selectedOption = value;
                          },
                        ),
                        title: Text('Off'),
                        onTap: () {
                          selectedOption = 'Off';
                          setState(
                            () {},
                          );
                        },
                      ),
                      ListTile(
                        leading: Radio<String>(
                          value: 'No Change',
                          groupValue: selectedOption,
                          onChanged: (value) {
                            selectedOption = value;
                          },
                        ),
                        title: Text('No Change'),
                        onTap: () {
                          selectedOption = 'No Change';
                          setState(
                            () {},
                          );
                        },
                      ),
                      SizedBox(height: 24),

                      // Save button at the bottom
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Close the modal and save the selected option
                            Navigator.pop(context, selectedOption);
                          },
                          style: ElevatedButton.styleFrom(
                            // backgroundColor: Colors.blue, // Customize button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ));
      },
    ).then((selectedOption) {
      // return selectedOption;
    });
    return selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      borderRadius: BorderRadius.circular(12),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          collapsedShape: Border.all(color: Colors.transparent),
          shape: Border.all(color: Colors.transparent),
          title: Row(
            children: [
              Image.asset(
                "assets/images/key_${widget.device.channel}.png",
                height: 40,
                width: 40,
                fit: BoxFit.fill,
              ),
              const SizedBox(
                width: 12,
              ),
              Text(widget.device.nodeID),
            ],
          ), // Show the device node ID
          children: [
            // Display keys in a grid
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true, // GridView inside an ExpansionTile
                physics:
                    const NeverScrollableScrollPhysics(), // No scrolling inside GridView
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Display keys in 3 columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: widget.keyStates.length, // Number of keys
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      String? resualt = await _showOptionModal(
                          context: context,
                          title: "${widget.device.nodeID}   key $index");
                      if (resualt != null) {
                        switch (resualt) {
                          case 'No Change':
                            widget.keyStates[index] = switchMode.NONE;
                            break;
                          case 'Off':
                            widget.keyStates[index] = switchMode.OFF;
                            break;
                          case 'On':
                            widget.keyStates[index] = switchMode.ON;
                          default:
                        }
                      }

                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: widget.keyStates[index] == switchMode.NONE
                            ? Colors.grey.shade100
                            : widget.keyStates[index] == switchMode.ON
                                ? Colors.green.shade200
                                : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Key ${index + 1}', // Display key number
                              style: TextStyle(
                                  color:
                                      widget.keyStates[index] == switchMode.NONE
                                          ? Colors.black
                                          : Colors.white),
                            ),
                            Text(
                              widget.keyStates[index] == switchMode.NONE
                                  ? "No change"
                                  : widget.keyStates[index] == switchMode.ON
                                      ? "On"
                                      : "Off", // Display key number
                              style: TextStyle(
                                  color:
                                      widget.keyStates[index] == switchMode.NONE
                                          ? Colors.black
                                          : Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
