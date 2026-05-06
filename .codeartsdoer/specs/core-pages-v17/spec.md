# 星云医疗助手 V17.0 - 8个核心页面需求规格文档

**版本**: v1.0
**创建日期**: 2026-05-06
**最后更新**: 2026-05-06
**作者**: SDD Agent
**状态**: 草稿

---

## 1. 概述

### 1.1 功能简介

本文档定义星云医疗助手V17.0版本的8个核心页面需求规格，涵盖用户认证、AI智能服务、医学影像分析、风险评估、古医影像处理和分布式协同等关键功能模块。这些页面是应用的核心入口，直接影响用户体验和业务价值。

### 1.2 业务背景

**当前痛点**:
- 33个页面存在TODO/FIXME标记，功能不完整
- 用户认证流程缺失，无法正常登录注册
- AI聊天界面体验不完整，缺少Markdown渲染和打字动画
- 医学影像分析功能占位，无法提供实际诊断辅助
- 风险评估问卷引擎未实现，无法生成健康风险报告
- 分布式协同功能未打通，多设备数据无法同步

**解决方案**:
通过SDD规格驱动开发，系统化实现8个核心页面的完整功能，确保每个页面具备生产级质量。

### 1.3 范围定义

**包含范围**:
- **P0-HomePage.ets**: 首页响应式布局（phone/tablet/2in1三种设备适配）
- **P0-Login.ets**: 登录页面（手机号+密码认证、JWT Token管理）
- **P0-Register.ets**: 注册页面（验证码流程、密码强度检测）
- **P1-AiChatPage.ets**: AI聊天界面（MedicalAgent集成、Markdown渲染）
- **P1-ImageAnalysisPage.ets**: 影像分析上传（医学影像AI分析）
- **P1-RiskAssessmentPage.ets**: 风险评估问卷（4种评估类型、结果可视化）
- **P2-AncientMedicalImgPage.ets**: 古医影像处理（图像修复、OCR识别）
- **P2-DistributedCollaborationPage.ets**: 分布式协同（设备发现、数据同步）

**排除范围**:
- 后端API开发（已有完整Controller层）
- 其他25个TODO页面的修复（不在本次范围）
- 性能优化和测试（Phase 4任务）
- AR导航和数字孪生模块（已完整实现）

---

## 2. 用户故事

### US-001: 多设备用户访问首页
**作为** 使用不同设备的用户（手机/平板/二合一）
**我想要** 首页能够自适应我的设备屏幕尺寸
**以便于** 在任何设备上都能获得最佳的操作体验和功能访问

**验收标准**:
- Given 用户使用手机设备（宽度<600vp）
- When 用户打开首页
- Then 首页显示2列Grid布局，所有功能卡片可正常点击

- Given 用户使用平板设备（600vp≤宽度<840vp）
- When 用户打开首页
- Then 首页显示3列Grid布局，功能卡片尺寸适配

- Given 用户使用二合一设备（宽度≥840vp）
- When 用户打开首页
- Then 首页显示4列Grid布局，充分利用大屏空间

### US-002: 用户登录认证
**作为** 已注册用户
**我想要** 通过手机号和密码快速登录系统
**以便于** 访问个人健康数据和个性化服务

**验收标准**:
- Given 用户在登录页面输入有效手机号和密码
- When 用户点击登录按钮
- Then 系统调用后端认证接口，成功后存储JWT Token并跳转首页

- Given 用户输入无效手机号格式
- When 用户点击登录按钮
- Then 系统显示"请输入正确的手机号"错误提示

### US-003: 新用户注册
**作为** 新用户
**我想要** 通过手机号注册账号并设置安全密码
**以便于** 成为系统正式用户并享受医疗服务

**验收标准**:
- Given 用户填写完整注册信息并勾选用户协议
- When 用户点击注册按钮
- Then 系统发送验证码，验证通过后创建账号并自动登录

### US-004: AI智能问诊
**作为** 寻求医疗咨询的用户
**我想要** 与AI医疗助手进行自然语言对话
**以便于** 获得初步的健康建议和疾病信息

**验收标准**:
- Given 用户在AI聊天页面输入健康问题
- When 用户发送消息
- Then AI助手返回专业回复，支持Markdown格式渲染和打字动画效果

