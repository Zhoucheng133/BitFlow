import 'dart:convert';

import 'package:bit_flow/types/types.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AriaService extends GetxController{
  Future<String?> getVersion(StoreItem item) async {
    if(item.type!=StoreType.aria){
      return null;
    }
    try {
      final response=await http.post(
        Uri.parse(item.url), 
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jsonrpc":"2.0",
          "method":"aria2.getVersion",
          "id":"ariaui",
          "params":["token:${item.password}"]
        })
      );
      final version=json.decode(utf8.decode(response.bodyBytes))['result']['version'];
      return version;
    } catch (_) {}

    return null;
  }
}