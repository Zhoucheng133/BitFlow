import 'package:bit_flow/components/header/header.dart';
import 'package:bit_flow/components/task_components/active_task.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {

  final StatusGet statusGet=Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(name: "活跃中", page: Pages.active,),
        Obx(()=>
          Expanded(
            child: ListView.builder(
              itemCount: statusGet.activeTasks.length,
              itemBuilder: (BuildContext context, int index)=>ActiveTask(item: statusGet.activeTasks[index])
            ),
          )
        )
      ],
    );
  }
}