### US-005: 医学影像AI分析
**作为** 需要影像诊断辅助的用户
**我想要** 上传医学影像并获得AI分析报告
**以便于** 了解影像中的异常区域和初步诊断建议

**验收标准**:
- Given 用户上传CT/MRI/X光影像
- When AI分析完成
- Then 显示标注异常区域的影像和结构化诊断报告

### US-006: 健康风险评估
**作为** 关注个人健康的用户
**我想要** 完成健康风险问卷并获得评估报告
**以便于** 了解自身健康风险等级和改善建议

**验收标准**:
- Given 用户选择评估类型并完成问卷
- When 用户提交问卷
- Then 系统生成可视化风险评估报告（雷达图/仪表盘）

### US-007: 古医影像数字化
**作为** 中医研究者和医生
**我想要** 对古籍医学影像进行修复和OCR识别
**以便于** 数字化保存和研究古代医学文献

**验收标准**:
- Given 用户上传古医影像
- When 处理流水线完成
- Then 输出修复后的高清影像和OCR识别文本

### US-008: 多设备数据协同
**作为** 拥有多台设备的用户
**我想要** 在不同设备间同步健康数据
**以便于** 在任意设备上查看完整的健康档案

**验收标准**:
- Given 用户在设备A上登录并授权设备B
- When 数据同步完成
- Then 设备B可查看设备A的健康数据（已脱敏处理）

---

## 3. 功能需求

### 3.1 首页响应式布局 (HomePage.ets)

#### FR-001: 断点系统适配
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The HomePage shall adapt grid layout columns based on BreakpointSystem breakpoint values (sm/md/lg)

**验收标准**:
- Given BreakpointSystem当前断点为sm（<600vp）
- When 首页渲染
- Then Grid组件显示2列布局，每个卡片宽度50%

- Given BreakpointSystem当前断点为md（600-840vp）
- When 首页渲染
- Then Grid组件显示3列布局，每个卡片宽度33.3%

- Given BreakpointSystem当前断点为lg（≥840vp）
- When 首页渲染
- Then Grid组件显示4列布局，每个卡片宽度25%

**依赖**: 无

#### FR-002: 功能入口卡片
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The HomePage shall display 13 functional entry cards with icons, titles, and navigation actions

**验收标准**:
- Given 首页加载完成
- When 用户查看功能卡片区域
- Then 显示13个功能入口：健康档案、医疗服务、药品服务、AI问诊、风险评估、影像分析、康复训练、智慧病房、AR导航、数字孪生、停车导航、分布式协同、设置

- Given 用户点击任意功能卡片
- When 点击事件触发
- Then 路由跳转到对应功能页面

**依赖**: FR-001

#### FR-003: 用户信息展示
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The HomePage shall display user avatar, name, and health summary in the header area

**验收标准**:
- Given 用户已登录
- When 首页加载
- Then 顶部显示用户头像、昵称、健康评分摘要

- Given 用户未登录
- When 首页加载
- Then 顶部显示"登录/注册"按钮

**依赖**: FR-001

---

### 3.2 登录页面 (Login.ets)

#### FR-004: 手机号密码登录表单
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The Login page shall provide phone number and password input fields with real-time validation

**验收标准**:
- Given 用户在手机号输入框输入内容
- When 输入内容匹配正则表达式 ^1[3-9]\d{9}$
- Then 手机号验证通过，输入框显示成功状态

- Given 用户在手机号输入框输入内容
- When 输入内容不匹配正则表达式
- Then 显示"请输入正确的手机号"错误提示

- Given 用户在密码输入框输入内容
- When 输入长度在6-20位之间
- Then 密码验证通过

**依赖**: 无

#### FR-005: JWT认证流程
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When user submits login form with valid credentials, the Login page shall call backend API and store JWT token

**验收标准**:
- Given 用户输入有效手机号和密码
- When 点击登录按钮
- Then 调用 HttpUtil.post('/api/user/login', {phone, password})

- Given 后端返回 {code: 200, data: {token, userInfo}}
- When 登录成功
- Then 执行 AppStorage.setOrCreate('userToken', token) 和 router.pushUrl({url: 'pages/HomePage'})

- Given 后端返回 {code: 401, message: '密码错误'}
- When 登录失败
- Then 显示错误提示"密码错误，请重新输入"

**依赖**: FR-004

#### FR-006: 登录状态管理
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The Login page shall manage loading state and disable interactions during authentication

