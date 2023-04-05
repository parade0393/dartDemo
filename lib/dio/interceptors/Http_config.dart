import 'package:dio/dio.dart';

class HttpConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration sendTimeout;
  final Duration receiveTimeout;
  final List<Interceptor>? interceptors;

  HttpConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 1),
    this.sendTimeout = const Duration(seconds: 1),
    this.receiveTimeout = const Duration(seconds: 1),
    this.interceptors,
  });
}
