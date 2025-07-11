enum StoreType{
  aria,
  qbit,
}

class StoreItem{
  late StoreType type;
  late String url;
  // Aria中没有username参数
  late String? username;
  late String password;
  StoreItem(this.type, this.url, this.username, this.password);
}