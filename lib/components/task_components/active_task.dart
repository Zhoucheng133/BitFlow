import 'package:bit_flow/types/task_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveTask extends StatefulWidget {

  final TaskItem item;

  const ActiveTask({super.key, required this.item});

  @override
  State<ActiveTask> createState() => _ActiveTaskState();
}

class _ActiveTaskState extends State<ActiveTask> {

  bool onHover=false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_)=>setState(() {
        onHover=true;
      }),
      onExit: (_)=>setState(() {
        onHover=false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: onHover ? Theme.of(context).colorScheme.primary.withAlpha(12) : Theme.of(context).colorScheme.primary.withAlpha(0),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.item.completeBytes / widget.item.size > 1 ? 1 : widget.item.completeBytes / widget.item.size,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withAlpha(50),
                        width: 2
                      ),
                    )
                  ),
                ),
              ),
            ),
            Padding(
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
                            fontWeight: FontWeight.bold,
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
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.item.sizeString(widget.item.uploadSpeed, useSpeed: true),
                          style: GoogleFonts.notoSansSc(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                        ),
                        Text(
                          widget.item.sizeString(widget.item.downloadSpeed, useSpeed: true),
                          style: GoogleFonts.notoSansSc(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}