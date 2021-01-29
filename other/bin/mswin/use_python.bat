@echo off

:: First param must specify the desired Python,
:: such that 'python%1' is its executable
if "%1"=="" goto usage

:: Ask the requested python for the location of its executable.
:: This requires 'python2' or 'python2.7' executables or symlinks on the PATH
for /f "tokens=*" %%a in ('python%1 -c "import sys; print(sys.prefix)"') do @set newpath=%%a

:: remove all Python-related directories from PATH
:: by generating a .bat file to set the modified PATH, then execute it
echo :: Generated by use_python.bat >%~dp0%use_python_path.bat
echo set PATH=%PATH%| tr ';' '\n' | gawk '{ if ($0 !~ /Python/) print $0 }' | paste -sd';' >>%~dp0%use_python_path.bat
call %~dp0%use_python_path.bat

:: then add requested Python path
set PATH=%PATH%;%NEWPATH%;%NEWPATH%\Scripts

:: display debug output
:: echo %PATH% | tr ';' '\n' | grep Python
python --version

goto end

:usage
echo Usage: use_python X
echo Where 'pythonX' is an executable on the PATH
:end

