import 'package:flutter/material.dart';

class SidebarSmallButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback func;
  final bool? star;

  const SidebarSmallButton({super.key, required this.icon, required this.func, this.star});

  @override
  State<SidebarSmallButton> createState() => _SidebarSmallButtonState();
}

class _SidebarSmallButtonState extends State<SidebarSmallButton> {

  bool hover=false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.func,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_)=>setState(() {
          hover=true;
        }),
        onExit: (_)=>setState(() {
          hover=false;
        }),
        child: Container(
          // duration: const Duration(milliseconds: 200),
          height: 35,
          decoration: BoxDecoration(
            color: hover ? Theme.of(context).hoverColor : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.star==true ? Colors.orange : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarButton extends StatefulWidget {

  final String label;

  const SidebarButton({super.key, required this.label});

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 30,
      decoration: BoxDecoration(
        
      ),
    );
  }
}