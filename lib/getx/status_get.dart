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

  RxList<TaskItem> tasks=<TaskItem>[].obs;
}