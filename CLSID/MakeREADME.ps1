<#
Combines CLSID and results in a Markdown table for README.md

Usage:
PS T:\JuicyPotato\Docs\CLSID> .\MakeREADME.ps1
Enter windows folder path: Windows_10_Enterprise

#>

$ErrorActionPreference = "Stop"

# Importing some requirements
. .\utils\ConvertTo-Markdown.ps1
. .\utils\Join-Object.ps1


$win = read-host "Enter windows folder path"
if (-not(test-path $win)){
    Write-host "Invalid folder"
    exit
}

$OS = $win -Replace "_", " "

$CLSID = Import-Csv ".\$win\CLSIDs.csv"
$RESULTS = Import-Csv ".\$win\result.log" -Header CLSID,User -Delimiter ";"

$TABLE = Join-Object -Left $CLSID -Right $RESULTS -LeftJoinProperty CLSID -RightJoinProperty CLSID -Type AllInLeft | Sort-Object User, LocalService -Descending

# Generate the table for the README.md
$README = ".\$win\README.md"

@"
# $OS

"@ | Out-File -FilePath $README -Encoding ASCII
$TABLE | ConvertTo-Markdown | Out-File -append -filepath $README -Encoding ascii


# TODO Remove files after merge
Rename-Item -Path ".\$win\result.log" -NewName "result.txt.deleteme"
