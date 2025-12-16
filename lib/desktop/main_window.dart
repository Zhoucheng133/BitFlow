import 'dart:io';

import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/components/header/active_buttons.dart';
import 'package:bit_flow/components/sidebar/sidebar.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/desktop/pages/download.dart';
import 'package:bit_flow/desktop/pages/finish.dart';
import 'package:bit_flow/desktop/pages/settings.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with WindowListener {
  bool isMax=false;
  final FuncsService funcsService=Get.find();

  Future<void> initHotKey(BuildContext context) async {
    HotKey hotKey = HotKey(
      key: PhysicalKeyboardKey.keyN,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) => addTaskDialog(context)
    );
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_){
      funcsService.init(context);
      if(Platform.isWindows){
        initHotKey(context);
      }
    });
  }

  Future<void> disposeHotKey() async {
    await hotKeyManager.unregisterAll();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    if(Platform.isWindows){
      disposeHotKey();
    }
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
    return Scaffold(
      body: Column(
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
                        label: "${'about'.tr} BitFlow",
                        onSelected: ()=>showAbout(context)
                      )
                    ]
                  ),
                  PlatformMenuItemGroup(
                    members: [
                      PlatformMenuItem(
                        label: "settings".tr,
                        shortcut: const SingleActivator(
                          LogicalKeyboardKey.comma,
                          meta: true,
                        ),
                        onSelected: (){
                          statusGet.page.value=Pages.settings;
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
                label: 'task'.tr, 
                menus: [
                  PlatformMenuItem(
                    label: 'addTask'.tr,
                    onSelected: ()=>addTaskDialog(context),
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.keyN,
                      meta: true,
                    ),
                  ),
                  PlatformMenuItem(
                    label: 'ok'.tr,
                    onSelected: (){},
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.enter,
                    ),
                  ),
                ]
              ),
              PlatformMenu(
                label: 'pages'.tr,
                menus: [
                  PlatformMenuItem(
                    label: 'active'.tr,
                    onSelected: ()=>statusGet.page.value=Pages.active,
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.digit1,
                      meta: true,
                    ),
                  ),
                  PlatformMenuItem(
                    label: 'finished'.tr,
                    onSelected: ()=>statusGet.page.value=Pages.finish,
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.digit2,
                      meta: true,
                    ),
                  )
                ]
              ),
              PlatformMenu(
                label: "edit".tr,
                menus: [
                  PlatformMenuItem(
                    label: "copy".tr,
                    onSelected: (){
                      final focusedContext = FocusManager.instance.primaryFocus?.context;
                      if (focusedContext != null) {
                        Actions.invoke(focusedContext, CopySelectionTextIntent.copy);
                      }
                    }
                  ),
                  PlatformMenuItem(
                    label: "paste".tr,
                    onSelected: (){
                      final focusedContext = FocusManager.instance.primaryFocus?.context;
                      if (focusedContext != null) {
                        Actions.invoke(focusedContext, const PasteTextIntent(SelectionChangedCause.keyboard));
                      }
                    },
                  ),
                  PlatformMenuItem(
                    label: "selectAll".tr,
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
                label: "window".tr, 
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
      ),
    );
  }
}