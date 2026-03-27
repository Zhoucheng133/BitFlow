import 'package:bit_flow/types/store_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    switch (type) {
      case StoreType.aria:
        return "Aria";
      case StoreType.qbit:
        return "qBittorrent";
      case StoreType.transmission:
        return "Transmission";
    }
  }

  void toEnumType(String? type){
    switch (type) {
      case "Aria":
        item.type=StoreType.aria;
        break;
      case "qBittorrent":
        item.type=StoreType.qbit;
        return;
      case "Transmission":
        item.type=StoreType.transmission;
        return;
    }
  }

  String linkHintText(){
    switch (item.type) {
      case StoreType.aria:
        return "http(s)://.../jsonrpc";
      case StoreType.qbit:
        return "http(s)://";
      case StoreType.transmission:
        return "http(s)://.../transmission/rpc";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddItem(
          label: 'type'.tr,
          content: Align(
            alignment: Alignment.centerLeft,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                focusColor: Colors.transparent,
                isDense: true,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                borderRadius: BorderRadius.circular(5),
                isExpanded: false,
                value: type,
                items: StoreType.values.map((StoreType type) {
                  final str = convertType(type);
                  return DropdownMenuItem<String>(
                    value: str,
                    child: Text(
                      str,
                      style: TextStyle(
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
          label: 'name'.tr, 
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'pickRandom'.tr,
              hintStyle: TextStyle(
                color: Colors.grey
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            ),
            controller: name,
            style: TextStyle(
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
          label: 'URL'.tr, 
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: linkHintText(),
              hintStyle: TextStyle(
                color: Colors.grey
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            ),
            controller: url,
            style: TextStyle(
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
        if(type=='qBittorrent' || type=='Transmission') const SizedBox(height: 10,),
        if(type=='qBittorrent' || type=='Transmission') AddItem(
          label: 'username'.tr, 
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintStyle: TextStyle(
                color: Colors.grey
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            ),
            controller: username,
            style: TextStyle(
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
          label: 'password'.tr, 
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintStyle: TextStyle(
                color: Colors.grey
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            ),
            obscureText: true,
            controller: password,
            style: TextStyle(
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