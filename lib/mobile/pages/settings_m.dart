import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/components/settings/setting_components.dart';
import 'package:bit_flow/components/settings/setting_item.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final ThemeGet themeGet=Get.find();
  final FuncsService funcsService=Get.find();
  final SettingComponents settingComponents=SettingComponents();

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
        title: Text(
          'downloadSerevr'.tr,
        ),
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
            child: Text("add".tr)
          ),
          TextButton(
            onPressed: ()=>Navigator.pop(context), 
            child: Text('cancel'.tr)
          ),
          ElevatedButton(
            onPressed: (){
              statusGet.sevrerIndex.value=serverIndex;
              storeGet.setStar(statusGet.sevrerIndex.value);
              Navigator.pop(context);
            }, 
            child: Text('ok'.tr)
          )
        ],
      )
    );

  }

  Future<void> showActiveOrderDialog(BuildContext context) async {
    OrderTypes type=storeGet.defaultActiveOrder.value;
    bool changed=false;
    await showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context)=>AlertDialog(
        title: Text(
          'defaultActiveOrder'.tr,
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropDownContent(
              selected: null,
              selectedIcon: orderToIcon(type), 
              selectedText: orderToString(type), 
              func: (val){
                val=val as OrderTypes;
                setState((){
                  type=val;
                });
              }, 
              list: OrderTypes.values.map((item)=>CustomDropDownItem(orderToString(item), item, orderToIcon(item))).toList(),
              mobile: true,
            );
          }
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context), 
            child: Text("cancel".tr)
          ),
          ElevatedButton(
            onPressed: (){
              changed=true;
              Navigator.pop(context);
            }, 
            child: Text("ok".tr)
          )
        ],
      )
    );
    if(context.mounted && changed){
      storeGet.defaultActiveOrder.value=type;
      prefs.setInt("defaultActiveOrder", type.index);
      showErrWarnDialog(
        context, 
        "defaultOrderChanged".tr, 
        "restartToApply".tr
      );
    }
  }

  Future<void> showFinishOrderDialog(BuildContext context) async {
    bool changed=false;
    OrderTypes type=storeGet.defaultFinishOrder.value;
    await showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context)=>AlertDialog(
        title: Text(
          'defaultFinishedOrder'.tr,
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropDownContent(
              selected: null,
              selectedIcon: orderToIcon(type), 
              selectedText: orderToString(type), 
              func: (val){
                val=val as OrderTypes;
                setState((){
                  type=val;
                });
              },
              list: OrderTypes.values.map((item)=>CustomDropDownItem(orderToString(item), item, orderToIcon(item))).toList(),
              mobile: true,
            );
          }
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context),
            child: Text("cancel".tr)
          ),
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context);
              changed=true;
            }, 
            child: Text("ok".tr)
          )
        ],
      ),
    );
    if(context.mounted && changed){
      storeGet.defaultFinishOrder.value=type;
      prefs.setInt("defaultFinishOrder", type.index);
      showErrWarnDialog(
        context, 
        "defaultOrderChanged".tr, 
        "restartToApply".tr
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> ListView(
        children: [
          ListTile(
            title: Text('downloadSerevr'.tr),
            subtitle: storeGet.servers.isEmpty ? Text("/") : Text(storeGet.servers[statusGet.sevrerIndex.value].name),
            onTap: ()=>showServerDialog(context),
          ),
          ListTile(
            title: Text('updateFrequency'.tr),
            subtitle: Text("${storeGet.freq.value.toString()} ${'ms'.tr}"),
            onTap: () async {
              int oldFreq=storeGet.freq.value;
              await storeGet.showFreqDialog(context);
              if(oldFreq!=storeGet.freq.value){
                funcsService.reLoadService();
                return;
              }
            },
          ),
          ListTile(
            title: Text("defaultActiveOrder".tr),
            subtitle: Text(orderToString(storeGet.defaultActiveOrder.value)),
            onTap: ()=>showActiveOrderDialog(context)
          ),
          ListTile(
            title: Text("defaultFinishedOrder".tr),
            subtitle: Text(orderToString(storeGet.defaultFinishOrder.value)),
            onTap: ()=>showFinishOrderDialog(context),
          ),
          ListTile(
            title: Text("downloaderConfig".tr),
            subtitle: Text("${'config'.tr} ${ storeGet.servers.isEmpty ? "" : storeGet.servers[statusGet.sevrerIndex.value].type==StoreType.aria?'Aria':'qBittorrent'}"),
            onTap: ()=>settingComponents.downloaderConfig(context),
          ),
          ListTile(
            title: Text('downloaderURL'.tr),
            subtitle: Text(
              storeGet.servers.isEmpty ? "" : storeGet.servers[statusGet.sevrerIndex.value].url,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              await FlutterClipboard.copy(storeGet.servers[statusGet.sevrerIndex.value].url);
              
            },
          ),
          ListTile(
            title: Text('darkMode'.tr),
            subtitle: Text(themeGet.autoDark.value ? "auto".tr : themeGet.darkMode.value ? "dark".tr : "light".tr),
            onTap: ()=>themeGet.showDarkModeDialog(context),
          ),
          ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('language'.tr),
                const SizedBox(width: 10,),
                FaIcon(
                  FontAwesomeIcons.globe,
                  size: 14,
                )
              ],
            ),
            subtitle: Text(statusGet.lang.value.name),
            onTap: ()=>languageDialog(context),
          ),
          ListTile(
            title: Text('clearConfig'.tr),
            subtitle: Text('initialize'.tr),
            onTap: () async {
              final ok=await showConfirmDialog(context, "clearConfig".tr, "clearConfigContent".tr);
              if(ok){
                final prefs=await SharedPreferences.getInstance();
                prefs.clear();
              }
            },
          ),
          ListTile(
            title: Text('${"about".tr} BitFlow'),
            subtitle: Text(version),
            onTap: () => showAbout(context),
          )
        ],
      ),
    );
  }
}