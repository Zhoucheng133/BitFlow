import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/mobile/pages/download_m.dart';
import 'package:bit_flow/mobile/pages/finish_m.dart';
import 'package:bit_flow/mobile/pages/settings_m.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  final StatusGet statusGet=Get.find();
  final FuncsService funcsService=Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      funcsService.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(pageToText(statusGet.page.value)),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          scrolledUnderElevation: 0.0
        ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.download_rounded),
              label: "活跃中",
            ),
            NavigationDestination(
              icon: Icon(Icons.download_done_rounded),
              label: "已完成"
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: "设置"
            )
          ],
          selectedIndex: statusGet.page.value.index,
          onDestinationSelected: (int index){
            statusGet.page.value=Pages.values[index];
          }
        ),
        body: IndexedStack(
          index: statusGet.page.value.index,
          children: [
            DownloadM(),
            FinishM(),
            SettingsM()
          ],
        )
      ),
    );
  }
}