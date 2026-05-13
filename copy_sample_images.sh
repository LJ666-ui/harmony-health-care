#!/bin/bash

# 医学影像测试图片复制脚本
# 用途: 从img文件夹复制测试图片到HarmonyOS资源目录

SOURCE_DIR="E:/harmony-health-care/img"
TARGET_DIR="E:/harmony-health-care/entry/src/main/resources/rawfile/medical-images"

echo "==================================="
echo "医学影像测试图片复制工具"
echo "==================================="
echo ""

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 源目录不存在: $SOURCE_DIR"
    echo "请确保img文件夹存在并包含测试图片"
    exit 1
fi

# 创建目标目录
mkdir -p "$TARGET_DIR/chest-xray"
mkdir -p "$TARGET_DIR/bone-xray"
mkdir -p "$TARGET_DIR/skin-photo"
mkdir -p "$TARGET_DIR/fundus-photo"
mkdir -p "$TARGET_DIR/breast-ultrasound"
mkdir -p "$TARGET_DIR/other"

echo "目标目录结构已创建"
echo ""

# 函数: 复制图片并重命名
copy_image() {
    local src=$1
    local dest=$2
    local type=$3
    
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        echo "✓ 已复制 $type: $src -> $dest"
    else
        echo "✗ 文件不存在: $src"
    fi
}

echo "开始复制测试图片..."
echo ""

# 复制胸部X光图片
echo "1. 胸部X光图片"
copy_image "$SOURCE_DIR/chest_xray_sample1.jpg" "$TARGET_DIR/chest-xray/sample1.jpg" "胸部X光"
copy_image "$SOURCE_DIR/chest_xray_sample2.jpg" "$TARGET_DIR/chest-xray/sample2.jpg" "胸部X光"

# 复制骨骼X光图片
echo ""
echo "2. 骨骼X光图片"
copy_image "$SOURCE_DIR/bone_xray_sample1.jpg" "$TARGET_DIR/bone-xray/sample1.jpg" "骨骼X光"

# 复制皮肤照片
echo ""
echo "3. 皮肤照片"
copy_image "$SOURCE_DIR/skin_photo_sample1.jpg" "$TARGET_DIR/skin-photo/sample1.jpg" "皮肤照片"
copy_image "$SOURCE_DIR/skin_photo_sample2.png" "$TARGET_DIR/skin-photo/sample2.png" "皮肤照片"

# 复制眼底照片
echo ""
echo "4. 眼底照片"
copy_image "$SOURCE_DIR/fundus_photo_sample1.jpg" "$TARGET_DIR/fundus-photo/sample1.jpg" "眼底照片"

# 复制乳腺超声
echo ""
echo "5. 乳腺超声"
copy_image "$SOURCE_DIR/breast_ultrasound_sample1.jpg" "$TARGET_DIR/breast-ultrasound/sample1.jpg" "乳腺超声"

# 复制其他类型
echo ""
echo "6. 其他类型"
copy_image "$SOURCE_DIR/other_medical_sample1.jpg" "$TARGET_DIR/other/sample1.jpg" "其他类型"

echo ""
echo "==================================="
echo "复制完成！"
echo "==================================="
echo ""
echo "下一步操作:"
echo "1. 运行数据库初始化脚本:"
echo "   mysql -u root -p medical_health < sql/sample_data_init.sql"
echo ""
echo "2. 重新编译HarmonyOS应用"
echo ""
echo "3. 运行应用并测试示例图片功能"
