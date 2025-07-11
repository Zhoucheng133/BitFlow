import 'dart:convert';

import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/types/types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitServivce extends GetxController{
  late SharedPreferences prefs;
  final StoreGet storeGet=Get.find();
  final StatusGet statusGet=Get.find();

  void parseStore(BuildContext context){
    final storePrefs=prefs.getString('store');
    if(storePrefs!=null){
      try {
        final List<StoreItem> store=jsonDecode(storePrefs);
        storeGet.servers.value=store;
        statusGet.initOk.value=true;
        return;
      } catch (_) {}
    }
    storeGet.addStore(context, init: true);
  }

  Future<void> init(BuildContext context) async {
    prefs=await SharedPreferences.getInstance();
    if(context.mounted){
      parseStore(context);
    }
  }
}