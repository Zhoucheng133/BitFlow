import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  final StatusGet statusGet=Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Scaffold(
        appBar: AppBar(
          title: Text(pageToText(statusGet.page.value)),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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
        body: Center(
          child: Text("Hello World!!!"),
        ),
      ),
    );
  }
}