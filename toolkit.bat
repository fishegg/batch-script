@echo off
:main
chcp 65001
title=TOOLKIT
set space=a a
rem mode con cols=101 lines=30

:set_package_param
set pkg=
if not "%~1" equ "" (set pkg=%1
goto set_package_name)
:set_package_input
if defined pre_pkg echo last .apk file: %pre_pkg% and type p to select
if defined pkg set pkg_tmp=%pkg%
set /p pkg=.apk file path: 
if %pkg% equ p (set pkg=%pre_pkg%
set pre_pkg=%pkg_tmp%
goto set_package_name)
if not defined pkg (echo No file set.
goto set_package_input)
if not exist %pkg% (echo No such file.
goto set_package_input)
:set_package_name
set suffix=%pkg:"=%
for %%i in ("%suffix%") do set suffix=%%~xi
if not "%suffix%" equ ".apk" (echo %pkg% is not a .apk file.
goto set_package_input)
if not defined pkg_tmp goto skip_pkg_tmp
if not %pkg_tmp% equ %pkg% set pre_pkg=%pkg_tmp%
:skip_pkg_tmp
set pkg_name=
for /f "tokens=2" %%a in ('aapt dump badging %pkg%^|findstr package') do set pkg_name=%%a
for /f "tokens=2" %%a in ('echo %pkg_name%') do set pkg_name=%%a
set pkg_name=%pkg_name:'=%
setlocal enabledelayedexpansion
if exist %~dp0\strlen.bat (
  call %~dp0\strlen.bat %pkg%
  if !errorlevel! leq 68 (set /a non_pkg_len=68-!errorlevel!) else set non_pkg_len=
  call %~dp0\strlen.bat %pkg_name%
  if !errorlevel! leq 60 (set /a non_pkg_name_len=60-!errorlevel!) else set non_pkg_name_len=
)
rem title=%pkg_name%
if defined serial goto select_tool

:select_device
rem set serial=
set retry_time=0
set retry_times=3
set device=
set abi=
echo=
echo devices:
adb devices|findstr "device\> unauthorized"|findstr -n "device\> unauthorized"
rem set /p device=device: 
if defined serial choice /c 1235670rc /m "device(press r to refresh list or press c to reconnect to %serial%): " /n
if not defined serial choice /c 1235670rc /m "device(press r to refresh list): " /n
set device=%errorlevel%
if not defined device (echo No device selected.
goto select_device)
if %device% equ 9 adb -s %serial% reconnect & timeout /t 5 & goto select_device
if %device% equ 8 goto select_device
rem set /a device+=1
:check_device
for /f "tokens=1,2,3 delims=:" %%a in ('adb devices^|findstr "device\> unauthorized"^|findstr -n "device\> unauthorized"') do if %%a==%device% (set serial=%%b & set netserial=%%c)
if defined netserial set serial=%serial: =%:%netserial%
if defined serial for /f "tokens=1,2" %%a in ('echo %serial%') do set serial=%%a & set type=%%b
if defined serial set serial=%serial: =%
if not defined serial (echo No such devices.
goto select_device)
if not defined type (echo No such devices.
goto select_device)
set /a retry_time+=1
if %type% equ unauthorized (
  echo %retry_time%/%retry_times% times of retry
  if not %serial:~0,3% equ 172 adb -s %serial% reconnect & timeout /t 5
  if %serial:~0,3% equ 172 adb -s %serial% disconnect & adb connect %serial% & timeout /t 5
  echo=
  if not %retry_time% equ %retry_times% goto check_device
  goto select_device
)
for /f "delims=" %%a in ('adb -s %serial% shell getprop ro.product.model') do set model=%%a&title=%model%
set model=%model: =_%
for /f "delims=" %%a in ('adb -s %serial% shell getprop ro.build.version.release') do set release=%%a
for /f "delims=" %%a in ('adb -s %serial% shell getprop ro.product.cpu.abi') do set abi=%%a
if exist %~dp0\strlen.bat (
  call %~dp0\strlen.bat "%serial% (%model% Android %release%)"
  if !errorlevel! leq 60 (set /a non_model_len=66-!errorlevel!) else set non_model_len=
  call %~dp0\strlen.bat "%abi%"
  set /a non_abi_len=70-!errorlevel!
  rem echo !non_abi_len!
)
title=%model%

