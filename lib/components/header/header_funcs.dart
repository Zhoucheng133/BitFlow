import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';

Future<OrderTypes?> changeOrderMenu(BuildContext context, OrderTypes originalType, RelativeRect position) async {

  OrderTypes? selectedType=originalType;

  selectedType=await showMenu(
    context: context, 
    position: position,
    color: Theme.of(context).colorScheme.surface,
    items: OrderTypes.values.map((item)=>
      PopupMenuItem(
        height: 40,
        value: item,
        child: Row(
          children: [
            Icon(
              orderToIcon(item),
              size: 15,
            ),
            SizedBox(width: 10,),
            Text(orderToString(item))
          ],
        )
      ),
    ).toList()
  );

  return selectedType;
}