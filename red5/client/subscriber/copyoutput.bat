@echo off
copy /Y "bin\stream.swf" "html"
copy /Y "bin\stream.swf" "..\..\..\server\src\html\media\"
rmdir /S /Q "temp"
