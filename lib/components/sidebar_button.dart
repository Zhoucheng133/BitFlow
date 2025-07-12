import 'package:flutter/material.dart';

class SidebarSmallButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback func;
  final bool? star;
  final double? size;
  final bool? disable;

  const SidebarSmallButton({super.key, required this.icon, required this.func, this.star, this.size, this.disable});

  @override
  State<SidebarSmallButton> createState() => _SidebarSmallButtonState();
}

class _SidebarSmallButtonState extends State<SidebarSmallButton> {

  bool hover=false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.disable==true ? null : widget.func,
      child: MouseRegion(
        cursor: widget.disable==true ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: widget.disable==true ? null : (_)=>setState(() {
          hover=true;
        }),
        onExit: (_)=>setState(() {
          hover=false;
        }),
        child: Container(
          height: 35,
          decoration: BoxDecoration(
            color: hover ? Theme.of(context).hoverColor : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.size ?? 16,
              color: widget.disable==true ? Colors.grey : widget.star==true ? Colors.orange : Colors.black,
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

  const SidebarButton({super.key, required this.label, required this.icon, required this.func});

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {

  bool hover=false;

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
        child: Container(
          height: 35,
          decoration: BoxDecoration(
            color: hover ? Theme.of(context).hoverColor : Theme.of(context).scaffoldBackgroundColor,
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
                Text(widget.label)
              ],
            ),
          ),
        ),
      ),
    );
  }
}