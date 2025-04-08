
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/io_client.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/utils/mqtt_client.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  Utils._();
  static List<Device> deviceList = [];
  static late Box infoBox;
  static late String username;
  static late String password;
  static late MqttService client;
  static late String topic;
  static IOClient? sslClient;
  static void confrimLogin({required String user, required String pass}) {
    username = user;
    password = pass;
    topic = "users/" + username;
    Utils.infoBox.put("loggedIn", true);
    Utils.infoBox.put("username", user);
    Utils.infoBox.put("password", pass);
    Utils.infoBox.put("lastLoginDate", DateTime.now().toIso8601String());
  }

  static Future<bool> requestPermission(
      {required Permission permission}) async {
    //  permission=Permission.sms;
    bool permissionStatus = false;
    bool isPermanetelydenied = await permission.isPermanentlyDenied;
    if (isPermanetelydenied) {
      await openAppSettings();

      return false;
    } else {
      var perStatu = await permission.request();
      permissionStatus = perStatu.isGranted;
      return permissionStatus;
      // print(permission_status);
    }
  }

  /// Show snackbar.
  static void showSnackBar(
      {required BuildContext context,
      required String txt,
      Function? afterSnack,
      int? sec,
      int? milliseconds}) {
    Future.delayed(Duration.zero).then((value) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(

            // margin: EdgeInsets.fromLTRB(0, 0, 0, 300),
            content: ConstrainedBox(
                constraints: BoxConstraints.loose(Size(double.infinity, 100)),
                child: Text(
                    txt == "check your connection"
                        ? "اتصال خود به اینترنت را بررسی فرمایید."
                        : txt,
                    textAlign: TextAlign.center)),
            duration:
                Duration(seconds: sec ?? 1, milliseconds: milliseconds ?? 500),
            behavior: SnackBarBehavior.floating),
      );
    }).then((value) {
      if (afterSnack != null) {
        afterSnack();
      }
    });
  }
  // NumberFormat('#.##',"fa").format(1312321)
  // static bool isLoggedIn = false;
  // static late DateTime lastLoginDate;
  /*
    document of Hive boxes and variables:
    info Box: key is "info" and there is three keys inside it
    1) "loggedIn" : it is a boolean that defines that user already logged in app or not , that means user have  a valid token
    2) "userModel" : a User information that contains thing like name and surname or ...
    3) "auth" : auth information that includes accessToken and refreshToken  and expiresIn that shows expire time of accessToken
    4) "loggedOnce" : determine that user logged once in app but right now he may or may not be logged in
    */

  // static User? user;
  // static Auth? auth;
  // static late AndroidDeviceInfo? androidInfo;
  // static final MyLocalization _myLocalization = MyLocalization();
  // static MyLocalizationDelegate myLocalizationDelegate = MyLocalizationDelegate(_myLocalization);
  // static ReceiveTypes stringToEnum(String type) {
  //   switch (type) {
  //     case "UserAckKey":
  //       return ReceiveTypes.ACK;
  //     case "Event":
  //       return ReceiveTypes.EVENT;

  //     case "Sample":
  //       return ReceiveTypes.SAMPLE;

  //     default:
  //       return ReceiveTypes.SAMPLE;
  //   }
  // }
  static void logout({required BuildContext context}) async {
    // Utils.isLoggedIn = false;
    // await Utils.infoBox.put("loginInfo", false);
    await Utils.infoBox.put("loggedIn", false);
    if (context.mounted) Navigator.of(context).pushReplacementNamed("/login");
  }

  static void updateDevice(
      {required String nodeID, required String keys, required int pwm}) {
    if (deviceList.where((element) => element.nodeID == nodeID).length > 0) {
      Device? current =
          deviceList.where((element) => element.nodeID == nodeID).first;
      current.pwm = pwm;
      for (var i = 0; i < keys.split(",").length; i++) {
        current.keys[i] = int.parse(keys.split(",")[i]);
      }
    }
  }
}
