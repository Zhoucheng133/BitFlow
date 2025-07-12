import 'dart:convert';

import 'package:bit_flow/components/add_store.dart';
import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:bit_flow/types/types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreGet extends GetxController{
  final AriaService ariaService=Get.find();
  final QbitService qbitService=Get.find();
  final StatusGet statusGet=Get.find();
  RxList<StoreItem> servers = <StoreItem>[].obs;
  RxInt starIndex=0.obs;

  late SharedPreferences prefs;


  init() async {
    prefs=await SharedPreferences.getInstance();
  }
  StoreGet(){
    init();
  }

  Future<void> saveStore() async {
    prefs.setString("store", jsonEncode(servers.map((item)=>item.toMap()).toList()));
  }

  Future<void> delStore(BuildContext context, int delIndex) async {
    final ok=await showComfirmDialog(context, "删除下载服务器", "你确定要删除下载服务器: ${servers[delIndex].name} 吗？");
    if(ok){
      statusGet.sevrerIndex.value=0;
      servers.removeAt(delIndex);
      if(starIndex>=servers.length){
        setStar(0);
      }
      saveStore();
    }
  }

  void setStar(int index){
    starIndex.value=index;
    prefs.setInt("star", index);
  }

  void addStore(BuildContext context, {init=false}){
    StoreItem item=StoreItem("", StoreType.aria, "", null, "");
    bool load=false;
    void setVal(StoreItem val){
      item = StoreItem(val.name, val.type, val.url, val.type==StoreType.aria ? null : val.username, val.password);
    }

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context)=>StatefulBuilder(
        builder: (context, setState)  {
          return AlertDialog(
            title: const Text('添加一个下载服务器'),
            content: SizedBox(
              width: 400,
              child: AddStore(valCallback: setVal,)
            ),
            actions: [
              TextButton(
                onPressed: init ? null : () => Navigator.pop(context), 
                child: const Text("取消")
              ),
              ElevatedButton(
                onPressed: load ? null : () async {
                  if(servers.any((element) => element.name==item.name)){
                    showErrWarnDialog(context, "添加失败", "这个下载器名称已存在");
                    return;
                  }
                  setState((){
                    load=true;
                  });
                  bool checked=await item.checkItem();
                  if(checked){
                    servers.add(item);
                    saveStore();
                    if(context.mounted) Navigator.pop(context);
                  }else{
                    if(context.mounted) showErrWarnDialog(context, "连接下载器失败", "请检查服务器地址和登录信息");
                  }
                  setState((){
                    load=false;
                  });
                }, 
                child: const Text("添加")
              )
            ],
          );
        }
      )
    );
  }
}