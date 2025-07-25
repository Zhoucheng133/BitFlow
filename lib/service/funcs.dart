import 'dart:async';
import 'dart:convert';

import 'package:bit_flow/components/dialogs.dart';
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

  late Worker pageListener;
  late Worker serverListener;
  late Worker selectListener;

  FuncsService(){
    pageListener=ever(statusGet.page, (_) async {
      statusGet.selectMode.value=false;
      await getTasks();
    });

    serverListener=ever(statusGet.sevrerIndex, (_) async {
      statusGet.selectMode.value=false;
      statusGet.activeTasks.value=[];
      statusGet.finishedTask.value=[];
      await getTasks();
    });

    selectListener=ever(statusGet.selectMode, (bool select){
      if(!select){
        statusGet.selectList.value=[];
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    pageListener.dispose();
    serverListener.dispose();
    selectListener.dispose();
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

  List<String> splitUrls(String url){
    return url.split("\n");
  }

  void addTaskHandler(String url){
    switch (storeGet.servers[statusGet.sevrerIndex.value].type) {
      case StoreType.aria:
        for(String urlItem in splitUrls(url)){
          ariaService.addTask(urlItem, storeGet.servers[statusGet.sevrerIndex.value]);
        }
        break;
      case StoreType.qbit:
        for(String urlItem in splitUrls(url)){
          qbitService.addTask(urlItem, storeGet.servers[statusGet.sevrerIndex.value]);
        }
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

  Future<void> delAllFinishedTasks(BuildContext context) async {
    bool confirm=await showConfirmDialog(context, "删除所有已完成的任务?", "这个操作不能撤销!");
    if(!confirm){
      return;
    }
    switch (storeGet.servers[statusGet.sevrerIndex.value].type) {
      case StoreType.aria:
        ariaService.clearFinished(storeGet.servers[statusGet.sevrerIndex.value]);
        break;
      case StoreType.qbit:
        final List<String> finishedList=statusGet.finishedTask.map((item)=>item.id).toList();
        final hashes=finishedList.join('|');
        qbitService.delFinishedTask(storeGet.servers[statusGet.sevrerIndex.value], hashes);
        break;
    }
  }

  Future<void> delSelected(BuildContext context, Pages page) async {
    bool confirm=await showConfirmDialog(context, "删除这些任务?", "这个操作不能撤销!");
    if(!confirm) return;
    switch (storeGet.servers[statusGet.sevrerIndex.value].type) {
      case StoreType.aria:
        for (var id in statusGet.selectList) {
          if(page==Pages.active){
            await ariaService.delActiveTask(id, storeGet.servers[statusGet.sevrerIndex.value]);
          }else if(page==Pages.finish){
            await ariaService.delFinishedTask(id, storeGet.servers[statusGet.sevrerIndex.value]);
          }
        }
        break;
      case StoreType.qbit:
        final hashes=statusGet.selectList.join('|');
        await qbitService.delActiveTask(storeGet.servers[statusGet.sevrerIndex.value], hashes);
        break;
    }
    getTasks();
  }
  
  Future<void> init(BuildContext context) async {
    prefs=await SharedPreferences.getInstance();
    if(context.mounted){
      parseStore(context);
    }
    if(storeGet.servers.isNotEmpty){
      interval= Timer.periodic(const Duration(milliseconds: 1500), (Timer time){
        getTasks();
      });
    }
  }
}