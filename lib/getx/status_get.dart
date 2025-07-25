import 'package:bit_flow/types/store_item.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

enum Pages{
  active,
  finish,
  settings
}

enum OrderTypes{
  // Aria默认情况下新的在后面

  // 添加日期（新的在前）
  addNew,
  // 添加日期（新的在后）
  addOld,
  // 任务名称A-->Z
  nameAZ,
  // 任务名称Z-->A
  nameZA
}

class StatusGet extends GetxController{
  RxBool initOk=false.obs;

  RxInt sevrerIndex=0.obs;
  Rx<Pages> page=Pages.active.obs;

  RxList<TaskItem> activeTasks=<TaskItem>[].obs;
  RxList<TaskItem> finishedTask=<TaskItem>[].obs;

  RxBool selectMode=false.obs;
  RxList<TaskItem> selectList=<TaskItem>[].obs;

  // 默认在活跃页面，新的在后，旧的在前
  Rx<OrderTypes> activeOrder=OrderTypes.addOld.obs;
  // 默认在已完成页面，新的在前，旧的在后
  Rx<OrderTypes> finishOrder=OrderTypes.addNew.obs;

  List<TaskItem> orderHandler(List<TaskItem> tasks, OrderTypes order, StoreType serverType){
    switch (order) {
      case OrderTypes.nameAZ:
        tasks.sort(((TaskItem a, TaskItem b){
          return a.name.compareTo(b.name);
        }));
        return tasks;
      case OrderTypes.nameZA:
        tasks.sort(((TaskItem a, TaskItem b){
          return b.name.compareTo(a.name);
        }));
        return tasks;
      case OrderTypes.addNew:
        if(serverType==StoreType.qbit){
          tasks.sort((TaskItem a, TaskItem b){
            if(a.addTime==null || b.addTime==null){
              return a.name.compareTo(b.name);
            }
            return b.addTime!.compareTo(a.addTime!);
          });
          return tasks;
        }
        return tasks.reversed.toList();
      case OrderTypes.addOld:
        if(serverType==StoreType.qbit){
          tasks.sort((TaskItem a, TaskItem b){
            if(a.addTime==null || b.addTime==null){
              return a.name.compareTo(b.name);
            }
            return a.addTime!.compareTo(b.addTime!);
          });
          return tasks;
        }
        return tasks.toList();
    }
  }

  void makeTasks(List<TaskItem> tasks, StoreType serverType){
    if(page.value==Pages.active){
      activeTasks.value=orderHandler(tasks, activeOrder.value, serverType);
    }else if(page.value==Pages.finish){
      finishedTask.value=orderHandler(tasks, finishOrder.value, serverType);
    }
  }

  IconData getOrderIcon(Pages page){
    if(page==Pages.active){
      switch (activeOrder.value) {
        case OrderTypes.addNew:
          return FontAwesomeIcons.arrowDownShortWide;
        case OrderTypes.addOld:
          return FontAwesomeIcons.arrowDownWideShort;
        case OrderTypes.nameAZ:
          return FontAwesomeIcons.arrowDownAZ;
        case OrderTypes.nameZA:
          return FontAwesomeIcons.arrowDownZA;
      }
    }else{
      switch (finishOrder.value) {
        case OrderTypes.addNew:
          return FontAwesomeIcons.arrowDownShortWide;
        case OrderTypes.addOld:
          return FontAwesomeIcons.arrowDownWideShort;
        case OrderTypes.nameAZ:
          return FontAwesomeIcons.arrowDownAZ;
        case OrderTypes.nameZA:
          return FontAwesomeIcons.arrowDownZA;
      }
    }
    
  }

}