import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveTask extends StatefulWidget {

  final TaskItem item;

  const ActiveTask({super.key, required this.item});

  @override
  State<ActiveTask> createState() => _ActiveTaskState();
}

enum ActiveTaskMenuTypes{
  pause,
  cont,
  info,
  files,
  copy,
  del,
}

IconData menuIcon(ActiveTaskMenuTypes menuType){
  switch (menuType) {
    case ActiveTaskMenuTypes.info:
      return FontAwesomeIcons.circleInfo;
    case ActiveTaskMenuTypes.files:
      return FontAwesomeIcons.file;
    case ActiveTaskMenuTypes.copy:
      return FontAwesomeIcons.copy;
    case ActiveTaskMenuTypes.del:
      return FontAwesomeIcons.trash;
    case ActiveTaskMenuTypes.pause:
      return FontAwesomeIcons.pause;
    case ActiveTaskMenuTypes.cont:
      return FontAwesomeIcons.play;
  }
}

String menuLabel(ActiveTaskMenuTypes menuType){
  switch (menuType) {
    case ActiveTaskMenuTypes.info:
      return "任务详情";
    case ActiveTaskMenuTypes.files:
      return "文件列表";
    case ActiveTaskMenuTypes.copy:
      return "复制链接";
    case ActiveTaskMenuTypes.del:
      return "删除";
    case ActiveTaskMenuTypes.pause:
      return "暂停";
    case ActiveTaskMenuTypes.cont:
      return "继续";
  }
}

class _ActiveTaskState extends State<ActiveTask> {

  bool onHover=false;
  final ThemeGet themeGet=Get.find();
  final StatusGet statusGet=Get.find();

  Future<void> showActiveTaskMenu(BuildContext context, TapDownDetails details) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = overlay.localToGlobal(details.globalPosition);
    ActiveTaskMenuTypes? val=await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 50,
        position.dy + 50,
      ),
      color: Theme.of(context).colorScheme.surface,
      items: ActiveTaskMenuTypes.values.where((item) {
        if (item == ActiveTaskMenuTypes.pause && widget.item.status==TaskStatus.pause){
          return false;
        }else if (item == ActiveTaskMenuTypes.cont && widget.item.status==TaskStatus.download){
          return false;
        }
        return true;
      }).map((ActiveTaskMenuTypes item){
        return PopupMenuItem(
          value: item,
          height: 35,
          child: Row(
            children: [
              Icon(
                menuIcon(item),
                size: 15,
              ),
              const SizedBox(width: 10,),
              Text(menuLabel(item)),
            ],
          )
        );
      }).toList()
    );
    
    switch (val) {
      case ActiveTaskMenuTypes.copy:
        await FlutterClipboard.copy(widget.item.link);
        break;
      case ActiveTaskMenuTypes.del:
        if(context.mounted) widget.item.delTask(context);
        break;
      case ActiveTaskMenuTypes.files:
        if(context.mounted) widget.item.showFiles(context);
        break;
      case ActiveTaskMenuTypes.info:
        if(context.mounted) widget.item.showTaskInfo(context);
        break;
      case ActiveTaskMenuTypes.pause:
        widget.item.pauseTask();
      case ActiveTaskMenuTypes.cont:
        widget.item.continueTask();
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {

    if(statusGet.page.value!=Pages.active){
      return Container();
    }

    return MouseRegion(
      onEnter: (_)=>setState(() {
        onHover=true;
      }),
      onExit: (_)=>setState(() {
        onHover=false;
      }),
      child: GestureDetector(
        onSecondaryTapDown: (details){
          showActiveTaskMenu(context, details);
        },
        onTap: (){
          if(!statusGet.selectMode.value){
            widget.item.showTaskInfo(context);
            return;
          }
          if(statusGet.selectList.contains(widget.item)){
            statusGet.selectList.remove(widget.item);
          }else{
            statusGet.selectList.add(widget.item);
          }
        },
        child: Tooltip(
          message: widget.item.name,
          waitDuration: const Duration(seconds: 1),
          child: SizedBox(
            width: double.infinity,
            height: 50,
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
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).brightness==Brightness.light ? Theme.of(context).colorScheme.primary.withAlpha(50) : Color.fromARGB(255, 100, 100, 100),
                            width: 2
                          ),
                        )
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: themeGet.taskItemColor(context, onHover),
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
                                      style: GoogleFonts.notoSansSc(
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
                                        style: GoogleFonts.notoSansSc(
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
                                        style: GoogleFonts.notoSansSc(
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    widget.item.calTime(),
                                    style: GoogleFonts.notoSansSc(
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
      ),
    );
  }
}