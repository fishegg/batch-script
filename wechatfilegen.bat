@set file_prefix=%date%_%time%
@set file_prefix=%file_prefix:/=_%
@set file_prefix=%file_prefix: =_%
@echo %file_prefix%
@echo off

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

:checktestfile
set testfileexists=null
for /f "tokens=1" %%a in ('adb -s %serial% shell find /sdcard/testfile') do set testfileexists=%%a
if %testfileexists% equ null echo please push testfile to /sdcard and press any key to continue & pause & goto checktestfile
if %testfileexists% equ find: echo please push testfile to /sdcard and press any key to continue & pause & goto checktestfile
set maxfilescount=
set /p maxfilescount=enter a value to define the count of files desired to generate (1-100):
set externalPath=/sdcard/tencent/MicroMsg
set internalPath=/sdcard/Android/data/com.tencent.mm
set internalMicroMsgPath=/sdcard/Android/data/com.tencent.mm/MicroMsg
set testimagepath=/sdcard/testfile/image
set testvideopath=/sdcard/testfile/video
set testvoicepath=/sdcard/testfile/voice
set testdownloadpath=/sdcard/testfile/Download
adb -s %serial% shell mkdir /sdcard/tencent 2>nul
adb -s %serial% shell mkdir /sdcard/tencent/MicroMsg 2>nul
adb -s %serial% shell mkdir /sdcard/tencent/MicroMsg/7a15499ef5ab7e5f926c94499bf981ff 2>nul
adb -s %serial% shell mkdir /sdcard/tencent/MicroMsg/7a15499ef5ab7e5f926c94499bf981aa 2>nul
adb -s %serial% shell mkdir /sdcard/Android/data/com.tencent.mm 2>nul
adb -s %serial% shell mkdir /sdcard/Android/data/com.tencent.mm/MicroMsg 2>nul
set recovery=%externalPath%/recovery
set diskcache=%externalPath%/diskcache
set vusericon=%externalPath%/vusericon
set extvideocache=%externalPath%/videocache
set xlog=%externalPath%/xlog
set checkresupdate=%externalPath%/CheckResUpdate
set card=%externalPath%/card
set extcrash=%externalPath%/crash
set game=%externalPath%/Game
set sqltrace=%externalPath%/SQLTrace
set handler=%externalPath%/Handler
set tmp=%externalPath%/.tmp
set download=%externalPath%/Download

set intcache=%internalPath%/cache
set tbslog=%internalPath%/files/tbslog
set intvideocache=%internalPath%/files/VideoCache

set wallet=%internalPath%/MicroMsg/wallet
set recbiz=%internalPath%/MicroMsg/recbiz

set wxacache=%externalPath%/wxacache
set wxafiles=%externalPath%/wxafiles
set wxanewfiles=%externalPath%/wxanewfiles

rem -----------------------------

adb -s %serial% shell mkdir %externalPath% 2>nul
adb -s %serial% shell mkdir %internalPath% 2>nul
adb -s %serial% shell mkdir %externalPath%/recovery 2>nul
adb -s %serial% shell mkdir %externalPath%/diskcache 2>nul
adb -s %serial% shell mkdir %externalPath%/vusericon 2>nul
adb -s %serial% shell mkdir %externalPath%/videocache 2>nul
adb -s %serial% shell mkdir %externalPath%/xlog 2>nul
adb -s %serial% shell mkdir %externalPath%/CheckResUpdate 2>nul
adb -s %serial% shell mkdir %externalPath%/card 2>nul
adb -s %serial% shell mkdir %externalPath%/crash 2>nul
adb -s %serial% shell mkdir %externalPath%/Game 2>nul
adb -s %serial% shell mkdir %externalPath%/SQLTrace 2>nul
adb -s %serial% shell mkdir %externalPath%/Handler 2>nul
adb -s %serial% shell mkdir %externalPath%/.tmp 2>nul
adb -s %serial% shell mkdir %externalPath%/Download 2>nul

adb -s %serial% shell mkdir %internalPath%/cache 2>nul
adb -s %serial% shell mkdir %internalPath%/files 2>nul
adb -s %serial% shell mkdir %internalPath%/files/tbslog 2>nul
adb -s %serial% shell mkdir %internalPath%/files/VideoCache 2>nul

