import 'package:again/services/database/db/database.dart';
import 'package:again/services/database/database_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final dbNotifierProvider =
    Provider<DatabaseNotifier>((ref) => DatabaseNotifier(ref));
