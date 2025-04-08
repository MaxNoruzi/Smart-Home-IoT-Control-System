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
        resault = null;
      },
      onError: (error) {
        resault = "اتفاقی غیر منتظره رخ داده است .";
      },
    );

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
        resault = "اتفاقی غیر منتظره رخ داده است .";
      },
    );
    return resault;
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
        resault = "اتفاقی غیر منتظره رخ داده است .";
      },
    );
    return resault;
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
        resault = "اتفاقی غیر منتظره رخ داده است .";
        // return "اتفاقی غیر منتظره رخ داده است .";
      },
    );
    return resault;
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
        resault = "اتفاقی غیر منتظره رخ داده است .";
      },
    );
    return resault;
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
