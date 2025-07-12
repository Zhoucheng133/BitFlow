import 'package:flutter/material.dart';

Future<void> showErrWarnDialog(BuildContext context, String title, String content) async {
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("好的")
        )
      ],
    )
  );
}

showComfirmDialog(BuildContext context, String title, String content) async {
  bool ok=false;
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(title),
      content: Text(content),
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
          child: const Text("好的")
        )
      ],
    )
  );
  return ok;
}