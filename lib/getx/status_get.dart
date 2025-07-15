import 'package:bit_flow/types/task_item.dart';
import 'package:get/get.dart';

enum Pages{
  active,
  finish,
  settings
}

class StatusGet extends GetxController{
  RxBool initOk=false.obs;

  RxInt sevrerIndex=0.obs;
  Rx<Pages> page=Pages.active.obs;
  RxBool loading=false.obs;

  RxList<TaskItem> activeTasks=<TaskItem>[].obs;
  RxList<TaskItem> finishedTask=<TaskItem>[].obs;

  void makeTasks(List<TaskItem> tasks){
    if(page.value==Pages.active){
      activeTasks.value=tasks;
    }else if(page.value==Pages.finish){
      finishedTask.value=tasks;
    }
  }
}