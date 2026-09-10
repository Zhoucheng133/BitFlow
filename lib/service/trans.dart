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
  double seedRatioLimit=0.0;
  // 启用下载速度限制【speed-limit-down-enabled】
  bool enableDownloadSpeedLimit=false;
  // 下载速度限制【speed-limit-down】
  int downloadSpeedLimit=0;
  // 启用上传速度限制【speed-limit-up-enabled】
  bool enableUploadSpeedLimit=false;
  // 上传速度限制【speed-limit-up】
  int uploadSpeedLimit=0;
  // 最大连接数【peer-limit-global】
  int peerLimitGlobal=200;
  // 单种子最大连接数【peer-limit-per-torrent】
  int peerLimitPerTorrent=50;
  // 监听端口【peer-port】
  int peerPort=51413;
  // 启用DHT【dht-enabled】
  bool dhtEnabled=true;
  // 启用PEX【pex-enabled】
  bool pexEnabled=true;
  // 启用LPD【lpd-enabled】
  bool lpdEnabled=false;
  // 启用UPnP【utp-enabled / port-forwarding-enabled】
  bool portForwardingEnabled=true;
  // 加密模式【encryption】: "preferred", "required", "despised"
  String encryption="preferred";

  factory TransmissionConfig.init(Map json){
    return TransmissionConfig(
      dir: json["download-dir"] ?? "",
      maxDownloadCount: json["download-queue-size"] ?? 5,
      maxSeedCount: json["seed-queue-size"] ?? 10,
      enableSeedRatio: json["seedRatioLimited"] ?? false,
      seedRatioLimit: double.tryParse((json["seedRatioLimit"] ?? 1.0).toString()) ?? 1.0,
      enableDownloadSpeedLimit: json["speed-limit-down-enabled"] ?? false,
      downloadSpeedLimit: json["speed-limit-down"] ?? 100,
      enableUploadSpeedLimit: json["speed-limit-up-enabled"] ?? false,
      uploadSpeedLimit: json["speed-limit-up"] ?? 50,
      peerLimitGlobal: json["peer-limit-global"] ?? 200,
      peerLimitPerTorrent: json["peer-limit-per-torrent"] ?? 50,
      peerPort: json["peer-port"] ?? 51413,
      dhtEnabled: json["dht-enabled"] ?? true,
      pexEnabled: json["pex-enabled"] ?? true,
      lpdEnabled: json["lpd-enabled"] ?? false,
      portForwardingEnabled: json["port-forwarding-enabled"] ?? true,
      encryption: json["encryption"] ?? "preferred",
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
    required this.peerLimitGlobal,
    required this.peerLimitPerTorrent,
    required this.peerPort,
    required this.dhtEnabled,
    required this.pexEnabled,
    required this.lpdEnabled,
    required this.portForwardingEnabled,
    required this.encryption,
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
      "peer-limit-global": peerLimitGlobal,
      "peer-limit-per-torrent": peerLimitPerTorrent,
      "peer-port": peerPort,
      "dht-enabled": dhtEnabled,
      "pex-enabled": pexEnabled,
      "lpd-enabled": lpdEnabled,
      "port-forwarding-enabled": portForwardingEnabled,
      "encryption": encryption,
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
      other.uploadSpeedLimit==uploadSpeedLimit &&
      other.peerLimitGlobal==peerLimitGlobal &&
      other.peerLimitPerTorrent==peerLimitPerTorrent &&
      other.peerPort==peerPort &&
      other.dhtEnabled==dhtEnabled &&
      other.pexEnabled==pexEnabled &&
      other.lpdEnabled==lpdEnabled &&
      other.portForwardingEnabled==portForwardingEnabled &&
      other.encryption==encryption;
  }

  @override
  int get hashCode => Object.hash(
    dir, maxDownloadCount, maxSeedCount, enableSeedRatio, seedRatioLimit,
    enableDownloadSpeedLimit, downloadSpeedLimit, enableUploadSpeedLimit, uploadSpeedLimit,
    peerLimitGlobal, peerLimitPerTorrent, peerPort, dhtEnabled, pexEnabled, lpdEnabled,
    portForwardingEnabled, encryption
  );
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
          "arguments": config.toJson()
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