import 'dart:math';

class FileItem{
  // 文件名称
  late String name;
  // 文件大小
  late int size;
  // 下载位置
  late String path;
  // 已完成 (Byte)
  late int completeBytes;

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
  // Aria => gid
  late String id;

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

  TaskItem(this.name, this.size, this.files, this.status, this.link, this.path, this.downloadSpeed, this.uploadSpeed, this.completeBytes, this.id);
}