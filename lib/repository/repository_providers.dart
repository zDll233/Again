import 'package:again/repository/database/database.dart';
import 'package:again/repository/repository_notifier.dart';
import 'package:again/repository/repository_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final repositoryProvider =
    NotifierProvider<RepositoryNotifier, RepositoryState>(
        RepositoryNotifier.new);
