import 'package:flutter/material.dart';

enum ButtonSide{
  left,
  mid,
  right
}

class HeaderButtonItem extends StatefulWidget {

  final ButtonSide buttonSide;
  final VoidCallback func;
  final IconData icon;
  final String text;

  const HeaderButtonItem({super.key, required this.buttonSide, required this.func, required this.icon, required this.text});

  @override
  State<HeaderButtonItem> createState() => _HeaderButtonItemState();
}

class _HeaderButtonItemState extends State<HeaderButtonItem> {
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: widget.buttonSide==ButtonSide.left ? BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10)
          ) : widget.buttonSide==ButtonSide.right ? BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10) 
          ) : BorderRadius.zero
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      onPressed: widget.func,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon),
          const SizedBox(width: 5,),
          Text(widget.text)
        ],
      )
    );
  }
}