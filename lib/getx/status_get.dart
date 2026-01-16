import 'dart:ui';

import 'package:bit_flow/types/store_item.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Pages{
  active,
  finish,
  settings
}

class LanguageType{
  String name;
  Locale locale;

  LanguageType(this.name, this.locale);
}

String pageToText(Pages page){
  switch (page) {
    case Pages.active:
      return "active".tr;
    case Pages.finish:
      return "finished".tr;
    case Pages.settings:
      return "settings".tr;
  }
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

String orderToString(OrderTypes type){
  switch (type) {
    case OrderTypes.addNew:
      return "timeDesc".tr;
    case OrderTypes.addOld:
      return "timeAsc".tr;
    case OrderTypes.nameAZ:
      return "nameDesc".tr;
    case OrderTypes.nameZA:
      return "nameAsc".tr;
  }
}

IconData orderToIcon(OrderTypes type){
  switch (type) {
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

List<LanguageType> get supportedLocales => [
  LanguageType("English", const Locale("en", "US")),
  LanguageType("简体中文", const Locale("zh", "CN")),
  LanguageType("繁體中文", const Locale("zh", "TW")),
];

class StatusGet extends GetxController{
  RxBool initOk=false.obs;

  RxInt sevrerIndex=0.obs;
  Rx<Pages> page=Pages.active.obs;

  RxBool loadOk=false.obs;

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

  Rx<LanguageType> lang=Rx(supportedLocales[0]);

  late SharedPreferences prefs;

  Future<void> initLang() async {
    prefs=await SharedPreferences.getInstance();

    int? langIndex=prefs.getInt("langIndex");

    if(langIndex==null){
      final deviceLocale=PlatformDispatcher.instance.locale;
      final local=Locale(deviceLocale.languageCode, deviceLocale.countryCode);
      int index=supportedLocales.indexWhere((element) => element.locale==local);
      if(index!=-1){
        lang.value=supportedLocales[index];
        lang.refresh();
      }
    }else{
      lang.value=supportedLocales[langIndex];
    }
  }

  void changeLanguage(int index){
    lang.value=supportedLocales[index];
    prefs.setInt("langIndex", index);
    lang.refresh();
    Get.updateLocale(lang.value.locale);
  }

}