import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:iot_project/cubit/devices_screen_cubit.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/ui/screens/home_page_screen.dart';
import 'package:iot_project/utils/appApi.dart';
import 'package:iot_project/utils/consts.dart';
import 'package:iot_project/utils/utils.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    String? resault;
    await AppApi.instance.postApi(
      url: "$baseApiUrl/api/login/",
      body: {"Username": data.name, "Password": data.password},
      onSuccess: (response) {
        List<Device> deviceList = List<Device>.from(
            (jsonDecode(response)['data']["devices_list"])
                .map((e) => Device.fromJson(e))).toList();
        Utils.deviceList = deviceList;
        Utils.confrimLogin(user: data.name, pass: data.password);
        // Utils.username = data.name;
        // Utils.password = data.password;
        resault = null;
      },
      onError: (error) {
        // if (response.body != "" &&
        //     jsonDecode(response.body)["status"] != null) {
        //   return jsonDecode(response.body)["status"];
        // }
        resault = "اتفاقی غیر منتظره رخ داده است .";
        // return "اتفاقی غیر منتظره رخ داده است .";
      },
    );
    // try {
    //   // Perform the network request
    //   final client = await Utils.createHttpClientWithCertificate();
    //   final response = await client.post(
    //     Uri.parse("$baseApiUrl/api/login/"),
    //     body: jsonEncode({"Username": data.name, "Password": data.password}),
    //     headers: {"Content-Type": "application/json"},
    //   );

    //   if (response.statusCode == 200 || response.statusCode == 201) {
    // List<Device> deviceList = List<Device>.from(
    //     (jsonDecode(response.body)['data']["devices_list"])
    //         .map((e) => Device.fromJson(e))).toList();
    // Utils.deviceList = deviceList;
    // Utils.confrimLogin(user: data.name, pass: data.password);
    // // Utils.username = data.name;
    // // Utils.password = data.password;
    // return null;
    //   } else {
    //     if (response.body != "" &&
    //         jsonDecode(response.body)["status"] != null) {
    //       return jsonDecode(response.body)["status"];
    //     }
    //     return "اتفاقی غیر منتظره رخ داده است .";
    //   }
    // } catch (e) {
    //   return 'An error occurred. Please try again later.';
    // }
    return resault;
  }

  Future<String?> _signupUser(SignupData data) async {
    String? resault;
    await AppApi.instance.postApi(
      url: "$baseApiUrl/api/register_email/",
      body: {"Username": data.name, "Password": data.password},
      onSuccess: (response) {
        resault = null;
      },
      onError: (error) {
        // if (response.body != "" &&
        //     jsonDecode(response.body)["status"] != null) {
        //   return jsonDecode(response.body)["status"];
        // }
        resault = "اتفاقی غیر منتظره رخ داده است .";
      },
    );
    return resault;
    // try {
    //   // Perform the network request
    //   final client = await Utils.createHttpClientWithCertificate();
    //   final response = await client.post(
    //     Uri.parse("$baseApiUrl/api/register_email/"),
    //     body: jsonEncode({"email": data.name, "password": data.password}),
    //     headers: {"Content-Type": "application/json"},
    //   );
    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     return null;
    //   } else {
    //     if (response.body != "" &&
    //         jsonDecode(response.body)["status"] != null) {
    //       return jsonDecode(response.body)["status"];
    //     }
    //     return "اتفاقی غیر منتظره رخ داده است .";
    //   }
    // } catch (e) {
    //   return 'An error occurred. Please try again later.';
    // }
  }

  Future<String?> _onConfirmSignup(String text, LoginData data) async {
    String? resault;
    await AppApi.instance.postApi(
      url: "$baseApiUrl/api/register_user/",
      body: {
        "username": data.name,
        "code": text,
        "email": data.name,
        "password": data.password
      },
      onSuccess: (response) {
        // Map<String, dynamic> decodedToken = jsonDecode(response)['result'];
        resault = null;
        // return null;
      },
      onError: (error) {
        // if (response.body != "" &&
        //     jsonDecode(response.body)["status"] != null) {
        //   return jsonDecode(response.body)["status"];
        // }
        resault = "اتفاقی غیر منتظره رخ داده است .";
        // return "اتفاقی غیر منتظره رخ داده است .";
      },
    );
    return resault;
    // try {
    //   // Perform the network request
    //   final client = await Utils.createHttpClientWithCertificate();
    //   final response = await client.post(
    //     Uri.parse("$baseApiUrl/api/register_user/"),
    //     body: jsonEncode({
    //       "username": data.name,
    //       "code": text,
    //       "email": data.name,
    //       "password": data.password
    //     }),
    //     headers: {"Content-Type": "application/json"},
    //   );

    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     Map<String, dynamic> decodedToken = jsonDecode(response.body)['result'];
    //     return null;
    //   } else {
    //     if (response.body != "" &&
    //         jsonDecode(response.body)["status"] != null) {
    //       return jsonDecode(response.body)["status"];
    //     }
    //     return "اتفاقی غیر منتظره رخ داده است .";
    //   }
    // } catch (e) {
    //   return 'An error occurred. Please try again later.';
    // }
  }

  Future<String?> _recoverPassword(String name) async {
    String? resault;
    await AppApi.instance.postApi(
      url: "$baseApiUrl/api/forgot_password/",
      body: {"email": name},
      onSuccess: (response) async {
        resault = null;
        // return null;
      },
      onError: (error) async {
        // if (response.body != "" &&
        //     jsonDecode(response.body)["status"] != null) {
        //   return jsonDecode(response.body)["status"];
        // }
        resault = "اتفاقی غیر منتظره رخ داده است .";
        // return "اتفاقی غیر منتظره رخ داده است .";
      },
    );
    return resault;
    // try {
    //   final client = await Utils.createHttpClientWithCertificate();
    //   final response = await client.post(
    //     Uri.parse("$baseApiUrl/api/forgot_password/"),
    //     body: jsonEncode({"email": name}),
    //     headers: {"Content-Type": "application/json"},
    //   );
    //   if (response.statusCode == 200) {
    //     return null;
    //   } else {
    //     if (response.body != "" &&
    //         jsonDecode(response.body)["status"] != null) {
    //       return jsonDecode(response.body)["status"];
    //     }
    //     return "اتفاقی غیر منتظره رخ داده است .";
    //   }
    // } catch (e) {
    //   return 'An error occurred. Please try again later.';
    // }
  }

  Future<String?> _onConfirmRecover(String text, LoginData data) async {
    String? resault;
    await AppApi.instance.postApi(
      url: "$baseApiUrl/api/reset_password/",
      body: {
        "email": data.name,
        "reset_code": text,
        "new_password": data.password
      },
      onSuccess: (response) async {
        resault = null;
        // return null;
      },
      onError: (error) async {
        // if (response.body != "" &&
        //     jsonDecode(response.body)["status"] != null) {
        //   return jsonDecode(response.body)["status"];
        // }
        resault = "اتفاقی غیر منتظره رخ داده است .";
        // return "اتفاقی غیر منتظره رخ داده است .";
      },
    );
    return resault;
    // try {
    //   // Perform the network request
    //   final client = await Utils.createHttpClientWithCertificate();
    //   final response = await client.post(
    //     Uri.parse("$baseApiUrl/api/reset_password/"),
    //     body: jsonEncode({
    //       "email": data.name,
    //       "reset_code": text,
    //       "new_password": data.password
    //     }),
    //     headers: {"Content-Type": "application/json"},
    //   );

    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     Map<String, dynamic> decodedToken = jsonDecode(response.body)['result'];
    //     return null;
    //   } else {
    //     if (response.body != "" &&
    //         jsonDecode(response.body)["status"] != null) {
    //       return jsonDecode(response.body)["status"];
    //     }
    //     return "اتفاقی غیر منتظره رخ داده است .";
    //   }
    // } catch (e) {
    //   // Handle other errors, such as network issues
    //   // print('Error: $e');
    //   return 'An error occurred. Please try again later.';
    // }
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
          builder: (context) => BlocProvider(
            create: (context) => DevicesScreenCubit(),
            child: const HomePageScreen(),
          ),
        ));
      },
    );
  }
}
