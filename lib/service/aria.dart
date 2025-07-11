import 'dart:convert';

import 'package:bit_flow/types/types.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AriaService extends GetxController{

  Future<Map> httpRequest(Map data, String aria) async {
    final url = Uri.parse(aria);
    final body = json.encode(data);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      return {};
    }
  }


  Future<String?> getVersion(StoreItem item) async {
    if(item.type!=StoreType.aria){
      return null;
    }
    try {
      return (await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.getVersion",
        "id":"ariaui",
        "params":["token:${item.password}"]
      }, item.url))['result']['version'];
    } catch (_) {
      return null;
    }
  }
}