:select_tool
echo=
echo %date% %time%
echo +-----------------------------------------------------------------------------------+
rem echo ^|Current file: %pkg%
set /p =^|Current file: %pkg%<nul&for /l %%a in (1,1,%non_pkg_len%) do set /p= <nul
if defined non_pkg_len (echo ^|) else echo=^|
rem echo ^|Current package name: %pkg_name%
setlocal enabledelayedexpansion&set /p =^|Current package name: %pkg_name%<nul&set padding="^|"&for /l %%a in (0,1,%non_pkg_name_len%) do set padding=" !padding:~1,-1!"
if defined non_pkg_name_len (echo %padding:"=%) else echo=^|
rem echo ^|Current device: %serial% (%model%)
set /p =^|Current device: %serial% (%model% Android %release%)<nul&set padding="^|"&for /l %%a in (0,1,%non_model_len%) do set padding=" !padding:~1,-1!"
if defined non_model_len (echo %padding:~1,-1%) else echo=^|
set /p =^|Device abi: %abi%<nul&set padding="^|"&for /l %%a in (0,1,%non_abi_len%) do set padding=" !padding:~1,-1!"
if defined non_abi_len (echo %padding:~1,-1%) else echo=^|
echo ^|i.Install   r.Replace install   a.Uninstall ^& install   u.Uninstall   c.Clear data ^|
echo ^|t.Input text   p.Input tap   s.Input swipe   k.Change package   d.Change device    ^|
echo ^|f.force stop   g.grant storage permission                                          ^|
echo +-----------------------------------------------------------------------------------+
endlocal
rem set tool=
rem set /p tool=tool: 
rem if not defined tool (echo No tool selected.
rem goto select_tool)
rem choice /c 1234567890 /m "tool: " /n
choice /c irauctpskdfgw /m "tool: " /n
set tool=%errorlevel%
rem goto 1

:jump_to_tool
if %tool% equ 1 goto install
if %tool% equ 2 goto replace_install
if %tool% equ 3 goto un_install
if %tool% equ 4 goto uninstall
if %tool% equ 5 goto clear_data
if %tool% equ 6 goto input_text
if %tool% equ 7 goto input_tap
if %tool% equ 8 goto input_swipe
if %tool% equ 9 goto set_package_input
if %tool% equ 10 goto select_device
if %tool% equ 11 goto force_stop
if %tool% equ 12 goto grant_permission
if %tool% equ 13 goto wake_up

:1
if %errorlevel% equ 1 goto install
if %errorlevel% equ 2 goto replace_install
if %errorlevel% equ 3 goto un_install
if %errorlevel% equ 4 goto uninstall
if %errorlevel% equ 5 goto clear_data
if %errorlevel% equ 6 goto input_text
if %errorlevel% equ 7 goto input_tap
if %errorlevel% equ 8 goto input_swipe
if %errorlevel% equ 9 goto set_package
if %errorlevel% equ 10 goto select_device

:install
echo on
if %model% equ V1818CA start %~dp0\vivoinstall.bat %serial% 1
if %model% equ PCT-AL10 start %~dp0\huaweiinstall.bat %serial% 1
adb -s %serial% install --abi %abi% %pkg%
@echo off
goto select_tool

:replace_install
echo on
if %model% equ V1818CA start %~dp0\vivoinstall.bat %serial% 1
if %model% equ PCT-AL10 start %~dp0\huaweiinstall.bat %serial% 1
adb -s %serial% install --abi %abi% -r %pkg%
@echo off
goto select_tool

:un_install
echo on
adb -s %serial% uninstall %pkg_name%
if %model% equ V1818CA start %~dp0\vivoinstall.bat %serial% 1
if %model% equ PCT-AL10 start %~dp0\huaweiinstall.bat %serial% 1
adb -s %serial% install --abi %abi% %pkg%
@echo off
goto select_tool

:uninstall
echo on
adb -s %serial% uninstall %pkg_name%
@echo off
goto select_tool

:clear_data
rem echo on
@rem choice /c 56q /n /m "press 5 to clear only app or press 6 to clear app and play or press q to quit"
choice /c cxq /n /m "press c to clear only app or press x to clear app and play or press q to quit"
@set choice=%errorlevel%
if %choice% equ 3 goto select_tool
rem echo %choice%
echo on
adb -s %serial% shell pm clear %pkg_name%
if %choice% equ 2 (
  rem adb -s %serial% shell pm clear com.android.vending
  rem adb -s %serial% shell am start com.android.vending/com.android.vending.AssetBrowserActivity
)
@echo off
goto select_tool

:input_text
echo=
echo device: %serial%
set text=
echo type text or type c to change device or type t to change tool:
set /p text=
rem set text=%text:\='\'%
rem set text=%text:&="\&"%
rem set text=%text:|="\|"%
rem set text=%text: ="\ "%
rem set text=%text:'="\'"%
rem set text=%text:"='\"'%
rem set text=%text:\='\'%
set text="%text:&=\&%"
rem set text=%text:|=\|%
set text=%text: =\ %
set text=%text:'=\'%
rem set text=%text:"=\"%
set text=%text:?=\?%
goto skip
rem set text=%text:*=\*%
:skip
rem set text_tmp="%text%"
rem echo %text_tmp%
if not defined text (echo Error input text
rem if %text_tmp% equ "" (echo Error input text
goto input_text)
if %text% equ "c" goto select_device
rem if %text_tmp% equ "c" goto select_device
if %text% equ "t" goto select_tool
rem if %text_tmp% equ "t" goto select_tool
echo on
if defined text adb -s %serial% shell input text %text%
@echo off
rem goto input_text
goto select_tool

:input_tap
echo=
echo device: %serial%
set times=
echo type tapping times or type c to change device or type t to change tool:
set /p times=
if not defined times (echo Times not set
goto input_tap)
if %times% equ c goto select_device
if %times% equ t goto select_tool
set coordinate=
set /p coordinate=x y: 
if not defined times (echo Coordinate not set
goto input_tap)
set /a count=0
:tap_loop
echo on
adb -s %serial% shell input tap %coordinate%
@echo off
set /a count+=1
echo %count%/%times% taps @%serial%
if %times% equ %count% goto input_tap
goto tap_loop

:input_swipe
echo=
echo device: %serial%
set times=
echo type swiping times or type c to change device or type t to change tool:
set /p times=
if not defined times (echo Times not set
goto input_swipe)
if %times% equ c goto select_device
if %times% equ t goto select_tool
set /a count=0
:x
set x=
set /p xmax=xmax(default 1080):
if not defined xmax (
set /a xmax=1080
echo set xmax to 1080)
:y
set y=
set /p ymax=ymax(default 1800):
if not defined ymax (
set /a ymax=1800
echo set ymax to 1800)
:swipe_loop
set /a x1=%random%%%%xmax%
set /a x2=%random%%%%xmax%
set /a y1=%random%%%%ymax%
set /a y2=%random%%%%ymax%
echo on
adb -s %serial% shell input swipe %x1% %y1% %x2% %y2% 30
@echo off
set /a count+=1
echo %count%/%times% swipes @%serial% (%x1%,%y1%)-^>(%x2%,%y2%)
if %times% equ %count% goto input_swipe
goto swipe_loop

:force_stop
echo on
adb -s %serial% shell am force-stop %pkg_name%
@echo off
goto select_tool

:grant_permission
echo on
adb -s %serial% shell pm grant %pkg_name% android.permission.READ_EXTERNAL_STORAGE
adb -s %serial% shell pm grant %pkg_name% android.permission.WRITE_EXTERNAL_STORAGE
@echo off
goto select_tool

:wake_up
echo on
adb -s %serial% shell input keyevent 26
adb -s %serial% shell input swipe 600 600 50 50 56
@echo off
goto select_tool
