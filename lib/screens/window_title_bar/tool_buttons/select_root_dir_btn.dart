import 'package:again/repository/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectRootDirBtn extends ConsumerWidget {
  const SelectRootDirBtn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
        onPressed:
            ref.read(repositoryProvider.notifier).selectAndSaveRootDirectory,
        icon: const Icon(
          Icons.folder_open,
          size: 20,
          color: Color.fromRGBO(255, 255, 255, 0.5),
        ));
  }
}
