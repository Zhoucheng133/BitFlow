import 'package:bit_flow/components/header/active_buttons.dart';
import 'package:bit_flow/components/header/finished_buttons.dart';
import 'package:bit_flow/getx/status_get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Header extends StatefulWidget {

  final String name;
  final Pages page;

  const Header({super.key, required this.name, required this.page});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: Row(
            children: [
              Text(
                widget.name,
                style: GoogleFonts.notoSansSc(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
              Expanded(
                child: widget.page==Pages.active ? ActiveButtons() : widget.page==Pages.finish ? FinishedButtons() : Container()
              )
            ],
          ),
        ),
        const SizedBox(height: 10,),
        Container(
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Theme.of(context).colorScheme.primary
          ),
        )
      ],
    );
  }
}