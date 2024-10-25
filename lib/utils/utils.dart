import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
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

//   static Future<http.Client> createHttpClientWithCertificate() async {
//     if (sslClient != null) return await Future.value(sslClient);
//     final SecurityContext context = SecurityContext(withTrustedRoots: true);

//     // Load the certificate
//     const String pem = """
// -----BEGIN CERTIFICATE-----
// MIIDnTCCAoWgAwIBAgIUDJeVZD1MhJhgV5we5JNgmYeARi0wDQYJKoZIhvcNAQEL
// BQAwaDELMAkGA1UEBhMCSVIxETAPBgNVBAgMCEtob3Jhc2FuMRAwDgYDVQQHDAdN
// YXNoaGFkMQ8wDQYDVQQKDAZTb2xhbmExDzANBgNVBAsMBnNvbGFuYTESMBAGA1UE
// AwwJbG9jYWxob3N0MCAXDTI0MDkyNzEwMDczOVoYDzIxMjQwOTAzMTAwNzM5WjBo
// MQswCQYDVQQGEwJJUjERMA8GA1UECAwIS2hvcmFzYW4xEDAOBgNVBAcMB01hc2ho
// YWQxDzANBgNVBAoMBlNvbGFuYTEPMA0GA1UECwwGc29sYW5hMRIwEAYDVQQDDAls
// b2NhbGhvc3QwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDFffKjQdL6
// dO1qXTGprxN2s6tjel4xi9XBzkRquf7HMOopyzH3DzBwyI9v5+GLfd2X31p2PCTz
// 7smehgREWuNR2LtyGyoUdAy28sOdpq5eTN/2nCDGH97rgwYNrpdJR9BworGi5n3J
// XaD4L/PptfzBGw5tupHLlOJUWPAQzxb3iZckKI1w/6tvrjraRz23n4gBFi94Ribb
// B6uaXhFWdr8FeKzzmnwRHMu12+Tf6RPH/4EkDIE7hL/c8XlXVnKu+w6KYMh6p19h
// DIt39PawYvENi1P+xT4duooB8URaAE2aql38YzImJTAtBwoK/C6Na1/mcG5JdtkB
// rwJVYVKb+8kXAgMBAAGjPTA7MBoGA1UdEQQTMBGCCWxvY2FsaG9zdIcE1BfJ9DAd
// BgNVHQ4EFgQUEdH20LqjIVsbfbxc6ZJ4Q2iSIKQwDQYJKoZIhvcNAQELBQADggEB
// AIHWnBKMMDeArgkwc1fY53/7h83+rlDQVyEVU7uKbipzmh4fO+Ht523i1RXDyv0b
// H0hWMRpqAebhW47woIALFlrXKGiwakSDfmyrlgHmadkavOxe+8yMIxmKrSAk6X8w
// 3jc0iF9eUjSVyhXktO2wm0R1/hxix9ynXmCsLj3ozRyVJRJ+7QXxgzD6wS/roRvU
// 9c2FXX0lkjXATkecJOzQ71gE9s5CSAJJbdsKM0S9Z7rz7kQt6YMmJfRvm7oQ1xzo
// 3YZTSc0N8fcVZyO0UVGdf4L6ewsbuto2o/HtmZ4M8fVr3s6k3/LdD7N96SSsKoVk
// DB93Ga9Bl0g17X6VUWPMVYc=
// -----END CERTIFICATE-----
// """;

//     context.setTrustedCertificatesBytes(utf8.encode(pem));

//     final httpClient = HttpClient(context: context);
//     httpClient.badCertificateCallback =
//         (X509Certificate cert, String host, int port) => true;

//     sslClient = IOClient(httpClient);
//     return IOClient(httpClient);
//   }

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
