import 'package:dartDemo/dio/dio_log_interceptor.dart';
import 'package:dio/dio.dart';

class HttpManager{
  static const String baseUrl = "https://www.wanandroid.com/";
  static const connectTimeOut = Duration(seconds: 10);
  late Dio dio;

  static late final HttpManager _singleton = HttpManager._internal();

  static HttpManager get instance => HttpManager._internal();

  factory HttpManager() => _singleton;


  HttpManager._internal(){
    var options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeOut,
    );
    dio = Dio(options);
    dio.interceptors.add(DioLogInterceptor());
  }
}