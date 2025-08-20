import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsM extends StatefulWidget {
  const SettingsM({super.key});

  @override
  State<SettingsM> createState() => _SettingsMState();
}

class _SettingsMState extends State<SettingsM> {

  final StatusGet statusGet=Get.find();
  final StoreGet storeGet=Get.find();

  String version="";

  late SharedPreferences prefs;

  Future<void> init() async {
    prefs=await SharedPreferences.getInstance();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version="v${packageInfo.version}";
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> showServerDialog(BuildContext context) async {
    int serverIndex=statusGet.sevrerIndex.value;
    int starIndex=storeGet.starIndex.value;
    await showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: const Text('下载服务器'),
        content: StatefulBuilder(
          builder: (context, setState)=>DropdownButtonHideUnderline(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton2<String>(
                  buttonStyleData: ButtonStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5)
                    )
                  ),
                  dropdownStyleData: DropdownStyleData(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.surface
                    )
                  ),
                  isExpanded: true,
                  value: storeGet.servers[serverIndex].name,
                  items: storeGet.servers.map((StoreItem item) {
                    final name=item.name;
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(
                        name,
                        style: GoogleFonts.notoSansSc(
                          fontSize: 14,
                          color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val){
                    // int index=storeGet.servers.indexWhere((item)=>item.name==val);
                    // statusGet.sevrerIndex.value=index;
                    int index=storeGet.servers.indexWhere((item)=>item.name==val);
                    setState((){
                      serverIndex=index;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: (){
                        if(starIndex!=serverIndex){
                          setState((){
                            starIndex=serverIndex;
                          });
                        }
                      }, 
                      icon: Icon(
                        Icons.star_rounded,
                        color: starIndex==serverIndex ? Colors.orange : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: storeGet.servers.length==1 ? null : (){
                        storeGet.delStore(context, statusGet.sevrerIndex.value);
                      }, 
                      icon: Icon(
                        Icons.delete_rounded,
                        size: 18,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              storeGet.addStore(context);
            }, 
            child: const Text("添加")
          ),
          TextButton(
            onPressed: ()=>Navigator.pop(context), 
            child: const Text('取消')
          ),
          ElevatedButton(
            onPressed: (){
              statusGet.sevrerIndex.value=serverIndex;
              storeGet.setStar(statusGet.sevrerIndex.value);
              Navigator.pop(context);
            }, 
            child: const Text('完成')
          )
        ],
      )
    );

  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> ListView(
        children: [
          ListTile(
            title: const Text('下载服务器'),
            subtitle: storeGet.servers.isEmpty ? Text("/") : Text(storeGet.servers[statusGet.sevrerIndex.value].name),
            onTap: ()=>showServerDialog(context),
          ),
          ListTile(
            title: const Text('清除所有配置文件'),
            subtitle: const Text('开发使用'),
            onTap: () async {
              final ok=await showConfirmDialog(context, "确定要清除所有用户配置文件吗", "这是一个开发用的功能!");
              if(ok){
                final prefs=await SharedPreferences.getInstance();
                prefs.clear();
              }
            },
          ),
          ListTile(
            title: const Text('关于 BitFlow'),
            subtitle: Text(version),
            onTap: () => showAbout(context),
          )
        ],
      ),
    );
  }
}