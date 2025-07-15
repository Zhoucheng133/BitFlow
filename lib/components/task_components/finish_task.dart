import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/types/task_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FinishTask extends StatefulWidget {

  final TaskItem item;

  const FinishTask({super.key, required this.item});

  @override
  State<FinishTask> createState() => _FinishTaskState();
}

class _FinishTaskState extends State<FinishTask> {
  bool onHover=false;
  final ThemeGet themeGet=Get.find();
  final StatusGet statusGet=Get.find();

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
                          Column(
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
    );
  }
}