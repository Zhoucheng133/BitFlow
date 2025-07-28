import 'package:flutter/material.dart';

class SettingItem extends StatefulWidget {

  final String label;
  final Widget child;
  final double gap;
  final bool showDivider;

  const SettingItem({super.key, required this.label, required this.child, this.gap=0.0, this.showDivider=true});

  @override
  State<SettingItem> createState() => _SettingItemState();
}

class _SettingItemState extends State<SettingItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 170,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    widget.label,
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              SizedBox(
                width: 180,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: widget.gap),
                    child: widget.child,
                  )
                )
              ),
            ],
          ),
        ),
        widget.showDivider==false ? Container() : const SettingDivider()
      ],
    );
  }
}

class SettingDivider extends StatelessWidget {
  const SettingDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 360,
        child: Divider(
          height: 3,
          color: Theme.of(context).colorScheme.primary.withAlpha(30),
        ),
      ),
    );
  }
}