import 'package:bit_flow/components/sidebar_button.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:bit_flow/getx/store_get.dart';
import 'package:bit_flow/types/types.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
      child: Obx(
        ()=> Column(
          children: [
            if(storeGet.servers.isNotEmpty) DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                buttonStyleData: ButtonStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10)
                  )
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
          ],
        ),
      ),
    );
  }
}