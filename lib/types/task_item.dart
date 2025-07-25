import 'dart:math';

import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class FileItem{
  // 文件名称
  late String name;
  // 文件大小
  late int size;
  // 下载位置
  late String? path;
  // 已完成 (Byte)
  late int? completeBytes;

  FileItem(this.name, this.size, this.path, this.completeBytes);
}

enum TaskStatus{
  download,
  wait,
  finish,
  seeding,
  pause,
}

class TaskItem{

  final AriaService ariaService=Get.find();
  final StatusGet statusGet=Get.find();
  final StoreGet storeGet=Get.find();
  final FuncsService funcsService=Get.find();
  final QbitService qbitService=Get.find();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is TaskItem && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // 服务器类型
  late StoreType type;
  // 任务名称
  late String name;
  // 大小 (Byte)
  late int size;
  // 文件列表
  late List<FileItem> files;
  // 状态
  late TaskStatus status;
  // 链接
  late String link;
  // 下载位置
  late String path;
  // 下载速度 (Byte)
  late int downloadSpeed;
  // 上传速度 (Byte)
  late int uploadSpeed;
  // 已完成 (Byte)
  late int completeBytes;
  // Aria => gid, qBit => hash
  late String id;
  // 添加日期 (时间戳: 秒)
  late int? addTime;
  // 已上传的大小
  late int uploaded;

  bool selected=false;

  String statusToText(TaskStatus status){
    switch (status) {
      case TaskStatus.download:
        return "下载中";
      case TaskStatus.finish:
        return "已完成/停止";
      case TaskStatus.pause:
        return "暂停中";
      case TaskStatus.seeding:
        return "做种中";
      case TaskStatus.wait:
        return "等待中";
    }
  }

  String sizeString(int val, {bool useSpeed=false}){
    try {
      if (val < 0) return 'Invalid value';
      const List<String> units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
      int unitIndex = max(0, min(units.length - 1, (log(val) / log(1024)).floor()));
      double value = val / pow(1024, unitIndex);
      String formattedValue = value % 1 == 0 ? '$value' : value.toStringAsFixed(2);
      return '$formattedValue ${units[unitIndex]}${useSpeed ? "/s" : ""}';
    } catch (_) {
      return '0 B${useSpeed ? "/s" : ""}';
    }
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    // 如果有小时数，则显示小时部分
    if (hours > 0) {
      String formattedHours = hours.toString();
      return '$formattedHours:$formattedMinutes:$formattedSeconds';
    } else {
      return '$formattedMinutes:$formattedSeconds';
    }
  }

  String calTime(){
    if(status==TaskStatus.seeding){
      return "做种中";
    }
    try {
      int sec=((size-completeBytes)/downloadSpeed).round();
      return formatDuration(sec);
    } catch (_) {
      return "/";
    }
  }

  double calPercent() {
    if (size == 0) return 0;
    double percent = completeBytes / size;
    if (percent.isNaN || percent.isInfinite) return 0;
    return percent.clamp(0.0, 1.0);
  }

