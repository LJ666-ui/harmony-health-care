@echo off
chcp 65001 >nul
REM 医学影像测试图片复制脚本 (Windows版本)
REM 用途: 从img文件夹复制测试图片到HarmonyOS资源目录

set SOURCE_DIR=E:\harmony-health-care\img
set TARGET_DIR=E:\harmony-health-care\entry\src\main\resources\rawfile\medical-images

echo ===================================
echo 医学影像测试图片复制工具
echo ===================================
echo.

REM 检查源目录是否存在
if not exist "%SOURCE_DIR%" (
    echo 错误: 源目录不存在: %SOURCE_DIR%
    echo 请确保img文件夹存在并包含测试图片
    pause
    exit /b 1
)

REM 创建目标目录
if not exist "%TARGET_DIR%\chest-xray" mkdir "%TARGET_DIR%\chest-xray"
if not exist "%TARGET_DIR%\bone-xray" mkdir "%TARGET_DIR%\bone-xray"
if not exist "%TARGET_DIR%\skin-photo" mkdir "%TARGET_DIR%\skin-photo"
if not exist "%TARGET_DIR%\fundus-photo" mkdir "%TARGET_DIR%\fundus-photo"
if not exist "%TARGET_DIR%\breast-ultrasound" mkdir "%TARGET_DIR%\breast-ultrasound"
if not exist "%TARGET_DIR%\other" mkdir "%TARGET_DIR%\other"

echo 目标目录结构已创建
echo.

echo 开始复制测试图片...
echo.

REM 复制胸部X光图片
echo 1. 胸部X光图片
if exist "%SOURCE_DIR%\chest_xray_sample1.jpg" (
    copy /Y "%SOURCE_DIR%\chest_xray_sample1.jpg" "%TARGET_DIR%\chest-xray\sample1.jpg" >nul
    echo √ 已复制 胸部X光: sample1.jpg
) else (
    echo × 文件不存在: chest_xray_sample1.jpg
)

if exist "%SOURCE_DIR%\chest_xray_sample2.jpg" (
    copy /Y "%SOURCE_DIR%\chest_xray_sample2.jpg" "%TARGET_DIR%\chest-xray\sample2.jpg" >nul
    echo √ 已复制 胸部X光: sample2.jpg
) else (
    echo × 文件不存在: chest_xray_sample2.jpg
)

echo.
REM 复制骨骼X光图片
echo 2. 骨骼X光图片
if exist "%SOURCE_DIR%\bone_xray_sample1.jpg" (
    copy /Y "%SOURCE_DIR%\bone_xray_sample1.jpg" "%TARGET_DIR%\bone-xray\sample1.jpg" >nul
    echo √ 已复制 骨骼X光: sample1.jpg
) else (
    echo × 文件不存在: bone_xray_sample1.jpg
)

echo.
REM 复制皮肤照片
echo 3. 皮肤照片
if exist "%SOURCE_DIR%\skin_photo_sample1.jpg" (
    copy /Y "%SOURCE_DIR%\skin_photo_sample1.jpg" "%TARGET_DIR%\skin-photo\sample1.jpg" >nul
    echo √ 已复制 皮肤照片: sample1.jpg
) else (
    echo × 文件不存在: skin_photo_sample1.jpg
)

if exist "%SOURCE_DIR%\skin_photo_sample2.png" (
    copy /Y "%SOURCE_DIR%\skin_photo_sample2.png" "%TARGET_DIR%\skin-photo\sample2.png" >nul
    echo √ 已复制 皮肤照片: sample2.png
) else (
    echo × 文件不存在: skin_photo_sample2.png
)

echo.
REM 复制眼底照片
echo 4. 眼底照片
if exist "%SOURCE_DIR%\fundus_photo_sample1.jpg" (
    copy /Y "%SOURCE_DIR%\fundus_photo_sample1.jpg" "%TARGET_DIR%\fundus-photo\sample1.jpg" >nul
    echo √ 已复制 眼底照片: sample1.jpg
) else (
    echo × 文件不存在: fundus_photo_sample1.jpg
)

echo.
REM 复制乳腺超声
echo 5. 乳腺超声
if exist "%SOURCE_DIR%\breast_ultrasound_sample1.jpg" (
    copy /Y "%SOURCE_DIR%\breast_ultrasound_sample1.jpg" "%TARGET_DIR%\breast-ultrasound\sample1.jpg" >nul
    echo √ 已复制 乳腺超声: sample1.jpg
) else (
    echo × 文件不存在: breast_ultrasound_sample1.jpg
)

echo.
REM 复制其他类型
echo 6. 其他类型
if exist "%SOURCE_DIR%\other_medical_sample1.jpg" (
    copy /Y "%SOURCE_DIR%\other_medical_sample1.jpg" "%TARGET_DIR%\other\sample1.jpg" >nul
    echo √ 已复制 其他类型: sample1.jpg
) else (
    echo × 文件不存在: other_medical_sample1.jpg
)

echo.
echo ===================================
echo 复制完成！
echo ===================================
echo.
echo 下一步操作:
echo 1. 运行数据库初始化脚本:
echo    mysql -u root -p medical_health ^< sql\sample_data_init.sql
echo.
echo 2. 重新编译HarmonyOS应用
echo.
echo 3. 运行应用并测试示例图片功能
echo.
pause