adb -s %serial% shell mkdir %internalPath%/MicroMsg 2>nul
adb -s %serial% shell mkdir %internalPath%/MicroMsg/wallet 2>nul
adb -s %serial% shell mkdir %internalPath%/MicroMsg/recbiz 2>nul

adb -s %serial% shell mkdir %externalPath%/wxacache 2>nul
adb -s %serial% shell mkdir %externalPath%/wxafiles 2>nul
adb -s %serial% shell mkdir %externalPath%/wxanewfiles 2>nul

@rem goto test
echo -------------------------------------------------------------------------
rem echo on
for /l %%i in (1,1,%maxfilescount%) do (
  echo creating %%i/%maxfilescount% files named as %file_prefix% at directories
  rem adb -s %serial% shell touch %recovery%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %diskcache%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %vusericon%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %extvideocache%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %xlog%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %checkresupdate%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %card%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %extcrash%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %game%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %sqltrace%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %handler%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %tmp%/%file_prefix%_%%i
  
  rem adb -s %serial% shell touch %intcache%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %tbslog%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %intvideocache%/%file_prefix%_%%i

  rem adb -s %serial% shell touch %wallet%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %recbiz%/%file_prefix%_%%i

  rem adb -s %serial% shell touch %wxacache%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %wxafiles%/%file_prefix%_%%i
  rem adb -s %serial% shell touch %wxanewfiles%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %recovery%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %diskcache%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %vusericon%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %extvideocache%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %xlog%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %checkresupdate%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %card%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %extcrash%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %game%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %sqltrace%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %handler%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %tmp%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %download%/%file_prefix%_%%i
  
  adb -s %serial% shell cp %testimagepath%/%%i.png %intcache%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %tbslog%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %intvideocache%/%file_prefix%_%%i

  adb -s %serial% shell cp %testimagepath%/%%i.png %wallet%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %recbiz%/%file_prefix%_%%i

  adb -s %serial% shell cp %testimagepath%/%%i.png %wxacache%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %wxafiles%/%file_prefix%_%%i
  adb -s %serial% shell cp %testimagepath%/%%i.png %wxanewfiles%/%file_prefix%_%%i
)
echo created %maxfilescount% files named as %file_prefix% at directories below
echo %recovery%   %diskcache%   %vusericon%   %extvideocache%   %xlog%   %checkresupdate%   %card%   %extcrash%   %game%   %sqltrace%   %handler%   %tmp%   %intcache%   %tbslog%   %intvideocache%   %wallet%   %recbiz%   %wxacache%   %wxafiles%   %wxanewfiles%
@echo off
echo -------------------------------------------------------------------------

:test
rem pause
rem echo on
setlocal enabledelayedexpansion
echo -------------------------------------------------------------------------
rem echo on
for /f "tokens=1" %%a in ('adb -s %serial% shell ls %internalMicroMsgPath%') do (
  rem create files
  if exist %~dp0\strlen.bat (
  rem pause
    call %~dp0\strlen.bat %%a
    rem pause
    if !errorlevel! gtr 25 (
      set image=%internalMicroMsgPath%/%%a/image
      set bizimg=%internalMicroMsgPath%/%%a/bizimg
      set brandicon=%internalMicroMsgPath%/%%a/brandicon
      rem adb -s %serial% shell mkdir %internalMicroMsgPath%/%%a
      adb -s %serial% shell mkdir !image! 2>nul
      adb -s %serial% shell mkdir !bizimg! 2>nul
      adb -s %serial% shell mkdir !brandicon! 2>nul
      for /l %%i in (1,1,%maxfilescount%) do (
        echo creating %%i/%maxfilescount% files named as %file_prefix% at directories
        rem adb -s %serial% shell touch !image!/%file_prefix%_%%i.png
        rem adb -s %serial% shell touch !bizimg!/%file_prefix%_%%i.png
        rem adb -s %serial% shell touch !brandicon!/%file_prefix%_%%i.png
        adb -s %serial% shell cp %testimagepath%/%%i.png !image!/%file_prefix%_%%i.png
        adb -s %serial% shell cp %testimagepath%/%%i.png !bizimg!/%file_prefix%_%%i.png
        adb -s %serial% shell cp %testimagepath%/%%i.png !brandicon!/%file_prefix%_%%i.png
      )
      echo created %maxfilescount% files named as %file_prefix% at directories below
      echo !image!   !bizimg!   !brandicon!
      echo -------------------------------------------------------------------------)
  )
)
@echo off

