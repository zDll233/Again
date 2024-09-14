import 'package:again/database/database_notifier.dart';
import 'package:again/database/database_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider =
    NotifierProvider<DatabaseNotifier, DatabaseState>(DatabaseNotifier.new);
