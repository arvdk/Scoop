<#
.SYNOPSIS
    Format manifest.
.PARAMETER App
    Manifest to format.

    Wildcards are supported.
.PARAMETER Dir
    Where to search for manifest(s).
.EXAMPLE
    PS BUCKETROOT> .\bin\formatjson.ps1
    Format all manifests inside bucket directory.
.EXAMPLE
    PS BUCKETROOT> .\bin\formatjson.ps1 7zip
    Format manifest '7zip' inside bucket directory.
#>
param(
    [String] $App = '*',
    [ValidateScript( {
        if (!(Test-Path $_ -Type Container)) {
            throw "$_ is not a directory!"
        } else {
            $true
        }
    })]
    [String] $Dir
)

. "$PSScriptRoot\..\lib\core.ps1"
. "$PSScriptRoot\..\lib\manifest.ps1"
. "$PSScriptRoot\..\lib\json.ps1"

if (Test-Path $App -PathType Leaf) {
    $Dir = Split-Path $App
    $App = (Split-Path $App -Leaf).replace(".json","")
} elseif ($Dir) {
    $Dir = Convert-Path $Dir
} else {
    throw "'-Dir' parameter required if '-App' is not a filepath!"
}

Get-ChildItem $Dir -Filter "$App.json" -Recurse | ForEach-Object {
    $file = $_.FullName
    # beautify
    $json = parse_json $file | ConvertToPrettyJson

    # convert to 4 spaces
    $json = $json -replace "`t", '    '
    [System.IO.File]::WriteAllLines($file, $json)
}
