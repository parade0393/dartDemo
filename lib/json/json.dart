import 'dart:convert' as convert;
import 'dart:developer' as developer;

/// json格式化输出
void main(){
  var map = {
    "id":1,
    "data":{
      "name":"parade",
      "list":[
        {
          "gradle":23
        },
        {
          "gradle":"难"
        },
      ]
    }
  };
  var str =  convert.JsonEncoder.withIndent(" ").convert(map);
  print(str);
}