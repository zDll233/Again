import 'package:again/services/repository/database_repository/database/database.dart';
import 'package:again/services/repository/database_repository/database_repository_notifier.dart';
import 'package:again/services/repository/database_repository/database_repository_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final dbRepoProvider =
    NotifierProvider<DatabaseRepositoryNotifier, DatabaseRepositoryState>(
        DatabaseRepositoryNotifier.new);
