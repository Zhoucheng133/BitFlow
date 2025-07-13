import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:get/get.dart';

enum StoreType{
  aria,
  qbit,
}

class StoreItem{
  late String name;
  late StoreType type;
  late String url;
  // Aria中没有username参数
  late String? username;
  late String password;
  StoreItem(this.name, this.type, this.url, this.username, this.password);

  final AriaService ariaService=Get.find();
  final QbitService qbitService=Get.find();
  final StoreGet storeGet=Get.find();

  Map toMap(){
    return {
      "name": name,
      "type": type.index,
      "url": url,
      "username": username??"",
      "password": password,
    };
  }

  Future<bool> checkItem() async {
    switch (type) {
      case StoreType.aria:
        final version=await ariaService.getVersion(this);
        if(version!=null){
          return true;
        }
        return false;
      case StoreType.qbit:
        final check=await qbitService.check(this);
        if(check){
          return true;
        }
        return false;
    }
  }
}