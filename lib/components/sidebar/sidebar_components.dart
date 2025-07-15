import 'package:bit_flow/getx/theme_get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SidebarDivider extends StatefulWidget {

  final VoidCallback? func;
  final bool useAdd;
  final String label;
  final String addHint;

  const SidebarDivider({super.key, this.func, this.useAdd=false, required this.label, this.addHint=""});

  @override
  State<SidebarDivider> createState() => _SidebarDividerState();
}

class _SidebarDividerState extends State<SidebarDivider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.notoSansSc(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary
                  ),
                ),
              ),
              if(widget.useAdd) Tooltip(
                message: widget.addHint,
                child: GestureDetector(
                  onTap: widget.func,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 5,),
        Container(
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Theme.of(context).colorScheme.primary.withAlpha(20)
          ),
        ),
        const SizedBox(height: 5,),
      ],
    );
  }
}

class SidebarSmallButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback func;
  final bool star;
  final double? size;
  final bool disable;

  const SidebarSmallButton({super.key, required this.icon, required this.func, this.star=false, this.size, this.disable=false});

  @override
  State<SidebarSmallButton> createState() => _SidebarSmallButtonState();
}

class _SidebarSmallButtonState extends State<SidebarSmallButton> {

  bool hover=false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.disable ? null : widget.func,
      child: MouseRegion(
        cursor: widget.disable ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: widget.disable ? null : (_)=>setState(() {
          hover=true;
        }),
        onExit: (_)=>setState(() {
          hover=false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 35,
          decoration: BoxDecoration(
            color: hover ? Theme.of(context).colorScheme.primary.withAlpha(12) : Theme.of(context).colorScheme.primary.withAlpha(0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.size ?? 16,
              color: widget.disable ? Theme.of(context).disabledColor : widget.star ? Colors.orange : Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarButton extends StatefulWidget {

  final String label;
  final IconData icon;
  final VoidCallback func;
  final bool selected;

  const SidebarButton({super.key, required this.label, required this.icon, required this.func, this.selected=false});

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {

  bool hover=false;
  final ThemeGet themeGet=Get.find();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.func,
      child: MouseRegion(
        onEnter: (_)=>setState(() {
          hover=true;
        }),
        onExit: (_)=>setState(() {
          hover=false;
        }),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 35,
          decoration: BoxDecoration(
            // color: widget.selected ? Theme.of(context).colorScheme.primary.withAlpha(18) : hover ? Theme.of(context).colorScheme.primary.withAlpha(12) : Theme.of(context).colorScheme.primary.withAlpha(0),
            color: themeGet.buttonColor(context, hover, widget.selected),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                ),
                const SizedBox(width: 5,),
                Text(
                  widget.label,
                  style: GoogleFonts.notoSansSc(
                    color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}