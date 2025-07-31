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
          case "stoppedDL":
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
        int addedOn=data['added_on'];
        int uploaded=data['uploaded'];
        tasks.add(TaskItem(name, size, [], status, link, path, downloadSpeed, uploadSpeed, completeBytes, id, addedOn, uploaded, StoreType.qbit));
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

  Future<void> addTask(String downloadUrl, StoreItem item) async {
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return;
      }
      cookie.value=temp;
    }
    try {
      final url = Uri.parse("${item.url}/api/v2/torrents/add");
      final request = http.MultipartRequest('POST', url);
      request.headers['Cookie'] = cookie.value;
      request.fields['urls'] = downloadUrl;
      await request.send();
      // print(await response.stream.bytesToString());
    } catch (_) {
      return;
    }
  }

  Future<List<FileItem>?> getFiles(StoreItem item, String hash) async {
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return [];
      }
      cookie.value=temp;
    }
    if(item.type!=StoreType.qbit){
      return null;
    }
    try {
      final url = Uri.parse("${item.url}/api/v2/torrents/files?hash=$hash");
      final response = await http.get(
        url,
        headers: {
          "Cookie": cookie.value,
        }
      );
      List data=json.decode(utf8.decode(response.bodyBytes));

      return data.map((item){
        return FileItem(item['name'], item['size'], null, null);
      }).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> delFinishedTask(StoreItem item, String hash, {bool delFile=false}) async {
    await delActiveTask(item, hash, delFile: delFile);
  }

  Future<void> delActiveTask(StoreItem item, String hash, {bool delFile=false}) async {
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return;
      }
      cookie.value=temp;
    }
    if(item.type!=StoreType.qbit){
      return;
    }
    try {
      final url = Uri.parse("${item.url}/api/v2/torrents/delete");
      await http.post(
        url,
        headers: {
          "Cookie": cookie.value,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'hashes': hash,
          'deleteFiles': delFile==true?"true":"false",
        },
      );
    } catch (_) {}
  }
  
  Future<void> pauseTask(StoreItem item, String hash) async {
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return;
      }
      cookie.value=temp;
    }
    if(item.type!=StoreType.qbit){
      return;
    }
    try {
      final url = Uri.parse("${item.url}/api/v2/torrents/stop");
      await http.post(
        url,
        headers: {
          "Cookie": cookie.value,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'hashes': hash,
        },
      );
    } catch (_) {}
  }

  Future<void> continueTask(StoreItem item, String hash) async {
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return;
      }
      cookie.value=temp;
    }
    if(item.type!=StoreType.qbit){
      return;
    }
    try {
      final url = Uri.parse("${item.url}/api/v2/torrents/start");
      await http.post(
        url,
        headers: {
          "Cookie": cookie.value,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'hashes': hash,
        },
      );
    } catch (_) {}
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