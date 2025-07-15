import 'package:bit_flow/components/header/header.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(name: '设置', page: Pages.settings,)
      ],
    );
  }
}