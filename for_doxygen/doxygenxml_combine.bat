powershell -ExecutionPolicy RemoteSigned -File %~dpn0.ps1 %*
@If Not Errorlevel 0 pause
