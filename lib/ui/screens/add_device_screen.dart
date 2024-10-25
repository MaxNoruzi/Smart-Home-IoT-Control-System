import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iot_project/model/wifi_config.dart';
import 'package:iot_project/ui/widgets/custom_loading_widget.dart';
import 'package:iot_project/utils/appApi.dart';
import 'package:iot_project/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

/// Example app for wifi_scan plugin.
class Scanner extends StatefulWidget {
  /// Default constructor for [MyApp] widget.
  const Scanner({Key? key}) : super(key: key);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  bool shouldCheckCan = true;
  late Timer timer;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _getScannedResults(context);
  }

  bool get isStreaming => subscription != null;
  // static Future<bool> _requestPermission(
  //     {required Permission permission}) async {
  //   //  permission=Permission.sms;
  //   bool permissionStatus = false;
  //   bool isPermanetelydenied = await permission.isPermanentlyDenied;
  //   if (isPermanetelydenied) {
  //     await openAppSettings();
  //     return false;
  //     // ispermanetelydenied = await permission.isPermanentlyDenied;
  //     // if (ispermanetelydenied) {
  //     //   requestPermission(permission: permission, afterFinish: () {});
  //     // }
  //   } else {
  //     var perStatu = await permission.request();
  //     permissionStatus = perStatu.isGranted;
  //     return permissionStatus;
  //     // print(permission_status);
  //   }
  // }

  void _showWarningDialog({
    required BuildContext context,
    required String warningMessage,
    required VoidCallback onButtonPressed,
    required String textMessage,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(warningMessage),
          actions: [
            TextButton(
              onPressed: () {
                onButtonPressed(); // Execute the callback function
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(textMessage),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (shouldCheckCan) {
      // check if can-getScannedResults
      final CanGetScannedResults can =
          await WiFiScan.instance.canGetScannedResults();
      // if can-not, then show error
      if (can != CanGetScannedResults.yes) {
        switch (can) {
          case CanGetScannedResults.notSupported:
            if (context.mounted) {
              Utils.showSnackBar(
                  context: context, txt: "Cannot get scanned results: $can");
              // Utils.kShowSnackBar(context, "Cannot get scanned results: $can");
            }
            break;
          case CanGetScannedResults.noLocationServiceDisabled:
            _showWarningDialog(
                context: context,
                onButtonPressed: () async {
                  await Geolocator.openLocationSettings();
                },
                warningMessage: "Please turn on your location.",
                textMessage: "Settings.");
            break;
          default:
            _showWarningDialog(
                context: context,
                onButtonPressed: () {
                  // Utils.requestPermission(permission: Permission.location);
                  openAppSettings();
                },
                warningMessage:
                    "Please grant Location access to the application.",
                textMessage: "Open settings");
        }

        // if (context.mounted) {
        //   Utils.kShowSnackBar(context, "Cannot get scanned results: $can");
        // }
        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Future<void> _getScannedResults(BuildContext context) async {
    // Check if Wi-Fi is enabled
    // int? iWiFiState;
    // WIFI_AP_STATE? wifiAPState;
    bool enabled = false;
    try {
      enabled = await WiFiForIoTPlugin.isEnabled();
    } on Exception {
      // iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_FAILED.index;
    }
    if (!enabled) {
      _showWarningDialog(
          context: context,
          warningMessage: "Your Wifi is off, please turn it on.",
          onButtonPressed: () {
            setState(() {
              WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
            });
          },
          textMessage: "Turn on Wifi");
    } else {
      setState(() {
        isLoading = true;
      });

      if (await _canGetScannedResults(context)) {
        // get scanned results
        final results = await WiFiScan.instance.getScannedResults();
        isLoading = false;
        setState(() => accessPoints =
            results.where((element) => element.ssid.contains("KEY")).toList());
      }
    }
  }

  void _stopListeningToScanResults() {
    try {
      WiFiForIoTPlugin.forceWifiUsage(false);
    } catch (e) {
      print(e);
    }
    subscription?.cancel();
    setState(() => subscription = null);
  }

  @override
  void dispose() {
    _stopListeningToScanResults();
    super.dispose();
    // stop subscription for scanned results
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _getScannedResults(context),
      child: Scaffold(
        // appBar: AppBar(
        //   // title: const Text('Plugin example app'),
        //   // actions: [
        //   //   _buildToggle(
        //   //       label: "Check can?",
        //   //       value: shouldCheckCan,
        //   //       onChanged: (v) => setState(() => shouldCheckCan = v),
        //   //       activeColor: Colors.purple)
        //   // ],
        // ),
        floatingActionButton: ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('GET'),
          onPressed: () async => _getScannedResults(context),
        ),
        body: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: isLoading
                ? CustomLoadingWidget()
                : accessPoints.isEmpty
                    ? const Center(
                        child: Text(
                            "no valid devices found, please use the get botton."),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Center(
                              child: accessPoints.isEmpty
                                  ? const Text("NO SCANNED RESULTS")
                                  : ListView.builder(
                                      itemCount: accessPoints.length,
                                      itemBuilder: (context, i) =>
                                          _AccessPointTile(
                                              accessPoint: accessPoints[i])),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

/// Show tile for AccessPoint.
///
/// Can see details when tapped.
class _AccessPointTile extends StatelessWidget {
  final WiFiAccessPoint accessPoint;

  const _AccessPointTile({Key? key, required this.accessPoint})
      : super(key: key);

  // build row that can display info, based on label: value pair.
  Widget _buildInfo(String label, dynamic value) => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(value.toString()))
          ],
        ),
      );

  void showWiFiConfigBottomSheet(BuildContext context, WiFiConfig wifiConfig,
      Function(WiFiConfig) onConfirm) {
    // Controllers for the text fields
    final TextEditingController ssidController =
        TextEditingController(text: wifiConfig.wifiSSID);
    final TextEditingController wifiPasswordController =
        TextEditingController(text: wifiConfig.wifiPassword);
    final TextEditingController usernameController =
        TextEditingController(text: wifiConfig.username);
    final TextEditingController userPasswordController =
        TextEditingController(text: wifiConfig.userPassword);
    bool obscureText = true;
    bool useUserInfo = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: StatefulBuilder(
              builder: (context, setState) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            'ویرایش تنظیمات WiFi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(height: 16),

                          // WiFi SSID
                          TextField(
                            controller: ssidController,
                            decoration: InputDecoration(
                              labelText: 'SSID WiFi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.wifi),
                            ),
                          ),
                          SizedBox(height: 16),

                          // WiFi Password
                          TextField(
                            controller: wifiPasswordController,
                            decoration: InputDecoration(
                              labelText: 'رمز عبور WiFi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Use user information"),
                              Switch(
                                  value: useUserInfo,
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        useUserInfo = value;
                                        if (value) {
                                          usernameController.text =
                                              Utils.username;
                                          userPasswordController.text =
                                              Utils.password;
                                        } else {
                                          usernameController.text =
                                              wifiConfig.username;
                                          userPasswordController.text =
                                              wifiConfig.userPassword;
                                        }
                                      },
                                    );
                                  })
                            ],
                          ),
                          SizedBox(height: 16),
                          // Username
                          TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: 'نام کاربری',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          SizedBox(height: 16),

                          // User Password
                          TextField(
                            controller: userPasswordController,
                            decoration: InputDecoration(
                                labelText: 'رمز عبور کاربر',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.lock_outline),
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(
                                        () => obscureText = !obscureText,
                                      );
                                    },
                                    child: Icon(!obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off))),
                            obscureText: obscureText,
                          ),
                          SizedBox(height: 32),

                          // Confirm Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.blueGrey,
                                elevation: 5.0,
                              ),
                              onPressed: () async {
                                // Create a new WiFiConfig object with updated values
                                final updatedWiFiConfig = WiFiConfig(
                                  wifiSSID: ssidController.text,
                                  wifiPassword: wifiPasswordController.text,
                                  username: usernameController.text,
                                  userPassword: userPasswordController.text,
                                );
                                // Pass the updated object to the callback
                                onConfirm(updatedWiFiConfig);
                                // Close the bottom sheet

                                Navigator.pop(context);
                              },
                              child: Text(
                                'تایید',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  )),
        );
        // return Padding(
        //   padding: EdgeInsets.only(
        //     bottom: MediaQuery.of(context).viewInsets.bottom,
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.all(24.0),
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         // Title
        //         Text(
        //           'ویرایش تنظیمات WiFi',
        //           style: TextStyle(
        //             fontSize: 20,
        //             fontWeight: FontWeight.bold,
        //             color: Colors.blueGrey,
        //           ),
        //         ),
        //         SizedBox(height: 16),

        //         // WiFi SSID
        //         TextField(
        //           controller: ssidController,
        //           decoration: InputDecoration(
        //             labelText: 'SSID WiFi',
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(12),
        //             ),
        //             prefixIcon: Icon(Icons.wifi),
        //           ),
        //         ),
        //         SizedBox(height: 16),

        //         // WiFi Password
        //         TextField(
        //           controller: wifiPasswordController,
        //           decoration: InputDecoration(
        //             labelText: 'رمز عبور WiFi',
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(12),
        //             ),
        //             prefixIcon: Icon(Icons.lock),
        //           ),
        //           obscureText: true,
        //         ),
        //         SizedBox(height: 16),

        //         SizedBox(height: 16),
        //         // Username
        //         TextField(
        //           controller: usernameController,
        //           decoration: InputDecoration(
        //             labelText: 'نام کاربری',
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(12),
        //             ),
        //             prefixIcon: Icon(Icons.person),
        //           ),
        //         ),
        //         SizedBox(height: 16),

        //         // User Password
        //         TextField(
        //           controller: userPasswordController,
        //           decoration: InputDecoration(
        //             labelText: 'رمز عبور کاربر',
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(12),
        //             ),
        //             prefixIcon: Icon(Icons.lock_outline),
        //           ),
        //           obscureText: obscureText,
        //         ),
        //         SizedBox(height: 32),

        //         // Confirm Button
        //         SizedBox(
        //           width: double.infinity,
        //           child: ElevatedButton(
        //             style: ElevatedButton.styleFrom(
        //               padding: EdgeInsets.symmetric(vertical: 16.0),
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(12),
        //               ),
        //               backgroundColor: Colors.blueGrey,
        //               elevation: 5.0,
        //             ),
        //             onPressed: () {
        //               // Create a new WiFiConfig object with updated values
        //               final updatedWiFiConfig = WiFiConfig(
        //                 wifiSSID: ssidController.text,
        //                 wifiPassword: wifiPasswordController.text,
        //                 username: usernameController.text,
        //                 userPassword: userPasswordController.text,
        //               );
        //               // Pass the updated object to the callback
        //               onConfirm(updatedWiFiConfig);
        //               // Close the bottom sheet
        //               Navigator.pop(context);
        //             },
        //             child: Text(
        //               'تایید',
        //               style: TextStyle(
        //                 fontSize: 18,
        //                 color: Colors.white,
        //               ),
        //             ),
        //           ),
        //         ),
        //         SizedBox(height: 24),
        //       ],
        //     ),
        //   ),
        // );
      },
    );
  }

  // Function to connect to a specific Wi-Fi network using SSID and password
  Future<void> connectToWifi(
      {required WiFiAccessPoint accessPoint,
      required String password,
      required BuildContext context}) async {
    // if android +12 comment this
    // await WiFiForIoTPlugin.forceWifiUsage(true);
    bool isConnected = await WiFiForIoTPlugin.connect(accessPoint.ssid,
        password: password,
        bssid: accessPoint.bssid,
        joinOnce: false,
        security: NetworkSecurity.WPA);
    bool isForce = await WiFiForIoTPlugin.forceWifiUsage(true);

    print(isForce);
    if (isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connected to ${accessPoint.ssid}")),
      );
      AppApi.instance.getApi(
        // retryNumber: 4,
        url: "http://192.168.4.1:80/api/cnfg",
        headers: {
          "Authorization":
              "Bearer !y5SBab0X!hpd6iMsG=fznDx=BiO6xM=!??1Z1iTrZDtTTrwxvw8JX2F"
        },
        onSuccess: (response) {
          print(response);
          WiFiConfig wiFiConfig = WiFiConfig.fromJson(jsonDecode(response));
          showWiFiConfigBottomSheet(
            context,
            wiFiConfig,
            (p) {
              AppApi.instance.postApi(
                // retryNumber: 4,
                url: "http://192.168.4.1:80/api/submit",
                header: {
                  "Authorization":
                      "Bearer !y5SBab0X!hpd6iMsG=fznDx=BiO6xM=!??1Z1iTrZDtTTrwxvw8JX2F"
                },
                body: p.toJson(),
                onSuccess: (response) {
                  Navigator.of(context).pop(true);
                },
                onError: (error) {
                  // Utils.kShowSnackBar(
                  //     context, "Something went wrong please try again.");
                  Utils.showSnackBar(
                      context: context, txt: error.title.toString());
                  // Utils.kShowSnackBar(context, error.title.toString());
                },
              );
            },
          );
        },
        onError: (error) {
          // Utils.kShowSnackBar(
          //     context, "Something went wrong please try again.");
          Utils.showSnackBar(context: context, txt: error.title.toString());
          // Utils.kShowSnackBar(context, error.title.toString());
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to ${accessPoint.ssid}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = accessPoint.ssid.isNotEmpty ? accessPoint.ssid : "**EMPTY**";
    final signalIcon = accessPoint.level >= -80
        ? Icons.signal_wifi_4_bar
        : Icons.signal_wifi_0_bar;
    return ListTile(
        visualDensity: VisualDensity.compact,
        leading: Icon(signalIcon),
        title: Text(title),
        subtitle: Text(accessPoint.capabilities),
        onTap: () {
          connectToWifi(
              context: context, password: "12345678", accessPoint: accessPoint);
        }
        // md1234567997MD
        // => showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: Text(title),
        //     content: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         _buildInfo("BSSDI", accessPoint.bssid),
        //         _buildInfo("Capability", accessPoint.capabilities),
        //         _buildInfo("frequency", "${accessPoint.frequency}MHz"),
        //         _buildInfo("level", accessPoint.level),
        //         _buildInfo("standard", accessPoint.standard),
        //         _buildInfo(
        //             "centerFrequency0", "${accessPoint.centerFrequency0}MHz"),
        //         _buildInfo(
        //             "centerFrequency1", "${accessPoint.centerFrequency1}MHz"),
        //         _buildInfo("channelWidth", accessPoint.channelWidth),
        //         _buildInfo("isPasspoint", accessPoint.isPasspoint),
        //         _buildInfo(
        //             "operatorFriendlyName", accessPoint.operatorFriendlyName),
        //         _buildInfo("venueName", accessPoint.venueName),
        //         _buildInfo("is80211mcResponder", accessPoint.is80211mcResponder),
        //       ],
        //     ),
        //   ),
        // ),
        );
  }
}
