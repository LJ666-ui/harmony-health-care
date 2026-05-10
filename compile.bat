@echo off
echo ============================================
echo Compiling Harmony Health Care Project
echo ============================================
echo.

echo Step 1: Cleaning build cache...
call hvigorw clean

echo.
echo Step 2: Building project...
call hvigorw assembleHap

echo.
echo ============================================
echo Compilation Complete
echo ============================================
pause
