import 'package:bit_flow/getx/status_get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showErrWarnDialog(BuildContext context, String title, String content, {String okText=""}) async {
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(
        title,
      ),
      content: Text(
        content,
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context), 
          child: Text(okText.isEmpty ? "ok".tr : okText)
        )
      ],
    )
  );
}

Future<bool> showConfirmDialog(BuildContext context, String title, String content, {String okText=""}) async {
  bool ok=false;
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: Text("cancel".tr)
        ),
        ElevatedButton(
          onPressed: (){
            ok=true;
            Navigator.pop(context);
          }, 
          child: Text(okText.isEmpty ? "ok".tr : okText)
        )
      ],
    )
  );
  return ok;
}

Future<void> showAbout(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  if(context.mounted){
    showDialog(
      context: context, 
      builder: (BuildContext context)=>AlertDialog(
        title: Text('about'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon.png',
              width: 100,
            ),
            const SizedBox(height: 10,),
            Text(
              'BitFlow',
              style: GoogleFonts.notoSansSc(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 3,),
            Text(
              'v${packageInfo.version}',
              style: GoogleFonts.notoSansSc(
                fontSize: 13,
                color: Colors.grey[400]
              ),
            ),
            const SizedBox(height: 20,),
            GestureDetector(
              onTap: (){
                final url=Uri.parse('https://github.com/Zhoucheng133/bitflow');
                launchUrl(url);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.github,
                      size: 15,
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'projUrl'.tr,
                        style: GoogleFonts.notoSansSc(
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: ()=>showLicensePage(
                applicationName: 'BitFlow',
                applicationVersion: 'v${packageInfo.version}',
                context: context
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.certificate,
                      size: 15,
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        "license".tr,
                        style: GoogleFonts.notoSansSc(
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            child: Text('ok'.tr)
          )
        ],
      ),
    );
  }
}

Future<int> freqDialogContent(BuildContext context, int storeFreq) async {
  int freq=storeFreq;
  
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text("updateFrequency".tr),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState)=>SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("recommendFreq".tr),
              const SizedBox(height: 10,),
              Text("$freq ${'ms'.tr} / ${freq/1000} ${'s'.tr}"),
              const SizedBox(height: 5,),
              SliderTheme(
                data: SliderThemeData(
                  overlayColor: Colors.transparent
                ),
                child: Slider(
                  value: freq.toDouble(), 
                  min: 500,
                  max: 10000,
                  divisions: 19,
                  onChanged: (double val){
                    setState((){
                      freq=val.round();
                    });
                  }
                ),
              )
            ],
          ),
        )
      ),
      actions: [
        TextButton(
          onPressed: (){
            freq=storeFreq;
            Navigator.pop(context);
          }, 
          child: Text('cancel'.tr)
        ),
        ElevatedButton(
          onPressed: ()=>Navigator.pop(context), 
          child: Text('ok'.tr)
        )
      ],
    )
  );

  return freq;
}

void languageDialog(BuildContext context){

  final statusGet=Get.find<StatusGet>();

  showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text("language".tr),
      content: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          value: statusGet.lang.value.name,
          items: supportedLocales.map((item)=>DropdownMenuItem<String>(
            value: item.name,
            child: Text(
              item.name
            ),
          )).toList(),
          onChanged: (val){
            final index=supportedLocales.indexWhere((element) => element.name==val);
            statusGet.changeLanguage(index);
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text('ok'.tr),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}