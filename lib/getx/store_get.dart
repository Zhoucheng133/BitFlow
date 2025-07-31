import 'dart:convert';

import 'package:bit_flow/components/add_store.dart';
import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreGet extends GetxController{
  final AriaService ariaService=Get.find();
  final QbitService qbitService=Get.find();
  final StatusGet statusGet=Get.find();
  RxList<StoreItem> servers = <StoreItem>[].obs;
  RxInt starIndex=0.obs;

  // 默认在活跃页面，新的在后，旧的在前
  Rx<OrderTypes> defaultActiveOrder=OrderTypes.addOld.obs;
  // 默认在已完成页面，新的在前，旧的在后
  Rx<OrderTypes> defaultFinishOrder=OrderTypes.addNew.obs;

  // 更新频率 (单位: 毫秒)
  RxInt freq=1500.obs;

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
    final ok=await showConfirmDialog(context, "删除下载服务器", "你确定要删除下载服务器: ${servers[delIndex].name} 吗？");
    if(ok){
      statusGet.sevrerIndex.value=0;
      servers.removeAt(delIndex);
      if(starIndex>=servers.length){
        setStar(0);
      }
      saveStore();
    }
  }

  Future<void> showFreqDialog(BuildContext context) async {
    freq.value=await freqDialogContent(context, freq.value);
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
            title: Text(
              '添加一个下载服务器',
              style: GoogleFonts.notoSansSc(
                color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
              ),
            ),
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