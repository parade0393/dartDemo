import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() async {
  const apiUrl = "https://h5.48.cn/resource/jsonp/allmembers.php?gid=10";
  final res = await http.get(Uri.parse(apiUrl));
  final json = convert.jsonDecode(res.body);
  var keyList = <String>[];
  final members = json["rows"]
      .map<Member>((row) =>
          Member(id: row["sid"], name: row["sname"], team: row["tname"]))
      .toList();
  final map = Map<String,dynamic>();
  members.forEach((m) {
    final key = m.team;
    if (map[key] != null) {
      map[key].add(m);
    } else {
      map[key] = [];
      map[key].add(m);
    }
  });
  keyList = map.keys.toList();
  // print(keyList);
  List.generate(keyList.length * 2, (index){
    if(index % 2 == 0){
      print(keyList[index ~/ 2]);
    }else{
      print(map[keyList[index ~/ 2]].length);
    }
  });
  // print(members);
}

class Member {
  final String id;
  final String name;
  final String team;

  Member({required this.id, required this.name, required this.team});

  @override
  String toString() {
    return 'Member{id: $id, name: $name}';
  }
}
