import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/desktop/main_window.dart';
import 'package:bit_flow/lang/en_us.dart';
import 'package:bit_flow/lang/zh_cn.dart';
import 'package:bit_flow/lang/zh_tw.dart';
import 'package:bit_flow/mobile/main_view.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeGet());
  final status=Get.put(StatusGet());
  Get.put(AriaService());
  Get.put(QbitService());
  Get.put(StoreGet());
  final FuncsService funcsService=Get.put(FuncsService());
  await status.initLang();
  if(funcsService.isDesktop()){
    await windowManager.ensureInitialized();
    await hotKeyManager.unregisterAll();
    WindowOptions windowOptions = WindowOptions(
      size: Size(850, 650),
      minimumSize: Size(850, 650),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: "BitFlow"
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }else{
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,     // 顶部朝上
      DeviceOrientation.portraitDown,   // 顶部朝下
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class MainTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'zh_CN': zhCN,
    'zh_TW': zhTW
  };
}

class _MainAppState extends State<MainApp> {
  final ThemeGet themeGet=Get.find();
  final FuncsService funcsService=Get.find();
  final StatusGet statusGet=Get.find();

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    themeGet.darkModeHandler(brightness==Brightness.dark);

    return Obx(
      ()=> GetMaterialApp(
        translations: MainTranslations(), 
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        locale: statusGet.lang.value.locale, 
        supportedLocales: supportedLocales.map((item)=>item.locale).toList(),
        theme: ThemeData(
          brightness: themeGet.darkMode.value ? Brightness.dark : Brightness.light,
          fontFamily: 'Noto', 
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: themeGet.darkMode.value ? Brightness.dark : Brightness.light,
          ),
          textTheme: themeGet.darkMode.value ? ThemeData.dark().textTheme.apply(
            fontFamily: 'Noto',
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ) : ThemeData.light().textTheme.apply(
            fontFamily: 'Noto',
          ),
        ),
        home: funcsService.isDesktop() ?  MainWindow() : MainView()
      ),
    );
  }
}
