import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FinishTask extends StatefulWidget {

  final TaskItem item;

  const FinishTask({super.key, required this.item});

  @override
  State<FinishTask> createState() => _FinishTaskState();
}

enum FinishTaskMenuTypes{
  info,
  files,
  copy,
  redownload,
  del,
}

IconData menuIcon(FinishTaskMenuTypes menuType){
  switch (menuType) {
    case FinishTaskMenuTypes.info:
      return FontAwesomeIcons.circleInfo;
    case FinishTaskMenuTypes.files:
      return FontAwesomeIcons.file;
    case FinishTaskMenuTypes.copy:
      return FontAwesomeIcons.copy;
    case FinishTaskMenuTypes.redownload:
      return FontAwesomeIcons.rotateRight;
    case FinishTaskMenuTypes.del:
      return FontAwesomeIcons.trash;
  }
}

String menuLabel(FinishTaskMenuTypes menuType){
  switch (menuType) {
    case FinishTaskMenuTypes.info:
      return "任务详情";
    case FinishTaskMenuTypes.files:
      return "文件列表";
    case FinishTaskMenuTypes.copy:
      return "复制链接";
    case FinishTaskMenuTypes.redownload:
      return "重新下载";
    case FinishTaskMenuTypes.del:
      return "删除";
  }
}

class _FinishTaskState extends State<FinishTask> {
  bool onHover=false;
  final ThemeGet themeGet=Get.find();
  final StatusGet statusGet=Get.find();

  Future<void> showFinishTaskMenu(BuildContext context, TapDownDetails details) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = overlay.localToGlobal(details.globalPosition);
    FinishTaskMenuTypes? val=await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 50,
        position.dy + 50,
      ),
      color: Theme.of(context).colorScheme.surface,
      items: FinishTaskMenuTypes.values.map((FinishTaskMenuTypes item){
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
      case FinishTaskMenuTypes.copy:
        await FlutterClipboard.copy(widget.item.link);
        break;
      case FinishTaskMenuTypes.del:

        break;
      case FinishTaskMenuTypes.files:

        break;
      case FinishTaskMenuTypes.info:
        if(context.mounted) widget.item.showTaskInfo(context);
        break;
      case FinishTaskMenuTypes.redownload:

        break;
      
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {    
    if(statusGet.page.value!=Pages.finish){
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
        onSecondaryTapDown: (details) => showFinishTaskMenu(context, details),
        child: SizedBox(
          width: double.infinity,
          height: 50,
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
                      color: Colors.green,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
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