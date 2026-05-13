# 智能体平台部署完整指南

> **项目**: Harmony Health Care (智慧康养)
> **更新时间**: 2026-05-12
> **适用平台**: MindSpore Lite / HiAI (华为) / Coze (字节) / 小艺Skill (华为) / 硅基流动

---

## 📋 目录

1. [MindSpore Lite 端侧推理引擎部署](#1-mindspore-lite-端侧推理引擎部署)
2. [华为开发者控制台 HiAI NPU加速配置](#2-华为开发者控制台-hiai-npu加速配置)
3. [Coze 智能体平台对接指南](#3-coze-智能体平台对接指南)
4. [小艺 Skill 注册与Intent配置](#4-小艺-skill-注册与intent配置)
5. [硅基流动 (SiliconFlow) 快速接入](#5-硅基流动-siliconflow-快速接入)
6. [全部参数汇总表（部署完需要填什么）](#6-全部参数汇总表部署完需要填什么)
7. [统一测试验证清单](#7-统一测试验证清单)

---

## 1. MindSpore Lite 端侧推理引擎部署

### 🎯 平台信息
- **官网下载页**: https://www.mindspore.cn/lite/docs/en/stable/use/downloads.html
- **用途**: 端侧AI模型推理（风险评估、异常检测、跌倒预测）
- **优势**: 数据不上云，保护用户隐私，低延迟

### 📦 在项目中用到了哪里？

| 功能模块 | 代码位置 | 调用场景 |
|---------|---------|---------|
| 风险评估引擎 | `entry/src/main/ets/mindsphere/MindSporeLiteEngine.ets` | 共病风险5维度评估 |
| 异常检测 | `MindSporeLiteEngine.detectAnomaly()` | 健康数据实时监测 |
| 规则引擎Fallback | `MindSporeLiteEngine.runRuleBasedAssessment()` | 模型不存在时降级 |

**核心调用示例**:
```typescript
import { MindSporeLiteEngine } from '../mindsphere/MindSporeLiteEngine';

const engine = MindSporeLiteEngine.getInstance();
await engine.initialize();

const result = await engine.assessRisk({
  age: 68, gender: 1, bmi: 24.5,
  systolic: 145, diastolic: 92,
  fastingGlucose: 6.8, hba1c: 6.5,
  exerciseFrequency: 2, sleepDuration: 6,
  stepCount: 3000, sedentaryTime: 8,
  smoking: 0, drinking: 0,
  hypertensionHistory: 1, diabetesHistory: 0,
  heartDiseaseHistory: 0, strokeHistory: 0,
  fractureHistory: 0, medicationCount: 3
});

console.log('风险等级:', result.overallLevel);
```

### 🔧 部署步骤

#### Step 1: 确认HarmonyOS内置MindSpore Lite能力

**重要**: 在HarmonyOS中，MindSpore Lite是**系统内置的AI推理引擎**，通过 `@ohos.ai.mindSporeLite` API直接调用，**不需要像Android那样手动下载SDK和集成so库！**

**你需要做的**:
1. 确保你的DevEco Studio版本 >= 5.0
2. 确保HarmonyOS SDK版本 >= API 12（在DevEco Studio → File → Settings → SDK中查看）
3. 如果SDK中没有AI模块，在SDK Manager中勾选安装 **"AI"** 组件

**验证方法**:
在代码中输入 `import { mindSporeLite } from '@ohos.ai.mindSporeLite';`，如果没有报错说明SDK已就绪。

#### Step 2: 下载模型转换工具（仅Windows开发机需要）

如果你需要自己训练和转换模型（.ms格式），需要下载MindSpore Lite的转换工具。

**下载地址**: https://www.mindspore.cn/lite/docs/en/stable/use/downloads.html

**选择哪个版本？**:

| 你需要什么 | 选择哪个包 | 文件名 | 大小 |
|-----------|-----------|--------|------|
| 模型转换工具 (在Windows上把PyTorch/ONNX模型转成.ms) | **End-to-end inference → CPU → Windows-x86_64** | `mindspore-lite-2.9.0-win-x64.zip` | ~200MB |
| Python API (用Python训练和转换模型) | **Python API → CPU/Ascend → Linux-x86_64 → Python3.10** | `mindspore_lite-2.9.0-cp310-cp310-linux_x86_64.whl` | ~150MB |

**⚠️ 注意**:
- **手机端运行不需要下载任何东西**，HarmonyOS系统自带MindSpore Lite运行时
- 上面这些下载是给**开发机**用的，用于训练和转换模型
- 如果你不打算自己训练模型，**可以跳过这一步**，直接用项目已实现的规则引擎Fallback

**下载步骤**:
1. 打开 https://www.mindspore.cn/lite/docs/en/stable/use/downloads.html
2. 找到 **"2.9.0"** 版本区域（最新稳定版）
3. 在 **"MindSpore Lite Development Library"** 表格中
4. 找到行: **End-to-end inference** → **CPU** → **Windows-x86_64**
5. 点击下载链接: `mindspore-lite-2.9.0-win-x64.zip`
6. 验证SHA-256: `bdfd3fa0fe32c246e0dd4741a9640ff767d59636444e1f8b4911c1a6f3b206d2`

**解压后目录结构**:
```
mindspore-lite-2.9.0-win-x64/
├── runtime/                    # 推理运行时（Windows上测试用）
│   ├── lib/
│   │   └── libmindspore_lite.so  # 推理库
│   └── include/                # C++头文件
├── tools/
│   └── converter/              # ★ 模型转换工具（核心！）
│       └── converter.exe       # ONNX/TFLite → .ms 转换器
└── benchmark/                  # 性能基准测试工具
```

#### Step 3: 准备模型文件 (.ms格式)

**当前项目需要的模型**:

| 模型名称 | 放置路径 | 用途 | 输入维度 | 输出维度 |
|---------|---------|------|---------|---------|
| risk_assess.ms | `entry/src/main/resources/rawfile/risk_assess.ms` | 共病风险评估 | [1, 20] | [1, 5] |

**获取模型的三种方式**:

**方式A: 不用模型，直接用规则引擎（最简单，推荐先跑通）**

项目代码已经实现了完整的规则引擎Fallback。即使没有模型文件，`MindSporeLiteEngine` 也能正常工作，会自动使用 `runRuleBasedAssessment()` 方法进行基于规则的风险评估。

**你什么都不需要做，直接运行项目即可。**

**方式B: 下载预训练模型（推荐）**

1. 访问 MindSpore Hub: https://www.mindspore.cn/resources/hub
2. 搜索 "health risk" 或 "classification" 类模型
3. 下载 .ms 格式模型文件
4. 重命名为 `risk_assess.ms`
5. 放到 `entry/src/main/resources/rawfile/` 目录下

**方式C: 自己训练模型（高级）**

需要Python环境和MindSpore训练框架：

```bash
# 1. 安装MindSpore (Linux环境)
pip install mindspore==2.9.0

# 2. 训练模型 (Python脚本)
# 参考项目中的训练模板，输入20维健康特征，输出5维风险概率

# 3. 导出为MINDIR格式
ms.export(model, Tensor(np.float32, [1, 20]), file_name='risk_assess', file_format='MINDIR')

# 4. 使用转换工具转为.ms格式 (Windows上执行)
# 解压Step 2下载的 mindspore-lite-2.9.0-win-x64.zip
cd mindspore-lite-2.9.0-win-x64/tools/converter
./converter.exe --fmk=MINDIR --modelFile=risk_assess.mindir --outputFile=risk_assess

# 5. 将生成的 risk_assess.ms 复制到项目
copy risk_assess.ms entry/src/main/resources/rawfile/
```

#### Step 4: 在代码中调用MindSpore Lite API

**当前项目状态**: `MindSporeLiteEngine.ets` 中使用的是模拟推理。要接入真实API，需要修改以下内容：

**4.1 添加import** (文件顶部):
```typescript
import { mindSporeLite } from '@ohos.ai.mindSporeLite';
```

**4.2 修改initialize()方法**:
```typescript
async initialize(): Promise<boolean> {
  try {
    console.info('[MindSpore] 正在初始化推理引擎...');

    const modelExists = await this.checkModelFile(this.riskModelConfig.modelPath);

    if (modelExists) {
      this.useRealModel = true;

      // ★ 新增：使用HarmonyOS内置API加载模型
      const context = { device: 'CPU' };  // 使用CPU推理，如需NPU改为 'NPU'
      const msLite = await mindSporeLite.createContext(context);
      this.model = await msLite.loadModelFromFile(this.riskModelConfig.modelPath);

      console.info('[MindSpore] 模型加载成功');
    } else {
      this.useRealModel = false;
      console.warn('[MindSpore] 模型文件不存在，将使用规则引擎作为fallback');
    }

    this.isInitialized = true;
    return true;
  } catch (error) {
    console.error('[MindSpore] 初始化失败:', error);
    this.useRealModel = false;
    this.isInitialized = true;
    return true;
  }
}
```

**4.3 修改runRealInference()方法**:
```typescript
private async runRealInference(input: RiskAssessmentInput): Promise<number[]> {
  // 将输入数据转为Float32Array
  const inputData = new Float32Array([
    input.age, input.gender, input.bmi, input.smoking, input.drinking,
    input.systolic, input.diastolic, input.fastingGlucose, input.hba1c,
    input.exerciseFrequency, input.sleepDuration, input.stepCount,
    input.sedentaryTime, input.hypertensionHistory, input.diabetesHistory,
    input.heartDiseaseHistory, input.strokeHistory, input.fractureHistory,
    input.medicationCount, 0  // padding
  ]);

  // 执行推理
  const inputs = this.model.getInputs();
  inputs[0].setData(inputData.buffer);
  const outputs = await this.model.predict(inputs);

  // 解析输出
  const outputData = new Float32Array(outputs[0].getData());
  return Array.from(outputData);
}
```

### ✅ 测试验证

```bash
# 查看日志
hdc shell hilog | grep MindSpore

# 预期输出（无模型）:
# [MindSpore] 正在初始化推理引擎...
# [MindSpore] 模型文件不存在，将使用规则引擎作为fallback
# [MindSpore] 引擎初始化完成, 使用模式: 规则引擎
# [MindSpore] 风险评估完成, 耗时=45ms, 等级=medium

# 预期输出（有模型）:
# [MindSpore] 正在初始化推理引擎...
# [MindSpore] 模型加载成功
# [MindSpore] 引擎初始化完成, 使用模式: 真实模型
# [MindSpore] 风险评估完成, 耗时=12ms, 等级=medium
```

### ⚠️ 常见问题

**Q1: 我需要下载MindSpore Lite SDK吗？**
**不需要！** HarmonyOS系统内置了 `@ohos.ai.mindSporeLite` API。你只需要确保DevEco Studio的HarmonyOS SDK中包含AI组件。

**Q2: 那下载页面上的东西是给谁用的？**
- `Windows-x86_64` 版本 → 给开发机用的**模型转换工具**
- `Android-aarch64` 版本 → 给Android应用用的（我们不用）
- `Linux-x86_64/aarch64` 版本 → 给服务器端推理用的（我们不用）

**Q3: 没有模型文件能用吗？**
**可以！** 代码已实现规则引擎Fallback，会自动降级使用基于规则的评估算法。

**Q4: 模型文件放在哪里？**
```
entry/src/main/resources/rawfile/risk_assess.ms
```

---

## 2. 华为开发者控制台 HiAI NPU加速配置

### 🎯 平台信息
- **控制台**: https://developer.huawei.com/consumer/cn/console/overview
- **用途**: 利用麒麟芯片NPU进行图像处理加速
- **能力**: 图像分类、OCR文字识别、姿态检测

### 📦 在项目中用到了哪里？

| 功能模块 | 代码位置 | 调用场景 |
|---------|---------|---------|
| 医学影像分类 | `entry/src/main/ets/hiai/HiAIVisionClient.classifyImage()` | X光/CT/MRI自动识别 |
| OCR文字识别 | `HiAIVisionClient.recognizeText()` | 古籍医书、检验报告提取 |
| 康复姿态检测 | `HiAIVisionClient.detectPose()` | 康复动作关键点识别 |

### 🔧 部署步骤

#### Step 1: 注册华为开发者账号

1. 访问 https://developer.huawei.com/consumer/cn/console/overview
2. 点击右上角 **"注册"**
3. 使用手机号注册华为账号
4. 完成实名认证:
   - 个人开发者: 身份证正反面 + 人脸识别
   - 企业开发者: 营业执照 + 法人信息
5. 实名认证通常 **1-3个工作日** 通过

#### Step 2: 创建应用（获取App ID和App Secret）

**⚠️ 重要：找到"应用管理"的正确路径**

华为开发者联盟控制台的界面经常更新，以下是几种可能的方式：

**方式A：通过左侧菜单（最常见）**

登录后你会看到类似这样的左侧菜单结构：

```
管理中心
├── 总览
├── 生态服务
├── 应用服务          ← 不要点这里！这是服务市场
├── 智慧服务
│
开发者中心           ← ★ 点击展开这个！
├── ★ 应用管理        ← ★ 在这里！或者叫"我的应用"
├── 我的报表
├── 开发者信息
└── 协议与声明

API服务
├── 凭证              ← App ID/App Secret 也可能在这里
└── 授权管理
```

**方式B：直接访问URL**

如果找不到菜单，直接在浏览器地址栏输入：

```
https://developer.huawei.com/consumer/cn/console/#/app/list
```

或旧版界面：
```
https://developer.huawei.com/consumer/cn/service/josp/agc/index.html#/myApp/myApp
```

**方式C：从首页卡片进入**

在控制台首页（总览）找这些卡片：
- **"我的应用"** 或 **"应用管理"**
- **"HarmonyOS..."** → 应用发布/元服务
- **"HUAWEI HiAI..."** → 可能直接跳转到AI服务配置

---

**创建应用的详细步骤**：

1. 进入 **"应用管理"** / **"我的应用"** 页面后
2. 点击右上角 **"创建应用"** 或 **"+"** 按钮
3. 填写应用信息：

| 字段 | 填写内容 | 说明 |
|------|---------|------|
| 应用名称 | `HarmonyHealthCare` | 随意，建议英文 |
| 应用类型 | **元服务** (推荐) 或 **应用** | 元服务无需安装，即点即用 |
| 包名 | `com.example.harmonyhealthcare` | 必须与项目 `build-profile.json5` 一致！ |
| 分类 | 健康/医疗 | 选择最接近的 |
| 默认语言 | 中文(简体) | - |

4. 点击 **"确定"** 创建应用

5. **★ 创建成功后，立即记录以下参数**：

| 参数名称 | 在哪里找到 | 示例格式 | 用途 |
|---------|-----------|---------|------|
| **App ID** | 应用详情页 → "应用信息" | `1234567890` (纯数字) | HiAI初始化 |
| **App Secret** | 应用详情页 → "应用信息" → 点击"查看" | `a1b2c3d4e5f6...` (32位hex) | HiAI鉴权 |
| **Client ID** | 应用详情页 → "应用信息" | `100123456` | OAuth认证 |
| **Client Secret** | 应用详情页 → "应用信息" → 点击"查看" | `x1y2z3...` (32位hex) | OAuth认证 |

#### Step 3: 开通HiAI Foundation服务

1. 在控制台左侧菜单找到 **"API服务"**
2. 搜索或找到 **"HiAI Foundation"**
3. 点击 **"开通服务"**
4. 选择需要的能力:
   - ✅ **图像分类** (Image Classification) → 用于医学影像类型识别
   - ✅ **文字识别** (Text Recognition/OCR) → 用于古籍/报告OCR
   - ✅ **姿态估计** (Pose Estimation) → 用于康复动作检测
   - ✅ **目标检测** (Object Detection) → 可选
5. 同意服务协议并提交申请
6. 大部分能力**即时开通**，部分需要审核

#### Step 4: 下载HarmonyOS SDK中的AI组件

**HiAI能力已集成在HarmonyOS SDK中，不需要单独下载SDK！**

**确认方法**:
1. 打开 DevEco Studio
2. File → Settings → HarmonyOS SDK
3. 确认已安装 **"AI"** 组件包
4. 如果没有，勾选后点击 **"Apply"** 安装

**SDK中的HiAI相关API**:
```
@ohos.ai.imageClassification    → 图像分类
@ohos.ai.textRecognition        → OCR文字识别
@ohos.ai.poseDetection          → 姿态检测
@ohos.ai.objectDetection        → 目标检测
```

#### Step 5: 配置权限声明

在 `entry/src/main/module.json5` 的 `requestPermissions` 中添加:
```json
{
  "name": "ohos.permission.CAMERA",
  "reason": "$string:camera_reason",
  "usedScene": {
    "abilities": ["EntryAbility"],
    "when": "inuse"
  }
}
```

在 `entry/src/main/resources/base/element/string.json` 中添加:
```json
{
  "name": "camera_reason",
  "value": "需要相机权限用于拍摄医学影像和康复动作"
}
```

#### Step 6: 修改代码接入真实HiAI API

**当前状态**: `HiAIVisionClient.ets` 中是Mock实现，需要替换为真实API调用。

**6.1 修改initialize()方法**:

```typescript
// 文件: entry/src/main/ets/hiai/HiAIVisionClient.ets

import { imageClassification } from '@ohos.ai.imageClassification';
import { textRecognition } from '@ohos.ai.textRecognition';
import { poseDetection } from '@ohos.ai.poseDetection';

export class HiAIVisionClient {
  private isInitialized: boolean = false;
  private imageClassifier: imageClassification.ImageClassifier | null = null;
  private textRecognizer: textRecognition.TextRecognizer | null = null;
  private poseDetector: poseDetection.PoseDetector | null = null;

  async initialize(): Promise<boolean> {
    try {
      console.info('[HiAI] 正在初始化视觉引擎...');

      // 初始化图像分类器
      const classifyConfig: imageClassification.ImageClassificationConfig = {
        modelType: imageClassification.ModelType.DEFAULT
      };
      this.imageClassifier = await imageClassification.createImageClassifier(classifyConfig);

      // 初始化文字识别器
      const ocrConfig: textRecognition.TextRecognitionConfig = {
        modelType: textRecognition.ModelType.DEFAULT
      };
      this.textRecognizer = await textRecognition.createTextRecognizer(ocrConfig);

      // 初始化姿态检测器
      const poseConfig: poseDetection.PoseDetectionConfig = {
        modelType: poseDetection.ModelType.DEFAULT
      };
      this.poseDetector = await poseDetection.createPoseDetector(poseConfig);

      this.isInitialized = true;
      console.info('[HiAI] 视觉引擎初始化完成');
      return true;
    } catch (error) {
      console.error('[HiAI] 初始化失败:', error);
      this.isInitialized = false;
      return false;
    }
  }
```

**6.2 修改classifyImage()方法**:
```typescript
async classifyImage(imageUri: string): Promise<ImageClassificationResult> {
  if (!this.isInitialized || !this.imageClassifier) {
    await this.initialize();
  }

  const image = await this.loadImage(imageUri);
  const result = await this.imageClassifier.classify(image);

  return {
    label: result.classifications[0]?.categoryName || '未知',
    confidence: result.classifications[0]?.score || 0,
    allResults: result.classifications.map(c => ({
      label: c.categoryName,
      confidence: c.score
    }))
  };
}
```

**6.3 修改recognizeText()方法**:
```typescript
async recognizeText(imageUri: string): Promise<TextRecognitionResult> {
  if (!this.isInitialized || !this.textRecognizer) {
    await this.initialize();
  }

  const image = await this.loadImage(imageUri);
  const result = await this.textRecognizer.recognize(image);

  return {
    text: result.textBlocks.map(b => b.text).join('\n'),
    blocks: result.textBlocks.map(b => ({
      text: b.text,
      boundingBox: b.boundingBox,
      confidence: b.confidence
    })),
    language: 'zh-CN'
  };
}
```

**6.4 修改detectPose()方法**:
```typescript
async detectPose(imageUri: string): Promise<PoseDetectionResult> {
  if (!this.isInitialized || !this.poseDetector) {
    await this.initialize();
  }

  const image = await this.loadImage(imageUri);
  const result = await this.poseDetector.detect(image);

  return {
    keypoints: result.keypoints.map(kp => ({
      x: kp.x,
      y: kp.y,
      name: kp.name,
      confidence: kp.score
    })),
    poseType: result.poseType,
    actionConfidence: result.score
  };
}
```

### ✅ 测试验证

```bash
hdc shell hilog | grep HiAI

# 预期输出:
# [HiAI] 正在初始化视觉引擎...
# [HiAI] 视觉引擎初始化完成
# [HiAI] 执行图像分类: file://xxx.jpg
```

### ⚠️ 重要说明

**Q1: 需要下载HiAI SDK吗？**
**不需要单独下载！** HiAI能力已集成在HarmonyOS SDK的AI组件中，通过 `@ohos.ai.*` API直接调用。

**Q2: 需要真机测试吗？**
**是的！** HiAI的NPU加速功能只在搭载麒麟芯片的华为设备上可用。模拟器上只能使用CPU模式。

**Q3: 开通HiAI Foundation收费吗？**
基础能力有免费额度，超出后按调用量计费。具体查看华为开发者控制台的定价页面。

---

## 3. Coze 智能体平台对接指南

### 🎯 平台信息
- **官网**: https://www.coze.cn/
- **用途**: 创建和管理专业医疗Bot（内科/眼科/康复等）
- **特点**: 可视化编排、工作流自动化、多轮对话管理

### 📦 在项目中用到了哪里？

| 功能模块 | 代码位置 | 调用场景 |
|---------|---------|---------|
| Coze API客户端 | `entry/src/main/ets/coze/CozeApiClient.ets` | 统一调用入口 |
| 内科会诊 | `CozeApiClient.consultInternalMedicine()` | 内科症状分析 |
| 眼科咨询 | `CozeApiClient.consultOphthalmology()` | 眼部问题诊断 |
| 康复指导 | `CozeApiClient.consultRehabilitation()` | 康复方案制定 |

### 🔧 部署步骤

#### Step 1: 注册Coze账号

1. 访问 https://www.coze.cn/
2. 点击右上角 **"登录/注册"**
3. 使用手机号注册（推荐）或邮箱注册
4. 完成实名认证（创建API Token需要）

#### Step 2: 创建第一个Bot（内科助手）

1. 登录后进入 **"工作空间"**
2. 点击左侧 **"+"** 或 **"创建Bot"**
3. 填写:
   - **Bot名称**: `智慧康养-内科助手`
   - **Bot描述**: `专业的老年人内科症状初步分析和就医建议`
   - **头图**: 上传医疗相关图标（可选）

#### Step 3: 编写系统提示词（Prompt）

在 **"人设与回复逻辑"** 区域粘贴以下内容:

```
你是一位经验丰富的内科医生助手，专门服务于老年人健康管理。

## 你的职责：
1. 根据患者描述的症状进行初步分析
2. 给出可能的诊断方向（不替代正式诊断）
3. 建议必要的检查项目
4. 提供家庭护理建议
5. 判断是否需要紧急就医

## 回复规范：
- 使用通俗易懂的语言，避免过多医学术语
- 对重要信息加粗显示
- 结尾给出明确的行动建议
- 如果症状严重，必须提醒立即就医

## 示例回复格式：
**可能的问题**: 高血压引起的头痛
**建议检查**: 血压测量、头颅CT
**护理建议**: ...
**⚠️ 就医建议**: 如果血压持续高于180/120，请立即拨打120
```

#### Step 4: 添加知识库（可选但推荐）

1. 左侧菜单 → **"知识库"** → **"创建知识库"**
2. 上传文档（常见疾病手册、用药指南等）
3. 支持格式: PDF / TXT / Markdown / URL

#### Step 5: 发布Bot

1. 点击右上角 **"发布"** 按钮
2. 选择 **"开发环境"** (先测试) 或 **"生产环境"** (正式上线)
3. 点击 **"发布"**

#### Step 6: ★ 获取API凭证（关键！）

**6.1 获取 Personal Access Token (API Key)**

1. 点击左侧菜单 **"授权"** (或 **"API"**)
2. 找到 **"个人访问令牌"** (Personal Access Token)
3. 点击 **"添加令牌"** / **"创建新令牌"**
4. 填写:
   - 令牌名称: `HarmonyHealthCare`
   - 过期时间: 选择 **"永不过期"** 或按需设置
   - 权限范围: 勾选 **"对话"** 和 **"工作流"**
5. 点击 **"生成"**
6. **★ 立即复制Token！只显示一次！**

Token格式: `pat_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` (以 `pat_` 开头)

**6.2 获取 Bot ID**

1. 打开你创建的Bot的编辑页面
2. 查看浏览器地址栏URL:
   ```
   https://www.coze.cn/space/73428668341XXXXXX/bot/7382917XXXXXXXX
                                              ↑ 这是Space ID    ↑ 这就是Bot ID
   ```
3. **Bot ID** 就是URL中 `/bot/` 后面那串数字

**6.3 记录参数**:

| 参数 | 格式 | 示例 | 从哪获取 |
|-----|------|------|---------|
| Personal Access Token | `pat_` + 32位字符 | `pat_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6` | 授权 → 个人访问令牌 |
| 内科Bot ID | 纯数字 | `7382917123456789012` | Bot编辑页URL |
| 眼科Bot ID | 纯数字 | `8493028987654321098` | Bot编辑页URL |
| 康复Bot ID | 纯数字 | `9504139111122233344` | Bot编辑页URL |

#### Step 7: 创建其他专科Bot

按照Step 2-6的流程，再创建2个Bot:

**眼科顾问Bot**:
- 名称: `智慧康养-眼科顾问`
- Prompt: 专注于眼部健康、视力问题、用眼建议

**康复专家Bot**:
- 名称: `智慧康养-康复专家`
- Prompt: 专注于术后康复、运动训练、功能恢复

#### Step 8: ★ 将参数填入项目代码

**8.1 填入API Token**

编辑 `entry/src/main/ets/coze/CozeApiClient.ets` 第55-62行:

```typescript
constructor(config: Partial<CozeConfig> = {}) {
  this.config = {
    apiKey: config.apiKey || 'pat_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6',  // ← 替换为你的Token
    baseUrl: config.baseUrl || 'https://api.coze.cn/v3',
    botId: config.botId
  };
}
```

**8.2 填入Bot ID**

编辑 `entry/src/main/ets/coze/CozeApiClient.ets` 中的 `getBotId()` 方法:

```typescript
private getBotId(type: string): string {
  const botIds: Record<string, string> = {
    internalMedicine: '7382917123456789012',   // ← 替换为内科Bot ID
    ophthalmology: '8493028987654321098',        // ← 替换为眼科Bot ID
    rehabilitation: '9504139111122233344'         // ← 替换为康复Bot ID
  };

  return botIds[type] || '';
}
```

### ✅ 测试验证

#### 方法1: Coze平台内置测试
1. 在Bot编辑页右侧 **"预览与调试"** 面板
2. 输入: `"我爷爷68岁，最近总是头晕"`
3. 检查回复是否符合预期

#### 方法2: HTTP直接调用（推荐先测试API连通性）
```bash
curl -X POST 'https://api.coze.cn/v3/chat' \
  -H 'Authorization: Bearer pat_你的Token' \
  -H 'Content-Type: application/json' \
  -d '{
    "bot_id": "你的Bot_ID",
    "user_id": "test_user_123",
    "stream": false,
    "auto_save_history": true,
    "additional_messages": [
      {"role": "user", "content": "你好", "content_type": "text"}
    ]
  }'
```

预期返回:
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "id": "chat_xxx",
    "conversation_id": "conv_xxx",
    "bot_id": "7382917xxx",
    "status": "completed",
    "last_error": { "code": 0 },
    "usage": { "token_count": 150 }
  }
}
```

#### 方法3: 查询对话结果（非流式模式）
```bash
curl -X GET 'https://api.coze.cn/v3/chat/retrieve?chat_id=chat_xxx&conversation_id=conv_xxx' \
  -H 'Authorization: Bearer pat_你的Token'
```

### ⚠️ 常见问题

**Q1: Token只显示一次怎么办？**
如果忘了复制，只能删除旧Token重新创建。

**Q2: Bot ID在哪里？**
打开Bot编辑页，URL中 `/bot/` 后面的数字就是。

**Q3: 调用报401错误？**
检查Token是否正确，是否以 `pat_` 开头，是否过期。

**Q4: 调用量限制？**
- 免费版: 100次/天
- 付费版: 根据套餐不同

---

## 4. 小艺 Skill 注册与Intent配置

### 🎯 平台信息
- **平台地址**: https://developer.huawei.com/consumer/cn/hag/hagindex.html#/agentHome/workSpace/agent
- **用途**: 让小艺语音助手能够调用我们的医疗Skill
- **触发方式**: 语音指令（如："小艺小艺，帮我挂号"）

### 📦 在项目中用到了哪里？

| 功能模块 | 代码位置 | 调用场景 |
|---------|---------|---------|
| Skill管理器 | `entry/src/main/ets/xiaoyi/XiaoyiSkillManager.ets` | Skill注册和调度 |
| Intent路由 | `XiaoyiSkillManager.autoRouteAndProcess()` | 语音指令匹配 |
| 健康查询Skill | `entry/src/main/ets/xiaoyi/skills/HealthQuerySkill.ets` | 血压/血糖查询 |
| AI问诊Skill | `entry/src/main/ets/xiaoyi/skills/AIConsultationSkill.ets` | 对接DeepSeek/Coze |
| Skill配置 | `entry/src/main/resources/base/profile/skill_config.json` | 8个Intent定义 |
| Skill测试工具 | `entry/src/main/ets/skill/utils/SkillTestTool.ets` | 自动化测试119条语料 |

### 🔧 部署步骤

#### Step 1: 登录小艺开放平台

1. 访问 https://developer.huawei.com/consumer/cn/hag/hagindex.html#/agentHome/workSpace/agent
2. 使用**华为开发者账号**登录（与HiAI控制台同一个账号）
3. 首次进入需要签署开发者协议

#### Step 2: 创建Skill应用

点击 **"+ 创建技能"**:

```
技能名称: 智慧康养助手
技能包名: com.example.harmonyhealthcare.skill
技能图标: 上传圆形图标 (建议1024x1024)
技能描述: 专业的老年人健康管理语音助手，提供挂号预约、健康查询、AR导航、紧急求助等功能
分类: 健康/生活服务
支持语言: 中文简体 (zh-CN)
```

#### Step 3: 配置Trigger Words（唤醒词）

| 唤醒词 | 类型 | 优先级 |
|-------|------|-------|
| 智慧康养 | 主唤醒词 | 高 |
| 健康助手 | 别名 | 中 |
| HarmonyHealth | 英文别名 | 低 |

#### Step 4: 配置Intents（意图）

**方法A: 导入配置文件（推荐）**

1. 找到项目文件 `entry/src/main/resources/base/profile/skill_config.json`
2. 在小艺平台的 **"意图配置"** 页面点击 **"导入配置"**
3. 上传该JSON文件，系统自动创建8个Intent

**方法B: 手动创建8个Intent**

| # | Intent ID | 显示名称 | 训练语料数 | 核心槽位 |
|---|-----------|---------|-----------|---------|
| 1 | appointment_booking | 📅 挂号预约服务 | 15条 | doctor_name, time, department |
| 2 | navigation | 🧭 AR智能导航 | 14条 | destination |
| 3 | health_query | ❤️ 健康数据查询 | 18条 | query_type |
| 4 | risk_assess | ⚠️ 健康风险评估 | 12条 | (无) |
| 5 | ai_consultation | 🤖 AI智能问诊 | 16条 | (无) |
| 6 | medication_reminder | 💊 用药提醒管理 | 13条 | action_type |
| 7 | emergency | 🚨 紧急求助 | 10条 | (无) |
| 8 | rehab_training | 🏃 康复训练指导 | 11条 | training_type |

每个Intent的完整训练语料见 `skill_config.json` 文件。

#### Step 5: 配置Skill权限

| 权限名称 | 权限码 | 必要性 |
|---------|-------|-------|
| 麦克风权限 | ohos.permission.MICROPHONE | 必须 |
| 相机权限 | ohos.permission.CAMERA | 可选 |
| 位置权限 | ohos.permission.LOCATION | 必须 |
| 联系人权限 | ohos.permission.READ_CONTACTS | 必须 |

#### Step 6: 测试与发布

1. 在 **"测试与调试"** 页面选择测试设备
2. 语音测试8个Intent
3. 运行项目内置测试工具:
```typescript
import { SkillTestTool } from '../skill/utils/SkillTestTool';
const tester = new SkillTestTool();
await tester.runAllTests(); // 测试119条语料
```
4. 测试通过后点击 **"提交审核"**
5. 审核通过后 **"发布上线"**

### ★ 部署完成后需要给我的参数

小艺Skill平台**不需要在代码中填入任何密钥**。它的工作方式是：
- 你在平台上配置Intent → 用户说语音指令 → 小艺平台识别 → 调用你的应用Ability
- 你的应用通过 `XiaoyiSkillManager` 处理请求并返回结果

**你需要记录的是**:
| 参数 | 值 | 用途 |
|-----|-----|------|
| Skill ID | 平台分配 | 唯一标识你的Skill |
| 审核状态 | 待审核/已通过 | 确认Skill是否上线 |

---

## 5. 硅基流动 (SiliconFlow) 快速接入

### 🎯 基本信息
- **官网**: https://siliconflow.cn/
- **API控制台**: https://cloud.siliconflow.cn/
- **用途**: 调用DeepSeek大模型进行自然语言理解
- **模型**: deepseek-ai/DeepSeek-V3 (671B参数MoE架构)

### 📦 在项目中用到了哪里？

| 代码位置 | 调用场景 |
|---------|---------|
| `entry/src/main/ets/ai/agents/DeepSeekAgent.ts` 第35行 | AI问诊的主要后端 |
| `entry/src/main/ets/deepseek/SiliconFlowClient.ets` 第38行 | HTTP请求封装 |
| `entry/src/main/ets/ai/orchestrator/AIOrchestrator.ts` | 智能体调度 |

### 🔧 部署步骤

#### Step 1: 注册硅基流动账号

1. 访问 https://cloud.siliconflow.cn/
2. 注册账号（手机号/邮箱）
3. 完成实名认证

#### Step 2: 获取API Key

1. 登录后进入 **"API Keys"** 页面
2. 点击 **"创建新的API Key"**
3. 复制Key（格式: `sk-nyvar...`）

#### Step 3: ★ 填入项目代码

**3.1 DeepSeekAgent.ts** (第35行):

```typescript
this.config = {
  apiUrl: 'https://api.siliconflow.cn/v1/chat/completions',
  apiKey: 'sk-nyvar你的真实Key',  // ← 替换这里
  model: 'deepseek-ai/DeepSeek-V3',
  maxTokens: 2048,
  temperature: 0.7,
  timeout: 30000
};
```

**3.2 SiliconFlowClient.ets** (第38行):

```typescript
this.config = {
  apiKey: config?.apiKey || 'sk-nyvar你的真实Key',  // ← 替换这里
  baseUrl: config?.baseUrl || 'https://api.siliconflow.cn/v1',
  model: config?.model || 'deepseek-ai/DeepSeek-V3',
  maxTokens: config?.maxTokens || 4096,
  temperature: config?.temperature || 0.7,
  timeout: config?.timeout || 15000
};
```

### ★ 部署完成后需要给我的参数

| 参数 | 格式 | 示例 | 从哪获取 |
|-----|------|------|---------|
| API Key | `sk-nyvar` + 40位字符 | `sk-nyvarnxvnqlheyvsvtqvkmdxjjsqaoacnududnkwjadpxhfv` | cloud.siliconflow.cn → API Keys |

---

## 6. 全部参数汇总表（部署完需要填什么）

### 📝 需要你部署后填入代码的参数清单

| # | 平台 | 参数名称 | 参数格式 | 填入哪个文件 | 填入哪一行 | 怎么获取 |
|---|------|---------|---------|------------|-----------|---------|
| 1 | 硅基流动 | API Key | `sk-hbuc...` (50字符) | `common/constants/SiliconFlowConfig.ets` | `SILICONFLOW_CONFIG.apiKey` | cloud.siliconflow.cn → API Keys |
| 2 | 硅基流动 | API Key | 同上（自动同步） | `DeepSeekAgent.ts` | 自动从配置读取 | - |
| 3 | 硅基流动 | API Key | 同上（自动同步） | `SiliconFlowClient.ets` | 自动从配置读取 | - |

**✅ 已配置的实际参数值（2026-05-12）**：

```typescript
// 文件: entry/src/main/ets/common/constants/SiliconFlowConfig.ets
export const SILICONFLOW_CONFIG = {
  apiUrl: 'https://api.siliconflow.cn/v1/chat/completions',  // ✅ 已填入
  apiKey: 'sk-hbucrijbdwvxzqjwvyenyqlejbmvciwelasphsafnftojvuo',  // ✅ 已填入
  model: 'deepseek-ai/DeepSeek-V3',  // ✅ 已填入
  maxTokens: 2048,  // ✅ 已填入
  temperature: 0.7,  // ✅ 已填入
  timeout: 30000  // ✅ 已填入
};
```

**代码更新状态**：
- ✅ [SiliconFlowConfig.ets](file:///e:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/common/constants/SiliconFlowConfig.ets) - 配置文件已创建
- ✅ [DeepSeekAgent.ts](file:///e:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/ai/agents/DeepSeekAgent.ts) - 已从配置文件读取API Key
- ✅ [SiliconFlowClient.ets](file:///e:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/deepseek/SiliconFlowClient.ets) - 已从配置文件读取API Key
- ✅ DeepSeek-V3模型用于健康咨询AI问诊

| 3 | Coze | Personal Access Token | `pat_` + 32位字符 | `CozeApiClient.ets` | 第58行 `apiKey` | coze.cn → 授权 → 个人访问令牌 |
| 4 | Coze | 内科Bot ID | 纯数字 (约19位) | `CozeApiClient.ets` | `getBotId()` 方法 | Bot编辑页URL中 `/bot/` 后的数字 |
| 5 | Coze | 眼科Bot ID | 纯数字 (约19位) | `CozeApiClient.ets` | `getBotId()` 方法 | 同上 |
| 6 | Coze | 康复Bot ID | 纯数字 (约19位) | `CozeApiClient.ets` | `getBotId()` 方法 | 同上 |
| 7 | 华为HiAI | App ID | 纯数字 (19位) | `common/constants/HiAIConfig.ets` | `HIAI_CONFIG.appId` | 华为开发者控制台 → APP与元服务 → 创建APP ID |
| 8 | 华为HiAI | API Key | Base64编码字符串 | `common/constants/HiAIConfig.ets` | `HIAI_CONFIG.apiKey` | 凭证 → 项目级凭证 → API密钥 → apiKey1 |
| 9 | 华为HiAI | Client Secret | 64位hex字符串 | `common/constants/HiAIConfig.ets` | `HIAI_CONFIG.clientSecret` | 凭证 → 项目级凭证 → OAuth 2.0客户端ID → 👁️查看密钥 |

**✅ 已配置的实际参数值（2026-05-12）**：

```typescript
// 文件: entry/src/main/ets/common/constants/HiAIConfig.ets
export const HIAI_CONFIG = {
  appId: '6917605309959973739',  // ✅ 已填入
  apiKey: 'DgEDAJJSMJjegWH5WYUJ7HyZVu6HyA40uv2XYYfSGn8R9Hg+Ut1yCTCc50EjuA+9p+eHIq0AOutiYIbvi2+9iorUzKgQXNjix8XF/A==',  // ✅ 已填入
  clientSecret: 'cce77fec1f2f575034eb05e08fd012e212fec594d1fb261bb5599d073a9fe281',  // ✅ 已填入
  packageName: 'com.example.harmonyhealthcare'  // ✅ 已填入
};
```

**代码更新状态**：
- ✅ [HiAIVisionClient.ets](file:///e:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/hiai/HiAIVisionClient.ets) - 已接入真实HiAI API（带Fallback到Mock）
- ✅ 支持三种能力：图像分类、OCR文字识别、姿态检测
- ✅ 初始化失败时自动降级为模拟模式

### 📝 不需要填入代码但需要记录的参数

| # | 平台 | 参数名称 | 用途 |
|---|------|---------|------|
| 1 | 小艺Skill | Skill ID | 确认Skill已上线 |
| 2 | 小艺Skill | 审核状态 | 确认是否可用 |
| 3 | 华为HiAI | Client ID | OAuth认证（如需） |
| 4 | 华为HiAI | Client Secret | OAuth认证（如需） |
| 5 | Coze | Space ID | 工作空间标识 |

### 📝 需要下载的文件清单

| # | 下载内容 | 下载地址 | 选择哪个版本 | 放到哪里 | 是否必须 |
|---|---------|---------|------------|---------|---------|
| 1 | MindSpore Lite 模型转换工具 | https://www.mindspore.cn/lite/docs/en/stable/use/downloads.html | **2.9.0** → End-to-end inference → CPU → **Windows-x86_64** → `mindspore-lite-2.9.0-win-x64.zip` | 开发机任意目录 | ❌ 不必须（不训练模型就不需要） |
| 2 | 风险评估模型文件 risk_assess.ms | 自行训练或从MindSpore Hub下载 | 输入[1,20]输出[1,5]的.ms模型 | `entry/src/main/resources/rawfile/risk_assess.ms` | ❌ 不必须（有规则引擎Fallback） |
| 3 | HarmonyOS SDK AI组件 | DevEco Studio → Settings → SDK | API 12+ 的 AI 组件包 | 自动安装到SDK目录 | ✅ 必须（HiAI和MindSpore Lite API依赖） |

### 📝 完全不需要下载的东西

| 项目 | 说明 |
|-----|------|
| MindSpore Lite Android SDK | 我们是HarmonyOS项目，不需要Android版 |
| MindSpore Lite Linux SDK | 那是服务器端用的 |
| HiAI Foundation SDK (独立包) | 已集成在HarmonyOS SDK的AI组件中 |
| 任何 .so 动态库 | HarmonyOS通过系统API调用，不需要手动集成so |

---

## 7. 统一测试验证清单

### 📊 全平台部署状态追踪表

| 平台 | 核心任务 | 状态 | 需要给我的参数 |
|-----|---------|------|--------------|
| **硅基流动** | □ 获取API Key | ○ | `sk-nyvar...` |
| | □ 填入DeepSeekAgent.ts | ○ | |
| | □ 填入SiliconFlowClient.ets | ○ | |
| | □ 测试AI问诊功能 | ○ | |
| **Coze** | □ 注册账号 | ○ | |
| | □ 创建3个Bot | ○ | |
| | □ 获取Personal Access Token | ○ | `pat_...` |
| | □ 获取3个Bot ID | ○ | 3个纯数字ID |
| | □ 填入CozeApiClient.ets | ○ | |
| | □ 测试Bot响应 | ○ | |
| **华为HiAI** | □ 注册开发者账号 | ○ | |
| | □ 创建应用 | ○ | App ID, App Secret |
| | □ 开通HiAI Foundation | ○ | |
| | □ 安装SDK AI组件 | ○ | |
| | □ 替换Mock代码 | ○ | |
| | □ 真机测试 | ○ | |
| **MindSpore Lite** | □ 确认SDK AI组件已安装 | ○ | |
| | □ (可选)下载转换工具 | ○ | |
| | □ (可选)准备模型文件 | ○ | |
| | □ 修改代码接入真实API | ○ | |
| | □ 测试推理结果 | ○ | |
| **小艺Skill** | □ 登录小艺开放平台 | ○ | |
| | □ 创建Skill应用 | ○ | Skill ID |
| | □ 配置8个Intent | ○ | |
| | □ 运行SkillTestTool | ○ | |
| | □ 提交审核 | ○ | 审核状态 |

### 🎯 端到端测试场景

#### 场景1: 完整就诊流程
```
1. "小艺小艺，智慧康养"
   → 小艺: "您好，我是智慧康养助手"

2. "帮我挂明天上午心内科的号"
   → Intent: appointment_booking → 打开预约页面

3. "导航去心内科"
   → Intent: navigation → 启动AR导航

4. "查一下今天的血压"
   → Intent: health_query → 查询本地数据库 → TTS播报

5. "评估一下我的健康风险"
   → Intent: risk_assess → MindSpore Lite推理 → 返回风险等级
```

#### 场景2: AI问诊流程
```
1. "小艺小艺，我想问问医生，最近总是头痛怎么办"
   → Intent: ai_consultation
   → 路由: DeepSeekAgent(硅基流动) → 返回分析

2. 如需专科会话:
   → 切换到 CozeApiClient.consultInternalMedicine()
   → 返回更专业的内科建议
```

#### 场景3: 紧急情况
```
1. "小艺小艺，救命！"
   → Intent: emergency (最高优先级)
   → 播放警报 → 发送GPS → 一键120 → 显示CPR指引
```

### 🐛 常见问题排查

| 问题 | 排查方法 |
|-----|---------|
| 小艺无法唤醒Skill | 检查Trigger Words / Skill是否已发布 / 手机小艺版本 |
| DeepSeek返回空 | 检查API Key / 账户余额 / 网络连接 |
| Coze Bot响应差 | 优化System Prompt / 添加知识库 / 使用工作流 |
| MindSpore加载模型失败 | 确认.ms文件路径 / 格式 / 使用规则引擎Fallback |
| HiAI初始化失败 | 需要真机(麒麟芯片) / 检查SDK AI组件 / 查看权限 |

---

## 🎉 总结

### 架构总览

```
用户语音输入
    ↓
┌─────────────────────────────────────┐
│         小艺 Skill (入口层)          │
│   8个Intent • 119条训练语料          │
│   代码: XiaoyiSkillManager.ets      │
└──────────────┬──────────────────────┘
               │ 路由分发
               ↓
    ┌──────────┼──────────┬──────────┐
    ↓          ↓          ↓          ↓
┌───────┐ ┌───────┐ ┌───────┐ ┌──────────┐
│MindSpore│ │ HiAI  │ │DeepSeek│ │  Coze    │
│ (端侧)  │ │ (NPU) │ │(硅基流动)│ │ (字节)   │
│风险/异常│ │图像/OCR│ │通用问答 │ │专科会诊  │
└───────┘ └───────┘ └───────┘ └──────────┘
    ↑          ↑          ↑          ↑
    └──────────┴──────────┴──────────┘
               │
        AIOrchestrator (统一调度)
        代码: AIOrchestrator.ts
```

### 需要下载的东西（总结）

| 下载项 | 是否必须 | 说明 |
|-------|---------|------|
| HarmonyOS SDK AI组件 | ✅ 必须 | DevEco Studio内安装 |
| MindSpore Lite Windows转换工具 | ❌ 可选 | 只有自己训练模型才需要 |
| risk_assess.ms 模型文件 | ❌ 可选 | 没有也能用规则引擎 |
| HiAI SDK | ❌ 不需要 | 已内置在HarmonyOS SDK中 |
| MindSpore Lite Android/Linux SDK | ❌ 不需要 | 我们是HarmonyOS项目 |

### 需要注册的账号（总结）

| 平台 | 注册地址 | 是否收费 |
|-----|---------|---------|
| 硅基流动 | https://cloud.siliconflow.cn/ | 有免费额度 |
| Coze | https://www.coze.cn/ | 有免费额度 |
| 华为开发者 | https://developer.huawei.com/ | 免费 |
| 小艺开放平台 | 同华为开发者账号 | 免费 |

### 建议的操作顺序

```
1. 硅基流动 (最简单，只需1个Key)
   → 给我: sk-nyvar... 的API Key
   ↓
2. Coze平台 (创建Bot+获取Token和Bot ID)
   → 给我: pat_... Token + 3个Bot ID
   ↓
3. 华为开发者控制台 (注册+开通HiAI)
   → 给我: App ID + App Secret
   ↓
4. MindSpore Lite (确认SDK组件即可)
   → 无需给我参数
   ↓
5. 小艺Skill (最后提交审核)
   → 给我: Skill ID + 审核状态
```

---

*文档版本: v2.0*
*最后更新: 2026-05-12*
*作者: Harmony Health Care Team*
