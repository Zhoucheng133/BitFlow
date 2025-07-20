import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<OrderTypes?> changeOrderMenu(BuildContext context, OrderTypes originalType, RelativeRect position) async {

  OrderTypes? selectedType=originalType;

  selectedType=await showMenu(
    context: context, 
    position: position,
    items: [
      PopupMenuItem(
        height: 40,
        value: OrderTypes.addNew,
        child: const Row(
          children: [
            Icon(
              FontAwesomeIcons.arrowDownShortWide,
              size: 15,
            ),
            SizedBox(width: 10,),
            Text('新的在前')
          ],
        )
      ),
      PopupMenuItem(
        height: 40,
        value: OrderTypes.addOld,
        child: const Row(
          children: [
            Icon(
              FontAwesomeIcons.arrowDownWideShort,
              size: 15,
            ),
            SizedBox(width: 10,),
            Text('新的在后')
          ],
        )
      ),
      PopupMenuItem(
        height: 40,
        value: OrderTypes.nameAZ,
        child: const Row(
          children: [
            Icon(
              FontAwesomeIcons.arrowDownAZ,
              size: 15,
            ),
            SizedBox(width: 10,),
            Text('名称A到Z')
          ],
        )
      ),
      PopupMenuItem(
        height: 40,
        value: OrderTypes.nameZA,
        child: const Row(
          children: [
            Icon(
              FontAwesomeIcons.arrowDownZA,
              size: 15,
            ),
            SizedBox(width: 10,),
            Text('名称Z到A')
          ],
        )
      ),
    ],

  );

  return selectedType;
}