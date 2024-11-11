import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/utils/log.dart';

/// scripts/delete.ps1
const String REMOVE_TO_RECYCLEBIN_SCRIPT = '''
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
  final scriptFile = File(DELETE_SCRIPT_PATH);

  if (!await scriptFile.exists()) {
    await scriptFile.create(recursive: true);
    scriptFile.writeAsString(REMOVE_TO_RECYCLEBIN_SCRIPT);
    Log.info('Generate script "$DELETE_SCRIPT_PATH"');
  }
}
