import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/components/header/header_button_item.dart';
import 'package:bit_flow/components/header/header_funcs.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ActiveButtons extends StatefulWidget {
  const ActiveButtons({super.key});

  @override
  State<ActiveButtons> createState() => _ActiveButtonsState();
}

void addTaskHandler(BuildContext context, TextEditingController link, FuncsService funcs){
  if(!link.text.startsWith("http://") && !link.text.startsWith("https://") && !link.text.startsWith("magnet:?xt=urn:btih:")){
    showErrWarnDialog(context, "addTaskFail".tr, "invalidLink".tr);
    return;
  }
  funcs.addTaskHandler(link.text);
  Navigator.pop(context);
}

Future<void> addTaskDialogM(BuildContext context) async {
  final FuncsService funcs=Get.find();
  final TextEditingController link=TextEditingController();
  final copyText=await FlutterClipboard.paste();
  if(copyText.startsWith("http://") || copyText.startsWith("https://") || copyText.startsWith("magnet:?xt=urn:btih:")){
    link.text=copyText;
  }
  if(context.mounted){

    FocusNode inputFocus=FocusNode();
    
    showDialog(
      context: context, 
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'addTask'.tr,
        ),
        content: SizedBox(
          width: 400,
          child: StatefulBuilder(
            builder: (BuildContext context, setState){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'multiTaskTip'.tr,
                  ),
                  const SizedBox(height: 5,),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 350
                    ),
                    child: TextField(
                      focusNode: inputFocus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'http(s)://\nmagnet:?xt=urn:btih:', 
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 13
                        ),
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                      ),
                      minLines: 3,
                      maxLines: null,
                      controller: link,
                      style: TextStyle(
                        fontSize: 13
                      ),
                    ),
                  )
                ],
              );
            }
          ),
        ),
        actions: [
          TextButton(
            onPressed: (){
              if (inputFocus.hasFocus) {
                inputFocus.unfocus();
              }
              Navigator.pop(context);
            }, 
            child: Text('cancel'.tr)
          ),
          TextButton(
            onPressed: () async {
              if (inputFocus.hasFocus) {
                inputFocus.unfocus();
              }
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ["torrent"]
              );
              if(result!=null){
                if(context.mounted) Navigator.pop(context);
                final filePath=result.files.single.path!;
                funcs.addTorrentTaskHandler(filePath);
              }
            }, 
            child: Text('fromTorrent'.tr)
          ),
          ElevatedButton(
            onPressed: (){
              if (inputFocus.hasFocus) {
                inputFocus.unfocus();
              }
              addTaskHandler(context, link, funcs);
            }, 
            child: Text('add'.tr)
          )
        ],
      )
    );
  }
}

Future<void> addTaskDialog(BuildContext context) async {
  final FuncsService funcs=Get.find();
  final TextEditingController link=TextEditingController();
  final copyText=await FlutterClipboard.paste();
  if(copyText.startsWith("http://") || copyText.startsWith("https://") || copyText.startsWith("magnet:?xt=urn:btih:")){
    link.text=copyText;
  }
  if(context.mounted){

    FocusNode node=FocusNode();
    FocusNode inputNode=FocusNode();

    showDialog(
      context: context, 
      builder: (BuildContext context) => AlertDialog(
        title: Text('addTask'.tr),
        content: SizedBox(
          width: 400,
          child: StatefulBuilder(
            builder: (BuildContext context, setState){
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  FocusScope.of(context).requestFocus(node);
                }
              });
              return KeyboardListener(
                focusNode: node,
                onKeyEvent: (event){
                  if(event is KeyDownEvent && event.logicalKey==LogicalKeyboardKey.enter && !inputNode.hasFocus){
                    addTaskHandler(context, link, funcs);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('multiTaskTip'.tr),
                    const SizedBox(height: 5,),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 350
                      ),
                      child: TextField(
                        focusNode: inputNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'http(s)://\nmagnet:?xt=urn:btih:', 
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 13
                          ),
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                        ),
                        minLines: 3,
                        maxLines: null,
                        controller: link,
                        style: TextStyle(
                          fontSize: 13
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          ),
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ["torrent"]
              );
              if(result!=null){
                if(context.mounted) Navigator.pop(context);
                final filePath=result.files.single.path!;
                funcs.addTorrentTaskHandler(filePath);
              }
            }, 
            child: Text('fromTorrent'.tr)
          ),
          ElevatedButton(
            onPressed: ()=>addTaskHandler(context, link, funcs), 
            child: Text('add'.tr)
          )
        ],
      )
    );
  }
}

class _ActiveButtonsState extends State<ActiveButtons> {

  final StatusGet statusGet=Get.find();
  final GlobalKey sortActiveMenuKey = GlobalKey(); 
  final FuncsService funcsService=Get.find();

  void selectAllHandler(){
    if(statusGet.selectList.length == statusGet.activeTasks.length){
      statusGet.selectList.value=[];
      return;
    }
    statusGet.selectList.value=statusGet.activeTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          HeaderButtonItem(buttonSide: ButtonSide.left, func: ()=>addTaskDialog(context), icon: Icons.add_rounded, text: "addTask".tr),
          HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>statusGet.selectMode.value=!statusGet.selectMode.value, icon: statusGet.selectMode.value ? Icons.close_rounded : Icons.check_box_rounded, text: statusGet.selectMode.value ? "unselect".tr : "select".tr),
          if(statusGet.selectMode.value) HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>selectAllHandler(), icon: Icons.checklist_rounded, text: "selectAll".tr),
          if(statusGet.selectMode.value) HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>funcsService.multiPause(context), icon: Icons.pause_rounded, text: "pause".tr),
          if(statusGet.selectMode.value) HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>funcsService.multiContinue(context), icon: Icons.play_arrow_rounded, text: "resume".tr),
          if(statusGet.selectMode.value) HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>funcsService.delSelected(context, Pages.active), icon: Icons.delete, text: "delete".tr),
          
          if(!statusGet.selectMode.value) HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>funcsService.pauseAll(context), icon: Icons.pause_rounded, text: "pauseAll".tr),
          if(!statusGet.selectMode.value) HeaderButtonItem(buttonSide: ButtonSide.mid, func: ()=>funcsService.continueAll(context), icon: Icons.play_arrow_rounded, text: "resumeAll".tr),

          HeaderButtonItem(
            buttonSide: ButtonSide.right, 
            func: () async {
              final RenderBox box = sortActiveMenuKey.currentContext!.findRenderObject() as RenderBox;
              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

              final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(
                  box.localToGlobal(Offset.zero, ancestor: overlay),
                  box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
                ),
                Offset.zero & overlay.size,
              );

              OrderTypes? type=await changeOrderMenu(context, statusGet.activeOrder.value, position);
              if(type!=null){
                statusGet.activeOrder.value=type;
                funcsService.getTasks();
              }
            }, 
            icon: statusGet.getOrderIcon(Pages.active), 
            iconSize: 13, 
            key: sortActiveMenuKey,
          )
        ],
      ),
    );
  }
}