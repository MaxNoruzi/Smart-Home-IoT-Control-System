import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iot_project/model/error_model.dart';
import 'package:iot_project/utils/consts.dart';

class AppApi {
  static final AppApi _instance = AppApi._internal();

  AppApi._internal();

  static AppApi get instance => _instance;

  final _dio = Dio(
    BaseOptions(
      receiveTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 90),
      connectTimeout: const Duration(seconds: 90),
    ),
  );
  void afterDioCreate() async {
    ByteData clientCertificate =
        await rootBundle.load("assets/Certificates/cert.pem");
    ByteData privateKey = await rootBundle.load("assets/Certificates/key.pem");
    ByteData rootCACertificate =
        await rootBundle.load("assets/Certificates/cert.pem");
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final SecurityContext scontext = SecurityContext();
        scontext.setTrustedCertificatesBytes(
            rootCACertificate.buffer.asUint8List());
        scontext.usePrivateKeyBytes(privateKey.buffer.asUint8List());
        scontext
            .useCertificateChainBytes(clientCertificate.buffer.asUint8List());

        HttpClient client = HttpClient(context: scontext);

        return client;
      },
    );
  }

  void _onErrorCatch({
    required Object e,
    // required DioException e,
    required Function(ErrorModel error)? onError,
  }) async {
    if (e is DioException) {
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          onError!(ErrorModel(
              title: e.response!.data, errorStatus: ErrorStatus.showErrorText));
        } else {
          onError!(ErrorModel(
              title: e.response!.data, errorStatus: ErrorStatus.server));
        }
        if (kDebugMode) {
          log(e.response!.data + "hi");
          log("${e.response!.headers}hi2");
          log("${e.response!.requestOptions}hi3");
        }
        // }
      } else {
        if (kDebugMode) {
          log(e.requestOptions.toString());
          log(e.message.toString());
        }
        if (e.message != null && e.message!.contains("connection")) {
          onError!(ErrorModel(
              title: "check your connection",
              errorStatus: ErrorStatus.connection));
        } else {
          if (kDebugMode) {
            onError!(ErrorModel(
                title: e.message ?? "unknown problem",
                errorStatus: ErrorStatus.server));
          } else {
            onError!(ErrorModel(
                title: "خطایی رخ داده است لطفا دوباره تلاش کنید . ",
                errorStatus: ErrorStatus.server));
          }
        }
      }
    } else if (e is Error) {
      if (kDebugMode) {
        onError!(ErrorModel(
            title: {
              "errorName": e.toString(),
              "stackTrace": e.stackTrace.toString()
            }.toString(),
            errorStatus: ErrorStatus.codeError));
        log(e.toString());
        log(e.stackTrace?.toString() ?? "");
      } else {
        postApi(
            url: "$baseApiUrl/log/mobile/",
            // header: {"Authorization": "Bearer ${Utils.auth!.accessToken}"},
            body: {
              "log": {
                "errorName": e.toString(),
                "stackTrace": e.stackTrace.toString()
              }.toString()
            },
            onError: (e) {
              // print(e.title);
            },
            onSuccess: (e) {
              // print(e);
            });
        onError!(ErrorModel(
            title: "خطایی رخ داده است لطفا دوباره تلاش کنید . ",
            errorStatus: ErrorStatus.codeError,
            subtitle: {
              "errorName": e.toString(),
              "stackTrace": e.stackTrace.toString()
            }.toString()));
      }
    } else {
      if (kDebugMode) {
        onError!(
            ErrorModel(title: e.toString(), errorStatus: ErrorStatus.unknown));
      } else {
        onError!(ErrorModel(
            title: "خطایی رخ داده است لطفا دوباره تلاش کنید . ",
            errorStatus: ErrorStatus.unknown));
      }
    }
  }

  Future<void> deleteApi(
      {required String url,
      Function(String response)? onSuccess,
      Function(ErrorModel error)? onError,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
      int retryNumber = 1}) async {
    if (retryNumber > 1) {
      List<Duration> retryDelays = [];

      for (int i = 0; i < retryNumber; i++) {
        retryDelays.add(Duration(seconds: i + 1));
      }
      _dio.interceptors.add(RetryInterceptor(
        dio: _dio,
        // logPrint: print, // specify log function (optional)
        retries: retryNumber, // retry count (optional)
        retryDelays: retryDelays,
      ));
    }

    try {
      Response response;

      response = await _dio.delete(url,
          options: Options(responseType: ResponseType.plain, headers: headers),
          queryParameters: queryParameters);
      if (kDebugMode) {
        log("response api: ${response.data.toString()}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (onSuccess != null) {
          onSuccess(response.data.toString());
        }
      } else {
        if (onError != null) {
          onError(ErrorModel(
              title: "سرور در دسترس نیست .", errorStatus: ErrorStatus.server));
        }
      }
    } catch (e) {
      _onErrorCatch(e: e, onError: onError);
    }
  }

  Future<bool> loadNetworkImage(
      {required List<Uint8List> data, required String url}) async {
    Response response;
    try {
      response = await _dio.get<List<int>>(url,
          options: Options(responseType: ResponseType.bytes));
      if (response.statusCode == 200 || response.statusCode == 201) {
        data.clear();
        data.add(response.data);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> getApi(
      {required String url,
      Function(String response)? onSuccess,
      Function(ErrorModel error)? onError,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
      int retryNumber = 1}) async {
    if (retryNumber > 1) {
      List<Duration> retryDelays = [];

      for (int i = 0; i < retryNumber; i++) {
        retryDelays.add(Duration(seconds: 1));
      }

      _dio.interceptors.add(RetryInterceptor(
        dio: _dio,
        // logPrint: print, // specify log function (optional)
        retries: retryNumber, // retry count (optional)
        retryDelays: retryDelays,
      ));
    }

    try {
      Response response;
      response = await _dio.get(url,
          options: Options(responseType: ResponseType.plain, headers: headers),
          queryParameters: queryParameters);
      if (kDebugMode) {
        log("response api: ${response.data.toString()}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (onSuccess != null) {
          await Future.sync(() => onSuccess(response.data.toString()));
          // onSuccess(response.data.toString());
        }
      } else {
        if (onError != null) {
          onError(ErrorModel(
              title: "سرور در دسترس نیست .", errorStatus: ErrorStatus.server));
        }
      }
    } catch (e) {
      _onErrorCatch(e: e, onError: onError);
    }
  }

  Future<void> postApi(
      {required String url,
      Map<String, dynamic>? header,
      required Map<String, dynamic> body,
      FormData? formData,
      Map<String, dynamic>? queryParameters,
      Function(dynamic response)? onSuccess,
      Function(ErrorModel error)? onError,
      int? timeoutDuration,
      ResponseType responseType = ResponseType.plain,
      int retryNumber = 1}) async {
    if (retryNumber > 1) {
      List<Duration> retryDelays = [];

      for (int i = 0; i < retryNumber; i++) {
        retryDelays.add(Duration(seconds: i + 1));
      }

      _dio.interceptors.add(RetryInterceptor(
        dio: _dio,
        // logPrint: print, // specify log function (optional)
        retries: retryNumber, // retry count (optional)
        retryDelays: retryDelays,
      ));
    }

    try {
      Response response;
      response = await (timeoutDuration == null
              ? _dio
              : Dio(
                  BaseOptions(
                    receiveTimeout: Duration(seconds: timeoutDuration),
                    sendTimeout: Duration(seconds: timeoutDuration),
                    connectTimeout: Duration(seconds: timeoutDuration),
                  ),
                ))
          .post(url,
              data: formData ?? body,
              queryParameters: queryParameters,
              options: Options(responseType: responseType, headers: header));
      if (kDebugMode) {
        log(response.data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (onSuccess != null) {
          // onSuccess(response.data);
          await Future.sync(() => onSuccess(response.data));
          return null;
        }
      } else {
        if (onError != null) {
          onError(ErrorModel(
              title: "سرور در دسترس نیست .", errorStatus: ErrorStatus.server));
          return null;
        }
      }
    } catch (e) {
      _onErrorCatch(e: e, onError: onError);
    }
  }

  Future<void> patchApi(
      {required String url,
      Map<String, dynamic>? header,
      required Map<String, dynamic> body,
      FormData? formData,
      Function(dynamic response)? onSuccess,
      Function(ErrorModel error)? onError,
      ResponseType responseType = ResponseType.plain,
      int retryNumber = 1}) async {
    if (retryNumber > 1) {
      List<Duration> retryDelays = [];

      for (int i = 0; i < retryNumber; i++) {
        retryDelays.add(Duration(seconds: i + 1));
      }

      _dio.interceptors.add(RetryInterceptor(
        dio: _dio,
        // logPrint: print, // specify log function (optional)
        retries: retryNumber, // retry count (optional)
        retryDelays: retryDelays,
      ));
    }

    try {
      Response response;
      response = await _dio.patch(url,
          data: formData ?? body,
          options: Options(responseType: responseType, headers: header));
      if (kDebugMode) {
        log(response.data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (onSuccess != null) {
          onSuccess(response.data);
        }
      } else {
        if (onError != null) {
          onError(ErrorModel(
              title: "سرور در دسترس نیست .", errorStatus: ErrorStatus.server));
        }
      }
    } catch (e) {
      _onErrorCatch(e: e, onError: onError);
    }
  }
}
