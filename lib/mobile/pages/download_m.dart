import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/mobile/components/active_task_m.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadM extends StatefulWidget {
  const DownloadM({super.key});

  @override
  State<DownloadM> createState() => _DownloadMState();
}

class _DownloadMState extends State<DownloadM> {

  final StatusGet statusGet=Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(()=>
      ListView.builder(
        itemCount: statusGet.activeTasks.length,
        itemBuilder: (BuildContext context, int index)=>ActiveTaskM(item: statusGet.activeTasks[index])
      )
    );
  }
}