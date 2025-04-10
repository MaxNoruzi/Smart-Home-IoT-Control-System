import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project/cubit/device_control_cubit.dart' as control;
import 'package:iot_project/cubit/devices_screen_cubit.dart';
import 'package:iot_project/ui/screens/add_device_screen.dart';
import 'package:iot_project/ui/screens/light_switch_screen.dart';
import 'package:iot_project/ui/widgets/custom_loading_widget.dart';
import 'package:iot_project/ui/widgets/custom_error.dart';
import 'package:iot_project/ui/widgets/device_widget.dart';
import 'package:iot_project/utils/appApi.dart';
import 'package:iot_project/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  DevicesScreenCubit get _cubit => context.read<DevicesScreenCubit>();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesScreenCubit, DevicesScreenState>(
      builder: (context, state) {
        // if (state is Loading) return CustomLoadingWidget();
        // if (state is Error) return CustomError();
        return Column(
          children: [
            AppBar(
              title: const Text("All Devices"),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                        builder: (context) => Scanner(),
                      ))
                          .then((value) {
                        if (value != null && value == true) {
                          Utils.showSnackBar(
                              context: context,
                              txt:
                                  "Configuration of device has been successfull, you can connect to desired Wifi now.");
                          // Utils.showSnackBar(context,
                          //     "Configuration of device has been successfull, you can connect to desired Wifi now.");
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.add_circle_rounded,
                      size: 32,
                    ))
              ],
            ),
            Expanded(
                child: (state is Loading)
                    ? const CustomLoadingWidget()
                    : (state is Error)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: CustomError(
                              error: state.error,
                              onCall: state.onCall,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () {
                              _cubit.fetchDevices();
                              return Future(() => null);
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: Utils.deviceList.length,
                              itemBuilder: (context, index) => DeviceWidget(
                                device: Utils.deviceList[index],
                                onTap: () {
                                  if (Utils.deviceList[index].keys.first !=
                                      -1) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                        create: (context) =>
                                            control.DeviceControlCubit(
                                                device: Utils.deviceList[index],
                                                topic:
                                                    "users/${Utils.username}"),
                                        child: LightSwitchScreen(
                                            device: Utils.deviceList[index]),
                                      ),
                                    ));
                                  }

                                  // _cubit.changeModule(
                                  //   device: Utils.deviceList[index])
                                },
                              ),
                            ),
                          ))
          ],
        );
      },
    );
  }
}
