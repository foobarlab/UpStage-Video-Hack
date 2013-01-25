@echo off
echo Cleaning temp ...
del /Q "temp"
echo Cleaning swfs ...
del /Q "bin\classes.swf"
del /Q "bin\client.swf"
del /Q "..\server\src\html\swf\client.swf"
echo Cleaning docs ...
rmdir /S /Q "doc\upstage"
rmdir /S /Q "doc\index-files"
del /Q "doc\*.*"
echo. > "doc\EMPTY"
pause
