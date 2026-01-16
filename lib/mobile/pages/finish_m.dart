import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/mobile/components/finish_task_m.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinishM extends StatefulWidget {
  const FinishM({super.key});

  @override
  State<FinishM> createState() => _FinishMState();
}

class _FinishMState extends State<FinishM> {

  final StatusGet statusGet=Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(()=>
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: statusGet.loadOk.value ?  ListView.builder(
          key: Key("default"),
          itemCount: statusGet.finishedTask.length,
          padding: const EdgeInsets.only(bottom: 70),
          itemBuilder: (BuildContext context, int index)=>FinishTaskM(item: statusGet.finishedTask[index])
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