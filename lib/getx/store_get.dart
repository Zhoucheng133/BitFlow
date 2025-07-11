import 'package:bit_flow/components/add_store.dart';
import 'package:bit_flow/types/types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreGet extends GetxController{
  RxList<StoreItem> servers = <StoreItem>[].obs;

  void addStore(BuildContext context, {init=false}){
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: const Text('添加一个下载服务器'),
        content: SizedBox(
          width: 400,
          child: AddStore()
        ),
        actions: [
          TextButton(
            onPressed: init ? null : () => Navigator.pop(context), 
            child: const Text("取消")
          ),
          ElevatedButton(
            onPressed: (){
              // TODO
            }, 
            child: const Text("添加")
          )
        ],
      )
    );
  }
}