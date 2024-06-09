import 'package:flutter/material.dart';

class VoicePanel<T> extends StatelessWidget {
  final String title;
  final Widget listView;
  final Icon icon;
  final Function()? onLocateBtnPressed;

  const VoicePanel({
    super.key,
    required this.title,
    required this.listView,
    required this.icon,
    this.onLocateBtnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(title),
              ElevatedButton(
                onPressed: onLocateBtnPressed,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15), // 控制按钮的大小
                ),
                child: icon,
              ),
            ],
          ),
        ),
        Expanded(
          child: listView,
        ),
      ],
    );
  }
}
