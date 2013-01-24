@echo off
copy /Y "bin\client.swf" "..\server\src\html\swf\"
rmdir /S /Q "temp"
