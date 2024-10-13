import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project/cubit/timer_schedule_cubit.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/ui/screens/timer_schedule_screen.dart';

class SwitchPick extends StatefulWidget {
  SwitchPick({super.key, required this.device});
  Device device;
  @override
  State<SwitchPick> createState() => _SwitchPickState();
}

class _SwitchPickState extends State<SwitchPick> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_rounded)),
        centerTitle: true,
      ),
      body: Column(
        children: List.generate(
            widget.device.keys.length,
            (index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => TimerScheduleCubit(
                            device: widget.device, keyNumber: index),
                        child: TimerScheduleScreen(),
                      ),
                    )),
                    child: Ink(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),

                          boxShadow: [BoxShadow(color: Colors.grey.shade100,spreadRadius: 4)]),
                      // margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Switch ${index + 1}"),
                            Icon(Icons.arrow_forward_ios_rounded)
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
      ),
    );
  }
}
