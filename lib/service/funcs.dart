import 'dart:async';
import 'dart:convert';

import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FuncsService extends GetxController{
  late SharedPreferences prefs;
  late Timer interval;
  final StoreGet storeGet=Get.find();
  final StatusGet statusGet=Get.find();

  void parseStore(BuildContext context){
    final storePrefs=prefs.getString('store');
    if(storePrefs!=null){
      try {
        List<StoreItem> store=(jsonDecode(storePrefs) as List).map((item)=>StoreItem(item['name'], StoreType.values[item['type']], item['url'], item['username'], item['password'])).toList();
        storeGet.servers.value=store;
        statusGet.initOk.value=true;
      } catch (_) {
        storeGet.addStore(context, init: true);
      }
    }else{
      storeGet.addStore(context, init: true);
    }
    final starPrefs=prefs.getInt("star");
    if(starPrefs!=null && starPrefs<storeGet.servers.length){
      storeGet.starIndex.value=starPrefs;
      statusGet.sevrerIndex.value=starPrefs;
    }
  }

  void getTasks(){

  }
  
  Future<void> init(BuildContext context) async {
    prefs=await SharedPreferences.getInstance();
    if(context.mounted){
      parseStore(context);
    }
    if(storeGet.servers.isNotEmpty){
      // interval= Timer.periodic(const Duration(seconds: 1), (Timer time){
      //   getTasks();
      // });
    }
  }
}