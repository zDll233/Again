String generateScript() {
  final buffer = StringBuffer();
  buffer.writeln('param(');
  buffer.writeln('    [string]\$filePath');
  buffer.writeln(')');
  buffer.writeln();
  buffer.writeln('\$sh = New-Object -ComObject "Shell.Application"');
  buffer.writeln('\$ns = \$sh.Namespace(0).ParseName(\$filePath)');
  buffer.writeln('\$ns.InvokeVerb("delete")');
  return buffer.toString();
}
