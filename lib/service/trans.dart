import 'dart:convert';

import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TransmissionConfig{

  // 下载位置【download-dir】
  String dir="";
  // 最大下载数【download-queue-size】
  int maxDownloadCount=0;
  // 最大做种数【seed-queue-size】
  int maxSeedCount=0;
  // 启用做种限制【seedRatioLimited】
  bool enableSeedRatio=false;
  // 做种限制【seedRatioLimit】
  int seedRatioLimit=0;
  // 启用下载速度限制【speed-limit-down-enabled】
  bool enableDownloadSpeedLimit=false;
  // 下载速度限制【speed-limit-down】
  int downloadSpeedLimit=0;
  // 启用上传速度限制【speed-limit-up-enabled】
  bool enableUploadSpeedLimit=false;
  // 上传速度限制【speed-limit-up】
  int uploadSpeedLimit=0;

  factory TransmissionConfig.init(Map json){
    return TransmissionConfig(
      dir: json["download-dir"],
      maxDownloadCount: json["download-queue-size"],
      maxSeedCount: json["seed-queue-size"],
      enableSeedRatio: json["seedRatioLimited"],
      seedRatioLimit: json["seedRatioLimit"],
      enableDownloadSpeedLimit: json["speed-limit-down-enabled"],
      downloadSpeedLimit: json["speed-limit-down"],
      enableUploadSpeedLimit: json["speed-limit-up-enabled"],
      uploadSpeedLimit: json["speed-limit-up"],
    );
  }

  TransmissionConfig({
    required this.dir,
    required this.maxDownloadCount,
    required this.maxSeedCount,
    required this.enableSeedRatio,
    required this.seedRatioLimit,
    required this.enableDownloadSpeedLimit,
    required this.downloadSpeedLimit,
    required this.enableUploadSpeedLimit,
    required this.uploadSpeedLimit,
  });

  Map toJson(){
    return {
      "download-dir": dir,
      "download-queue-size": maxDownloadCount,
      "seed-queue-size": maxSeedCount,
      "seedRatioLimited": enableSeedRatio,
      "seedRatioLimit": seedRatioLimit,
      "speed-limit-down-enabled": enableDownloadSpeedLimit,
      "speed-limit-down": downloadSpeedLimit,
      "speed-limit-up-enabled": enableUploadSpeedLimit,
      "speed-limit-up": uploadSpeedLimit,
    };
  }

  @override
  bool operator ==(Object other){
    if (identical(this, other)) return true;
    return other is TransmissionConfig &&
      other.dir==dir &&
      other.maxDownloadCount==maxDownloadCount &&
      other.maxSeedCount==maxSeedCount &&
      other.enableSeedRatio==enableSeedRatio &&
      other.seedRatioLimit==seedRatioLimit &&
      other.enableDownloadSpeedLimit==enableDownloadSpeedLimit &&
      other.downloadSpeedLimit==downloadSpeedLimit &&
      other.enableUploadSpeedLimit==enableUploadSpeedLimit &&
      other.uploadSpeedLimit==uploadSpeedLimit;
  }

  @override
  int get hashCode => Object.hash(dir, maxDownloadCount, maxSeedCount, enableSeedRatio, seedRatioLimit, enableDownloadSpeedLimit, downloadSpeedLimit, enableUploadSpeedLimit, uploadSpeedLimit);
}

class TransmissionService extends GetxController {

  String sessionId="";