**验收标准**:
- Given 用户点击登录按钮
- When HTTP请求进行中
- Then 登录按钮显示loading动画并禁用点击

- Given HTTP请求完成（成功或失败）
- When 响应返回
- Then 恢复按钮正常状态

**依赖**: FR-005

#### FR-007: 辅助功能链接
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The Login page shall provide "Forgot Password" and "Register Account" links

**验收标准**:
- Given 用户点击"忘记密码"链接
- When 点击事件触发
- Then 显示Toast提示"请联系客服重置密码"

- Given 用户点击"注册账号"链接
- When 点击事件触发
- Then 路由跳转到 Register 页面

**依赖**: 无

---

### 3.3 注册页面 (Register.ets)

#### FR-008: 注册表单字段
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The Register page shall provide phone number, password, confirm password, and verification code input fields

**验收标准**:
- Given 注册页面加载完成
- When 用户查看表单
- Then 显示手机号、密码、确认密码、验证码四个输入框

- Given 用户在确认密码框输入内容
- When 内容与密码框不一致
- Then 显示"两次密码输入不一致"错误提示

**依赖**: 无

#### FR-009: 验证码流程
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When user clicks "Get Verification Code" button, the Register page shall send SMS code and start 60-second countdown

**验收标准**:
- Given 用户输入有效手机号
- When 点击"获取验证码"按钮
- Then 调用后端发送验证码接口，按钮变为60秒倒计时

- Given 倒计时进行中
- When 倒计时未归零
- Then 按钮禁用并显示剩余秒数

- Given 倒计时归零
- When 倒计时结束
- Then 按钮恢复为"重新获取"

**依赖**: FR-008

#### FR-010: 密码强度检测
**优先级**: P1
**类型**: 功能需求

**需求描述**:
While user enters password, the Register page shall display password strength indicator (Weak/Medium/Strong)

**验收标准**:
- Given 密码长度<8位或纯数字
- When 密码强度计算
- Then 显示"弱"强度指示器（红色）

- Given 密码长度8-12位且包含字母和数字
- When 密码强度计算
- Then 显示"中"强度指示器（黄色）

- Given 密码长度>12位且包含特殊字符
- When 密码强度计算
- Then 显示"强"强度指示器（绿色）

**依赖**: FR-008

#### FR-011: 用户协议确认
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The Register page shall require user to accept User Agreement before registration

**验收标准**:
- Given 用户未勾选"我已阅读并同意用户协议"
- When 点击注册按钮
- Then 显示"请先同意用户协议"提示，不执行注册

- Given 用户勾选协议Checkbox
- When 点击注册按钮
- Then 执行注册流程

**依赖**: FR-008

#### FR-012: 注册成功自动登录
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When registration succeeds, the Register page shall automatically login and navigate to HomePage

**验收标准**:
- Given 用户完成注册表单并提交
- When 后端返回注册成功
- Then 自动调用登录接口，存储Token，跳转首页

**依赖**: FR-008, FR-009, FR-011

---

### 3.4 AI聊天界面 (AiChatPage.ets)

#### FR-013: 聊天消息列表
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The AiChatPage shall display conversation history with user messages (right-aligned) and AI messages (left-aligned)

**验收标准**:
- Given 聊天页面加载
- When 存在历史对话
- Then 显示历史消息列表，用户消息右对齐蓝色气泡，AI消息左对齐白色气泡

- Given 消息列表超过100条
- When 滚动加载
- Then 使用LazyForEach实现虚拟滚动，保证性能

**依赖**: 无

#### FR-014: Markdown内容渲染
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The AiChatPage shall render AI response content in Markdown format

**验收标准**:
- Given AI返回包含Markdown格式的内容（标题、列表、代码块、加粗等）
- When 消息渲染
- Then 正确解析并显示Markdown样式

**依赖**: FR-013

#### FR-015: 打字动画效果
**优先级**: P2
**类型**: 功能需求

**需求描述**:
While AI is generating response, the AiChatPage shall display typing animation effect

**验收标准**:
- Given AI响应流式返回
- When 内容逐步生成
- Then 显示逐字打印动画效果

- Given AI响应完成
- When 动画结束
- Then 显示完整消息内容

**依赖**: FR-013

#### FR-016: MedicalAgent集成
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When user sends health question, the AiChatPage shall call MedicalAgent for professional medical response

