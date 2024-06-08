
import 'package:flutter/material.dart';

class VoicePanel<T> extends StatelessWidget {
  final String title;
  final Widget listView;
  final Function() onLocateBtnPressed;

  const VoicePanel({
    super.key,
    required this.title,
    required this.listView,
    required this.onLocateBtnPressed,
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
                child: const Icon(Icons.location_searching),
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