  Future<void> getSession(StoreItem item) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
    try {
      final response=await http.post(Uri.parse(item.url),
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
      final url = Uri.parse(item.url);
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
      final response=await http.post(Uri.parse(item.url),
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
      final response=await http.post(Uri.parse(item.url),
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
  
  Future<void> delActiveTask(StoreItem item, List<String> ids, {bool delFile=false}) async {
    if(sessionId.isEmpty){
      await getSession(item);
      if(sessionId.isEmpty){
        return;
      }
    }

    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
      final response=await http.post(Uri.parse(item.url),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": "torrent-remove",
          "arguments": {
            "ids": ids.map((item)=>int.parse(item)).toList(),
            "delete-local-data": delFile
          }
        }),
      );
      if (response.statusCode == 409) {
        sessionId = response.headers['x-transmission-session-id'] ?? "";
        return delActiveTask(item, ids, delFile: delFile);
      }
      final Map<String, dynamic> fullJson = json.decode(utf8.decode(response.bodyBytes));

      if (fullJson['result'] != 'success') return;
    } catch (_) {}
  }

  Future<void> delFinishedTask(StoreItem item, List<String> ids, {bool delFile=false}) async {
    delActiveTask(item, ids, delFile: delFile);
  }

  Future<void> pauseTask(StoreItem item, List<String> ids) async{
    if(sessionId.isEmpty){
      await getSession(item);
      if(sessionId.isEmpty){
        return;
      }
    }

    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
      final response=await http.post(Uri.parse(item.url),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": "torrent-stop",
          "arguments": {
            "ids": ids.map((item)=>int.parse(item)).toList(),
          }
        }),
      );
      if (response.statusCode == 409) {
        sessionId = response.headers['x-transmission-session-id'] ?? "";
        return pauseTask(item, ids);
      }
      final Map<String, dynamic> fullJson = json.decode(utf8.decode(response.bodyBytes));

      if (fullJson['result'] != 'success') return;
    } catch (_) {}
  }

  Future<void> continueTask(StoreItem item, List<String> ids) async{
    if(sessionId.isEmpty){
      await getSession(item);
      if(sessionId.isEmpty){
        return;
      }
    }

    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
      final response=await http.post(Uri.parse(item.url),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": "torrent-start",
          "arguments": {
            "ids": ids.map((item)=>int.parse(item)).toList(),
          }
        }),
      );
      if (response.statusCode == 409) {
        sessionId = response.headers['x-transmission-session-id'] ?? "";
        return continueTask(item, ids);
      }
      final Map<String, dynamic> fullJson = json.decode(utf8.decode(response.bodyBytes));

      if (fullJson['result'] != 'success') return;
    } catch (_) {}
  }
  
  Future<TransmissionConfig?> getConfig(StoreItem item) async {
    if(sessionId.isEmpty){
      await getSession(item);
      if(sessionId.isEmpty){
        return null;
      }
    }

    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
      final response=await http.post(Uri.parse(item.url),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": "session-get",
          "arguments": {}
        }),
      );
      if (response.statusCode == 409) {
        sessionId = response.headers['x-transmission-session-id'] ?? "";
        return getConfig(item);
      }
      final Map<String, dynamic> fullJson = json.decode(utf8.decode(response.bodyBytes));
      try {
        return TransmissionConfig.init(fullJson['arguments']);
      } catch (_) {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  void saveConfig(StoreItem item, TransmissionConfig config) async { 
    if(sessionId.isEmpty){
      await getSession(item);
      if(sessionId.isEmpty){
        return;
      }
    }
    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('${item.username}:${item.password}'))}';
      final response=await http.post(Uri.parse(item.url),
        headers: {
          "X-Transmission-Session-Id": sessionId,
          "Authorization": basicAuth,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "method": "session-set",
          "arguments": {
            "download-dir": config.dir,
            "download-queue-size": config.maxDownloadCount,
            "seed-queue-size": config.maxSeedCount,
            "seedRatioLimited": config.enableSeedRatio,
            "seedRatioLimit": config.seedRatioLimit,
            "speed-limit-down-enabled": config.enableDownloadSpeedLimit,
            "speed-limit-down": config.downloadSpeedLimit,
            "speed-limit-up-enabled": config.enableUploadSpeedLimit,
            "speed-limit-up": config.uploadSpeedLimit,
          }
        })
      );
      if (response.statusCode == 409) {
        sessionId = response.headers['x-transmission-session-id'] ?? "";
        return saveConfig(item, config);
      }
      final Map<String, dynamic> fullJson = json.decode(utf8.decode(response.bodyBytes));
      if (fullJson['result'] != 'success') return;
    } catch (_) {}
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