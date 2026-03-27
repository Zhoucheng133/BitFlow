import 'dart:convert';

import 'package:bit_flow/types/store_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TransmissionConfig{

}

class TransmissionService extends GetxController {

  String sessionId="";

  Future<void> getSession(StoreItem item) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
    try {
      final response=await http.post(Uri.parse("${item.url}/transmission/rpc"),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({"method": "session-get"}),
      );
      if(response.statusCode==409){
        sessionId=response.headers["x-transmission-session-id"]!;
      }
    } catch (_) {}
  }

  Future<bool> check(StoreItem item) async {
    if(item.type!=StoreType.transmission){
      return false;
    }
    await getSession(item);
    if(sessionId.isEmpty){
      return false;
    }
    return true;
  }
}