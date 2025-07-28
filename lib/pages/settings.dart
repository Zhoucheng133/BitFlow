import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/components/header/header.dart';
import 'package:bit_flow/components/settings/setting_item.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String version="";

  Future<void> initVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version="v${packageInfo.version}";
    });
  }

  @override
  void initState() {
    super.initState();
    initVersion();
  }

  bool hoverVersion=false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(name: '设置', page: Pages.settings,),
        Expanded(
          child: ListView(
            children: [
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
              )
            ],
          )
        )
      ],
    );
  }
}