import 'dart:convert';

import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TransmissionConfig{

}

class TransmissionService extends GetxController {

  String sessionId="";

  Future<void> getSession(StoreItem item) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
    try {
      final response=await http.post(Uri.parse("${item.url}/transmission/rpc"),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({"method": "session-get"}),
      );
      if(response.statusCode==409){
        sessionId=response.headers["x-transmission-session-id"]!;
      }
    } catch (_) {}
  }

  Future<List<TaskItem>?> getAll(StoreItem item) async{
    if(sessionId.isEmpty){
      await getSession(item);
      if(sessionId.isEmpty){
        return null;
      }
    }
    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
      final url = Uri.parse("${item.url}/transmission/rpc");
      final response = await http.post(
        url,
        headers: {
          "Authorization": basicAuth,
          "x-transmission-session-id": sessionId,
        },
        body: jsonEncode({
          'method': 'torrent-get',
          "arguments": {
            "fields": [
              "id", 
              "name", 
              "totalSize", 
              "status", 
              "addedDate",
              "percentDone",
              "hashString",
              "rateDownload",
              "rateUpload",
              "downloadDir",
              "downloadedEver",
              "uploadedEver",
              "files",
            ]
          }
        })
      );

      if (response.statusCode == 409) {
        sessionId = response.headers['x-transmission-session-id'] ?? "";
        return getAll(item);
      }

      final Map<String, dynamic> fullJson = json.decode(utf8.decode(response.bodyBytes));

      if (fullJson['result'] != 'success') return [];
      final List data = fullJson['arguments']['torrents'];
      
      List<TaskItem> tasks=[];
      for(var item in data){
        List<FileItem> files=[];
        for(var file in item["files"]){
          files.add(FileItem(
            file["name"],
            file["length"],
            null,
            file["bytesCompleted"]
          ));
        }

        TaskStatus status=TaskStatus.wait;

        switch (item['status']) {
          case 0:
            status=item['percentDone'] >= 1.0 ? TaskStatus.finish : TaskStatus.pause;
          case 1:
          case 3:
          case 5:
            status=TaskStatus.wait;
          case 2:
          case 4:
            status=TaskStatus.download;
          case 6:
            status=TaskStatus.seeding;
          default:
            status=TaskStatus.pause;
        }
        
        tasks.add(TaskItem(
          name: item["name"],
          size: item["totalSize"],
          files: files,
          status: status,
          link: "magnet:?xt=urn:btih:${item["hashString"]}",
          path: item['downloadDir'],
          downloadSpeed: item["rateDownload"],
          uploadSpeed: item["rateUpload"],
          completeBytes: item['downloadedEver'],
          id: item['id'].toString(),
          addTime: item['addedDate'],
          uploaded: item['uploadedEver'],
          type: StoreType.transmission,
          errorCode: null,
          errorMessage: null,
        ));
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
    if(sessionId.isEmpty){
      await getSession(item);
      if(sessionId.isEmpty){
        return;
      }
    }
    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
      final response=await http.post(Uri.parse("${item.url}/transmission/rpc"),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": "torrent-add",
          "arguments": {
            "filename": downloadUrl
          }
        }),
      );
      if (response.statusCode == 409) {
        sessionId = response.headers['x-transmission-session-id'] ?? "";
        return addTask(downloadUrl, item);
      }
      final Map<String, dynamic> fullJson = json.decode(utf8.decode(response.bodyBytes));

      if (fullJson['result'] != 'success') return;
    } catch (_) {}
  }

  Future<void> addTorrentTask(String base64, StoreItem item) async {
    if(sessionId.isEmpty){
      await getSession(item);
      if(sessionId.isEmpty){
        return;
      }
    }
    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
      final response=await http.post(Uri.parse("${item.url}/transmission/rpc"),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": "torrent-add",
          "arguments": {
            "metainfo": base64
          }
        }),
      );
      if (response.statusCode == 409) {
        sessionId = response.headers['x-transmission-session-id'] ?? "";
        return addTorrentTask(base64, item);
      }
      final Map<String, dynamic> fullJson = json.decode(utf8.decode(response.bodyBytes));

      if (fullJson['result'] != 'success') return;
    } catch (_) {}
  }
  
  Future<void> delActiveTask(StoreItem item, String id, {bool delFile=false}) async {
    if(sessionId.isEmpty){
      await getSession(item);
      if(sessionId.isEmpty){
        return;
      }
    }

    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
      final response=await http.post(Uri.parse("${item.url}/transmission/rpc"),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": "torrent-remove",
          "arguments": {
            "ids": [int.parse(id)],
            "delete-local-data": delFile
          }
        }),
      );
      if (response.statusCode == 409) {
        sessionId = response.headers['x-transmission-session-id'] ?? "";
        return delActiveTask(item, id, delFile: delFile);
      }
      final Map<String, dynamic> fullJson = json.decode(utf8.decode(response.bodyBytes));

      if (fullJson['result'] != 'success') return;
    } catch (_) {}
  }

  Future<void> delFinishedTask(StoreItem item, String id, {bool delFile=false}) async {
    delActiveTask(item, id, delFile: delFile);
  }
  
  Future<bool> check(StoreItem item) async {
    if(item.type!=StoreType.transmission){
      return false;
    }
    await getSession(item);
    if(sessionId.isEmpty){
      return false;
    }
    return true;
  }
}