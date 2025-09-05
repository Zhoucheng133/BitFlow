import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ConfigItem extends StatefulWidget {

  final String label;
  final Widget child;

  const ConfigItem({super.key, required this.label, required this.child});

  @override
  State<ConfigItem> createState() => _ConfigItemState();
}

class _ConfigItemState extends State<ConfigItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.label)
            )
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: widget.child
            )
          )
        ],
      ),
    );
  }
}

class ConfigItemWithTextField extends StatefulWidget {

  final String label;
  final TextEditingController controller;
  final bool useDouble;
  final bool useInt;
  final bool multiLine;

  const ConfigItemWithTextField({super.key, required this.label, required this.controller, this.useDouble=false, this.useInt=false, this.multiLine=false});

  @override
  State<ConfigItemWithTextField> createState() => _ConfigItemWithTextFieldState();
}

class _ConfigItemWithTextFieldState extends State<ConfigItemWithTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.label,
              )
            )
          ),
          const SizedBox(width: 18,),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                inputFormatters: widget.useInt ? [
                  FilteringTextInputFormatter.digitsOnly,
                ] : widget.useDouble ? [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,}$')),
                ] : [],
                controller: widget.controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                ),
                maxLines: widget.multiLine ? 3 : 1,
              )
            )
          )
        ],
      ),
    );
  }
}

class SettingComponents {
  final StoreGet storeGet=Get.find();
  final StatusGet statusGet=Get.find();
  final AriaService ariaService=Get.find();
  final QbitService qbitService=Get.find();
  
