import 'package:bit_flow/components/header/header_button_item.dart';
import 'package:flutter/material.dart';

class FinishedButtons extends StatefulWidget {
  const FinishedButtons({super.key});

  @override
  State<FinishedButtons> createState() => _FinishedButtonsState();
}

class _FinishedButtonsState extends State<FinishedButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Container()),
        HeaderButtonItem(buttonSide: ButtonSide.left, func: (){}, icon: Icons.check_box_outlined, text: "选择"),
        HeaderButtonItem(buttonSide: ButtonSide.right, func: (){}, icon: Icons.delete_rounded, text: "清空已完成")
      ],
    );
  }
}