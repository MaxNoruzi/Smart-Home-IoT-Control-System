import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/model/receive_model.dart';
import 'package:iot_project/utils/mqtt_client.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  Utils._();
  static late List<Device> deviceList;
  static late Box infoBox;
  static late String username;
  static late String password;
  static late MqttService client;
  static late String topic;
  static void confrimLogin({required String user, required String pass}) {
    username = user;
    password = pass;
    topic = "users/" + username;
    Utils.infoBox.put("loggedIn", true);
    Utils.infoBox.put("username", user);
    Utils.infoBox.put("password", pass);
    Utils.infoBox.put("lastLoginDate", DateTime.now().toIso8601String());
  }

  static Future<http.Client> createHttpClientWithCertificate() async {
    final SecurityContext context = SecurityContext(withTrustedRoots: true);

    // Load the certificate
    const String pem = """
-----BEGIN CERTIFICATE-----
MIICpTCCAY2gAwIBAgIBATANBgkqhkiG9w0BAQsFADANMQswCQYDVQQDEwJDQTAe
Fw0yNDA4MTUwMDAwMDBaFw0zNDA4MTQyMzU5NTlaMA0xCzAJBgNVBAMTAkNBMIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6bpS/ItjK8iFec+noI927oAb
QDyrclhy7BIL9xZb4NT+DayYmH115UdoOZsMKC2n+3cqxv1XrvgZVUnsxQC4gmYO
aXz2BwO2wiQTAGoIC4IhR9VSr/QzQjT/YfBxyr6fenufTVyco0FDyZM208wCCiSP
JtTcPlgmN7QBGLrg5hnE+ZV3JSvXbe9pY2Mtsy/6jyfP0D/zD+xWVp+fDb8cAOON
ZPtDpamWN/qCVvB0+tYybV9BdtFQ8otKPJKY75P1svNy4yd5ZgQfrUEDaBg3gZ4y
z86n7hJK92GgEY0tVugYhXnwMxAoug+u28BfckKdPDqZ6SAgY3Z1V478J37w0QID
AQABoxAwDjAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBEH0S4x1ij
2J+zc6UGnQci7+Vs4N1DYAVdQP4bE2tAhe5UrMcL/WGDdBZFlWbYMheNecm0CD9U
7l3EWhA2JYTcpBo0sx0lqWgO1PCxffymb3hCpgEOPN7eevxQCk6pUHlEB52tON2W
cBhyqABG0Bv0P0CLHEJ0dcG/8Vjdw/GW1yX5QVkRt4zbbkbIhAR+Gr4wanx6NA5B
OxvsN3P/LmsS8Om8a3jgOPRVjfXt2A+FDiZaLr9Y+Eyb/yE7dr2y9QwjGbEbyX3e
eBM0xK3mPDtvrMuEYKKWp3VAib2GOfB/PnPf/x2dkH/x6FxfWVN55FRwz8ZgSI0z
FkkwOvXaJwR8
-----END CERTIFICATE-----
""";

    context.setTrustedCertificatesBytes(utf8.encode(pem));

    final httpClient = HttpClient(context: context);
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    return IOClient(httpClient);
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
  static void kShowSnackBar(BuildContext context, String message) {
    if (kDebugMode) print(message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
