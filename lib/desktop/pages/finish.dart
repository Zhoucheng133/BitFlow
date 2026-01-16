import 'package:bit_flow/components/header/header.dart';
import 'package:bit_flow/components/task_components/finish_task.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinishPage extends StatefulWidget {
  const FinishPage({super.key});

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {

  final StatusGet statusGet=Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(name: "finished".tr, page: Pages.finish,),
        Obx(()=>
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: statusGet.loadOk.value ? ListView.builder(
                key: Key("default"),
                itemCount: statusGet.finishedTask.length,
                itemBuilder: (BuildContext context, int index)=>FinishTask(item: statusGet.finishedTask[index])
              )  : Center(
                key: Key("loading"),
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator()
                ),
              ),
            ),
          )
        )
      ],
    );
  }
}