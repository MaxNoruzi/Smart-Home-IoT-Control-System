import 'package:flutter/material.dart';
import 'package:iot_project/model/device_model.dart';

class DeviceWidget extends StatelessWidget {
  const DeviceWidget({super.key, required this.device, required this.onTap});
  final Device device;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 8,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.key_sharp),
                    Text(
                      device.keys.first == -1 ? " Offilne" : " Online",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: device.keys.first == -1
                              ? Colors.red
                              : Colors.green),
                    )
                  ],
                ),
                Text(device.nodeID)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
