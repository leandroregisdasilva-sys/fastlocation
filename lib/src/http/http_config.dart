import 'package:dio/dio.dart';

class HttpConfig {
  HttpConfig._();

  static const String baseUrl = 'https://viacep.com.br/ws';
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;

  static final Dio dio = create();

  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        responseType: ResponseType.json,
        headers: <String, dynamic>{'Accept': 'application/json'},
      ),
    );
  }
}
