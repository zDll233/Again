import 'package:again/services/database/db/database.dart';
import 'package:again/services/database/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final dbServiceProvider =
    Provider<DatabaseNotifier>((ref) => DatabaseNotifier(ref));
