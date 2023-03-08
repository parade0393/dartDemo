
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
void main() async{
  const apiUrl = "https://h5.48.cn/resource/jsonp/allmembers.php?gid=10";
  final res = await http.get(Uri.parse(apiUrl));
  final json = convert.jsonDecode(res.body);
  final members = json["rows"].map<Member>((row) => Member(id: row["sid"], name: row["sname"],team: row["tname"])).toList();
  final map = Map();
  members.forEach((m){
    final key = m.team;
    if(map[key] != null){
      map[key].add(m);
    }else{
      map[key] = [];
      map[key].add(m);
    }
  });
  print(map);
  // print(members);
}

class Member{
  final String id;
  final String name;
  final String team;

  Member({required this.id,required this.name,required this.team});

  @override
  String toString() {
    return 'Member{id: $id, name: $name}';
  }
}