**验收标准**:
- Given 用户输入健康问题
- When 点击发送按钮
- Then 调用 MedicalAgent.chat(question, conversationMemory)

- Given MedicalAgent返回响应
- When 响应包含结构化医疗建议
- Then 显示专业医疗回复，包含可能的疾病、建议、注意事项

**依赖**: FR-013

#### FR-017: 对话上下文管理
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The AiChatPage shall maintain conversation context using ConversationMemory

**验收标准**:
- Given 用户进行多轮对话
- When 发送新问题
- Then ConversationMemory保存历史上下文，AI能理解前文内容

- Given 对话超过10轮
- When 上下文过长
- Then 自动截断早期对话，保留最近10轮

**依赖**: FR-016

---

### 3.5 影像分析上传 (ImageAnalysisPage.ets)

#### FR-018: 影像上传功能
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The ImageAnalysisPage shall support medical image upload via camera or gallery

**验收标准**:
- Given 用户点击上传按钮
- When 选择上传方式
- Then 显示"拍照"和"从相册选择"两个选项

- Given 用户选择拍照
- When 调用ImagePicker
- Then 打开相机拍摄医学影像

- Given 用户选择相册
- When 调用ImagePicker
- Then 打开系统相册选择影像

**依赖**: 无

#### FR-019: 影像预览和确认
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When user selects image, the ImageAnalysisPage shall display preview and allow confirmation

**验收标准**:
- Given 用户选择影像
- When 影像加载完成
- Then 显示影像预览，提供"重新选择"和"开始分析"按钮

**依赖**: FR-018

#### FR-020: AI影像分析
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When user confirms analysis, the ImageAnalysisPage shall call backend AI service and display results

**验收标准**:
- Given 用户点击"开始分析"
- When 影像上传到后端
- Then 使用FormData格式上传，调用 /api/medical-image/analyze 接口

- Given AI分析完成
- When 返回分析结果
- Then 显示异常区域标注和诊断报告

**依赖**: FR-019

#### FR-021: 异常区域标注
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The ImageAnalysisPage shall highlight abnormal regions on the medical image with bounding boxes

**验收标准**:
- Given AI检测到异常区域
- When 显示分析结果
- Then 在影像上绘制边界框，标注异常位置和类型

**依赖**: FR-020

#### FR-022: 诊断报告展示
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The ImageAnalysisPage shall display structured diagnosis report with findings and recommendations

**验收标准**:
- Given AI分析完成
- When 查看报告区域
- Then 显示结构化报告：影像类型、异常发现、可能诊断、建议措施、置信度

**依赖**: FR-020

---

### 3.6 风险评估问卷 (RiskAssessmentPage.ets)

#### FR-023: 评估类型选择
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The RiskAssessmentPage shall provide 4 assessment types: Cardiovascular, Diabetes, Cancer, Comprehensive

**验收标准**:
- Given 风险评估页面加载
- When 用户查看评估类型
- Then 显示4种评估类型卡片：心血管风险评估、糖尿病风险评估、癌症风险评估、综合健康评估

- Given 用户选择评估类型
- When 点击类型卡片
- Then 进入对应问卷流程

**依赖**: 无

#### FR-024: 问卷引擎
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The RiskAssessmentPage shall render dynamic questionnaire based on assessment type using Stepper component

**验收标准**:
- Given 用户开始问卷
- When 问卷加载
- Then 使用Stepper组件分步显示问题，每步包含若干问题项

- Given 用户完成当前步骤
- When 点击"下一步"
- Then 验证当前步骤必填项，通过后进入下一步

- Given 用户在最后一步
- When 点击"提交"
- Then 提交问卷数据到后端

**依赖**: FR-023

#### FR-025: 问卷数据验证
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The RiskAssessmentPage shall validate questionnaire inputs before submission

**验收标准**:
- Given 必填问题未回答
- When 点击"下一步"或"提交"
- Then 显示"请完成所有必填问题"提示

- Given 数值型问题输入超出范围
- When 输入验证
- Then 显示有效范围提示

**依赖**: FR-024

#### FR-026: 风险结果可视化
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When assessment completes, the RiskAssessmentPage shall display visualized risk report with charts

**验收标准**:
- Given 问卷提交成功
- When 后端返回风险评估结果
- Then 显示风险等级（低/中/高）、雷达图（多维度评分）、仪表盘（综合评分）

