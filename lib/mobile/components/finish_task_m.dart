import 'package:bit_flow/components/task_components/finish_task.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FinishTaskM extends StatefulWidget {

  final TaskItem item;

  const FinishTaskM({super.key, required this.item});

  @override
  State<FinishTaskM> createState() => _FinishTaskMState();
}

class _FinishTaskMState extends State<FinishTaskM> {
  final ThemeGet themeGet=Get.find();
  final StatusGet statusGet=Get.find();
  final FuncsService funcsService=Get.find();


  @override
  Widget build(BuildContext context) {    
    if(statusGet.page.value!=Pages.finish){
      return Container();
    }
    return Ink(
      child: InkWell(
        onTap: (){
          showModalBottomSheet(
            context: context, 
            clipBehavior: Clip.antiAlias,
            builder: (BuildContext context)=>Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(
                  FinishTaskMenuTypes.values.length,
                  (index)=>ListTile(
                    leading: Icon(
                      menuIcon(FinishTaskMenuTypes.values[index]),
                      size: 18,
                    ),
                    title: Text(menuLabel(FinishTaskMenuTypes.values[index])),
                    onTap: () async {
                      switch (FinishTaskMenuTypes.values[index]) {
                        case FinishTaskMenuTypes.copy:
                          Navigator.pop(context);
                          await FlutterClipboard.copy(widget.item.link);
                          break;
                        case FinishTaskMenuTypes.del:
                          Navigator.pop(context);
                          final parentContext = Navigator.of(context, rootNavigator: true).context;
                          widget.item.delTask(parentContext);
                          break;
                        case FinishTaskMenuTypes.files:
                          Navigator.pop(context);
                          if(context.mounted) widget.item.showFiles(context);
                          break;
                        case FinishTaskMenuTypes.info:
                          Navigator.pop(context);
                          if(context.mounted) widget.item.showTaskInfo(context);
                          break;
                        case FinishTaskMenuTypes.redownload:
                          Navigator.pop(context);
                          if(context.mounted) widget.item.reDownload(context);
                          break;
                      }
                    },
                  )
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom,),
              ],
            )
          );
        },
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: Stack(
            children: [
              if(widget.item.calPercent()!=1) Positioned(
                top: 0,
                left: 10,
                right: 0,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.item.calPercent(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).brightness==Brightness.light ? Theme.of(context).colorScheme.primary.withAlpha(50) : Color.fromARGB(255, 100, 100, 100),
                          width: 3
                        ),
                      )
                    ),
                  ),
                ),
              ),
              Container(
                color: themeGet.taskItemColor(context, false),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 10,
                      color: Colors.green,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Obx(()=>
                              statusGet.selectMode.value ? Checkbox(
                                splashRadius: 0,
                                value: statusGet.selectList.contains(widget.item), 
                                onChanged: (bool? select){
                                  if(select==null) return;
                                  if(select){
                                    statusGet.selectList.add(widget.item);
                                  }else{
                                    statusGet.selectList.remove(widget.item);
                                  }
                                }
                              ) : Container()
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.item.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.notoSansSc(
                                      // fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.item.sizeString(widget.item.size),
                                          style: GoogleFonts.notoSansSc(
                                            fontSize: 12,
                                            color: Colors.grey
                                          ),
                                        ),
                                      ),
                                      Text(
                                        widget.item.addTimeGet()??"",
                                        style: GoogleFonts.notoSansSc(
                                          fontSize: 12,
                                          color: Colors.grey
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ),
                            const SizedBox(width: 10,),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}