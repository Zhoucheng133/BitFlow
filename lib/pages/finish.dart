import 'package:bit_flow/components/header.dart';
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
        Header(name: "下载中"),
        Obx(()=>
          Expanded(
            child: ListView.builder(
              itemCount: statusGet.tasks.length,
              itemBuilder: (BuildContext context, int index)=>FinishTask(item: statusGet.tasks[index])
            ),
          )
        )
      ],
    );
  }
}