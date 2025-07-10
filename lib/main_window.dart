import 'dart:io';

import 'package:bit_flow/getx/theme_get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  bool isMax=false;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Row(
            children: [
              Expanded(child: DragToMoveArea(child: Container())),
              if(Platform.isMacOS) Obx(()=>
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
        // TODO
      ],
    );
  }
}