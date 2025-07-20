import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';

Future<OrderTypes> changeOrderMenu(BuildContext context, OrderTypes originalType, RelativeRect position) async {

  OrderTypes selectedType=originalType;

  await showMenu(
    context: context, 
    position: position,
    items: [
      PopupMenuItem(child: const Text("1")),
      PopupMenuItem(child: const Text("2")),
      PopupMenuItem(child: const Text("3")),
    ]
  );

  return selectedType;
}