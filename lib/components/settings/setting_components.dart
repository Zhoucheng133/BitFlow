import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/service/aria.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:bit_flow/service/qbit.dart';
import 'package:bit_flow/service/trans.dart';
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

  FuncsService funcsService=Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: funcsService.isDesktop() ? 150 : 100,
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
  final bool enabled;

  const ConfigItemWithTextField({super.key, required this.label, required this.controller, this.useDouble=false, this.useInt=false, this.multiLine=false, this.enabled=true});

  @override
  State<ConfigItemWithTextField> createState() => _ConfigItemWithTextFieldState();
}

class _ConfigItemWithTextFieldState extends State<ConfigItemWithTextField> {

  FuncsService funcsService=Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: funcsService.isDesktop() ? 150 : 100,
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
                enabled: widget.enabled,
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
  final TransmissionService transmissionService=Get.find();
  
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
    // 新增扩展配置控制器
    bool enableDownloadLimit = config.enableDownloadLimit;
    bool enableUploadLimit = config.enableUploadLimit;
    bool enableSeedRatio = config.enableSeedRatio;
    bool enableDht = config.enableDht;
    bool enableDht6 = config.enableDht6;
    TextEditingController maxConnectionPerServer = TextEditingController(text: config.maxConnectionPerServer.toString());
    TextEditingController btMaxPeers = TextEditingController(text: config.btMaxPeers.toString());
    TextEditingController listenPort = TextEditingController(text: config.listenPort.toString());

