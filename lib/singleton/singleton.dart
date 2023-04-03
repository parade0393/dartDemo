/// 单例使用
class Singleton1{
  static Singleton1? _instance;

  static get instance{
    if(_instance == null){
      _instance = Singleton1._internal();
    }
    return _instance;
  }

  Singleton1._internal();
}