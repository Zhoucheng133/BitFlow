import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/getx/theme_get.dart';
import 'package:bit_flow/desktop/main_window.dart';
import 'package:bit_flow/mobile/main_view.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeGet());
  Get.put(StatusGet());
  Get.put(AriaService());
  Get.put(QbitService());
  Get.put(StoreGet());
  final FuncsService funcsService=Get.put(FuncsService());
  if(funcsService.isDesktop()){
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(850, 650),
      minimumSize: Size(850, 650),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
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

class _MainAppState extends State<MainApp> {
  final ThemeGet themeGet=Get.find();
  final FuncsService funcsService=Get.find();

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    themeGet.darkModeHandler(brightness==Brightness.dark);

    return Obx(()=>
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: [
          Locale('zh', 'CN'),
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: themeGet.darkMode.value ? Brightness.dark : Brightness.light
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.notoSansScTextTheme(),
        ),
        home: funcsService.isDesktop() ?  MainWindow() : MainView()
      )
    );
  }
}
