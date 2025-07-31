import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showErrWarnDialog(BuildContext context, String title, String content, {String okText="好的"}) async {
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(
        title,
        style: GoogleFonts.notoSansSc(
          color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
        ),
      ),
      content: Text(
        content,
        style: GoogleFonts.notoSansSc(
          color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context), 
          child: Text(okText)
        )
      ],
    )
  );
}

Future<bool> showConfirmDialog(BuildContext context, String title, String content, {String okText="好的"}) async {
  bool ok=false;
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(
        title,
        style: GoogleFonts.notoSansSc(
          color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
        ),
      ),
      content: Text(
        content,
        style: GoogleFonts.notoSansSc(
          color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("取消")
        ),
        ElevatedButton(
          onPressed: (){
            ok=true;
            Navigator.pop(context);
          }, 
          child: Text(okText)
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
        title: Text(
          '关于',
          style: GoogleFonts.notoSansSc(
            color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
          ),
        ),
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
                color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
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
                        '项目地址',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 13,
                          color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
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
                        "许可证",
                        style: GoogleFonts.notoSansSc(
                          fontSize: 13,
                          color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
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
            child: Text('好的')
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
        title: Text(
          "设置更新频率",
          style: GoogleFonts.notoSansSc(
            color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
          ),
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState)=>SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "注意，推荐最小更新时间为1.5s (1500毫秒)\n更新频率过高在一些下载服务器中可能会触发缓存机制",
                  style: GoogleFonts.notoSansSc(
                    color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
                  ),
                ),
                const SizedBox(height: 10,),
                Text("$freq 毫秒 / ${freq/1000} 秒"),
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
            child: const Text('取消')
          ),
          ElevatedButton(
            onPressed: ()=>Navigator.pop(context), 
            child: const Text('完成')
          )
        ],
      )
    );

    return freq;
  }