import 'package:bit_flow/types/types.dart';
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
          child: Text(widget.label)
        ),
        const SizedBox(width: 15,),
        Expanded(child: widget.content)
      ],
    );
  }
}

class AddStore extends StatefulWidget {
  const AddStore({super.key});

  @override
  State<AddStore> createState() => _AddStoreState();
}

class _AddStoreState extends State<AddStore> {

  String type="Aria";
    TextEditingController url=TextEditingController();
    TextEditingController username=TextEditingController();
    TextEditingController password=TextEditingController();

    String convertType(StoreType type){
      if(type==StoreType.aria){
        return "Aria";
      }else if(type==StoreType.qbit){
        return "qBittorrent";
      }
      return "";
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
                },
              ),
            ),
          ),
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
          )
        ),
      ],
    );
  }
}