  Future<void> ariaConfig(BuildContext context) async {
    final AriaConfig? config=await ariaService.getGlobalSettings(storeGet.servers[statusGet.sevrerIndex.value]);
    if(config==null){
      return;
    }

    // 允许覆盖【allow-overwrite】
    bool allowOverwrite=config.allowOverwrite;
    // 下载位置【dir】
    TextEditingController dir=TextEditingController(text: config.dir);
    // 最多同时下载个数【max-concurrent-downloads】
    TextEditingController maxDownloads=TextEditingController(text: config.maxDownloads.toString());
    // 做种时间【seed-time】
    TextEditingController seedTime=TextEditingController(text: config.seedTime.toString());
    // 下载限制【max-overall-download-limit】
    TextEditingController downloadLimit=TextEditingController(text: config.downloadLimit.toString());
    // 上传限制【max-overall-upload-limit】
    TextEditingController uploadLimit=TextEditingController(text: config.uploadLimit.toString());
    // 用户代理【user-agent】
    TextEditingController userAgent=TextEditingController(text: config.userAgent);
    // 做种比率【seed-ratio】
    TextEditingController seedRatio=TextEditingController(text: config.seedRatio.toString());

    if(context.mounted){
      showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: Text(
            '配置Aria',
          ),
          content: SizedBox(
            width: 350,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState)=>Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "速度和大小单位为Byte(/s)",
                          ),
                        ),
                        ConfigItem(
                          label: "允许下载覆盖", 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              splashRadius: 0,
                              value: allowOverwrite, 
                              onChanged: (bool val){
                                setState((){
                                  allowOverwrite=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItemWithTextField(
                          label: "下载位置", 
                          controller: dir,
                        ),
                        ConfigItemWithTextField(
                          label: "同时下载个数", 
                          controller: maxDownloads,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "做种时间", 
                          controller: seedTime,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "下载速度限制", 
                          controller: downloadLimit,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "上传速度限制", 
                          controller: uploadLimit,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "做种比率", 
                          controller: seedRatio,
                          useDouble: true,
                        ),
                        ConfigItemWithTextField(
                          label: "用户代理", 
                          controller: userAgent,
                          multiLine: true,
                        ),
                      ],
                    )
                  ),
                ],
              )
            ),
          ),
          actions: [
            TextButton(
              onPressed: ()=>Navigator.pop(context), 
              child: const Text("取消"),
            ),
            ElevatedButton(
              onPressed: (){
                ariaService.changeGlobalSettings(storeGet.servers[statusGet.sevrerIndex.value], {
                  "allow-overwrite": allowOverwrite.toString(),
                  "dir": dir.text,
                  "max-concurrent-downloads": maxDownloads.text,
                  "seed-time": seedTime.text,
                  "max-overall-download-limit": downloadLimit.text,
                  "max-overall-upload-limit": uploadLimit.text,
                  "user-agent": userAgent.text
                });
                Navigator.pop(context);
              },
              child: const Text('完成')
            )
          ],
        )
      );
    }
  }

  Future<void> qbitConfig(BuildContext context) async {
    final QbitConfig config=await qbitService.getConfig(storeGet.servers[statusGet.sevrerIndex.value]);

    // 下载位置【dir】
    TextEditingController savePath=TextEditingController(text: config.savePath);
    // 最多同时下载个数【max-concurrent-downloads】
    TextEditingController maxDownloadCount=TextEditingController(text: config.maxDownloadCount.toString());
    // 做种时间【seed-time】
    bool seedTimeEnable=config.seedTimeEnable;
    TextEditingController seedTime=TextEditingController(text: config.seedTime.toString());
    // 下载限制【max-overall-download-limit】
    TextEditingController downloadLimit=TextEditingController(text: config.downloadLimit.toString());
    // 上传限制【max-overall-upload-limit】
    TextEditingController uploadLimit=TextEditingController(text: config.uploadLimit.toString());
    // 做种比率【seed-ratio】
    bool ratioEnable=config.ratioEnable;
    TextEditingController seedRatio=TextEditingController(text: config.seedRatio.toString());

    if(context.mounted){
      await showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: Text(
            "配置qBittorrent",
          ),
          content: SizedBox(
            width: 350,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState)=>Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "速度和大小单位为Byte(/s)",
                          ),
                        ),
                        ConfigItemWithTextField(
                          label: "下载位置", 
                          controller: savePath,
                        ),
                        ConfigItemWithTextField(
                          label: "同时下载个数", 
                          controller: maxDownloadCount,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "启用做种时间", 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              splashRadius: 0,
                              value: seedTimeEnable, 
                              onChanged: (bool val){
                                setState((){
                                  seedTimeEnable=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItemWithTextField(
                          label: "做种时间", 
                          controller: seedTime,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "启用做种比率", 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              splashRadius: 0,
                              value: ratioEnable, 
                              onChanged: (bool val){
                                setState((){
                                  ratioEnable=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItemWithTextField(
                          label: "做种比率", 
                          controller: seedRatio,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "下载速度限制", 
                          controller: downloadLimit,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "上传速度限制", 
                          controller: uploadLimit,
                          useInt: true,
                        ),
                      ],
                    )
                  ),
                ],
              )
            ),
          ),
          actions: [
            TextButton(
              onPressed: ()=>Navigator.pop(context), 
              child: const Text('取消')
            ),
            ElevatedButton(
              onPressed: (){
                qbitService.saveConfig(
                  storeGet.servers[statusGet.sevrerIndex.value], 
                  config, 
                  QbitConfig(savePath.text, int.parse(maxDownloadCount.text), seedTimeEnable, int.parse(seedTime.text), ratioEnable, int.parse(seedRatio.text), int.parse(downloadLimit.text), int.parse(uploadLimit.text))
                );
                Navigator.pop(context);
              }, 
              child: const Text('完成')
            )
          ],
        )
      );
    }
  }

  Future<void> downloaderConfig(BuildContext context) async {
    if(storeGet.servers[statusGet.sevrerIndex.value].type==StoreType.aria){
      await ariaConfig(context);
    }else if(storeGet.servers[statusGet.sevrerIndex.value].type==StoreType.qbit){
      await qbitConfig(context);
    }
  }
}