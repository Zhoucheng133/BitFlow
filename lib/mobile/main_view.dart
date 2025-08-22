import 'package:bit_flow/components/header/active_buttons.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/mobile/pages/download_m.dart';
import 'package:bit_flow/mobile/pages/finish_m.dart';
import 'package:bit_flow/mobile/pages/settings_m.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  final StatusGet statusGet=Get.find();
  final FuncsService funcsService=Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      funcsService.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(pageToText(statusGet.page.value)),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          scrolledUnderElevation: 0.0,
          actions: [
            if(statusGet.selectMode.value) TextButton(
              onPressed: (){
                statusGet.selectMode.value=false;
                statusGet.selectList.value=[];
              }, 
              child: const Text('取消')
            ),
          ],
        ),
        bottomNavigationBar: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: statusGet.selectMode.value ? BottomAppBar(
            key: Key('selectMode'),
            child: Row(
              children: [
                IconButton(
                  onPressed: (){
                    if(statusGet.page.value==Pages.active){
                      if(statusGet.selectList.length == statusGet.activeTasks.length){
                        statusGet.selectList.value=[];
                        return;
                      }
                      statusGet.selectList.value=statusGet.activeTasks;
                    }else{
                      if(statusGet.selectList.length == statusGet.finishedTask.length){
                        statusGet.selectList.value=[];
                        return;
                      }
                      statusGet.selectList.value=statusGet.finishedTask;
                    }
                  }, 
                  icon: Icon(
                    Icons.checklist_rounded,
                    size: 25,
                  )
                ),
                Expanded(child: Container()),
                if(statusGet.page.value==Pages.active) IconButton(
                  onPressed: statusGet.selectList.isEmpty ? null : (){
                    funcsService.multiPause(context);
                  }, 
                  icon: Icon(
                    Icons.pause_rounded,
                    size: 25,
                  )
                ),
                if(statusGet.page.value==Pages.active) const SizedBox(width: 10,),
                if(statusGet.page.value==Pages.active) IconButton(
                  onPressed: statusGet.selectList.isEmpty ? null : (){
                    funcsService.multiContinue(context);
                  }, 
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    size: 25,
                  )
                ),
                const SizedBox(width: 10,),
                IconButton(
                  onPressed: statusGet.selectList.isEmpty ? null : (){
                    funcsService.delSelected(context, statusGet.page.value);
                  }, 
                  icon: Icon(
                    Icons.delete_rounded,
                    size: 25,
                  )
                ),
                if(statusGet.page.value==Pages.finish) const SizedBox(width: 10,),
                if(statusGet.page.value==Pages.finish)  IconButton(
                  onPressed: statusGet.selectList.isEmpty ? null : (){
                    funcsService.reDownloadSelected(context);
                  }, 
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 25,
                  )
                ),
              ],
            ),
          ) : NavigationBar(
            key: Key("default"),
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
        ),
        body: IndexedStack(
          index: statusGet.page.value.index,
          children: [
            DownloadM(),
            FinishM(),
            SettingsM()
          ],
        ),
        floatingActionButton: statusGet.page.value==Pages.active ? FloatingActionButton(
          onPressed: ()=>addTaskDialogM(context),
          child: Center(
            child: Icon(Icons.add_rounded),
          ),
        ) : null,
      ),
    );
  }
}