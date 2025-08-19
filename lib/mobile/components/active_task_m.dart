import 'package:bit_flow/types/task_item.dart';
import 'package:flutter/material.dart';

class ActiveTaskM extends StatefulWidget {

  final TaskItem task;

  const ActiveTaskM({super.key, required this.task});

  @override
  State<ActiveTaskM> createState() => _ActiveTaskMState();
}

class _ActiveTaskMState extends State<ActiveTaskM> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}