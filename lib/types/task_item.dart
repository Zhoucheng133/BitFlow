class FileItem{
  // 文件名称
  late String name;
  // 文件大小
  late String size;
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
  // 大小=>转换=>例如【13 MB】
  late String size;
  // 文件列表
  late List<FileItem> files;
  // 进度=>0~100
  late int percent;
  // 状态
  late TaskStatus status;
  
}