    if(context.mounted){
      showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: Text(
            '${"config".tr} Aria2',
          ),
          content: SizedBox(
            width: 450,
            height: 500,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState)=>Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "sizeTip".tr,
                          ),
                        ),
                        ConfigItem(
                          label: "enableOverride".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
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
                          label: "downloadPath".tr, 
                          controller: dir,
                        ),
                        ConfigItemWithTextField(
                          label: "downloadCount".tr, 
                          controller: maxDownloads,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableDownloadLimit".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: enableDownloadLimit, 
                              onChanged: (bool val){
                                setState((){
                                  enableDownloadLimit=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItemWithTextField(
                          enabled: enableDownloadLimit,
                          label: "downloadLimit".tr, 
                          controller: downloadLimit,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableUploadLimit".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: enableUploadLimit, 
                              onChanged: (bool val){
                                setState((){
                                  enableUploadLimit=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItemWithTextField(
                          enabled: enableUploadLimit,
                          label: "uploadLimit".tr, 
                          controller: uploadLimit,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableSeedRatio".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: enableSeedRatio, 
                              onChanged: (bool val){
                                setState((){
                                  enableSeedRatio=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItemWithTextField(
                          enabled: enableSeedRatio,
                          label: "seedRatio".tr, 
                          controller: seedRatio,
                          useDouble: true,
                        ),
                        ConfigItemWithTextField(
                          label: "seedTime".tr, 
                          controller: seedTime,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "maxConnections".tr, 
                          controller: maxConnectionPerServer,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "maxPeerPerTorrent".tr, 
                          controller: btMaxPeers,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "port".tr, 
                          controller: listenPort,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableDht".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: enableDht, 
                              onChanged: (bool val){
                                setState((){
                                  enableDht=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItem(
                          label: "enableDht6".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: enableDht6, 
                              onChanged: (bool val){
                                setState((){
                                  enableDht6=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItemWithTextField(
                          label: "userAgent".tr, 
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
              child: Text("cancel".tr),
            ),
            ElevatedButton(
              onPressed: (){
                ariaService.changeGlobalSettings(storeGet.servers[statusGet.sevrerIndex.value], {
                  "allow-overwrite": allowOverwrite.toString(),
                  "dir": dir.text,
                  "max-concurrent-downloads": maxDownloads.text,
                  "seed-time": seedTime.text,
                  "max-overall-download-limit": enableDownloadLimit ? downloadLimit.text : "0",
                  "max-overall-upload-limit": enableUploadLimit ? uploadLimit.text : "0",
                  "seed-ratio": enableSeedRatio ? seedRatio.text : "0",
                  "max-connection-per-server": maxConnectionPerServer.text,
                  "bt-max-peers": btMaxPeers.text,
                  "listen-port": listenPort.text,
                  "enable-dht": enableDht.toString(),
                  "enable-dht6": enableDht6.toString(),
                  "user-agent": userAgent.text
                });
                Navigator.pop(context);
              },
              child: Text('ok'.tr)
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
    TextEditingController maxActiveTasks=TextEditingController(text: config.maxActiveTasks.toString());
    TextEditingController maxActiveUploads=TextEditingController(text: config.maxActiveUploads.toString());
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
    
    // 扩展配置
    TextEditingController listenPort=TextEditingController(text: config.listenPort.toString());
    bool dhtEnabled=config.dhtEnabled;
    bool lpdEnabled=config.lpdEnabled;
    bool pexEnabled=config.pexEnabled;
    bool upnpEnabled=config.upnpEnabled;
    TextEditingController maxConns=TextEditingController(text: config.maxConns.toString());
    TextEditingController maxConnsPerTorrent=TextEditingController(text: config.maxConnsPerTorrent.toString());

    if(context.mounted){
      await showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: Text(
            "${'config'.tr} qBittorrent",
          ),
          content: SizedBox(
            width: 450,
            height: 500,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState)=>Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "sizeTip".tr,
                          ),
                        ),
                        ConfigItemWithTextField(
                          label: "downloadPath".tr, 
                          controller: savePath,
                        ),
                        ConfigItemWithTextField(
                          label: "maxActiveDownloads".tr, 
                          controller: maxDownloadCount,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "maxActiveTorrents".tr, 
                          controller: maxActiveTasks,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "maxActiveUploads".tr, 
                          controller: maxActiveUploads,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableSeedTime".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
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
                          enabled: seedTimeEnable,
                          label: "seedTime".tr, 
                          controller: seedTime,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableSeedRatio".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
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
                          enabled: ratioEnable,
                          label: "seedRatio".tr, 
                          controller: seedRatio,
                          useDouble: true,
                        ),
                        ConfigItemWithTextField(
                          label: "downloadLimit".tr, 
                          controller: downloadLimit,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "uploadLimit".tr, 
                          controller: uploadLimit,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "port".tr, 
                          controller: listenPort,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "maxConnections".tr, 
                          controller: maxConns,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "maxPeerPerTorrent".tr, 
                          controller: maxConnsPerTorrent,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableDht".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: dhtEnabled, 
                              onChanged: (bool val){
                                setState((){
                                  dhtEnabled=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItem(
                          label: "enableLpd".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: lpdEnabled, 
                              onChanged: (bool val){
                                setState((){
                                  lpdEnabled=val;
                                });
                              }
                            ),
                          )
                        ),
                        ConfigItem(
                          label: "enablePex".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: pexEnabled, 
                              onChanged: (bool val){
                                setState((){
                                  pexEnabled=val;
                                });
                              }
                            ),
                          )
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
              child: Text('cancel'.tr)
            ),
            ElevatedButton(
              onPressed: (){
                qbitService.saveConfig(
                  storeGet.servers[statusGet.sevrerIndex.value], 
                  config, 
                  QbitConfig(
                    savePath: savePath.text, 
                    maxDownloadCount: int.tryParse(maxDownloadCount.text) ?? 3, 
                    maxActiveTasks: int.tryParse(maxActiveTasks.text) ?? 5,
                    maxActiveUploads: int.tryParse(maxActiveUploads.text) ?? 3,
                    seedTimeEnable: seedTimeEnable, 
                    seedTime: int.tryParse(seedTime.text) ?? 0, 
                    ratioEnable: ratioEnable, 
                    seedRatio: double.tryParse(seedRatio.text) ?? 1.0, 
                    downloadLimit: int.tryParse(downloadLimit.text) ?? 0, 
                    uploadLimit: int.tryParse(uploadLimit.text) ?? 0,
                    listenPort: int.tryParse(listenPort.text) ?? 6881,
                    dhtEnabled: dhtEnabled,
                    lpdEnabled: lpdEnabled,
                    pexEnabled: pexEnabled,
                    upnpEnabled: upnpEnabled,
                    maxConns: int.tryParse(maxConns.text) ?? 500,
                    maxConnsPerTorrent: int.tryParse(maxConnsPerTorrent.text) ?? 100,
                  )
                );
                Navigator.pop(context);
              }, 
              child: Text('ok'.tr)
            )
          ],
        )
      );
    }
  }

  Future<void> transConfig(BuildContext context) async { 
    final TransmissionConfig? config= await transmissionService.getConfig(storeGet.servers[statusGet.sevrerIndex.value]);
    if(config==null){
      return;
    }

    TextEditingController savePath=TextEditingController(text: config.dir);
    TextEditingController maxDownloadCount=TextEditingController(text: config.maxDownloadCount.toString());
    TextEditingController maxSeedCount=TextEditingController(text: config.maxSeedCount.toString());
    bool enableSeedRatio=config.enableSeedRatio;
    TextEditingController seedRatioLimit=TextEditingController(text: config.seedRatioLimit.toString());
    bool enableDownloadSpeedLimit=config.enableDownloadSpeedLimit;
    TextEditingController downloadSpeedLimit=TextEditingController(text: config.downloadSpeedLimit.toString());
    bool enableUploadSpeedLimit=config.enableUploadSpeedLimit;
    TextEditingController uploadSpeedLimit=TextEditingController(text: config.uploadSpeedLimit.toString());

    // 扩展配置
    TextEditingController peerLimitGlobal=TextEditingController(text: config.peerLimitGlobal.toString());
    TextEditingController peerLimitPerTorrent=TextEditingController(text: config.peerLimitPerTorrent.toString());
    TextEditingController peerPort=TextEditingController(text: config.peerPort.toString());
    bool dhtEnabled=config.dhtEnabled;
    bool pexEnabled=config.pexEnabled;
    bool lpdEnabled=config.lpdEnabled;

    if(context.mounted){
      await showDialog(
        context: context, 
        builder: (context)=>AlertDialog(
          title: Text(
            "${'config'.tr} Transmission",
          ),
          content: SizedBox(
            width: 450,
            height: 500,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState)=>Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "sizeTip".tr,
                          ),
                        ),
                        ConfigItemWithTextField(
                          label: "downloadPath".tr, 
                          controller: savePath,
                        ),
                        ConfigItemWithTextField(
                          label: "downloadCount".tr, 
                          controller: maxDownloadCount,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "seedCount".tr, 
                          controller: maxSeedCount,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableSeedRatio".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: enableSeedRatio, 
                              onChanged: (bool val){
                                setState((){
                                  enableSeedRatio=val;
                                });
                              }
                            )
                          )
                        ),
                        ConfigItemWithTextField(
                          enabled: enableSeedRatio,
                          label: "seedRatio".tr, 
                          controller: seedRatioLimit,
                          useDouble: true,
                        ),
                        ConfigItem(
                          label: "enableDownloadLimit".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: enableDownloadSpeedLimit, 
                              onChanged: (bool val){
                                setState((){
                                  enableDownloadSpeedLimit=val;
                                });
                              }
                            )
                          )
                        ),
                        ConfigItemWithTextField(
                          enabled: enableDownloadSpeedLimit,
                          label: "downloadLimit".tr, 
                          controller: downloadSpeedLimit,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableUploadLimit".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: enableUploadSpeedLimit, 
                              onChanged: (bool val){
                                setState((){
                                  enableUploadSpeedLimit=val;
                                });
                              }
                            )
                          )
                        ),
                        ConfigItemWithTextField(
                          enabled: enableUploadSpeedLimit,
                          label: "uploadLimit".tr, 
                          controller: uploadSpeedLimit,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "maxConnections".tr, 
                          controller: peerLimitGlobal,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "maxPeerPerTorrent".tr, 
                          controller: peerLimitPerTorrent,
                          useInt: true,
                        ),
                        ConfigItemWithTextField(
                          label: "port".tr, 
                          controller: peerPort,
                          useInt: true,
                        ),
                        ConfigItem(
                          label: "enableDht".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: dhtEnabled, 
                              onChanged: (bool val){
                                setState((){
                                  dhtEnabled=val;
                                });
                              }
                            )
                          )
                        ),
                        ConfigItem(
                          label: "enablePex".tr, 
                          child: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              mouseCursor: SystemMouseCursors.basic,
                              splashRadius: 0,
                              value: pexEnabled, 
                              onChanged: (bool val){
                                setState((){
                                  pexEnabled=val;
                                });
                              }
                            )
                          )
                        ),
                      ]
                    )
                  )
                ]
              )
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "cancel".tr,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                TransmissionConfig newConfig=TransmissionConfig(
                  dir: savePath.text, 
                  maxDownloadCount: int.tryParse(maxDownloadCount.text) ?? 5, 
                  maxSeedCount: int.tryParse(maxSeedCount.text) ?? 10, 
                  enableSeedRatio: enableSeedRatio, 
                  seedRatioLimit: double.tryParse(seedRatioLimit.text) ?? 1.0, 
                  enableDownloadSpeedLimit: enableDownloadSpeedLimit, 
                  downloadSpeedLimit: int.tryParse(downloadSpeedLimit.text) ?? 100, 
                  enableUploadSpeedLimit: enableUploadSpeedLimit, 
                  uploadSpeedLimit: int.tryParse(uploadSpeedLimit.text) ?? 50,
                  peerLimitGlobal: int.tryParse(peerLimitGlobal.text) ?? 200,
                  peerLimitPerTorrent: int.tryParse(peerLimitPerTorrent.text) ?? 50,
                  peerPort: int.tryParse(peerPort.text) ?? 51413,
                  dhtEnabled: dhtEnabled,
                  pexEnabled: pexEnabled,
                  lpdEnabled: lpdEnabled,
                  portForwardingEnabled: config.portForwardingEnabled,
                  encryption: config.encryption,
                );
                if(newConfig!=config){
                  transmissionService.saveConfig(
                    storeGet.servers[statusGet.sevrerIndex.value], 
                    newConfig
                  );
                }
                Navigator.pop(context);
              }, 
              child: Text(
                'ok'.tr
              )
            )
          ],
        )
      );
    }
  }

  Future<void> downloaderConfig(BuildContext context) async {
    switch (storeGet.servers[statusGet.sevrerIndex.value].type) {
      case StoreType.aria:
        await ariaConfig(context);
        break;
      case StoreType.qbit:
        await qbitConfig(context);
        break;
      case StoreType.transmission:
        await transConfig(context);
        break;
    }
  }
}