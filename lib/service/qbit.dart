import 'dart:convert';

import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class QbitService extends GetxController {

  RxString cookie="".obs;

  Future<String?> getCookie(StoreItem item) async {
    if(item.type!=StoreType.qbit){
      return null;
    }
    try {
      final url = Uri.parse("${item.url}/api/v2/auth/login");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': item.username,
          'password': item.password,
        },
      );
      String setCookie=response.headers['set-cookie']!;
      return setCookie.split(';')[0];
    } catch (_) {
      return null;
    }
  }

  Future<List<TaskItem>?> getAll(StoreItem item) async{
    // final cookie=await getCookie(item);
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return null;
      }
      cookie.value=temp;
    }
    try {
      final url = Uri.parse("${item.url}/api/v2/torrents/info");
      final response = await http.post(
        url,
        headers: {
          "Cookie": cookie.value,
        }
      );
      List data=json.decode(utf8.decode(response.bodyBytes));

      List<TaskItem> tasks=[];
      for (var data in data) {
        String name=data['name'];
        int size=data['size'];
        TaskStatus status=TaskStatus.download;
        switch (data['state']) {
          case "downloading":
          case "stoppedDL":
          case "checkingDL":
          case "allocating":
          case "metaDL":
          case "stalledDL":
            break;
          case "uploading":
          case "pausedUP":
          case "queuedUP":
          case "stalledUP" :
            status=TaskStatus.seeding;
            break;
          case "pausedDL":
            status=TaskStatus.pause;
            break;
          case "queuedDL":
            status=TaskStatus.wait;
            break;
          default:
            status=TaskStatus.finish;
        }
        String link=data['magnet_uri'];
        String path=data['content_path'];
        int downloadSpeed=data['dlspeed'];
        int uploadSpeed=data['upspeed'];
        int completeBytes=data['completed'];
        String id=data['hash'];
        tasks.add(TaskItem(name, size, [], status, link, path, downloadSpeed, uploadSpeed, completeBytes, id));
      }
      return tasks;
    } catch (e) {
      return [];
    }
  }

  Future<List<TaskItem>> getTasks(Pages page, StoreItem item) async {
    List<TaskItem> all=(await getAll(item))??[];
    if(page==Pages.active){
      return all.where((item)=>item.status!=TaskStatus.finish).toList();
    }else if(page==Pages.finish){
      return all.where((item)=>item.status==TaskStatus.finish).toList();
    }
    return [];
  }

  void addTask(String url, StoreItem item){

  }
  
  Future<bool> check(StoreItem item) async {
    if(item.type!=StoreType.qbit){
      return false;
    }
    final cookie=await getCookie(item);
    if(cookie==null){
      return false;
    }

    return true;
  }
}