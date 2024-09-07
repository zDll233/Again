param(
    [string]$path
)

Add-Type -AssemblyName Microsoft.VisualBasic

function Remove-Item-ToRecycleBin($path) {
    $item = Get-Item -Path $path -ErrorAction SilentlyContinue
    if ($null -eq $item) {
        Write-Error("'{0}' not found" -f $path)
    }
    else {
        $fullpath = $item.FullName
        Write-Host ("Moving '{0}' to the Recycle Bin" -f $fullpath)
        if (Test-Path -Path $fullpath -PathType Container) {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($fullpath, 'OnlyErrorDialogs', 'SendToRecycleBin')
        }
        else {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($fullpath, 'OnlyErrorDialogs', 'SendToRecycleBin')
        }
    }
}

Remove-Item-ToRecycleBin -Path "$path"
