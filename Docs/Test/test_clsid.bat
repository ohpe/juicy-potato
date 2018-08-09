@echo off
:: Starting port, you can change it
set /a port=10000
SETLOCAL ENABLEDELAYEDEXPANSION

FOR /F %%i IN (CLSID.list) DO (
   set p=%port%
   echo %%i
   juicypotato.exe -z -l !port! -c %%i >> result.log
   set /a port=port+1
)
