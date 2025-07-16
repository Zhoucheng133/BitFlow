import 'dart:io';

import 'package:bit_flow/components/sidebar/sidebar.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/pages/download.dart';
import 'package:bit_flow/pages/finish.dart';
import 'package:bit_flow/pages/settings.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with WindowListener {
  bool isMax=false;
  final FuncsService funcsService=Get.put(FuncsService());

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_){
      funcsService.init(context);
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

  final StoreGet storeGet=Get.find();
  final StatusGet statusGet=Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Row(
            children: [
              Expanded(child: DragToMoveArea(child: Container())),
              if(Platform.isWindows) Row(
                children: [
                  WindowCaptionButton.minimize(
                    onPressed: windowManager.minimize,
                    brightness: Theme.of(context).brightness==Brightness.dark ? Brightness.dark : Brightness.light,
                  ),
                  isMax ? WindowCaptionButton.unmaximize(
                    onPressed: windowManager.unmaximize,
                    brightness: Theme.of(context).brightness==Brightness.dark ? Brightness.dark : Brightness.light,
                  ) : WindowCaptionButton.maximize(
                    onPressed: windowManager.maximize,
                    brightness: Theme.of(context).brightness==Brightness.dark ? Brightness.dark : Brightness.light,
                  ),
                  WindowCaptionButton.close(
                    onPressed: windowManager.close,
                    brightness: Theme.of(context).brightness==Brightness.dark ? Brightness.dark : Brightness.light,
                  ),
                ]
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
                      color: Theme.of(context).brightness==Brightness.dark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Obx(()=>
                        IndexedStack(
                          index: statusGet.page.value.index,
                          children: [
                            DownloadPage(),
                            FinishPage(),
                            SettingsPage()
                          ],
                        ),
                      )
                    ),
                  ),
                )
              )
            ],
          ),
        ),
        Platform.isMacOS ? PlatformMenuBar(
          menus: [
            PlatformMenu(
              label: "BitFlow", 
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: "关于 BitFlow".tr,
                      onSelected: (){
                        // TODO 显示关于
                      }
                    )
                  ]
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: "设置",
                      shortcut: const SingleActivator(
                        LogicalKeyboardKey.comma,
                        meta: true,
                      ),
                      onSelected: (){
                        // TODO 跳转到设置
                      }
                    ),
                  ]
                ),
                const PlatformMenuItemGroup(
                  members: [
                    PlatformProvidedMenuItem(
                      enabled: true,
                      type: PlatformProvidedMenuItemType.hide,
                    ),
                    PlatformProvidedMenuItem(
                      enabled: true,
                      type: PlatformProvidedMenuItemType.quit,
                    ),
                  ]
                )
              ]
            ),
            PlatformMenu(
              label: "编辑",
              menus: [
                PlatformMenuItem(
                  label: "复制",
                  onSelected: (){
                    final focusedContext = FocusManager.instance.primaryFocus?.context;
                    if (focusedContext != null) {
                      Actions.invoke(focusedContext, CopySelectionTextIntent.copy);
                    }
                  }
                ),
                PlatformMenuItem(
                  label: "粘贴",
                  onSelected: (){
                    final focusedContext = FocusManager.instance.primaryFocus?.context;
                    if (focusedContext != null) {
                      Actions.invoke(focusedContext, const PasteTextIntent(SelectionChangedCause.keyboard));
                    }
                  },
                ),
                PlatformMenuItem(
                  label: "全选",
                  onSelected: (){
                    final focusedContext = FocusManager.instance.primaryFocus?.context;
                    if (focusedContext != null) {
                      Actions.invoke(focusedContext, const SelectAllTextIntent(SelectionChangedCause.keyboard));
                    }
                  }
                )
              ]
            ),
            PlatformMenu(
              label: "窗口", 
              menus: [
                const PlatformMenuItemGroup(
                  members: [
                    PlatformProvidedMenuItem(
                      enabled: true,
                      type: PlatformProvidedMenuItemType.minimizeWindow,
                    ),
                    PlatformProvidedMenuItem(
                      enabled: true,
                      type: PlatformProvidedMenuItemType.toggleFullScreen,
                    )
                  ]
                )
              ]
            )
          ]
        ) : Container()
      ],
    );
  }
}