echo -------------------------------------------------------------------------
rem echo on
for /f "tokens=1" %%a in ('adb -s %serial% shell ls %externalPath%') do (
  rem create files
  if exist %~dp0\strlen.bat (
    call %~dp0\strlen.bat %%a
    if !errorlevel! gtr 25 (
      rem set image=%externalPath%/%%a/image
      set bizimg=%externalPath%/%%a/bizimg
      set brandicon=%externalPath%/%%a/brandicon
      set emoji=%externalPath%/%%a/emoji
      set video=%externalPath%/%%a/video
      set image2=%externalPath%/%%a/image2
      set voice2=%externalPath%/%%a/voice2
      set Download=%externalPath%/%%a/Download
      rem adb -s %serial% shell mkdir %externalPath%/%%a
      rem adb -s %serial% shell mkdir !image! 2>nul
      adb -s %serial% shell mkdir !bizimg! 2>nul
      adb -s %serial% shell mkdir !brandicon! 2>nul
      adb -s %serial% shell mkdir !emoji! 2>nul
      adb -s %serial% shell mkdir !video! 2>nul
      adb -s %serial% shell mkdir !image2! 2>nul
      adb -s %serial% shell mkdir !image2!/0a 2>nul
      adb -s %serial% shell mkdir !image2!/0a/01 2>nul
      adb -s %serial% shell mkdir !image2!/1a 2>nul
      adb -s %serial% shell mkdir !image2!/1a/01 2>nul
      adb -s %serial% shell mkdir !voice2! 2>nul
      rem adb -s %serial% shell mkdir !Download! 2>nul
      for /l %%i in (1,1,%maxfilescount%) do (
        echo creating %%i/%maxfilescount% files named as %file_prefix% at directories
        rem adb -s %serial% shell touch !image!/%file_prefix%_%%i
        rem adb -s %serial% shell touch !bizimg!/%file_prefix%_%%i.png
        rem adb -s %serial% shell touch !brandicon!/%file_prefix%_%%i.png
        rem adb -s %serial% shell touch !emoji!/%file_prefix%_%%i.png
        rem adb -s %serial% shell touch !video!/%file_prefix%_%%i.mp4
        rem adb -s %serial% shell touch !video!/%file_prefix%_%%i.jpg
        rem adb -s %serial% shell touch !image2!/%file_prefix%_%%i.jpg
        rem adb -s %serial% shell touch !voice2!/%file_prefix%_%%i.aac
        rem adb -s %serial% shell touch !Download!/%file_prefix%_%%i.txt
        adb -s %serial% shell cp %testimagepath%/%%i.png !bizimg!/%file_prefix%_%%i.png
        adb -s %serial% shell cp %testimagepath%/%%i.png !brandicon!/%file_prefix%_%%i.png
        adb -s %serial% shell cp %testimagepath%/%%i.png !emoji!/%file_prefix%_%%i.png
        adb -s %serial% shell cp %testvideopath%/%%i.mp4 !video!/%file_prefix%_%%i.mp4
        adb -s %serial% shell cp %testvideopath%/%%i.jpg !video!/%file_prefix%_%%i.jpg
        adb -s %serial% shell cp %testimagepath%/%%i.png !image2!/0a/01/%file_prefix%_%%i.png
        adb -s %serial% shell cp %testimagepath%/%%i.png !image2!/1a/01/%file_prefix%_%%i.png
        adb -s %serial% shell cp %testvoicepath%/%%i.amr !voice2!/%file_prefix%_%%i.amr
        rem adb -s %serial% shell cp %testdownloadpath%/%%i.png !Download!/%file_prefix%_%%i.png
      )
      echo created %maxfilescount% files named as %file_prefix% at directories below
      echo !bizimg!   !brandicon!   !emoji!   !video!   !image2!   !voice2!   !Download!
      echo -------------------------------------------------------------------------)
  )
)
@echo off
setlocal disabledelayedexpansion
echo %file_prefix%
pause