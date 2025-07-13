import 'package:bit_flow/components/header.dart';
import 'package:flutter/material.dart';

class FinishPage extends StatefulWidget {
  const FinishPage({super.key});

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(name: '已完成')
      ],
    );
  }
}