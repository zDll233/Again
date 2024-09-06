param(
    [string]$filePath
)

$sh = New-Object -ComObject "Shell.Application"
$ns = $sh.Namespace(0).ParseName($filePath)
$ns.InvokeVerb("delete")
