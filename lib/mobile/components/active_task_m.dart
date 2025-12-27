import 'package:bit_flow/components/task_components/active_task.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ActiveTaskM extends StatefulWidget {

  final TaskItem item;

  const ActiveTaskM({super.key, required this.item});

  @override
  State<ActiveTaskM> createState() => _ActiveTaskMState();
}

class _ActiveTaskMState extends State<ActiveTaskM> {
  final ThemeGet themeGet=Get.find();
  final StatusGet statusGet=Get.find();

  @override
  Widget build(BuildContext context) {

    if(statusGet.page.value!=Pages.active){
      return Container();
    }

    return Ink(
      child: InkWell(
        onLongPress: (){
          statusGet.selectMode.value=true;
          statusGet.selectList.add(widget.item);
        },
        onTap: (){
          if(statusGet.selectMode.value){
            if(statusGet.selectList.contains(widget.item)){
              statusGet.selectList.remove(widget.item);
            }else{
              statusGet.selectList.add(widget.item);
            }
          }else {
            showModalBottomSheet(
              context: context, 
              clipBehavior: Clip.antiAlias,
              builder: (BuildContext context)=>Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(
                    ActiveTaskMenuTypes.values.length,
                    (index)=>ListTile(
                      leading: Icon(
                        menuIcon(ActiveTaskMenuTypes.values[index]),
                        size: 18,
                      ),
                      title: Text(menuLabel(ActiveTaskMenuTypes.values[index])),
                      onTap: () async {
                        switch (ActiveTaskMenuTypes.values[index]) {
                          case ActiveTaskMenuTypes.copy:
                            Navigator.pop(context);
                            await FlutterClipboard.copy(widget.item.link);
                            break;
                          case ActiveTaskMenuTypes.del:
                            Navigator.pop(context);
                            final parentContext = Navigator.of(context, rootNavigator: true).context;
                            widget.item.delTask(parentContext);
                            break;
                          case ActiveTaskMenuTypes.files:
                            Navigator.pop(context);
                            if(context.mounted) widget.item.showFiles(context);
                            break;
                          case ActiveTaskMenuTypes.info:
                            Navigator.pop(context);
                            if(context.mounted) widget.item.showTaskInfo(context);
                            break;
                          case ActiveTaskMenuTypes.pause:
                            Navigator.pop(context);
                            widget.item.pauseTask();
                          case ActiveTaskMenuTypes.cont:
                            Navigator.pop(context);
                            widget.item.continueTask();
                        }
                      },
                    )
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom,),
                ],
              )
            );
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: Stack(
            children: [
              if(widget.item.status!=TaskStatus.seeding) Positioned(
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
                      color: widget.item.status==TaskStatus.download ? Theme.of(context).colorScheme.primary : widget.item.status==TaskStatus.pause || widget.item.status==TaskStatus.wait ? Colors.grey[300] : Colors.green,
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
                                  ),
                                  Text(
                                    widget.item.sizeString(widget.item.size),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey
                                    ),
                                  )
                                ],
                              )
                            ),
                            const SizedBox(width: 10,),
                            if(widget.item.status==TaskStatus.download) Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if(widget.item.uploadSpeed!=0) Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 16,
                                      ),
                                    ),
                                    if(widget.item.uploadSpeed!=0) Text(
                                      widget.item.sizeString(widget.item.uploadSpeed, useSpeed: true),
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    if(widget.item.downloadSpeed!=0) const SizedBox(width: 10,),
                                    if(widget.item.downloadSpeed!=0) Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 16,
                                      ),
                                    ),
                                    if(widget.item.downloadSpeed!=0) Text(
                                      widget.item.sizeString(widget.item.downloadSpeed, useSpeed: true),
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                                Text(
                                  widget.item.calTime(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey
                                  ),
                                )
                              ],
                            ),
                            if(widget.item.status==TaskStatus.pause) Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.pause,
                                  size: 16,
                                  color: Colors.grey[300],
                                )
                              ],
                            ),
                            if(widget.item.status==TaskStatus.wait) Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.clock,
                                  size: 16,
                                  color: Colors.grey[300],
                                )
                              ],
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