import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/ui/screens/home_page_screen.dart';
import 'package:iot_project/utils/consts.dart';
import 'package:iot_project/utils/utils.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);
//   Future<http.Client> createHttpClientWithCertificate() async {
//     final SecurityContext context = SecurityContext(withTrustedRoots: true);

//     // Load the certificate
//     const String pem = """
// -----BEGIN CERTIFICATE-----
// MIICpTCCAY2gAwIBAgIBATANBgkqhkiG9w0BAQsFADANMQswCQYDVQQDEwJDQTAe
// Fw0yNDA4MTUwMDAwMDBaFw0zNDA4MTQyMzU5NTlaMA0xCzAJBgNVBAMTAkNBMIIB
// IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6bpS/ItjK8iFec+noI927oAb
// QDyrclhy7BIL9xZb4NT+DayYmH115UdoOZsMKC2n+3cqxv1XrvgZVUnsxQC4gmYO
// aXz2BwO2wiQTAGoIC4IhR9VSr/QzQjT/YfBxyr6fenufTVyco0FDyZM208wCCiSP
// JtTcPlgmN7QBGLrg5hnE+ZV3JSvXbe9pY2Mtsy/6jyfP0D/zD+xWVp+fDb8cAOON
// ZPtDpamWN/qCVvB0+tYybV9BdtFQ8otKPJKY75P1svNy4yd5ZgQfrUEDaBg3gZ4y
// z86n7hJK92GgEY0tVugYhXnwMxAoug+u28BfckKdPDqZ6SAgY3Z1V478J37w0QID
// AQABoxAwDjAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBEH0S4x1ij
// 2J+zc6UGnQci7+Vs4N1DYAVdQP4bE2tAhe5UrMcL/WGDdBZFlWbYMheNecm0CD9U
// 7l3EWhA2JYTcpBo0sx0lqWgO1PCxffymb3hCpgEOPN7eevxQCk6pUHlEB52tON2W
// cBhyqABG0Bv0P0CLHEJ0dcG/8Vjdw/GW1yX5QVkRt4zbbkbIhAR+Gr4wanx6NA5B
// OxvsN3P/LmsS8Om8a3jgOPRVjfXt2A+FDiZaLr9Y+Eyb/yE7dr2y9QwjGbEbyX3e
// eBM0xK3mPDtvrMuEYKKWp3VAib2GOfB/PnPf/x2dkH/x6FxfWVN55FRwz8ZgSI0z
// FkkwOvXaJwR8
// -----END CERTIFICATE-----
// """;

//     context.setTrustedCertificatesBytes(utf8.encode(pem));

//     final httpClient = HttpClient(context: context);
//     httpClient.badCertificateCallback =
//         (X509Certificate cert, String host, int port) => true;

//     return IOClient(httpClient);
//   }

  Future<String?> _authUser(LoginData data) async {
    try {
      // Perform the network request
      final client = await Utils.createHttpClientWithCertificate();
      final response = await client.post(
        Uri.parse("$baseApiUrl/api/login/"),
        body: jsonEncode({"Username": data.name, "Password": data.password}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<Device> deviceList = List<Device>.from(
            (jsonDecode(response.body)['data']["devices_list"])
                .map((e) => Device.fromJson(e))).toList();
        Utils.deviceList = deviceList;
        Utils.confrimLogin(user: data.name, pass: data.password);
        // Utils.username = data.name;
        // Utils.password = data.password;
        return null;
      } else {
        if (response.body != "" &&
            jsonDecode(response.body)["status"] != null) {
          return jsonDecode(response.body)["status"];
        }
        return "اتفاقی غیر منتظره رخ داده است .";
      }
    } catch (e) {
      return 'An error occurred. Please try again later.';
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    try {
      // Perform the network request
      final client = await Utils.createHttpClientWithCertificate();
      final response = await client.post(
        Uri.parse("$baseApiUrl/api/register_email/"),
        body: jsonEncode({"email": data.name, "password": data.password}),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return null;
      } else {
        if (response.body != "" &&
            jsonDecode(response.body)["status"] != null) {
          return jsonDecode(response.body)["status"];
        }
        return "اتفاقی غیر منتظره رخ داده است .";
      }
    } catch (e) {
      return 'An error occurred. Please try again later.';
    }
  }

  Future<String?> _onConfirmSignup(String text, LoginData data) async {
    try {
      // Perform the network request
      final client = await Utils.createHttpClientWithCertificate();
      final response = await client.post(
        Uri.parse("$baseApiUrl/api/register_user/"),
        body: jsonEncode({
          "username": data.name,
          "code": text,
          "email": data.name,
          "password": data.password
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedToken = jsonDecode(response.body)['result'];
        return null;
      } else {
        if (response.body != "" &&
            jsonDecode(response.body)["status"] != null) {
          return jsonDecode(response.body)["status"];
        }
        return "اتفاقی غیر منتظره رخ داده است .";
      }
    } catch (e) {
      return 'An error occurred. Please try again later.';
    }
  }

  Future<String?> _recoverPassword(String name) async {
    try {
      final client = await Utils.createHttpClientWithCertificate();
      final response = await client.post(
        Uri.parse("$baseApiUrl/api/forgot_password/"),
        body: jsonEncode({"email": name}),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return null;
      } else {
        if (response.body != "" &&
            jsonDecode(response.body)["status"] != null) {
          return jsonDecode(response.body)["status"];
        }
        return "اتفاقی غیر منتظره رخ داده است .";
      }
    } catch (e) {
      return 'An error occurred. Please try again later.';
    }
  }

  Future<String?> _onConfirmRecover(String text, LoginData data) async {
    try {
      // Perform the network request
      final client = await Utils.createHttpClientWithCertificate();
      final response = await client.post(
        Uri.parse("$baseApiUrl/api/reset_password/"),
        body: jsonEncode({
          "email": data.name,
          "reset_code": text,
          "new_password": data.password
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedToken = jsonDecode(response.body)['result'];
        return null;
      } else {
        if (response.body != "" &&
            jsonDecode(response.body)["status"] != null) {
          return jsonDecode(response.body)["status"];
        }
        return "اتفاقی غیر منتظره رخ داده است .";
      }
    } catch (e) {
      // Handle other errors, such as network issues
      // print('Error: $e');
      return 'An error occurred. Please try again later.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      messages: LoginMessages(),
      theme:
          LoginTheme(titleStyle: TextStyle(color: Colors.white), logoWidth: 1),
      onRecoverPassword: _recoverPassword,
      onConfirmRecover: _onConfirmRecover,
      onConfirmSignup: _onConfirmSignup,
      onLogin: _authUser,
      onSignup: _signupUser,
      loginAfterSignUp: false,
      logo: "assets/images/logo.jpg",
      logoTag: "assets/images/logo.jpg",
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomePageScreen(),
        ));
      },
    );
  }
}
