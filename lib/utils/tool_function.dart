String replaceLast(String input, String target, String replacement) {
  final index = input.lastIndexOf(target);
  if (index == -1) {
    return input;
  }
  return input.replaceFirst(target, replacement, index);
}