import 'dart:async';
import 'dart:convert';

import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:bit_flow/types/task_item.dart';
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
    if(statusGet.selectList.isEmpty){
      await showErrWarnDialog(context, "无效操作", "没有选择任何任务");
      return;
    }
    bool confirm=await showConfirmDialog(context, "删除这些任务?", "这个操作不能撤销!");
    if(!confirm) return;
    switch (storeGet.servers[statusGet.sevrerIndex.value].type) {
      case StoreType.aria:
        for (var item in statusGet.selectList) {
          if(page==Pages.active){
            await ariaService.delActiveTask(item.id, storeGet.servers[statusGet.sevrerIndex.value]);
          }else if(page==Pages.finish){
            await ariaService.delFinishedTask(item.id, storeGet.servers[statusGet.sevrerIndex.value]);
          }
        }
        break;
      case StoreType.qbit:
        final String hashes=statusGet.selectList.map((item)=>item.id).toList().join('|');
        if(context.mounted){
          final delFile=await showConfirmDialog(context, "同时删除文件吗", "是否要同时删除文件?");
          await qbitService.delActiveTask(storeGet.servers[statusGet.sevrerIndex.value], hashes, delFile: delFile);
        }
        break;
    }
    getTasks();
    statusGet.selectMode.value=false;
  }

  Future<void> reDownloadSelected(BuildContext context) async {
    if(statusGet.selectList.isEmpty){
      await showErrWarnDialog(context, "无效操作", "没有选择任何任务");
      return;
    }
    bool confirm=await showConfirmDialog(context, "重新下载这些任务?", "将会删除这些任务并重新添加为新的任务");
    if(!confirm) return;
    switch (storeGet.servers[statusGet.sevrerIndex.value].type) {
      case StoreType.aria:
        for (var item in statusGet.selectList) {
          await ariaService.delFinishedTask(item.id, storeGet.servers[statusGet.sevrerIndex.value]);
          await ariaService.addTask(item.link, storeGet.servers[statusGet.sevrerIndex.value]);
        }
        break;
      case StoreType.qbit:
        final String hashes=statusGet.selectList.map((item)=>item.id).toList().join('|');
        await qbitService.delFinishedTask(storeGet.servers[statusGet.sevrerIndex.value], hashes, delFile: true);
        for(TaskItem item in statusGet.selectList){
          await qbitService.addTask(item.link, storeGet.servers[statusGet.sevrerIndex.value]);
        }
        break;
    }
    getTasks();
    statusGet.selectMode.value=false;
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