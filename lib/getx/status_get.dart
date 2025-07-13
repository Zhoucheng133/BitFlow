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
}