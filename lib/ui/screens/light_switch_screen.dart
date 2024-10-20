import 'package:cart_stepper/cart_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project/cubit/device_control_cubit.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/ui/screens/switch_pick.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';

class LightSwitchScreen extends StatefulWidget {
  LightSwitchScreen({super.key, required this.device}) {}
  final Device device;
  @override
  State<LightSwitchScreen> createState() => _LightSwitchScreenState();
}

class _LightSwitchScreenState extends State<LightSwitchScreen> {
  DeviceControlCubit get _cubit => context.read<DeviceControlCubit>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.device.nodeID),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back on button press
            },
          ),
        ),
        body: BlocBuilder<DeviceControlCubit, DeviceControlState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  0.7, // Number of columns in the grid
                              crossAxisSpacing: 32,
                              mainAxisSpacing: 16
                              // childAspectRatio: 2, // Aspect ratio of each grid item
                              ),
                      itemCount:
                          widget.device.channel, // Total number of switches
                      itemBuilder: (context, index) {
                        return Opacity(
                            opacity: widget.device.keys[index] == -1 ? 0.3 : 1,
                            child: GestureDetector(
                              onTap: () {
                                _cubit.onOffModule(
                                    device: widget.device,
                                    channel: index + 1,
                                    state: widget.device.keys[index] == 1
                                        ? false
                                        : true
                                    //  !widget.switches[index]
                                    );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 150,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: widget.device.keys[index] == 1
                                      ? Colors.grey[500]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.7),
                                      offset: Offset(
                                          0,
                                          widget.device.keys[index] == 1
                                              ? 4
                                              : 12),

                                      // blurStyle: BlurStyle.solid,
                                      blurRadius: widget.device.keys[index] == 1
                                          ? 0.5
                                          : 4,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Switch ${index}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color:
                                                widget.device.keys[index] == 1
                                                    ? Colors.white
                                                    : Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        width: 20,
                                        height: 4,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Brightness :"),
                      CartStepperInt(
                        editKeyboardType: TextInputType.none,
                        size: 32,
                        elevation: 12,
                        value: widget.device.pwm,
                        stepper: 10,
                        alwaysExpanded: true,
                        didChangeCount: (value) {
                          // widget.device.pwm = value.toInt();
                          _cubit.pwmChange(
                              device: widget.device, value: value.toInt());
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SwitchPick(
                                device: widget.device,
                              ),
                            )),
                            child: Ink(
                              decoration: ShapeDecoration(
                                shape: CircleBorder(),
                              ),
                              child: Icon(Icons.timer_sharp),
                            ),
                          ),
                          Text(
                            "Timer",
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ));
  }
}
