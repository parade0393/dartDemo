import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'dart:math' as math;

class DioLogInterceptor extends Interceptor {
  static const corner_up = "┌";
  static const corner_bottom = "└";
  static const h_line = "─";
  static const v_line = "│";
  static const center_line = "├";
  static const url_tag = "URL: ";
  static const headers_tag = "Headers: ";
  static const method_tag = "Method: @";
  /// InitialTab count to logPrint json response
  static const int kInitialTab = 1;
  /// 1 tab length
  static const String tabStep = '    ';
  late DateTime _startTime;
  late DateTime _endTime;

  /// Width size per logPrint
  final int maxWidth;
  final bool enabled;

  /// Print compact json response
  final bool compact;

  /// Log printer; defaults logPrint log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  final void Function(Object object) logPrint;

  /// Size in which the Uint8List will be splitted
  static const int chunkSize = 20;

  DioLogInterceptor({this.maxWidth = 90, this.enabled = true, this.compact = true,this.logPrint = print});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if(enabled){
      _startTime = DateTime.now();
      _printRequestHeader();
      _printRow(url_tag+options.uri.toString());//完整的Url
      // _printRow(url_tag+options.uri.path);//除了baseUrl的部分
      _printRow("$method_tag${options.method}");
      // _printMapAsTable(options.queryParameters,header: "Query Parameters：");
      final requestHeaders = <String, dynamic>{};
      requestHeaders.addAll(options.headers);
      requestHeaders['contentType'] = options.contentType?.toString();
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      requestHeaders['connectTimeout'] = options.connectTimeout?.toString();
      requestHeaders['receiveTimeout'] = options.receiveTimeout?.toString();
      _printMapAsTable(requestHeaders, header: headers_tag);
      _printMapAsTable(options.extra, header: 'Extras');

      if(options.method != 'GET'){
        final dynamic data = options.data;
        if(data != null){
          if (data is Map) _printMapAsTable(options.data as Map?, header: 'Body：');
          if(data is FormData){
            final formDataMap = <String, dynamic>{}
              ..addEntries(data.fields)
              ..addEntries(data.files);
            _printMapAsTable(formDataMap, header: 'Form data | ${data.boundary}：');
          }else{
            _printBlock(data.toString());
          }
        }
      }
      _printLine(pre: corner_bottom);

    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if(enabled){
      _endTime = DateTime.now();
      _printResponseHeader();
      _printRow(url_tag+response.realUri.toString());//完整的Url
      _printRow("statusCode：${response.statusCode}${' '}${h_line}${' '}receive in ${_endTime.difference(_startTime).inMilliseconds}ms");

      final responseHeaders = <String, String>{};
      response.headers
          .forEach((k, list) => responseHeaders[k] = list.join(";"));
      _printMapAsTable(responseHeaders, header: headers_tag);
      _printRow("Body：");
      _printRow("");
      _printResponse(response);
      _printLine(pre: corner_bottom);
    }
    super.onResponse(response, handler);
  }

  String _indent([int tabCount = kInitialTab]) => tabStep * tabCount;

  void _printResponse(Response response) {
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(response.data as Map);
      } else if (response.data is Uint8List) {
        logPrint('$v_line${_indent()}[');
        _printUint8List(response.data as Uint8List);
        logPrint('$v_line${_indent()}]');
      } else if (response.data is List) {
        logPrint('$v_line${_indent()}[');
        _printList(response.data as List);
        logPrint('$v_line${_indent()}]');
      } else {
        _printBlock(response.data.toString());
      }
    }
  }

  void _printPrettyMap(
      Map data, {
        int initialTab = kInitialTab,
        bool isListItem = false,
        bool isLast = false,
      }) {
    var tabs = initialTab;
    final isRoot = tabs == kInitialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) logPrint('$v_line$initialIndent{');

    data.keys.toList().asMap().forEach((index, dynamic key) {
      final isLast = index == data.length - 1;
      dynamic value = data[key];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          logPrint('$v_line${_indent(tabs)} $key: $value${!isLast ? ',' : ''}');
        } else {
          logPrint('$v_line${_indent(tabs)} $key: {');
          _printPrettyMap(value, initialTab: tabs);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          logPrint('$v_line${_indent(tabs)} $key: ${value.toString()}');
        } else {
          logPrint('$v_line${_indent(tabs)} $key: [');
          _printList(value, tabs: tabs);
          logPrint('$v_line${_indent(tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(tabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            logPrint(
                '$v_line${_indent(tabs)} ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}');
          }
        } else {
          logPrint('$v_line${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    });

    logPrint('$v_line$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(List list, {int tabs = kInitialTab}) {
    list.asMap().forEach((i, dynamic e) {
      final isLast = i == list.length - 1;
      if (e is Map) {
        if (compact && _canFlattenMap(e)) {
          logPrint('$v_line${_indent(tabs)}  $e${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(e, initialTab: tabs + 1, isListItem: true, isLast: isLast);
        }
      } else {
        logPrint('$v_line${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    });
  }

  void _printUint8List(Uint8List list, {int tabs = kInitialTab}) {
    var chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
            i, i + chunkSize > list.length ? list.length : i + chunkSize),
      );
    }
    for (var element in chunks) {
      logPrint('$v_line${_indent(tabs)} ${element.join(", ")}');
    }
  }

  void _printLine({String pre = "",  String? middle}){
    if(middle != null && middle.isNotEmpty){
      logPrint("$pre${h_line * 2}${' '}$middle${' '}${h_line * 40}");
    }else{
      logPrint("$pre${h_line * 40}");
    }
  }
  void _printRow(String? message) => logPrint("${v_line}${' '*2}$message");
  void _printCenterRow(String? message) => logPrint("${center_line}${' '*3}$message");
  void _printRequestHeader() => _printLine(pre:corner_up,middle: "Request");
  void _printResponseHeader() => _printLine(pre:corner_up,middle: "Response");
  void _printEndLine() => _printLine(middle: "");
  void _printKV(String? key,Object? v){
      final pre = "$key: ";
      final msg = v.toString();
      _printCenterRow("$pre$msg");
  }

  void _printBlock(String msg){
    final lines = (msg.length / maxWidth).ceil();
    for (int i = 0; i < lines; i++) {
      logPrint((i >= 0 ? v_line : '') +
          msg.substring(i * maxWidth,
              math.min<int>(i * maxWidth + maxWidth, msg.length)));
    }
  }

  void _printMapAsTable(Map? map, {String? header}) {
      if(map == null || map.isEmpty) return;
      _printRow(header);
      map.forEach((dynamic key, dynamic value) {
        _printKV(key, value);
      });
  }

  bool _canFlattenMap(Map map) {
    return map.values
        .where((dynamic val) => val is Map || val is List)
        .isEmpty &&
        map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }
}
