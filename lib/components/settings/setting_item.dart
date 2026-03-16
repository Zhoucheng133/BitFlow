import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';

class SettingItem extends StatefulWidget {

  final String label;
  final Widget child;
  final double gap;
  final bool showDivider;
  final double paddingRight;

  const SettingItem({super.key, required this.label, required this.child, this.gap=0.0, this.showDivider=true, this.paddingRight=0.0});

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
          height: 45,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
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
                child: Padding(
                  padding: EdgeInsets.only(right: widget.paddingRight),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: widget.gap),
                      child: widget.child,
                    )
                  ),
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
        width: 380,
        child: Divider(
          height: 3,
          color: Theme.of(context).colorScheme.primary.withAlpha(30),
        ),
      ),
    );
  }
}

class CustomDropDownItem{
  String label;
  dynamic key;
  IconData icon;

  CustomDropDownItem(this.label, this.key, this.icon);
}


class SettingDropDownItem extends StatefulWidget {

  final String label;
  final OrderTypes selected;
  final IconData selectedIcon;
  final String selectedText;
  final ValueChanged func;
  final List<CustomDropDownItem> list;

  const SettingDropDownItem({super.key, required this.label, required this.selected, required this.selectedIcon, required this.selectedText, required this.func, required this.list});

  @override
  State<SettingDropDownItem> createState() => _SettingDropDownItemState();
}

class _SettingDropDownItemState extends State<SettingDropDownItem> {

  @override
  Widget build(BuildContext context) {
    return SettingItem(
      label: widget.label, 
      child: DropDownContent(
        selected: widget.selected,
        selectedIcon: widget.selectedIcon,
        selectedText: widget.selectedText,
        func: widget.func,
        list: widget.list,
      )
    );
  }
}

class DropDownContent extends StatefulWidget {

  final OrderTypes selected;
  final IconData selectedIcon;
  final String selectedText;
  final ValueChanged func;
  final List<CustomDropDownItem> list;
  final bool mobile;

  const DropDownContent({super.key, required this.selected, required this.selectedIcon, required this.selectedText, required this.func, required this.list, this.mobile=false});

  @override
  State<DropDownContent> createState() => _DropDownContentState();
}

class _DropDownContentState extends State<DropDownContent> {

  bool hover=false;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(5),
      color: Theme.of(context).brightness==Brightness.light ? Colors.white : Colors.grey[850],
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            value: widget.selected,
            isExpanded: false,
            focusColor: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            padding: EdgeInsets.symmetric(horizontal: 5),
            items: widget.list.map((item)=>
              DropdownMenuItem(
                value: item.key,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 15,
                    ),
                    SizedBox(width: 10,),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              )
            ).toList(),
            onChanged: (val){
              if(val!=null){
                widget.func(val);
              }
            },
          )
        ),
      ),
    );
  }
}