# 医学影像测试图片说明

## 目录结构

测试图片应放置在HarmonyOS应用的资源目录中：

```
entry/src/main/resources/rawfile/medical-images/
├── chest-xray/        # 胸部X光示例图片
│   ├── sample1.jpg
│   └── sample2.jpg
├── bone-xray/         # 骨骼X光示例图片
│   └── sample1.jpg
├── skin-photo/        # 皮肤照片示例图片
│   ├── sample1.jpg
│   └── sample2.png
├── fundus-photo/      # 眼底照片示例图片
│   └── sample1.jpg
├── breast-ultrasound/ # 乳腺超声示例图片
│   └── sample1.jpg
└── other/             # 其他类型示例图片
    └── sample1.jpg
```

## 图片要求

### 格式要求
- **支持格式**: JPG、PNG、WebP、DICOM
- **推荐格式**: JPG（压缩效果好，加载速度快）
- **色彩空间**: RGB或灰度

### 大小要求
- **单个文件**: ≤ 10MB
- **推荐大小**: 1-3MB（平衡画质和加载速度）
- **分辨率**: 建议 800x600 ~ 1920x1080

### 命名规范
- 文件名使用小写字母和连字符
- 示例：sample1.jpg、sample2.jpg、chest-normal.jpg
- 避免使用中文和特殊字符

## 如何添加测试图片

### 步骤1: 准备图片文件
从项目根目录的 `img/` 文件夹中选择测试图片，或使用您自己的医学影像图片。

### 步骤2: 复制到对应目录
根据影像类型，将图片复制到对应的子目录：

```bash
# 示例：复制胸部X光图片
cp img/chest-xray-001.jpg entry/src/main/resources/rawfile/medical-images/chest-xray/sample1.jpg

# 示例：复制皮肤照片
cp img/skin-lesion-001.jpg entry/src/main/resources/rawfile/medical-images/skin-photo/sample1.jpg
```

### 步骤3: 更新数据库
运行SQL初始化脚本：

```bash
mysql -u root -p medical_health < sql/sample_data_init.sql
```

## 示例图片说明

### 1. 胸部X光 (CHEST_XRAY)
- **用途**: 肺部疾病筛查、心脏大小评估
- **拍摄位置**: 后前位（PA）、侧位
- **示例内容**: 正常胸部、肺炎、肺结节等

### 2. 骨骼X光 (BONE_XRAY)
- **用途**: 骨折检测、关节病变诊断
- **拍摄部位**: 四肢、脊柱、胸廓
- **示例内容**: 正常骨骼、骨折、骨质疏松等

### 3. 皮肤照片 (SKIN_PHOTO)
- **用途**: 皮肤病诊断、皮损分析
- **拍摄要求**: 充足光照、清晰对焦
- **示例内容**: 皮疹、色素痣、溃疡等

### 4. 眼底照片 (FUNDUS_PHOTO)
- **用途**: 糖尿病视网膜病变筛查、青光眼诊断
- **拍摄设备**: 眼底照相机
- **示例内容**: 正常眼底、视网膜病变、视盘水肿等

### 5. 乳腺超声 (BREAST_ULTRASOUND)
- **用途**: 乳腺肿块筛查、良恶性判断
- **成像特点**: 灰阶超声、彩色多普勒
- **示例内容**: 正常乳腺、乳腺囊肿、乳腺肿瘤等

### 6. 其他类型 (OTHER)
- **用途**: 其他医学影像类型
- **包括**: CT、MRI、PET-CT等（预留扩展）

## 注意事项

1. **隐私保护**: 
   - 请勿使用真实患者的个人信息
   - 推荐使用公开数据集或合成影像

2. **版权声明**: 
   - 确保使用的图片有合法授权
   - 标注图片来源和版权信息

3. **质量控制**: 
   - 图片应清晰可辨，无明显伪影
   - 避免过度压缩导致细节丢失

4. **存储优化**: 
   - 使用压缩工具优化图片大小
   - 推荐工具: TinyPNG、ImageOptim

## 公开数据集推荐

如果需要医学影像测试数据，可使用以下公开数据集：

1. **NIH Chest X-ray Dataset**: 美国国立卫生研究院胸部X光数据集
2. **ISIC Archive**: 国际皮肤成像合作档案
3. **DDSM**: 数字乳腺筛查数据库
4. **MURA**: 肌肉骨骼X光异常检测数据集

## 数据库查询

查询已导入的示例图片：

```sql
SELECT 
    image_id,
    image_type,
    original_format,
    ROUND(original_size/1024/1024, 2) AS size_mb,
    storage_url
FROM image_metadata 
WHERE image_id LIKE 'SAMPLE-%'
ORDER BY image_type;
```

## 相关文件

- 数据库初始化脚本: `sql/sample_data_init.sql`
- 前端示例图片加载: `entry/src/main/ets/pages/medicalimage/MedicalImageDiagnosisPage.ets`
- 后端API接口: `src/main/java/com/example/medical/controller/medicalimage/MedicalImageController.java`
