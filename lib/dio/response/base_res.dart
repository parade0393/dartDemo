
class BaseResponse {
  late dynamic data;
  late int errorCode;
  String? errorMsg;

  BaseResponse({
    required this.data,
    required this.errorCode,
    required this.errorMsg,
  });

  BaseResponse.fromJson(dynamic json){
    if(json == null) return;
      data = json["data"];
      errorCode = json["errorCode"];
      errorMsg = json["errorMsg"]?? "";
  }
}
