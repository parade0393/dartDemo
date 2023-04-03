import 'package:dartDemo/dio/interceptors/request_headers_interceptor.dart';
import 'package:dartDemo/dio/interceptors/dio_log_interceptor.dart';
import 'package:dio/dio.dart';
/// 单例
/// 请求头拦截
/// 日志拦截
/// 响应处理
/// 错误处理
class HttpManager {
  static const String _baseUrl = "https://www.wanandroid.com/";
  static const _connectTimeOut = Duration(seconds: 10);
  late Dio dio;

  static late final HttpManager _singleton = HttpManager._internal();

  static HttpManager get instance => HttpManager._internal();

  factory HttpManager() => _singleton;

  HttpManager._internal() {
    print("1111");
    var options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _connectTimeOut,
    );
    dio = Dio(options)
      ..interceptors.add(RequestHeaders())
      ..interceptors.add(DioLogInterceptor());
  }
}
