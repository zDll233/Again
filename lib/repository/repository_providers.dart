import 'package:again/repository/database_repo/database/database.dart';
import 'package:again/repository/database_repo/database_repository_notifier.dart';
import 'package:again/repository/database_repo/database_repository_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final dbRepoProvider =
    NotifierProvider<DatabaseRepositoryNotifier, DatabaseRepositoryState>(
        DatabaseRepositoryNotifier.new);
