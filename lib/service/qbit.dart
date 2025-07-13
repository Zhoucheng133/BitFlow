import 'package:bit_flow/types/store_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class QbitService extends GetxController {
  Future<String?> getCookie(StoreItem item) async {
    if(item.type!=StoreType.qbit){
      return null;
    }
    try {
      final url = Uri.parse("${item.url}/api/v2/auth/login");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': item.username,
          'password': item.password,
        },
      );
      String setCookie=response.headers['set-cookie']!;
      return setCookie.split(';')[0];
    } catch (_) {
      return null;
    }
  }
  
  Future<bool> check(StoreItem item) async {
    if(item.type!=StoreType.qbit){
      return false;
    }
    final cookie=await getCookie(item);
    if(cookie==null){
      return false;
    }

    return true;
  }
}