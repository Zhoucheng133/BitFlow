import 'dart:convert';

import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class QbitConfig{
  // 保存位置【save_path】=> app/preferences
  String savePath;
  // 最多下载个数【max_active_downloads】=> app/preferences
  int maxDownloadCount;
  // 做种时间【max_seeding_time】【需要max_seeding_time_enabled为true】=> app/preferences
  bool seedTimeEnable;
  int seedTime;
  // 做种比率【max_ratio】【需要max_ratio_enabled为true】=> app/preferences
  bool ratioEnable;
  int seedRatio;
  // 下载速度限制【dl_rate_limit】=> transfer/info
  int downloadLimit;
  // 上传速度限制【up_rate_limit】=> transfer/info
  int uploadLimit;

  QbitConfig(this.savePath, this.maxDownloadCount, this.seedTimeEnable, this.seedTime, this.ratioEnable, this.seedRatio, this.downloadLimit, this.uploadLimit);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // 同一对象直接相等
    return other is QbitConfig &&
      other.savePath==savePath &&
      other.maxDownloadCount==maxDownloadCount &&
      other.seedTimeEnable==seedTimeEnable &&
      other.seedTime==seedTime &&
      other.ratioEnable==ratioEnable &&
      other.seedRatio==seedRatio &&
      other.downloadLimit==downloadLimit &&
      other.uploadLimit==uploadLimit;
  }
  
  @override
  int get hashCode => Object.hash(savePath, maxDownloadCount, seedTimeEnable, seedTime, ratioEnable, seedRatio, downloadLimit, uploadLimit);

  Map toJson(){
    return {
      "save_path": savePath,
      "max_active_downloads": maxDownloadCount,
      "max_seeding_time_enabled": seedTimeEnable,
      "max_seeding_time": seedTime,
      "max_ratio_enabled": ratioEnable,
      "max_ratio": seedRatio,
    };
  }
}

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
      ).timeout(Duration(seconds: 3));
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

  Future<void> addTorrentTask(String filePath, StoreItem item) async {
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return;
      }
      cookie.value=temp;
    }
    try {
      final url = Uri.parse("${item.url}/api/v2/torrents/add");
      final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('torrents', filePath))
      ..headers['Cookie'] = cookie.value;
      await request.send();
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

  Future<Map> getAppConfig(StoreItem item) async {
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return {};
      }
      cookie.value=temp;
    }
    if(item.type!=StoreType.qbit){
      return {};
    }
    Map data={};
    try {
      final url = Uri.parse("${item.url}/api/v2/app/preferences");
      final response=await http.get(
        url,
        headers: {
          "Cookie": cookie.value,
        },
      );
      data=json.decode(utf8.decode(response.bodyBytes));
    } catch (_) {}
    return data;
  }

  Future<Map> getTransferConfig(StoreItem item) async {
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return {};
      }
      cookie.value=temp;
    }
    if(item.type!=StoreType.qbit){
      return {};
    }
    Map data={};
    try {
      final url = Uri.parse("${item.url}/api/v2/transfer/info");
      final response=await http.get(
        url,
        headers: {
          "Cookie": cookie.value,
        },
      );
      data=json.decode(utf8.decode(response.bodyBytes));
    } catch (_) {}
    return data;
  }
  
  Future<QbitConfig> getConfig(StoreItem item) async {
    // App配置API【/api/v2/app/preferences】【/api/v2/app/setPreferences】
    // 传输配置API【/api/v2/transfer/info】【/api/v2/transfer/setDownloadLimit】【/api/v2/transfer/setUploadLimit】
    final appConfig=await getAppConfig(item);
    final transferConfig=await getTransferConfig(item);
    
    return QbitConfig(appConfig['save_path'], appConfig['max_active_downloads'], appConfig['max_seeding_time_enabled'], appConfig['max_seeding_time'], appConfig['max_ratio_enabled'], appConfig['max_ratio'], transferConfig['dl_rate_limit'], transferConfig['up_rate_limit']);
  }

  bool samePreference(QbitConfig config1, QbitConfig config2){
    return config1.savePath==config2.savePath &&
      config1.maxDownloadCount==config2.maxDownloadCount &&
      config1.seedTimeEnable==config2.seedTimeEnable &&
      config1.seedTime==config2.seedTime &&
      config1.ratioEnable==config2.ratioEnable &&
      config1.seedRatio==config2.seedRatio;
  }

  // 保存配置
  Future<void> saveConfig(StoreItem item, QbitConfig preConfig, QbitConfig nowConfig) async {
    if(preConfig==nowConfig){
      // 设置没有变化
      return;
    }
    if(cookie.isEmpty){
      final temp=await getCookie(item);
      if(temp==null){
        return;
      }
      cookie.value=temp;
    }
    if(preConfig.downloadLimit != nowConfig.downloadLimit){
      try {
        final url = Uri.parse("${item.url}/api/v2/transfer/setDownloadLimit");
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "Cookie": cookie.value,
          },
          body: {
            'limit': nowConfig.downloadLimit.toString(),
          },
        );
      } catch (_) {}
    }
    if(preConfig.uploadLimit!=nowConfig.uploadLimit){
      try {
        final url = Uri.parse("${item.url}/api/v2/transfer/setUploadLimit");
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "Cookie": cookie.value,
          },
          body: {
            'limit': nowConfig.uploadLimit.toString(),
          },
        );
      } catch (_) {}
    }

    if(!samePreference(preConfig, nowConfig)){
      try {
        final url = Uri.parse("${item.url}/api/v2/app/setPreferences");
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "Cookie": cookie.value,
          },
          body: {
            'json': jsonEncode(nowConfig.toJson()),
          },
        );
      } catch (_) {}
    }
  }
}