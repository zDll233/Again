import 'package:flutter/material.dart';

class VoicePanel<T> extends StatelessWidget {
  final String title;
  final Widget listView;
  final Icon icon;
  final Function()? onIconBtnPressed;
  final Function()? onTextBtnPressed;

  const VoicePanel({
    super.key,
    required this.title,
    required this.listView,
    required this.icon,
    this.onIconBtnPressed,
    this.onTextBtnPressed,
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
              TextButton(
                onPressed: onTextBtnPressed,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              IconButton(
                onPressed: onIconBtnPressed,
                icon: icon,
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
