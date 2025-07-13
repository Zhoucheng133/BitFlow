import 'package:bit_flow/components/header.dart';
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
        Header(name: "下载中"),
        Obx(()=>
          Expanded(
            child: ListView.builder(
              itemCount: statusGet.tasks.length,
              itemBuilder: (BuildContext context, int index)=>Text(statusGet.tasks[index].name)
            ),
          )
        )
      ],
    );
  }
}