import 'package:again/services/audio/audio_state.dart';
import 'package:again/services/audio/audio_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioProvider =
    NotifierProvider<AudioNotifier, AudioState>(AudioNotifier.new);
