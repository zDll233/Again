import 'package:again/pages/player/components/time_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats durations below one hour as mm:ss', () {
    expect(formatDuration(const Duration(minutes: 2, seconds: 4)), '02:04');
    expect(formatDuration(const Duration(minutes: 59, seconds: 59)), '59:59');
  });

  test('formats durations of one hour or more as h:mm:ss', () {
    expect(formatDuration(const Duration(hours: 1)), '1:00:00');
    expect(
      formatDuration(const Duration(hours: 2, minutes: 3, seconds: 5)),
      '2:03:05',
    );
  });

  test('keeps empty display for zero and formats combined desktop text', () {
    expect(getTimeText(Duration.zero), '');
    expect(
      getTimeDisplayText(
        const Duration(minutes: 2, seconds: 4),
        const Duration(minutes: 10, seconds: 23),
      ),
      '02:04 / 10:23',
    );
  });
}
