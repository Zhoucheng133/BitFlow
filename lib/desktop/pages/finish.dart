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
        Header(name: "已完成", page: Pages.finish,),
        Obx(()=>
          Expanded(
            child: ListView.builder(
              itemCount: statusGet.finishedTask.length,
              itemBuilder: (BuildContext context, int index)=>FinishTask(item: statusGet.finishedTask[index])
            ),
          )
        )
      ],
    );
  }
}