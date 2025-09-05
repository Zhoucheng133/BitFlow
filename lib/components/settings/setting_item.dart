import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        width: 360,
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
  final dynamic selected;
  final IconData selectedIcon;
  final String selectedText;
  final ValueChanged func;
  final List<CustomDropDownItem> list;

  const SettingDropDownItem({super.key, required this.label, this.selected, required this.selectedIcon, required this.selectedText, required this.func, required this.list});

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

  final dynamic selected;
  final IconData selectedIcon;
  final String selectedText;
  final ValueChanged func;
  final List<CustomDropDownItem> list;
  final bool mobile;

  const DropDownContent({super.key, this.selected, required this.selectedIcon, required this.selectedText, required this.func, required this.list, this.mobile=false});

  @override
  State<DropDownContent> createState() => _DropDownContentState();
}

class _DropDownContentState extends State<DropDownContent> {

  bool hover=false;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        value: widget.selected,
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5)
          )
        ),
        menuItemStyleData: MenuItemStyleData(
          height: widget.mobile ? 50 : 40,
          padding: EdgeInsets.only(left: 10, right: 10),
        ),
        dropdownStyleData: DropdownStyleData(
          padding: const EdgeInsets.symmetric(vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).colorScheme.surface
          )
        ),
        customButton: MouseRegion(
          onEnter: (_) => setState(() => hover = true),
          onExit: (_) => setState(() => hover = false),
          child: AnimatedContainer(
            height: widget.mobile ? 45 : 35,
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: hover ? Theme.of(context).colorScheme.primary.withAlpha(12) : Theme.of(context).colorScheme.primary.withAlpha(0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    widget.selectedIcon,
                    size: 15,
                  ),
                  const SizedBox(width: 10,),
                  Text(
                    widget.selectedText,
                    style: GoogleFonts.notoSansSc(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        isExpanded: false,
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
                  style: GoogleFonts.notoSansSc(
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
    );
  }
}