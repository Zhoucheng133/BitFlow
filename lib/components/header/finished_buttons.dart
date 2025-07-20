import 'package:bit_flow/components/header/header_button_item.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinishedButtons extends StatefulWidget {
  const FinishedButtons({super.key});

  @override
  State<FinishedButtons> createState() => _FinishedButtonsState();
}

class _FinishedButtonsState extends State<FinishedButtons> {

  final StatusGet statusGet=Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Container()),
        HeaderButtonItem(buttonSide: ButtonSide.left, func: (){}, icon: Icons.check_box_outlined, text: "选择"),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: (){}, icon: Icons.delete_rounded, text: "清空已完成"),
        HeaderButtonItem(buttonSide: ButtonSide.right, func: (){}, icon: statusGet.getOrderIcon(Pages.finish), iconSize: 13)
      ],
    );
  }
}