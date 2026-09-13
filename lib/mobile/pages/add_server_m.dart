import 'package:bit_flow/components/add_store.dart';
import 'package:bit_flow/components/dialogs.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddServerM extends StatefulWidget {

  final bool init;

  const AddServerM({super.key, this.init=false});

  @override
  State<AddServerM> createState() => _AddServerMState();
}

class _AddServerMState extends State<AddServerM> {

  StoreItem item=StoreItem("", StoreType.aria, "", null, "");
  bool load=false;
  final StoreGet storeGet=Get.find();
  final FuncsService funcsService=Get.find();

  void setVal(StoreItem val){
    item = StoreItem(val.name, val.type, val.url, val.type==StoreType.aria ? null : val.username, val.password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0.0,
        title: Text('addDownloader'.tr,),
        automaticallyImplyLeading: false,
        leading: widget.init ? null : BackButton(),
        actions: [
          Padding(
            padding: .only(right: 15),
            child: FilledButton(
              onPressed: load ? null : () async {
                if(storeGet.servers.any((element) => element.name==item.name)){
                  showErrWarnDialog(context, "addFailed".tr, "duplicateName".tr);
                  return;
                }
                setState((){
                  load=true;
                });
                bool checked=await item.checkItem();
                if(checked){
                  storeGet.servers.add(item);
                  await storeGet.saveStore();
                  if(widget.init){
                      funcsService.init(Get.context!);
                    }
                  if(context.mounted) Navigator.pop(context);
                }else{
                  if(context.mounted) showErrWarnDialog(context, "connectFailed".tr, "checkDownloader".tr);
                }
                setState((){
                  load=false;
                });
              }, 
              child: load ? SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                )
              ) : Text("add".tr)
            ),
          ),
        ],
      ),
      body: PopScope(
        canPop: !widget.init,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: .min,
            children: [
              AddStore(valCallback: setVal),
            ],
          ),
        ),
      ),
    );
  }
}