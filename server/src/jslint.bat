@echo off
cd ..\..\lib\jslint
for %%f in (..\..\server\src\html\*.js) do call run-jslint.bat %%f
