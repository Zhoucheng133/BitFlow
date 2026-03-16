import 'package:bit_flow/components/sidebar/sidebar_components.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

  final StatusGet statusGet=Get.find();
  final StoreGet storeGet=Get.find();

  bool hover=false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 20),
      child: Obx(
        ()=> Column(
          children: [
            SidebarDivider(func: ()=>storeGet.addStore(context), label: 'downloadSerevr'.tr, useAdd: true, addHint: "addDownloader".tr,),
            if(storeGet.servers.isNotEmpty) DropdownButtonHideUnderline(
              child: MouseRegion(
                child: DropdownButton<String>(
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                  focusColor: Colors.transparent, 
                  borderRadius: BorderRadius.circular(10),
                  value: storeGet.servers[statusGet.sevrerIndex.value].name,
                  items: storeGet.servers.map((StoreItem item) {
                    final name=item.name;
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val){
                    int index=storeGet.servers.indexWhere((item)=>item.name==val);
                    statusGet.sevrerIndex.value=index;
                  },
                ),
              ),
            ),
            // const SizedBox(height: 5,),
            // SidebarButton(label: "添加下载器", icon: Icons.add_rounded, func: ()=>storeGet.addStore(context)),
            const SizedBox(height: 5,),
            Row(
              children: [
                Expanded(child: SidebarSmallButton(icon: Icons.star_rounded, func: ()=>storeGet.setStar(statusGet.sevrerIndex.value), star: storeGet.starIndex.value==statusGet.sevrerIndex.value, size: 18,)),
                const SizedBox(width: 10,),
                Expanded(child: SidebarSmallButton(icon: Icons.delete_rounded, func: ()=>storeGet.delStore(context, statusGet.sevrerIndex.value), disable: storeGet.servers.length==1,))
              ],
            ),
            const SizedBox(height: 10,),
            SidebarDivider(label: "pages".tr),
            SidebarButton(label: "active".tr, icon: Icons.download_rounded, func: ()=>statusGet.page.value=Pages.active, selected: statusGet.page.value==Pages.active,),
            const SizedBox(height: 5,),
            SidebarButton(label: "finished".tr, icon: Icons.download_done_rounded, func: ()=>statusGet.page.value=Pages.finish, selected: statusGet.page.value==Pages.finish,),
            Expanded(child: Container()),
            SidebarButton(label: "settings".tr, icon: Icons.settings_rounded, func: ()=>statusGet.page.value=Pages.settings, selected: statusGet.page.value==Pages.settings,),
          ],
        ),
      ),
    );
  }
}