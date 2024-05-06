import 'package:again/screens/left/left_side.dart';
import 'package:again/screens/right/right_side.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Row(
        children: [
          LeftSide(),
          VerticalDivider(
            width: 5.0,
            color: Color(0x80B3B0F6),
          ),
          RightSide()
        ],
      ),
    );
  }
}
