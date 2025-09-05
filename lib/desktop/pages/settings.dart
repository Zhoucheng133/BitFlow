import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/components/header/header.dart';
import 'package:bit_flow/components/settings/setting_components.dart';
import 'package:bit_flow/components/settings/setting_item.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String version="";
  final StoreGet storeGet=Get.find();
  final FuncsService funcsService=Get.find();
  final StatusGet statusGet=Get.find();
  final ThemeGet themeGet=Get.find();
  final SettingComponents settingComponents=SettingComponents();

  late SharedPreferences prefs;

  Future<void> init() async {
    // 初始化prefs
    prefs=await SharedPreferences.getInstance();

    // 获取版本号
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

  bool hoverVersion=false;
  bool hoverFreq=false;
  bool hoverConfig=false;
  bool hoverDark=false;
  bool hoverUrl=false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(name: '设置', page: Pages.settings,),
        Expanded(
          child: ListView(
            children: [
              SettingItem(
                label: '更新频率', 
                child: GestureDetector(
                  onTap: () async {
                    int oldFreq=storeGet.freq.value;
                    await storeGet.showFreqDialog(context);
                    if(oldFreq!=storeGet.freq.value){
                      funcsService.reLoadService();
                      return;
                    }
                  },
                  child: MouseRegion(
                    onEnter: (_)=>setState(() {
                      hoverFreq=true;
                    }),
                    onExit: (_)=>setState(() {
                      hoverFreq=false;
                    }),
                    cursor: SystemMouseCursors.click,
                    child: AnimatedDefaultTextStyle(
                      style: GoogleFonts.notoSansSc(
                        color: hoverFreq ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withAlpha(180)
                      ), 
                      duration: const Duration(milliseconds: 200),
                      child: Obx(()=> Text("${storeGet.freq.value.toString()} 毫秒"))
                    ),
                  ),
                )
              ),
              Obx(()=>
                SettingDropDownItem(
                  label: "默认活跃任务顺序", 
                  selectedIcon: orderToIcon(storeGet.defaultActiveOrder.value), 
                  selectedText: orderToString(storeGet.defaultActiveOrder.value), 
                  func: (val){
                    val=val as OrderTypes;
                    storeGet.defaultActiveOrder.value=val;
                    prefs.setInt("defaultActiveOrder", val.index);
                  }, 
                  list: OrderTypes.values.map((item)=>CustomDropDownItem(orderToString(item), item, orderToIcon(item))).toList()
                ),
              ),
              Obx(()=>
                SettingDropDownItem(
                  label: "默认已完成任务顺序", 
                  selectedIcon: orderToIcon(storeGet.defaultFinishOrder.value), 
                  selectedText: orderToString(storeGet.defaultFinishOrder.value), 
                  func: (val){
                    val=val as OrderTypes;
                    storeGet.defaultFinishOrder.value=val;
                    prefs.setInt("defaultFinishOrder", val.index);
                  }, 
                  list: OrderTypes.values.map((item)=>CustomDropDownItem(orderToString(item), item, orderToIcon(item))).toList()
                ),
              ),
              Obx(()=>
                SettingItem(
                  label: "下载器地址", 
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_)=>setState(() {
                      hoverUrl=true;
                    }),
                    onExit: (_)=>setState(() {
                      hoverUrl=false;
                    }),
                    child: GestureDetector(
                      onTap: () async {
                        await FlutterClipboard.copy(storeGet.servers[statusGet.sevrerIndex.value].url);
                      },
                      child: Tooltip(
                        message: storeGet.servers.isEmpty ? "" : "${storeGet.servers[statusGet.sevrerIndex.value].url}\n点击复制",
                        child: AnimatedDefaultTextStyle(
                          style: GoogleFonts.notoSansSc(
                            color: hoverUrl ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withAlpha(180)
                          ),
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            storeGet.servers.isEmpty ? "" : storeGet.servers[statusGet.sevrerIndex.value].url,
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                      ),
                    ),
                  )
                )
              ),
              SettingItem(
                label: "下载器配置", 
                child: GestureDetector(
                  onTap: ()=>settingComponents.downloaderConfig(context),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_)=>setState(() {
                      hoverConfig=true;
                    }),
                    onExit: (_)=>setState(() {
                      hoverConfig=false;
                    }),
                    child: AnimatedDefaultTextStyle(
                      style: GoogleFonts.notoSansSc(
                        color: hoverConfig ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withAlpha(180)
                      ), 
                      duration: const Duration(milliseconds: 200),
                      child: Obx(() => Text("配置${ storeGet.servers.isEmpty ? "" : storeGet.servers[statusGet.sevrerIndex.value].type==StoreType.aria?'Aria':'qBittorrent'}"))
                    ),
                  ),
                )
              ),
              SettingItem(
                label: "深色模式", 
                child: GestureDetector(
                  onTap: ()=>themeGet.showDarkModeDialog(context),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_)=>setState(() {
                      hoverDark=true;
                    }),
                    onExit: (_)=>setState(() {
                      hoverDark=false;
                    }),
                    child: AnimatedDefaultTextStyle(
                      style: GoogleFonts.notoSansSc(
                        color: hoverDark ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withAlpha(180)
                      ), 
                      duration: const Duration(milliseconds: 200),
                      child: Obx(() => Text(themeGet.autoDark.value ? "自动" : themeGet.darkMode.value ? "深色" : "浅色"))
                    ),
                  ),
                )
              ),
              SettingItem(
                label: "关于 BitFlow",
                showDivider: false, 
                child: GestureDetector(
                  onTap: ()=>showAbout(context),
                  child: MouseRegion(
                    onEnter: (_)=>setState(() {
                      hoverVersion=true;
                    }),
                    onExit: (_)=>setState(() {
                      hoverVersion=false;
                    }),
                    cursor: SystemMouseCursors.click,
                    // child: Text(version)
                    child: AnimatedDefaultTextStyle(
                      style: GoogleFonts.notoSansSc(
                        color: hoverVersion ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withAlpha(180)
                      ), 
                      duration: const Duration(milliseconds: 200),
                      child: Text(version)
                    ),
                  )
                ),
              ),
            ],
          )
        )
      ],
    );
  }
}