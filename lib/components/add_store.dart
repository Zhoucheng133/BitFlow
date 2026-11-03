import 'package:bit_flow/service/funcs.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddItem extends StatefulWidget {

  final String label;
  final Widget content;
  final bool horizontal;

  const AddItem({super.key, required this.label, required this.content, this.horizontal=true});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  @override
  Widget build(BuildContext context) {
    return widget.horizontal ? Row(
      spacing: 15,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            widget.label,
          )
        ),
        Expanded(child: widget.content)
      ],
    ) : Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      spacing: 10,
      children: [
        Text(
          widget.label,
        ),
        widget.content
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
  TextEditingController path=TextEditingController(text: "/jsonrpc");

  StoreItem item=StoreItem("", StoreType.aria, "", "", "");

  @override
  void initState() {
    super.initState();
    updateItem();
  }

  void updateItem(){
    String baseUrl=url.text.trim();
    String pathVal=path.text.trim();
    if(type=='Aria' || type=='Transmission'){
      if(baseUrl.isEmpty){
        item.url="";
      }else{
        if(!pathVal.startsWith('/')){
          pathVal='/$pathVal';
        }
        if(baseUrl.endsWith('/')){
          baseUrl=baseUrl.substring(0, baseUrl.length - 1);
        }
        item.url=baseUrl + pathVal;
      }
    }else{
      item.url=baseUrl;
    }
    item.name=name.text;
    item.password=password.text;
    item.username=username.text;
    toEnumType(type);
    widget.valCallback(item);
  }

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                      if(type=='Aria'){
                        path.text='/jsonrpc';
                      }else if(type=='Transmission'){
                        path.text='/transmission/rpc';
                      }else{
                        path.text='';
                      }
                    });
                    toEnumType(val);
                    updateItem();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          AddItem(
            horizontal: isDesktop(),
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
                updateItem();
              },
            )
          ),
          const SizedBox(height: 10,),
          AddItem(
            label: 'URL'.tr, 
            horizontal: isDesktop(),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "http(s)://...",
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
                    updateItem();
                  },
                ),
                if(type=='Aria' || type=='Transmission') ...[
                  const SizedBox(height: 5),
                  Text(
                    'pathTip'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            )
          ),
          if(type=='qBittorrent' || type=='Transmission') const SizedBox(height: 10,),
          if(type=='qBittorrent' || type=='Transmission') AddItem(
            horizontal: isDesktop(),
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
                updateItem();
              },
            )
          ),
          const SizedBox(height: 10,),
          AddItem(
            label: 'password'.tr, 
            horizontal: isDesktop(),
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
                updateItem();
              },
            )
          ),
          if(type=='Aria' || type=='Transmission') const SizedBox(height: 10,),
          if(type=='Aria' || type=='Transmission') Card(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            child: ExpansionTile(
              title: Text(
                'advancedSettings'.tr,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              initiallyExpanded: false,
              tilePadding: .symmetric(horizontal: 10.0),
              childrenPadding: .all(10.0),
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              collapsedShape: RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              children: [
                const SizedBox(height: 10,),
                AddItem(
                  horizontal: isDesktop(),
                  label: 'path'.tr, 
                  content: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(
                        color: Colors.grey
                      ),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                    ),
                    controller: path,
                    style: TextStyle(
                      fontSize: 14
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (val){
                      updateItem();
                    },
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}