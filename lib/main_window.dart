import 'dart:io';

import 'package:bit_flow/components/sidebar.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/service/init.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with WindowListener {
  bool isMax=false;
  final InitServivce initServivce=InitServivce();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_){
      initServivce.init(context);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    setState(() {
      isMax=true;
    });
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    setState(() {
      isMax=false;
    });
  }

  final ThemeGet themeGet=Get.find();
  final StoreGet storeGet=Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Row(
            children: [
              Expanded(child: DragToMoveArea(child: Container())),
              if(Platform.isWindows) Obx(()=>
                Row(
                  children: [
                    WindowCaptionButton.minimize(
                      onPressed: windowManager.minimize,
                      brightness: themeGet.darkMode.value ? Brightness.dark : Brightness.light,
                    ),
                    isMax ? WindowCaptionButton.unmaximize(
                      onPressed: windowManager.unmaximize,
                      brightness: themeGet.darkMode.value ? Brightness.dark : Brightness.light,
                    ) : WindowCaptionButton.maximize(
                      onPressed: windowManager.maximize,
                      brightness: themeGet.darkMode.value ? Brightness.dark : Brightness.light,
                    ),
                    WindowCaptionButton.close(
                      onPressed: windowManager.close,
                      brightness: themeGet.darkMode.value ? Brightness.dark : Brightness.light,
                    ),
                  ]
                )
              )
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: Sidebar(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 10, top: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                )
              )
            ],
          ),
        )
      ],
    );
  }
}