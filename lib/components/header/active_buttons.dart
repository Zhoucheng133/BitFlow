import 'package:bit_flow/components/header/header_button_item.dart';
import 'package:flutter/material.dart';

class ActiveButtons extends StatefulWidget {
  const ActiveButtons({super.key});

  @override
  State<ActiveButtons> createState() => _ActiveButtonsState();
}

class _ActiveButtonsState extends State<ActiveButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Container()),
        HeaderButtonItem(buttonSide: ButtonSide.left, func: (){}, icon: Icons.add_rounded, text: "添加任务"),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: (){}, icon: Icons.check_box_outlined, text: "选择"),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: (){}, icon: Icons.pause_rounded, text: "全部暂停"),
        HeaderButtonItem(buttonSide: ButtonSide.right, func: (){}, icon: Icons.play_arrow_rounded, text: "全部继续")
      ],
    );
  }
}