<#
This script extracts CLSIDs and AppIDs related to LocalService.DESCRIPTION
Then exports to CSV
#>

$ErrorActionPreference = "Stop"

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

Write-Output "Looking for CLSIDs"
$CLSID = @()
Foreach($ID in (Get-ItemProperty HKCR:\clsid\* | select-object AppID,@{N='CLSID'; E={$_.pschildname}})){
    if ($ID.appid -ne $null){
        $CLSID += $ID
    }
}

Write-Output "Looking for APIDs"
$APPID = @()
Foreach($AID in (Get-ItemProperty HKCR:\appid\* | select-object localservice,@{N='AppID'; E={$_.pschildname}})){
    if ($AID.LocalService -ne $null){
        $APPID += $AID
    }
}

Write-Output "Joining CLSIDs and APIDs"
$RESULT = @()
Foreach ($app in $APPID){
    Foreach ($CLS in $CLSID){
        if($CLS.AppId -eq $app.AppID){
            $RESULT += New-Object psobject -Property @{
                AppId    = $app.AppId
                LocalService = $app.LocalService
                CLSID = $CLS.CLSID
            }

            break
        }
    }
}

$RESULT = $RESULT | Sort-Object LocalService

# Preparing to Output
$OS = (Get-WmiObject -Class Win32_OperatingSystem | ForEach-Object -MemberName Caption).Trim() -Replace "Microsoft ", ""
$TARGET = $OS -Replace " ","_"

# Make target folder
New-Item -ItemType Directory -Force -Path .\$TARGET

# Output in a CSV
$RESULT | Export-Csv -Path ".\$TARGET\CLSIDs.csv" -Encoding ascii -NoTypeInformation

# Export CLSIDs list
$RESULT | Select CLSID -ExpandProperty CLSID | Out-File -FilePath ".\$TARGET\CLSID.list" -Encoding ascii

# Visual Table
$RESULT | ogv