- Given 用户查看详细报告
- When 点击"查看详情"
- Then 跳转到 RiskResultPage 显示完整报告

**依赖**: FR-024

---

### 3.7 古医影像处理 (AncientMedicalImgPage.ets)

#### FR-027: 图像上传和预处理
**优先级**: P2
**类型**: 功能需求

**需求描述**:
The AncientMedicalImgPage shall support ancient medical image upload and preprocessing

**验收标准**:
- Given 用户上传古籍医学影像
- When 影像加载完成
- Then ImagePreprocessor执行去噪、增强、二值化预处理

**依赖**: 无

#### FR-028: 图像修复流水线
**优先级**: P2
**类型**: 功能需求

**需求描述**:
The AncientMedicalImgPage shall execute image restoration pipeline including color restoration and super-resolution

**验收标准**:
- Given 预处理完成
- When 执行修复流水线
- Then ColorRestorer恢复褪色区域，SRGAN超分辨率提升清晰度

**依赖**: FR-027

#### FR-029: OCR文本识别
**优先级**: P2
**类型**: 功能需求

**需求描述**:
The AncientMedicalImgPage shall perform OCR recognition on restored image to extract text

**验收标准**:
- Given 图像修复完成
- When 执行OCR识别
- Then 调用NLP OCR引擎，提取影像中的文字内容

- Given OCR识别完成
- When 显示识别结果
- Then 显示可编辑的文本区域，用户可修正识别错误

**依赖**: FR-028

#### FR-030: 标注工具
**优先级**: P2
**类型**: 功能需求

**需求描述**:
The AncientMedicalImgPage shall provide annotation tools for marking important regions

**验收标准**:
- Given 用户进入标注模式
- When 使用标注工具
- Then 提供矩形框、圆形框、自由绘制、文本标注等工具

- Given 标注完成
- When 保存标注
- Then 标注信息与影像关联存储

**依赖**: FR-027

---

### 3.8 分布式协同 (DistributedCollaborationPage.ets)

#### FR-031: 设备发现和配对
**优先级**: P2
**类型**: 功能需求

**需求描述**:
The DistributedCollaborationPage shall discover nearby devices and support pairing

**验收标准**:
- Given 用户打开分布式协同页面
- When 点击"发现设备"
- Then DevicePairingService扫描附近设备，显示可用设备列表

- Given 用户选择目标设备
- When 发起配对请求
- Then 目标设备收到配对确认，双方确认后建立连接

**依赖**: 无

#### FR-032: 数据同步传输
**优先级**: P2
**类型**: 功能需求

**需求描述**:
When devices are paired, the DistributedCollaborationPage shall support data synchronization

**验收标准**:
- Given 设备已配对
- When 用户选择同步数据类型（健康档案、用药记录等）
- Then DataTransferService传输数据，显示同步进度

- Given 同步完成
- When 数据写入目标设备
- Then 显示"同步成功"提示

**依赖**: FR-031

#### FR-033: 权限管理
**优先级**: P2
**类型**: 功能需求

**需求描述**:
The DistributedCollaborationPage shall manage data access permissions between devices

**验收标准**:
- Given 设备请求访问数据
- When 权限检查
- Then 根据用户授权设置决定是否允许访问

- Given 用户修改权限设置
- When 保存权限配置
- Then 更新权限管理器，影响后续数据访问

**依赖**: FR-031

#### FR-034: 数据脱敏
**优先级**: P2
**类型**: 功能需求

**需求描述**:
The DistributedCollaborationPage shall desensitize sensitive data before transmission

**验收标准**:
- Given 数据包含敏感信息（身份证号、病历号等）
- When 准备传输
- Then DesensitizationUtil对敏感字段进行脱敏处理（部分隐藏或加密）

- Given 接收方收到数据
- When 查看数据
- Then 敏感信息已脱敏显示

**依赖**: FR-032

---

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 页面加载性能
**指标**: 首页加载时间 < 2秒，其他页面加载时间 < 3秒
**测试方法**: 使用DevEco Studio性能分析工具测量页面onPageShow到渲染完成的时间

#### NFR-002: 响应式布局性能
**指标**: 断点切换响应时间 < 300ms，无卡顿
**测试方法**: 在不同设备模拟器上切换屏幕尺寸，测量布局重排时间

