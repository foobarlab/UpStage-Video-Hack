@echo off
echo Cleaning temp ...
del /Q "temp"
echo Cleaning swfs ...
del /Q "bin\classes.swf"
del /Q "bin\stream.swf"
del /Q "html\stream.swf"
rem del /Q "..\..\..\server\src\html\media\stream.swf"
rem echo Cleaning docs ...
rem rmdir /S /Q "doc\upstage"
rem rmdir /S /Q "doc\index-files"
rem del /Q "doc\*.*"
rem echo. > "doc\EMPTY"
pause
