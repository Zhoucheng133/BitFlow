import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> ListView(
        children: [
          ListTile(
            title: const Text('下载服务器'),
            subtitle: storeGet.servers.isEmpty ? Text("/") : Text(storeGet.servers[statusGet.sevrerIndex.value].name),
            onTap: (){},
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