#### NFR-003: AI聊天性能
**指标**: 消息发送到AI响应显示 < 5秒（网络正常情况下）
**测试方法**: 测量从点击发送到AI消息气泡出现的时间

#### NFR-004: 影像上传性能
**指标**: 10MB影像上传时间 < 15秒（4G网络）
**测试方法**: 使用不同大小影像文件测试上传时间

### 4.2 安全需求

#### NFR-005: JWT Token安全
**指标**: Token存储使用HarmonyOS安全存储API，Token有效期24小时
**测试方法**: 检查Token存储方式，测试Token过期自动登出

#### NFR-006: 数据传输安全
**指标**: 所有API调用使用HTTPS，敏感数据传输加密
**测试方法**: 抓包验证HTTPS加密，检查敏感字段是否加密

#### NFR-007: 权限控制
**指标**: 未登录用户无法访问需认证页面，Token过期自动跳转登录
**测试方法**: 清除Token后访问需认证页面，验证跳转行为

### 4.3 兼容性需求

#### NFR-008: 设备兼容性
**指标**: 支持HarmonyOS NEXT 5.0+，适配phone/tablet/2in1三种设备类型
**测试方法**: 在三种设备模拟器上运行测试

#### NFR-009: 屏幕尺寸适配
**指标**: 支持屏幕宽度360vp-1280vp，支持横竖屏切换
**测试方法**: 在不同分辨率模拟器上测试布局适配

### 4.4 可用性需求

#### NFR-010: 表单验证反馈
**指标**: 所有输入错误在300ms内显示提示，提示信息清晰准确
**测试方法**: 输入各种错误数据，验证提示及时性和准确性

#### NFR-011: 加载状态反馈
**指标**: 所有异步操作显示loading状态，超时显示错误提示
**测试方法**: 模拟网络延迟和失败，验证状态反馈

---

## 5. 数据需求

### 5.1 数据模型

#### 用户认证数据
```typescript
interface UserLoginRequest {
  phone: string;      // 手机号，11位
  password: string;   // 密码，6-20位
}

interface UserRegisterRequest {
  phone: string;
  password: string;
  verificationCode: string;  // 验证码，6位
  agreedToTerms: boolean;    // 是否同意协议
}

interface LoginResponse {
  token: string;       // JWT Token
  userInfo: UserInfo;
}

interface UserInfo {
  userId: number;
  phone: string;
  nickname: string;
  avatar: string;
  healthScore?: number;
}
```

#### AI对话数据
```typescript
interface ChatMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
  markdown?: boolean;  // 是否为Markdown格式
}

interface ConversationContext {
  messages: ChatMessage[];
  userId: string;
  sessionId: string;
}
```

#### 影像分析数据
```typescript
interface ImageAnalysisRequest {
  imageFile: File;     // 影像文件
  imageType: 'CT' | 'MRI' | 'XRay' | 'Ultrasound';
  patientId?: string;
}

interface ImageAnalysisResult {
  imageId: string;
  abnormalities: AbnormalRegion[];
  diagnosis: DiagnosisReport;
  confidence: number;  // 置信度 0-1
}

interface AbnormalRegion {
  bbox: [number, number, number, number];  // [x, y, width, height]
  type: string;
  description: string;
}

interface DiagnosisReport {
  findings: string[];
  possibleDiagnoses: string[];
  recommendations: string[];
  urgency: 'low' | 'medium' | 'high';
}
```

#### 风险评估数据
```typescript
interface RiskAssessmentRequest {
  assessmentType: 'cardiovascular' | 'diabetes' | 'cancer' | 'comprehensive';
  answers: QuestionAnswer[];
  userId: string;
}

interface QuestionAnswer {
  questionId: string;
  answer: string | number | boolean;
}

interface RiskAssessmentResult {
  riskLevel: 'low' | 'medium' | 'high';
  overallScore: number;  // 0-100
  dimensionScores: Map<string, number>;
  recommendations: string[];
}
```

### 5.2 数据存储

- **JWT Token**: 使用 `AppStorage` 存储，key为 `userToken`
- **用户信息**: 使用 `AppStorage` 存储，key为 `userInfo`
- **对话历史**: 使用 `Preferences` API持久化存储，支持离线查看
- **影像文件**: 临时存储在应用缓存目录，分析完成后可选保存到相册
- **风险评估结果**: 存储到SQLite本地数据库，支持历史查看

### 5.3 数据安全

