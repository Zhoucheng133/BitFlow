import 'package:bit_flow/components/header/active_buttons.dart';
import 'package:bit_flow/service/funcs.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTaskM extends StatefulWidget {

  const AddTaskM({super.key});

  @override
  State<AddTaskM> createState() => _AddTaskMState();
}

class _AddTaskMState extends State<AddTaskM> {

  final TextEditingController link=TextEditingController();
  final FuncsService funcs=Get.find();

  Future<void> init() async {
    final copyText=await FlutterClipboard.paste();
    if(copyText.startsWith("http://") || copyText.startsWith("https://") || copyText.startsWith("magnet:?xt=urn:btih:")){
      link.text=copyText;
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('addTask'.tr,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text(
              'multiTaskTip'.tr,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 350
              ),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'http(s)://\nmagnet:?xt=urn:btih:', 
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 13
                  ),
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                ),
                minLines: 3,
                maxLines: null,
                controller: link,
                style: TextStyle(
                  fontSize: 13
                ),
              ),
            ),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                TextButton(
                  onPressed: ()async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ["torrent"]
                    );
                    if(result!=null){
                      if(context.mounted) Navigator.pop(context);
                      final filePath=result.files.single.path!;
                      funcs.addTorrentTaskHandler(filePath);
                    }
                  }, 
                  child: Text('fromTorrent'.tr)
                ),
                FilledButton(
                  onPressed: (){
                    addTaskHandler(context, link, funcs);
                  },
                  child: Text("add".tr)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}