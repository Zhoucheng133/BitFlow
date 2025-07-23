import 'package:bit_flow/components/header/header_button_item.dart';
import 'package:bit_flow/components/header/header_funcs.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinishedButtons extends StatefulWidget {
  const FinishedButtons({super.key});

  @override
  State<FinishedButtons> createState() => _FinishedButtonsState();
}

class _FinishedButtonsState extends State<FinishedButtons> {

  final StatusGet statusGet=Get.find();
  final GlobalKey sortFinishedMenuKey = GlobalKey();
  final FuncsService funcsService=Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          HeaderButtonItem(buttonSide: ButtonSide.left, func: (){}, icon: Icons.check_box_outlined, text: "选择"),
          HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>funcsService.delAllFinishedTasks(context), icon: Icons.delete_rounded, text: "清空已完成"),
          HeaderButtonItem(
              buttonSide: ButtonSide.right, 
              func: () async {
                final RenderBox box = sortFinishedMenuKey.currentContext!.findRenderObject() as RenderBox;
                final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    box.localToGlobal(Offset.zero, ancestor: overlay),
                    box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );
      
                OrderTypes? type=await changeOrderMenu(context, statusGet.finishOrder.value, position);
                if(type!=null){
                  statusGet.finishOrder.value=type;
                  funcsService.getTasks();
                }
              }, 
              icon: statusGet.getOrderIcon(Pages.finish), 
              iconSize: 13, 
              key: sortFinishedMenuKey,
            )
        ],
      ),
    );
  }
}