- JWT Token不记录日志，不暴露给非授权组件
- 用户健康数据传输使用HTTPS加密
- 分布式协同数据传输前进行脱敏处理
- 影像文件上传前检查权限，不包含EXIF敏感信息

---

## 6. 接口需求

### 6.1 用户界面

#### 登录页面UI
- 顶部：应用Logo + "登录"标题
- 中部：手机号输入框（带清除按钮）+ 密码输入框（带显示/隐藏切换）
- 底部：登录按钮（支持loading状态）+ "忘记密码"链接 + "注册账号"链接
- 配色：主色调#4A90E2，错误提示#F5222D

#### 注册页面UI
- 顶部：应用Logo + "注册"标题
- 中部：手机号输入框 + 验证码输入框（带获取按钮）+ 密码输入框（带强度指示器）+ 确认密码输入框
- 底部：用户协议Checkbox + 注册按钮
- 密码强度指示器：弱（红色）/ 中（黄色）/ 强（绿色）

#### AI聊天页面UI
- 顶部：标题栏 + 清空对话按钮
- 中部：消息列表（用户消息右对齐蓝色，AI消息左对齐白色）
- 底部：输入框 + 发送按钮
- AI消息支持Markdown渲染和打字动画

#### 影像分析页面UI
- 顶部：标题栏 + 上传按钮
- 中部：影像预览区域（支持缩放拖拽）+ 异常区域标注层
- 底部：分析结果报告区域（可折叠）

#### 风险评估页面UI
- 顶部：评估类型选择卡片（4个）
- 中部：问卷区域（Stepper分步）
- 底部：结果可视化区域（雷达图 + 仪表盘）

### 6.2 系统接口

#### 认证接口
```
POST /api/user/login
Request: { phone: string, password: string }
Response: { code: number, data: { token: string, userInfo: UserInfo } }

POST /api/user/register
Request: { phone: string, password: string, verificationCode: string }
Response: { code: number, data: { userId: number } }

POST /api/user/send-code
Request: { phone: string }
Response: { code: number, message: string }
```

#### AI对话接口
```
POST /api/ai/chat
Request: { message: string, sessionId: string, context?: ChatMessage[] }
Response: { code: number, data: { reply: string, markdown: boolean } }
```

#### 影像分析接口
```
POST /api/medical-image/analyze
Request: FormData { image: File, type: string }
Response: { code: number, data: ImageAnalysisResult }
```

#### 风险评估接口
```
POST /api/risk-assessment/submit
Request: RiskAssessmentRequest
Response: { code: number, data: RiskAssessmentResult }
```

---

## 7. 约束条件

### 7.1 技术约束

- **前端框架**: HarmonyOS NEXT + ArkTS + ArkUI
- **后端框架**: Spring Boot 2.x + MyBatis-Plus
- **数据库**: MySQL 8.0 + SQLite（离线缓存）
- **AI服务**: DeepSeek AI + MedicalAgent
- **网络库**: 自定义HttpUtil封装fetch API
- **响应式**: BreakpointSystem断点系统（sm/md/lg）

### 7.2 业务约束

- 手机号必须为11位中国大陆手机号（1开头）
- 密码长度6-20位，建议包含字母和数字
- 验证码有效期5分钟，60秒内不可重复获取
- AI对话单次上下文最多10轮
- 影像文件大小限制10MB，支持JPG/PNG/DICOM格式
- 风险评估问卷每类型约20-30个问题

### 7.3 时间约束

- **Day 1**: 完成Login.ets和Register.ets（P0优先级）
- **Day 2**: 完成AiChatPage.ets（P1优先级）
- **Day 3**: 完成ImageAnalysisPage.ets（P1优先级）
- **Day 4**: 完成RiskAssessmentPage.ets（P1优先级）
- **Day 5**: 完成AncientMedicalImgPage.ets（P2优先级）
- **Day 6**: 完成DistributedCollaborationPage.ets（P2优先级）
- **Day 7**: HomePage.ets响应式优化和全量测试

