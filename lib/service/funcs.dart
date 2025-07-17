import 'dart:async';
import 'dart:convert';

import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FuncsService extends GetxController{
  late SharedPreferences prefs;
  late Timer interval;
  final StoreGet storeGet=Get.find();
  final StatusGet statusGet=Get.find();
  final AriaService ariaService=Get.find();
  final QbitService qbitService=Get.find();

  FuncsService(){
    ever(statusGet.page, (_) async {
      statusGet.loading.value=true;
      await getTasks();
      await Future.delayed(const Duration(seconds: 1), (){
        statusGet.loading.value=false;
      });
    });

    ever(statusGet.sevrerIndex, (_) async {
      statusGet.loading.value=true;
      statusGet.activeTasks.value=[];
      statusGet.finishedTask.value=[];
      await getTasks();
      await Future.delayed(const Duration(seconds: 1), (){
        statusGet.loading.value=false;
      });
    });
  }

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

  void addTaskHandler(String url){
    switch (storeGet.servers[statusGet.sevrerIndex.value].type) {
      case StoreType.aria:
        ariaService.addTask(url, storeGet.servers[statusGet.sevrerIndex.value]);
        break;
      case StoreType.qbit:
        qbitService.addTask(url, storeGet.servers[statusGet.sevrerIndex.value]);
        break;
    }
  }

  Future<void> getTasks() async {
    switch (storeGet.servers[statusGet.sevrerIndex.value].type) {
      case StoreType.aria:
        statusGet.makeTasks(await ariaService.getTasks(statusGet.page.value, storeGet.servers[statusGet.sevrerIndex.value]), storeGet.servers[statusGet.sevrerIndex.value].type);
        break;
      case StoreType.qbit:
        statusGet.makeTasks(await qbitService.getTasks(statusGet.page.value, storeGet.servers[statusGet.sevrerIndex.value]), storeGet.servers[statusGet.sevrerIndex.value].type);
        break;
    }
  }
  
  Future<void> init(BuildContext context) async {
    prefs=await SharedPreferences.getInstance();
    if(context.mounted){
      parseStore(context);
    }
    if(storeGet.servers.isNotEmpty){
      interval= Timer.periodic(const Duration(milliseconds: 1100), (Timer time){
        if(!statusGet.loading.value){
          getTasks();
        }
      });
    }
  }
}