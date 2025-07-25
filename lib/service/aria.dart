import 'dart:convert';

import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class AriaService extends GetxController{

  Future<Map> httpRequest(Map data, String aria) async {
    final url = Uri.parse(aria);
    final body = json.encode(data);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      return {};
    }
  }

  Future<List<TaskItem>?> getActive(StoreItem item) async {
    try {
      final data = (await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.tellActive",
        "id":"bitflow",
        "params":["token:${item.password}"]
      }, item.url))['result'];
      List<TaskItem> ls=[];
      for (var task in data) {
        String name="";
        try {
          name=task['bittorrent']['info']['name'];
        } catch (_) {
          name=p.basename(task['files'][0]['path']);
        }
        String link="";
        try {
          link=task['infoHash'];
        } catch (_) {
          link=task['files'][0]['uris'][0]['uri'];
        }
        int completeBytes=int.parse(task['completedLength']);
        int downloadSpeed=int.parse(task['downloadSpeed']);
        int uploadSpeed=int.parse(task['uploadSpeed']);
        int size=int.parse(task['totalLength']);
        String path=task['dir'];
        String gid=task['gid'];
        List<FileItem> files=[];
        TaskStatus status=TaskStatus.download;
        for (var file in task['files']) {
          files.add(FileItem(p.basename(file['path']), int.parse(file['length']), file['path'], int.parse(file['completedLength'])));
        }
        if(task['completedLength']==task['totalLength'] && task['status']=='active' && size!=0){
          status=TaskStatus.seeding;
        }
        int uploaded=int.parse(task['uploadLength']);
        ls.add(TaskItem(name, size, files, status, link, path, downloadSpeed, uploadSpeed, completeBytes, gid, null, uploaded, StoreType.aria));
      }
      return ls;
    } catch (_) {}
    return null;
  }

  Future<List<TaskItem>?> getWait(StoreItem item) async {
    try {
      final data = (await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.tellWaiting",
        "id":"bitflow",
        "params":["token:${item.password}", 0, 1000]
      }, item.url))['result'];
      List<TaskItem> ls=[];
      for (var task in data) {
        String name="";
        try {
          name=task['bittorrent']['info']['name'];
        } catch (_) {
          name=p.basename(task['files'][0]['path']);
        }
        String link="";
        try {
          link=task['infoHash'];
        } catch (_) {
          link=task['files'][0]['uris'][0]['uri'];
        }
        int completeBytes=int.parse(task['completedLength']);
        int downloadSpeed=int.parse(task['downloadSpeed']);
        int uploadSpeed=int.parse(task['uploadSpeed']);
        int size=int.parse(task['totalLength']);
        String path=task['dir'];
        String gid=task['gid'];
        List<FileItem> files=[];
        for (var file in task['files']) {
          files.add(FileItem(p.basename(file['path']), int.parse(file['length']), file['path'], int.parse(file['completedLength'])));
        }
        TaskStatus status=task['status']=='paused' ? TaskStatus.pause : TaskStatus.wait;
        int uploaded=int.parse(task['uploadLength']);
        ls.add(TaskItem(name, size, files, status, link, path, downloadSpeed, uploadSpeed, completeBytes, gid, null, uploaded, StoreType.aria));
      }
      return ls;
    } catch (_) {}
    return null;
  }

  Future<List<TaskItem>?> getFinish(StoreItem item) async {
    try {
      final data = (await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.tellStopped",
        "id":"bitflow",
        "params":["token:${item.password}", 0, 1000]
      }, item.url))['result'];
      List<TaskItem> ls=[];
      for (var task in data) {
        String name="";
        try {
          name=task['bittorrent']['info']['name'];
        } catch (_) {
          name=p.basename(task['files'][0]['path']);
        }
        String link="";
        try {
          link=task['infoHash'];
        } catch (_) {
          link=task['files'][0]['uris'][0]['uri'];
        }
        int completeBytes=int.parse(task['completedLength']);
        int downloadSpeed=int.parse(task['downloadSpeed']);
        int uploadSpeed=int.parse(task['uploadSpeed']);
        int size=int.parse(task['totalLength']);
        String path=task['dir'];
        String gid=task['gid'];
        List<FileItem> files=[];
        for (var file in task['files']) {
          files.add(FileItem(p.basename(file['path']), int.parse(file['length']), file['path'], int.parse(file['completedLength'])));
        }
        TaskStatus status=TaskStatus.finish;
        int uploaded=int.parse(task['uploadLength']);
        ls.add(TaskItem(name, size, files, status, link, path, downloadSpeed, uploadSpeed, completeBytes, gid, null, uploaded, StoreType.aria));
      }
      return ls;
    } catch (_) {}
    return null;
  }

  Future<List<TaskItem>> getTasks(Pages page, StoreItem item) async {
    if(page==Pages.active){
      List active = (await getActive(item))??[];
      List wait = (await getWait(item))??[];
      return [...active, ...wait];
    }else if(page==Pages.finish){
      List<TaskItem> finish=(await getFinish(item))??[];
      return finish;
    }
    return [];
  }

  Future<void> addTask(String downloadUrl, StoreItem item) async {
    try {
      await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.addUri",
        "id":"bitflow",
        "params":["token:${item.password}", [downloadUrl], {}]
      }, item.url);
    } catch (_) {}
  }

  Future<void> delActiveTask(String id, StoreItem item) async {
    try {
      await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.remove",
        "id":"bitflow",
        "params":["token:${item.password}", id]
      }, item.url);
    } catch (_) {}
  }

  Future<void> delFinishedTask(String id, StoreItem item) async {
    try {
      await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.removeDownloadResult",
        "id":"bitflow",
        "params":["token:${item.password}", id]
      }, item.url);
    } catch (_) {}
  }

  Future<void> pauseTask(String id, StoreItem item) async {
    try {
      await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.pause",
        "id":"bitflow",
        "params":["token:${item.password}", id]
      }, item.url);
    } catch (_) {}
  }

  Future<void> continueTask(String id, StoreItem item) async {
    try {
      await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.unpause",
        "id":"bitflow",
        "params":["token:${item.password}", id]
      }, item.url);
    } catch (_) {}
  }

  Future<void> clearFinished(StoreItem item) async {
    try {
      await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.purgeDownloadResult",
        "id":"bitflow",
        "params":["token:${item.password}"]
      }, item.url);
    } catch (_) {}
  }

  Future<String?> getVersion(StoreItem item) async {
    if(item.type!=StoreType.aria){
      return null;
    }
    try {
      return (await httpRequest({
        "jsonrpc":"2.0",
        "method":"aria2.getVersion",
        "id":"bitflow",
        "params":["token:${item.password}"]
      }, item.url))['result']['version'];
    } catch (_) {
      return null;
    }
  }
}