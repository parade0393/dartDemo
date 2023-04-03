import 'package:dio/dio.dart';

/// 添加自定义请求头
class RequestHeaders extends Interceptor{
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers["platform"] = "android";
    super.onRequest(options, handler);
  }
}