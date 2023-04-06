import 'dart:io';

import 'package:dartDemo/dio/api_exption.dart';
import 'package:dartDemo/dio/interceptors/Http_config.dart';
import 'package:dartDemo/dio/interceptors/request_headers_interceptor.dart';
import 'package:dartDemo/dio/interceptors/dio_log_interceptor.dart';
import 'package:dartDemo/dio/response/base_res.dart';
import 'package:dio/dio.dart';
import 'dart:convert' as convert;

import 'package:dio/io.dart';

/// 单例
/// 请求头拦截
/// 日志拦截
/// 响应处理
/// 错误处理
class HttpManager {
  static const String _baseUrl = "https://www.wanandroid.com/";
  static const _connectTimeOut = Duration(seconds: 10);
  late Dio _dio;
  bool _isInit = false;

  static late final HttpManager _singleton = HttpManager._internal();

  static HttpManager get instance => _singleton;

  factory HttpManager() => _singleton;

  HttpManager._internal() {
  }

  void init(HttpConfig httpConfig){
    _isInit = true;
    var options = BaseOptions(
      baseUrl: httpConfig.baseUrl,
      connectTimeout: httpConfig.connectTimeout,
      receiveTimeout: httpConfig.receiveTimeout,
      sendTimeout: httpConfig.sendTimeout
    );
    _dio = Dio(options)
      ..interceptors.add(RequestHeaders())
      ..interceptors.add(DioLogInterceptor());
    if(httpConfig.interceptors?.isNotEmpty ?? false){
      _dio.interceptors.addAll(httpConfig.interceptors!);
    }
    ( _dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client){
      client.badCertificateCallback = (X509Certificate cert, String host, int port)=>true;
      return client;
    };
  }

  Future<BaseResponse?> request({
    required String url,
    required String method,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? requestOptions,
    bool Function(ApiException)? onError,
  }) async {
    try {
      if(!_isInit){
        throw ApiException(-1,"Please call the init method first");
      }
      Options options = Options()
        ..method = method;
      if(requestOptions != null){
       options.copyWith(
         sendTimeout: requestOptions.sendTimeout,
         receiveTimeout: requestOptions.receiveTimeout,
         extra: requestOptions.extra,
         responseType: requestOptions.responseType,
         contentType: requestOptions.contentType,
         validateStatus: requestOptions.validateStatus,
         receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
         followRedirects: requestOptions.followRedirects,
         maxRedirects: requestOptions.maxRedirects,
         persistentConnection: requestOptions.persistentConnection,
         requestEncoder: requestOptions.requestEncoder,
         responseDecoder: requestOptions.responseDecoder,
         listFormat: requestOptions.listFormat,
         headers: requestOptions.headers
       );

      }
      data = _convertRequestData(data);
      Response response = await _dio.request(
        url,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
    return _handleResponse(response);
    } catch (e) {
      var exception = ApiException.from(e);
      if(onError == null){
        // toast提示
      }
      if (onError?.call(exception) ?? false) {
        throw exception;
      }
    }
    return null;
  }

  Future<BaseResponse?> get({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    Options? options,
    bool Function(ApiException)? onError,
  }){
    return request(url: url, method: "get",queryParameters: queryParameters,data: data,onError: onError,requestOptions: options);
  }

  Future<BaseResponse?> post({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    Options? options,
    bool Function(ApiException)? onError,
  }){
    return request(url: url, method: "post",queryParameters: queryParameters,data: data,onError: onError,requestOptions: options);
  }

  ///将请求 data 数据先使用 jsonEncode 转换为字符串，再使用 jsonDecode 方法将字符串转换为 Map。
  dynamic _convertRequestData(dynamic data) {
    if (data != null) {
      data = convert.jsonDecode(convert.jsonEncode(data));
    }
    return data;
  }

 BaseResponse? _handleResponse(Response response){
     if(response.statusCode == 200){
       if(response.data["errorCode"] == 0){
         return BaseResponse.fromJson(response.data);
       }else{
         throw ApiException(response.data["errorCode"]??-1,response.data["errorMsg"]??"未知错误");
       }

     }else{
       throw ApiException(response.statusCode,response.statusMessage);
     }
  }
}
