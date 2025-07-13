import 'package:bit_flow/components/sidebar/sidebar_components.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/types/store_item.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
            SidebarDivider(func: ()=>storeGet.addStore(context), label: '下载服务器', useAdd: true, addHint: "添加一个下载服务器",),
            if(storeGet.servers.isNotEmpty) DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                buttonStyleData: ButtonStyleData(
                  overlayColor: WidgetStateProperty.all(Colors.transparent)
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                  padding: EdgeInsets.only(left: 10, right: 10),
                ),
                dropdownStyleData: DropdownStyleData(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).cardColor
                  )
                ),
                isExpanded: true,
                customButton: MouseRegion(
                  onEnter: (_) => setState(() => hover = true),
                  onExit: (_) => setState(() => hover = false),
                  child: AnimatedContainer(
                    width: double.infinity,
                    height: 35,
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: hover ? Theme.of(context).hoverColor : Theme.of(context).hoverColor.withAlpha(0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              storeGet.servers[statusGet.sevrerIndex.value].name,
                              style: GoogleFonts.notoSansSc(
                                fontSize: 14
                              ),
                            )
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                value: storeGet.servers[statusGet.sevrerIndex.value].name,
                items: storeGet.servers.map((StoreItem item) {
                  final name=item.name;
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(
                      name,
                      style: GoogleFonts.notoSansSc(
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
            SidebarDivider(label: "页面"),
            SidebarButton(label: "下载中", icon: Icons.download_rounded, func: ()=>statusGet.page.value=Pages.active, selected: statusGet.page.value==Pages.active,),
            const SizedBox(height: 5,),
            SidebarButton(label: "已完成", icon: Icons.download_done_rounded, func: ()=>statusGet.page.value=Pages.finish, selected: statusGet.page.value==Pages.finish,),
            Expanded(child: Container()),
            SidebarButton(label: "设置", icon: Icons.settings_rounded, func: ()=>statusGet.page.value=Pages.settings, selected: statusGet.page.value==Pages.settings,),
          ],
        ),
      ),
    );
  }
}