import 'package:again/repository/repository_notifier.dart';
import 'package:again/repository/repository_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final repositoryProvider =
    NotifierProvider<RepositoryNotifier, RepositoryState>(RepositoryNotifier.new);
