import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeGet extends GetxController{
  RxBool darkMode=false.obs;

  Color bgColor(BuildContext context){
    return Theme.of(context).colorScheme.surface;
  }

  Color buttonColor(BuildContext context, bool hover, bool selected){
    if(Theme.of(context).brightness==Brightness.light){
      return selected ? Theme.of(context).colorScheme.primary.withAlpha(18) : hover ? Theme.of(context).colorScheme.primary.withAlpha(12) : Theme.of(context).colorScheme.primary.withAlpha(0);
    }else{
      return selected ? Color.fromARGB(255, 60, 60, 60) : hover ? Color.fromARGB(255, 40, 40, 40) : Theme.of(context).colorScheme.surface;
    }
  }

  Color taskItemColor(BuildContext context, bool hover){
    if(Theme.of(context).brightness==Brightness.light){
      return hover ? Theme.of(context).primaryColor.withAlpha(15) : Theme.of(context).primaryColor.withAlpha(0);
    }else{
      return hover ? Color.fromARGB(100, 100, 100, 100) : Color.fromARGB(0, 100, 100, 100);
    }
  }
}