/// 单例使用,普通的getter使用
class Singleton1{
  static Singleton1? _instance;

  static Singleton1 get instance{
    if(_instance == null){
      _instance = Singleton1._internal();
    }
    return _instance!;
  }

  Singleton1._internal();
}

/// factory构造函数
/// 普通的构造函数不能使用return

class Singleton2{
  static Singleton2? _instance;
  Singleton2._internal();

  factory Singleton2(){
      if(_instance == null){
        _instance = Singleton2._internal();
      }
      return _instance!;
  }
}

/// 使用 ?? 操作符
class Singleton3{
  static Singleton3? _instance;
  Singleton3._internal(){
    _instance = this;
  }

  factory Singleton3() => _instance ?? Singleton3._internal();
}

class Singleton4{
  Singleton4._internal();
  // 被标记为 late 的变量 _instance 的初始化操作将会延迟到字段首次被访问时执行
  static late final Singleton4 _instance = Singleton4._internal();
  factory Singleton4() => _instance;
}

