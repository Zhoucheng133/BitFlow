import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeGet extends GetxController{
  RxBool darkMode=false.obs;
  RxBool autoDark=true.obs;

  Color bgColor(BuildContext context){
    return Theme.of(context).colorScheme.surface;
  }

  Color buttonColor(BuildContext context, bool hover, bool selected){
    if(Theme.of(context).brightness==Brightness.light){
      return selected ? Theme.of(context).colorScheme.primary.withAlpha(18) : hover ? Theme.of(context).colorScheme.primary.withAlpha(12) : Theme.of(context).colorScheme.primary.withAlpha(0);
    }else{
      return selected ? Color.fromARGB(255, 60, 60, 60) : hover ? Color.fromARGB(255, 40, 40, 40) : Theme.of(context).colorScheme.surface;
    }
  }

  Color taskItemColor(BuildContext context, bool hover){
    if(Theme.of(context).brightness==Brightness.light){
      return hover ? Theme.of(context).primaryColor.withAlpha(15) : Theme.of(context).primaryColor.withAlpha(0);
    }else{
      return hover ? Color.fromARGB(100, 100, 100, 100) : Color.fromARGB(0, 100, 100, 100);
    }
  }

  void darkModeHandler(bool dark){
    if(autoDark.value){
      darkMode.value=dark;
    }
  }

  void showDarkModeDialog(BuildContext context){
    bool tmpDarkMode=darkMode.value;
    bool tmpAutoDark=autoDark.value;

    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text(
          "深色模式",
          style: GoogleFonts.notoSansSc(
            color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
          ),
        ),
        content: SizedBox(
          width: 200,
          child: Obx(()=>
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        "跟随系统",
                        style: GoogleFonts.notoSansSc(
                          color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
                        ),
                      )
                    ),
                    const SizedBox(width: 10,),
                    Expanded(child: Container(height: 10,)),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        splashRadius: 0,
                        value: autoDark.value, 
                        onChanged: (val) async {
                          autoDark.value=val;
                          if(val){
                            final Brightness brightness = MediaQuery.of(context).platformBrightness;
                            if(brightness == Brightness.dark){
                              darkMode.value=true;
                            }else{
                              darkMode.value=false;
                            }
                          }
                        }
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        "启用深色模式",
                        style: GoogleFonts.notoSansSc(
                          color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
                        ),
                      )
                    ),
                    const SizedBox(width: 10,),
                    Expanded(child: Container(height: 10,)),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        splashRadius: 0,
                        value: darkMode.value, 
                        onChanged: autoDark.value ? null : (val) async {
                          darkMode.value=val;
                        }
                      ),
                    )
                  ],
                ),
              ],
            )
          ),
        ),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              darkMode.value=tmpDarkMode;
              autoDark.value=tmpAutoDark;
            }, 
            child: Text(
              "取消",
              style: GoogleFonts.notoSansSc(
                color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
              ),
            )
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs=await SharedPreferences.getInstance();
              prefs.setBool('darkMode', darkMode.value);
              prefs.setBool('autoDark', autoDark.value);
            }, 
            child: Text(
              "好的",
              style: GoogleFonts.notoSansSc(
                color: Theme.of(context).brightness==Brightness.dark ? Colors.white : Colors.black
              ),
            )
          )
        ],
      )
    );
  }
}