---

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 断点系统适配 | sm/md/lg三断点Grid列数正确 | P0 | 待验证 |
| FR-002 | 功能入口卡片 | 13个功能卡片显示正确且可跳转 | P0 | 待验证 |
| FR-003 | 用户信息展示 | 登录/未登录状态显示正确 | P1 | 待验证 |
| FR-004 | 登录表单验证 | 手机号密码实时验证 | P0 | 待验证 |
| FR-005 | JWT认证流程 | 登录成功存储Token并跳转 | P0 | 待验证 |
| FR-006 | 登录状态管理 | Loading状态正确显示 | P0 | 待验证 |
| FR-007 | 辅助功能链接 | 忘记密码和注册链接可用 | P1 | 待验证 |
| FR-008 | 注册表单字段 | 四字段验证正确 | P0 | 待验证 |
| FR-009 | 验证码流程 | 60秒倒计时正确 | P0 | 待验证 |
| FR-010 | 密码强度检测 | 弱/中/强三级显示正确 | P1 | 待验证 |
| FR-011 | 用户协议确认 | 未勾选阻止注册 | P0 | 待验证 |
| FR-012 | 注册自动登录 | 注册成功自动跳转首页 | P0 | 待验证 |
| FR-013 | 聊天消息列表 | 消息对齐和虚拟滚动正确 | P1 | 待验证 |
| FR-014 | Markdown渲染 | Markdown格式正确显示 | P1 | 待验证 |
| FR-015 | 打字动画效果 | 逐字打印动画流畅 | P2 | 待验证 |
| FR-016 | MedicalAgent集成 | AI返回专业医疗回复 | P1 | 待验证 |
| FR-017 | 对话上下文管理 | 多轮对话上下文保持 | P1 | 待验证 |
| FR-018 | 影像上传功能 | 拍照和相册选择可用 | P1 | 待验证 |
| FR-019 | 影像预览确认 | 预览和确认流程正确 | P1 | 待验证 |
| FR-020 | AI影像分析 | 分析结果正确返回 | P1 | 待验证 |
| FR-021 | 异常区域标注 | 边界框标注正确显示 | P1 | 待验证 |
| FR-022 | 诊断报告展示 | 结构化报告完整显示 | P1 | 待验证 |
| FR-023 | 评估类型选择 | 4种类型可选 | P1 | 待验证 |
| FR-024 | 问卷引擎 | Stepper分步和验证正确 | P1 | 待验证 |
| FR-025 | 问卷数据验证 | 必填和范围验证正确 | P1 | 待验证 |
| FR-026 | 风险结果可视化 | 图表正确显示 | P1 | 待验证 |
| FR-027 | 图像上传预处理 | 预处理流程正确 | P2 | 待验证 |
| FR-028 | 图像修复流水线 | 修复效果符合预期 | P2 | 待验证 |
| FR-029 | OCR文本识别 | 识别准确率>85% | P2 | 待验证 |
| FR-030 | 标注工具 | 标注工具完整可用 | P2 | 待验证 |
| FR-031 | 设备发现配对 | 发现和配对流程正确 | P2 | 待验证 |
| FR-032 | 数据同步传输 | 同步进度和结果正确 | P2 | 待验证 |
| FR-033 | 权限管理 | 权限控制生效 | P2 | 待验证 |
| FR-034 | 数据脱敏 | 敏感数据已脱敏 | P2 | 待验证 |

---

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| ArkTS | HarmonyOS应用开发语言，TypeScript的超集 |
| ArkUI | HarmonyOS声明式UI框架 |
| BreakpointSystem | HarmonyOS响应式断点系统，支持sm/md/lg三断点 |
| JWT | JSON Web Token，用于用户认证的令牌标准 |
| MedicalAgent | 医疗AI代理，提供专业医疗问答服务 |
| ConversationMemory | 对话记忆管理器，维护多轮对话上下文 |
| SRGAN | Super-Resolution GAN，超分辨率生成对抗网络 |
| OCR | Optical Character Recognition，光学字符识别 |
| FormData | HTTP文件上传数据格式 |
| LazyForEach | ArkUI懒加载ForEach，用于大数据列表虚拟滚动 |
| Stepper | 步骤器组件，用于分步表单 |
| AppStorage | HarmonyOS应用全局状态存储 |
| Preferences | HarmonyOS轻量级数据持久化API |

---

## 10. 附录

### 10.1 参考资料

- HarmonyOS NEXT开发文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/
- ArkUI组件参考：https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/
- Spring Boot官方文档：https://spring.io/projects/spring-boot
- JWT标准：RFC 7519

### 10.2 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2026-05-06 | 初始版本，定义8个核心页面需求规格 | SDD Agent |
