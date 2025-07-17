import 'package:bit_flow/types/store_item.dart';
import 'package:bit_flow/types/task_item.dart';
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
  RxBool loading=false.obs;

  RxList<TaskItem> activeTasks=<TaskItem>[].obs;
  RxList<TaskItem> finishedTask=<TaskItem>[].obs;

  Rx<OrderTypes> activeOrder=OrderTypes.addNew.obs;
  Rx<OrderTypes> finishOrder=OrderTypes.addOld.obs;

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
}