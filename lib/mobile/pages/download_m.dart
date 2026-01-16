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
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: statusGet.loadOk.value ? ListView.builder(
          key: Key("default"),
          itemCount: statusGet.activeTasks.length,
          padding: const EdgeInsets.only(bottom: 70),
          itemBuilder: (BuildContext context, int index)=>ActiveTaskM(item: statusGet.activeTasks[index])
        ) : Center(
          key: Key("loading"),
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator()
          ),
        ),
      )
    );
  }
}