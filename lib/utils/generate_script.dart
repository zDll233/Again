import 'dart:io';

import 'package:again/utils/log.dart';

import 'package:path/path.dart' as p;

/// scripts/recycle.ps1
const String recycleScript = '''
param(
    [string]\$path
)

Add-Type -AssemblyName Microsoft.VisualBasic

function Remove-Item-ToRecycleBin(\$path) {
    \$item = Get-Item -Path \$path -ErrorAction SilentlyContinue
    if (\$null -eq \$item) {
        Write-Error("'{0}' not found" -f \$path)
    }
    else {
        \$fullpath = \$item.FullName
        Write-Host ("Moving '{0}' to the Recycle Bin" -f \$fullpath)
        if (Test-Path -Path \$fullpath -PathType Container) {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(\$fullpath, 'OnlyErrorDialogs', 'SendToRecycleBin')
        }
        else {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(\$fullpath, 'OnlyErrorDialogs', 'SendToRecycleBin')
        }
    }
}

Remove-Item-ToRecycleBin -Path "\$path"
''';


Future<void> generateDeleteScript() async {
  final scriptPath = p.join("scripts", "delete.ps1");
  final scriptFile = File(scriptPath);

  if (!await scriptFile.exists()) {
    await scriptFile.create(recursive: true);
    scriptFile.writeAsString(recycleScript);
    Log.info('Generate script "$scriptPath"');
  }
}
