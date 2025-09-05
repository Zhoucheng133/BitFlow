import 'package:bit_flow/types/store_item.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddItem extends StatefulWidget {

  final String label;
  final Widget content;

  const AddItem({super.key, required this.label, required this.content});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            widget.label,
          )
        ),
        const SizedBox(width: 15,),
        Expanded(child: widget.content)
      ],
    );
  }
}

class AddStore extends StatefulWidget {
  final ValueChanged<StoreItem> valCallback;
  const AddStore({super.key, required this.valCallback});

  @override
  State<AddStore> createState() => _AddStoreState();
}

class _AddStoreState extends State<AddStore> {

  String type="Aria";
  TextEditingController name=TextEditingController();
  TextEditingController url=TextEditingController();
  TextEditingController username=TextEditingController();
  TextEditingController password=TextEditingController();

  StoreItem item=StoreItem("", StoreType.aria, "", "", "");

  String convertType(StoreType type){
    if(type==StoreType.aria){
      return "Aria";
    }else if(type==StoreType.qbit){
      return "qBittorrent";
    }
    return "";
  }

  void toEnumType(String? type){
    switch (type) {
      case "Aria":
        item.type=StoreType.aria;
        break;
      case "qBittorrent":
        item.type=StoreType.qbit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddItem(
          label: '下载器类型',
          content: Align(
            alignment: Alignment.centerLeft,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                buttonStyleData: ButtonStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                  padding: EdgeInsets.only(left: 10, right: 10),
                ),
                dropdownStyleData: DropdownStyleData(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).colorScheme.surface
                  )
                ),
                isExpanded: false,
                value: type,
                items: StoreType.values.map((StoreType type) {
                  final str = convertType(type);
                  return DropdownMenuItem<String>(
                    value: str,
                    child: Text(
                      str,
                      style: GoogleFonts.notoSansSc(
                        fontSize: 14,
                      ),
                    ),
                  );
                })
                .toList(),
                onChanged: (String? val){
                  setState((){
                    type=val!;
                  });
                  toEnumType(val);
                  widget.valCallback(item);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10,),
        AddItem(
          label: '名称', 
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '随意取一个',
              hintStyle: GoogleFonts.notoSansSc(
                color: Colors.grey
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            ),
            controller: name,
            style: GoogleFonts.notoSansSc(
              fontSize: 14
            ),
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (val){
              item.name=val;
              widget.valCallback(item);
            },
          )
        ),
        const SizedBox(height: 10,),
        AddItem(
          label: '服务器地址', 
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'http(s)://',
              hintStyle: GoogleFonts.notoSansSc(
                color: Colors.grey
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            ),
            controller: url,
            style: GoogleFonts.notoSansSc(
              fontSize: 14
            ),
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (val){
              item.url=val;
              widget.valCallback(item);
            },
          )
        ),
        if(type=='qBittorrent') const SizedBox(height: 10,),
        if(type=='qBittorrent') AddItem(
          label: '用户名', 
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintStyle: GoogleFonts.notoSansSc(
                color: Colors.grey
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            ),
            controller: username,
            style: GoogleFonts.notoSansSc(
              fontSize: 14
            ),
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (val){
              item.username=val;
              widget.valCallback(item);
            },
          )
        ),
        const SizedBox(height: 10,),
        AddItem(
          label: '密码', 
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintStyle: GoogleFonts.notoSansSc(
                color: Colors.grey
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            ),
            obscureText: true,
            controller: password,
            style: GoogleFonts.notoSansSc(
              fontSize: 14
            ),
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (val){
              item.password=val;
              widget.valCallback(item);
            },
          )
        ),
      ],
    );
  }
}