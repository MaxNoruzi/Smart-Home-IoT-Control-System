enum ErrorStatus { server, timeout, connection, unknown, none, badRequest, codeError ,showErrorText }

class ErrorModel {
  final String title;
  final String? subtitle;
  final ErrorStatus errorStatus;

  ErrorModel({required this.title, this.subtitle, required this.errorStatus});
}
