@echo off
cd /d "c:\Program Files\MetaTrader 5"
metaeditor64.exe /compile:"c:\Program Files\MetaTrader 5\MQL5\Experts\misape\Consolidated_Misape_Bot.mq5" /log:"c:\Program Files\MetaTrader 5\MQL5\Experts\misape\compile.log"
echo Compilation completed
if exist "c:\Program Files\MetaTrader 5\MQL5\Experts\misape\compile.log" (
    echo Log file created
    type "c:\Program Files\MetaTrader 5\MQL5\Experts\misape\compile.log"
) else (
    echo No log file created
)
pause