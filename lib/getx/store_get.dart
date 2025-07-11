import 'package:bit_flow/components/add_store.dart';
import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:bit_flow/types/types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreGet extends GetxController{
  final AriaService ariaService=Get.find();
  final QbitService qbitService=Get.find();
  RxList<StoreItem> servers = <StoreItem>[].obs;

  Future<bool> checkStore(StoreItem item) async {
    switch (item.type) {
      case StoreType.aria:
        final version=await ariaService.getVersion(item);
        if(version!=null){
          return true;
        }
        return false;
      case StoreType.qbit:
        final version=await qbitService.getVersion(item);
        if(version!=null){
          return true;
        }
        return false;
    }
  }

  void addStore(BuildContext context, {init=false}){
    StoreItem item=StoreItem(StoreType.aria, "", null, "");
    void setVal(StoreItem val){
      item = StoreItem(val.type, val.url, val.type==StoreType.aria ? null : val.username, val.password);
    }

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context)=>AlertDialog(
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
            onPressed: () async {
              if(await checkStore(item)){
                servers.add(item);
                if(context.mounted) Navigator.pop(context);
              }else{
                if(context.mounted) showErrWarnDialog(context, "连接下载器失败", "请检查服务器地址和登录信息");
              }
            }, 
            child: const Text("添加")
          )
        ],
      )
    );
  }
}