import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/components/header/header_button_item.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveButtons extends StatefulWidget {
  const ActiveButtons({super.key});

  @override
  State<ActiveButtons> createState() => _ActiveButtonsState();
}

void addTaskHandler(BuildContext context, TextEditingController link, FuncsService funcs){
  if(!link.text.startsWith("http://") && !link.text.startsWith("https://") && !link.text.startsWith("magnet:?xt=urn:btih:")){
    showErrWarnDialog(context, "添加任务失败", "链接不合法");
    return;
  }
  funcs.addTaskHandler(link.text);
  Navigator.pop(context);
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
        title: Text('添加任务'),
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
                    Text('若要添加多个任务，用回车拆分'),
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
                          hintStyle: GoogleFonts.notoSansSc(
                            color: Colors.grey,
                            fontSize: 13
                          ),
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                        ),
                        minLines: 3,
                        maxLines: null,
                        controller: link,
                        style: GoogleFonts.notoSansSc(
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
          TextButton(onPressed: ()=>Navigator.pop(context), child: Text('取消')),
          ElevatedButton(
            onPressed: ()=>addTaskHandler(context, link, funcs), 
            child: Text('添加')
          )
        ],
      )
    );
  }
}

class _ActiveButtonsState extends State<ActiveButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Container()),
        HeaderButtonItem(buttonSide: ButtonSide.left, func: ()=>addTaskDialog(context), icon: Icons.add_rounded, text: "添加任务"),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: (){}, icon: Icons.check_box_outlined, text: "选择"),
        HeaderButtonItem(buttonSide: ButtonSide.mid, func: (){}, icon: Icons.pause_rounded, text: "全部暂停"),
        HeaderButtonItem(buttonSide: ButtonSide.right, func: (){}, icon: Icons.play_arrow_rounded, text: "全部继续")
      ],
    );
  }
}