  String? addTimeGet(){
    if(addTime==null){
      return null;
    }
    DateTime date = DateTime.fromMillisecondsSinceEpoch(addTime! * 1000);
    return "${date.year}/${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  // 显示任务信息
  Future<void> showTaskInfo(BuildContext context) async {
    await showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: const Text("任务信息"),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('任务名称')
                    )
                  ),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ],
              ),
              const SizedBox(height: 5,),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('下载位置')
                    )
                  ),
                  Expanded(
                    child: Text(
                      p.dirname(path),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ],
              ),
              const SizedBox(height: 5,),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('大小')
                    )
                  ),
                  Expanded(
                    child: Text(
                      sizeString(size),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ],
              ),
              const SizedBox(height: 5,),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('已完成大小')
                    )
                  ),
                  Expanded(
                    child: Text(
                      sizeString(completeBytes),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ],
              ),
              const SizedBox(height: 5,),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('已上传大小')
                    )
                  ),
                  Expanded(
                    child: Text(
                      sizeString(uploaded),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ],
              ),
              const SizedBox(height: 5,),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('状态')
                    )
                  ),
                  Expanded(
                    child: Text(
                      statusToText(status),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: ()=>Navigator.pop(context),
            child: const Text('完成')
          )
        ],
      )
    );
  }
  
  // 显示文件
  Future<void> showFiles(BuildContext context) async {
    if(type==StoreType.qbit){
      files=(await qbitService.getFiles(storeGet.servers[statusGet.sevrerIndex.value], id))??[];
    }
    if(context.mounted){
      showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: const Text('文件列表'),
          content: SizedBox(
            width: 400,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 400
              ),
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index)=>Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Tooltip(
                    message: files[index].name,
                    waitDuration: const Duration(seconds: 1),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            files[index].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Text(sizeString(files[index].size))
                      ],
                    ),
                  ),
                )
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: ()=>Navigator.pop(context),
              child: const Text('完成')
            )
          ],
        ),
      );
    }
  }

  // 删除已完成的任务
  Future<void> delFinishedTask({bool delFile=false}) async {
    switch (type) {
      case StoreType.aria:
        await ariaService.delFinishedTask(id, storeGet.servers[statusGet.sevrerIndex.value]);
        break;
      case StoreType.qbit:
        await qbitService.delFinishedTask(storeGet.servers[statusGet.sevrerIndex.value], id, delFile: delFile);
        break;
    }
    funcsService.getTasks();
  }

  // 删除活跃中的任务
  Future<void> delActiveTask({bool delFile=false}) async {
    switch (type) {
      case StoreType.aria:
        await ariaService.delActiveTask(id, storeGet.servers[statusGet.sevrerIndex.value]);
        break;
      case StoreType.qbit:
        await qbitService.delActiveTask(storeGet.servers[statusGet.sevrerIndex.value], id, delFile: delFile);
        break;
    }
    funcsService.getTasks();
  }

  // 删除任务【总】
  Future<void> delTask(BuildContext context) async {
    bool confirm=await showConfirmDialog(context, "删除这个任务", "确定要删除这个任务吗? 这个操作无法撤销!");
    bool delFile=false;
    if(type==StoreType.qbit){
      if(context.mounted) delFile=await showConfirmDialog(context, "删除文件", "删除这个任务的同时删除文件?");
    }
    if(confirm){
      if(status==TaskStatus.finish){
        delFinishedTask(delFile: delFile);
      }else{
        delActiveTask(delFile: delFile);
      }
    }
  }

  // 重新下载任务(针对已停止的任务)
  Future<void> reDownload(BuildContext context) async {
    if(status!=TaskStatus.finish){
      return;
    }
    bool confirm=await showConfirmDialog(context, "重新下载这个任务", "将会从已完成任务中删除，并且重新添加为新的任务");
    if(confirm){
      await delFinishedTask(delFile: true);
      funcsService.addTaskHandler(link);
      funcsService.getTasks();
    }
  }

  // 暂停任务
  Future<void> pauseTask() async {
    switch (type) {
      case StoreType.aria:
        await ariaService.pauseTask(id, storeGet.servers[statusGet.sevrerIndex.value]);
        break;
      case StoreType.qbit:
        await qbitService.pauseTask(storeGet.servers[statusGet.sevrerIndex.value], id);
        break;
    }
    funcsService.getTasks();
  }

  // 继续任务
  Future<void> continueTask() async {
    switch (type) {
      case StoreType.aria:
        await ariaService.continueTask(id, storeGet.servers[statusGet.sevrerIndex.value]);
        break;
      case StoreType.qbit:
        await qbitService.continueTask(storeGet.servers[statusGet.sevrerIndex.value], id);
        break;
    }
    funcsService.getTasks();
  }
  TaskItem(this.name, this.size, this.files, this.status, this.link, this.path, this.downloadSpeed, this.uploadSpeed, this.completeBytes, this.id, this.addTime, this.uploaded, this.type);
  
}