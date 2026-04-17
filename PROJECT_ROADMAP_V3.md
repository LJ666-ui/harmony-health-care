# 星云医疗助手 - 项目开发实施规划书 V3.0

> **版本：** V3.0 Final
> **制定日期：** 2026-04-10
> **基于实际进度：** 项目已完成的24个页面 + GlobalTheme组件系统 + Mock数据层
> **目标：** 21天完成前后端联调，产出可演示的完整应用

---

## 一、项目当前状态总览

### 1.1 前端完成度分析

#### 已完成的核心基础（100%）

**全局样式系统：**
- GlobalTheme类完整定义（颜色常量、字体大小、间距、圆角等）
- 老年模式支持体系（@StorageLink + AppStorage双向绑定）
- 标准化组件库：Header、Footer、Card、Button、Input、Loading、EmptyState、PullRefresh、ClickableCard

**数据模型层：**
- HealthData.ets定义了15个核心数据接口（UserInfo、HealthRecord、Appointment、Medication、Hospital、Doctor等）
- 类型系统完善，支持TypeScript类型检查

**页面完成情况统计：**

| 分类 | 页面总数 | 已创建 | 使用GlobalTheme | 未标准化 | 完成率 |
|------|----------|--------|-----------------|----------|--------|
| **入口/登录** | 2个（Index、Login） | 2个 | 2个 | 0个 | **100%** ✅ |
| **首页/Tab页** | 5个（HomePage、MedicalPage、RehabPage、SciencePage、Profile） | 5个 | 4个 | 1个 | **90%** ✅ |
| **就医服务** | 6个（HospitalPage、DepartmentPage、Appointments、AddAppointmentPage、ARNavigationPage） | 6个 | 2个 | 4个 | **67%** ⚠️ |
| **康复训练** | 4个（RehabListPage、Rehab3DPage） | 4个 | 0个 | 4个 | **50%** ⚠️ |
| **健康记录** | 3个（HealthRecords、Medications、RiskAssessmentPage） | 3个 | 1个 | 2个 | **67%** ⚠️ |
| **科普内容** | 3个（ScienceListPage、ScienceDetailPage） | 3个 | 1个 | 2个 | **67%** ⚠️ |
| **个人中心** | 4个（Profile、PrivacyPage、PrivacySettingPage、PrivacyPolicyPage） | 4个 | 3个 | 1个 | **85%** ✅ |
| **设备/语音** | 3个（DeviceDiscoveryPage、VoiceAssistantPage） | 3个 | 1个 | 2个 | **67%** ⚠️ |

**总体前端完成度：78%**

#### 待优化项清单（10个页面需GlobalTheme适配）

1. **Appointments.ets** - 预约管理页面（硬编码fontSize/fontColor/backgroundColor）
2. **Medications.ets** - 用药管理页面（同上）
3. **DeviceDiscoveryPage.ets** - 设备发现页面（同上）
4. **RiskAssessmentPage.ets** - 风险评估页面（同上）
5. **RehabListPage.ets** - 康复课程列表（同上）
6. **ScienceDetailPage.ets** - 科普详情页（同上）
7. **AddAppointmentPage.ets** - 新增预约表单（同上）
8. **DepartmentPage.ets** - 科室选择页（同上）
9. **Rehab3DPage.ets** - 3D康复页（部分未适配）
10. **Index.ets** - 启动页（需重构为品牌展示页）

### 1.2 后端完成度分析

#### 当前状态：❌ 完全未开发

**已有的准备工作：**
- ApiConstants.ets定义了登录接口路径常量
- HttpUtil.ets定义了LoginRequest/LoginResponse接口类型
- 数据模型已在HealthData.ets中定义（可直接用于后端实体类映射）

**缺失的后端基础设施：**
- ❌ Spring Boot项目未创建
- ❌ MySQL数据库未安装和配置
- ❌ 数据库表结构未创建（17张表待建）
- ❌ MyBatis-Plus集成未完成
- ❌ 用户认证模块（JWT Token）未开发
- ❌ 所有业务API接口未定义
- ❌ 跨域配置未设置
- ❌ 统一返回结果封装未实现

### 1.3 Mock数据现状

所有24个页面当前均使用硬编码的Mock数据，数据量较少：
- HealthRecords: 4条记录（血压/血糖/心率/体重各1条）
- Appointments: 2条预约
- Medications: 2种药品
- HospitalPage: 6家医院
- ScienceListPage: 8篇文章
- DeviceDiscoveryPage: 3台设备
- RiskAssessmentPage: 5项指标
- RehabListPage: 4门课程
- VoiceAssistantPage: 5条语音指令
- PrivacyPage: 5条访问日志

---

## 二、团队角色与分工定义

### 2.1 团队配置（4人标准）

| 角色 | 代号 | 核心职责 | 技术栈要求 |
|------|------|----------|------------|
| **队长/全栈架构师** | A | 项目架构设计、分布式能力开发、隐私加密模块、版本打包、技术问题解决 | HarmonyOS API22、ArkTS、分布式软总线、AES加密、Spring Boot架构 |
| **前端工程师** | B | 页面UI优化、GlobalTheme适配、交互体验增强、3D/AR界面、老年模式打磨 | ArkUI声明式开发、GlobalTheme系统、组件化设计、动画效果 |
| **后端/AI工程师** | C | Spring Boot后端搭建、数据库设计与实现、API接口开发、AI模型集成 | Spring Boot 2.7、MyBatis-Plus、MySQL 8.0、MindSpore Lite |
| **产品/测试专员** | D | 需求梳理、功能测试、Bug跟踪、文档撰写、演示视频制作、答辩准备 | 测试用例设计、Postman接口测试、文档编写、视频剪辑 |

### 2.2 工作隔离原则

**关键原则：每个人的工作必须是独立可交付的**

- **A的工作**：不依赖B/C的具体代码，负责架构规范、公共工具类、分布式核心逻辑
- **B的工作**：纯前端页面优化，初期全部使用Mock数据，后期对接C的API
- **C的工作**：纯后端服务开发，独立可测试（Postman），不依赖前端页面
- **D的工作**：独立测试环境搭建、测试用例执行、文档整理，不参与编码

**协作机制：**
- A负责制定前后端接口契约（API文档）
- B按照A制定的接口规范调用C开发的API
- C按照A设计的数据库结构开发接口
- D验证B+C的集成效果

---

## 三、三周详细开发时间规划

### 第1周（Day 1-7）：基础搭建与核心功能贯通

#### 总目标
**产出可运行的MVP版本：登录→首页→基本功能浏览→数据Mock展示**

#### Day 1-2：环境搭建与架构初始化

##### **A的任务（全栈架构师）**
**工作时间：8小时/天 × 2天 = 16小时**

**Day 1 具体任务：**
1. 创建Spring Boot后端项目骨架
   - 使用Spring Initializr生成项目（Java 8, Spring Boot 2.7.18）
   - 配置Maven依赖：MyBatis-Plus 3.5.3.1、HikariCP 4.1.2、JWT、Lombok
   - 创建标准包结构：controller/service/mapper/entity/config/common/utils
   - 配置application.yml（端口8080、数据库连接池、MyBatis日志）

2. 设计并创建MySQL数据库
   - 安装MySQL 8.0.45（如本地已有则跳过安装）
   - 创建数据库：harmony_healthcare
   - 执行SQL脚本创建17张核心表（见附录A：完整DDL语句）
   - 插入初始测试数据（用户账号、医院信息、科室字典等）

3. 编写后端基础框架代码
   - 统一返回结果类Result<T>（code/message/data）
   - 全局异常处理器@ControllerAdvice
   - 跨域配置CorsConfig
   - JWT工具类（Token生成/解析/校验）
   - AES加密解密工具类（用于隐私数据脱敏）
   - MyBatis-Plus分页插件配置

**Day 1 结束后的交付物：**
- ✅ Spring Boot项目可启动运行（访问http://localhost:8080显示欢迎页）
- ✅ MySQL数据库17张表创建成功，含初始种子数据
- ✅ 公共工具类可用（Result、JwtUtils、AESUtil等）

**Day 2 具体任务：**
1. 开发用户认证模块（P0优先级）
   - 编写User实体类（对应user_info表）
   - 编写UserMapper接口（继承BaseMapper<User>）
   - 编写UserService（注册/登录/获取用户信息/修改密码）
   - 编写AuthController（POST /api/auth/login、POST /api/auth/register）
   - 实现JWT Token签发逻辑（登录成功返回token）
   - 编写JWT拦截器（验证后续请求的token有效性）

2. 定义前后端API接口契约文档
   - 输出API.md文档（包含所有接口的路径/方法/参数/返回值）
   - 与B沟通确认接口字段命名规范（驼峰式）
   - 与C确认分页参数统一格式（pageNum/pageSize）

**Day 2 结束后的交付物：**
- ✅ 用户登录接口可调用（Postman测试通过）
- ✅ JWT Token认证机制生效
- ✅ API接口文档v1.0发布给团队

---

##### **B的任务（前端工程师）**
**工作时间：8小时/天 × 2天 = 16小时**

**Day 1 具体任务：**
1. 完成10个页面的GlobalTheme标准化改造
   - 按优先级排序处理：
     - P0（必须）：Appointments.ets、Medications.ets、AddAppointmentPage.ets（高频使用页面）
     - P1（重要）：HospitalPage.ets、DepartmentPage.ets、RehabListPage.ets
     - P2（一般）：DeviceDiscoveryPage.ets、RiskAssessmentPage.ets、ScienceDetailPage.ets、Rehab3DPage.ets

   **每个页面的改造步骤（以Appointments.ets为例）：**
   - 步骤1：在文件顶部添加 `import { GlobalTheme } from '../global';`
   - 步骤2：在@Component前添加 `@StorageLink('isOldModeEnabled') isElderMode: boolean = false;`
   - 步骤3：在aboutToAppear()中初始化老年模式状态
   - 步骤4：替换所有硬编码值（按替换规则速查表逐一修改）：
     * `.fontSize(24)` → `.fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))`
     * `.fontColor('#1677FF')` → `.fontColor(GlobalTheme.THEME_COLOR)`
     * `.backgroundColor('#F5F7FA')` → `.backgroundColor(GlobalTheme.BG_COLOR)`
     * `.borderRadius(12)` → `.borderRadius(GlobalTheme.RADIUS_MD)`
     * `.margin({ top: 16 })` → `.margin({ top: GlobalTheme.getSpacingMD(this.isElderMode) })`

   **预计工作量：** 每个页面15-20分钟，10个页面总计约3小时

2. 重构Index.ets为品牌启动页
   - 添加星云医疗助手Logo（文字或图标）
   - 显示应用名称和slogan
   - 2秒后自动跳转到Login页面
   - 支持老年模式大字体显示

**Day 1 结束后的交付物：**
- ✅ 10个页面全部使用GlobalTheme统一样式
- ✅ 老年模式切换后所有页面字号/间距同步变化
- ✅ Index.ets变为专业启动页

**Day 2 具体任务：**
1. 扩充Mock数据至真实化水平
   - **HealthRecords**：从4条扩充到12条（血压×2、血糖×2、心率×2、体温×2、体重×2、睡眠×2，含正常/异常值）
   - **Appointments**：从2条扩充到6条（覆盖内科/外科/骨科/儿科/妇科/眼科，不同时间段）
   - **Medications**：从2条扩充到8条（降压药/降糖药/维生素/消炎药/止痛药/中药等）
   - **HospitalPage**：从6家扩充到10家（三甲医院4家+专科医院3家+社区医院3家）
   - **ScienceListPage**：从8篇扩充到15篇（心血管/骨科/内分泌/营养/心理/中医等分类）
   - **PrivacyPage日志**：从5条扩充到10条（登录/查看/修改/导出/授权等多种操作）
   - **DeviceDiscoveryPage**：从3台扩充到8台（手环/手表/血压计/体脂秤/血糖仪/血氧仪/体温计/体重秤）
   - **RiskAssessmentPage**：从5项指标扩充到8项（新增BMI/骨密度/肺功能/睡眠质量评估）
   - **RehabListPage**：从4门课程扩充到8门课程（颈椎/腰椎/肩周/膝关节炎/糖尿病/高血压/帕金森/术后恢复）
   - **VoiceAssistantPage**：从5条指令扩充到10条指令（增加查药品/查医院/查症状/紧急呼叫场景）

   **数据质量要求：**
   - 每条数据必须有真实感的notes备注（如"晨起测量，昨晚熬夜"）
   - 时间戳要符合逻辑（不能出现未来日期）
   - 状态值要多样化（不能全是confirmed或pending）

2. 添加全局点击反馈动画（F2.01功能）
   - 为所有可点击元素（按钮、卡片、列表项）添加缩放+透明度动画
   - 使用onTouch事件监听按下/抬起状态
   - 动画时长150ms，缩放比例0.97，透明度降至0.9

**Day 2 结束后的交付物：**
- ✅ 所有页面Mock数据丰富饱满，适合演示
- ✅ 点击任何可交互元素都有视觉反馈

---

##### **C的任务（后端/AI工程师）**
**工作时间：8小时/天 × 2天 = 16小时**

**注意：C的工作完全依赖A Day 1完成后提供的数据库和项目骨架**

**Day 1 任务（等待A完成数据库创建后开始）：**
1. 学习和理解A创建的项目结构
2. 阅读A输出的API接口文档v1.0
3. 熟悉HealthData.ets中的数据模型（作为实体类参考）

**Day 2 具体任务：**
1. 编写实体类和Mapper层
   - 根据数据库17张表，创建对应的Entity类（使用Lombok注解@Data/@TableName）
   - 编写所有Mapper接口（继承BaseMapper<T>）
   - 重点实现以下核心表的CRUD：
     * user_info（用户信息）
     * health_data（健康数据）
     * appointment（预约管理）
     * medication（用药管理）
     * hospital_info（医院信息）
     * article（科普文章）

2. 编写Service业务逻辑层
   - UserServiceImpl：用户注册/登录/信息查询/密码修改
   - HealthDataServiceImpl：健康数据的增删改查/按类型筛选/按时间范围查询
   - AppointmentServiceImpl：预约创建/取消/查询我的预约/按状态筛选
   - MedicationServiceImpl：药品增删改查/提醒开关控制
   - HospitalServiceImpl：医院列表/搜索/科室查询
   - ArticleServiceImpl：文章列表/详情/分类筛选/阅读量统计

**Day 2 结束后的交付物：**
- ✅ 6个核心Service及其实现类完成
- ✅ 可通过Postman测试基础CRUD接口

---

##### **D的任务（产品/测试专员）**
**工作时间：8小时/天 × 2天 = 16小时**

**Day 1 具体任务：**
1. 整理最终需求清单（基于项目详细规划.md）
   - 提取P0/P1/P2优先级功能点
   - 制作需求追踪矩阵Excel表格
   - 标注每个功能的负责人（A/B/C）和预期完成时间

2. 搭建测试环境
   - 安装Postman（如未安装）
   - 创建测试用例集合（按模块分类：用户模块/健康数据/预约/科普等）
   - 准备测试账号数据（普通用户/医生管理员）

3. 收集医疗科普素材
   - 从丁香医生、国家卫健委网站收集15篇高质量文章
   - 整理文章标题、摘要、正文内容
   - 收集古医图/古迹图片素材（用于AI复原功能展示）

**Day 2 具体任务：**
1. 开始测试B完成的前端页面
   - 验证10个页面的GlobalTheme适配是否生效
   - 测试老年模式切换功能（所有页面字号是否变化）
   - 检查Mock数据显示是否正常
   - 记录发现的UI问题（字体过大/过小、间距不合理、颜色对比度不足）

2. 编写测试报告模板
   - BUG记录表（编号/描述/严重程度/截图/责任人/状态）
   - 测试进度日报格式
   - 功能验收标准checklist

**Day 2 结束后的交付物：**
- ✅ 需求追踪矩阵建立
- ✅ Postman测试集合创建完毕
- ✅ 第一轮前端UI测试报告输出（含BUG清单）

---

#### Day 1-2 结束后的里程碑检查点

**必须达成的目标：**
- [ ] A：Spring Boot项目跑通，数据库17张表就绪，登录接口可用
- [ ] B：10个页面GlobalTheme适配完成，Mock数据扩充完毕
- [ ] C：6个核心Service完成，基础CRUD可测
- [ ] D：测试环境就绪，第一轮UI测试报告输出
- [ ] 全队：API接口文档v1.0对齐，前后端数据格式达成一致

---

#### Day 3-4：核心业务功能开发

##### **A的任务（全栈架构师）**
**Day 3 具体任务：**
1. 开发健康数据管理API
   - GET /api/health/data - 获取当前用户健康数据列表（支持分页、按类型筛选）
   - POST /api/health/data - 新增一条健康记录
   - PUT /api/health/data/{id} - 修改健康记录
   - DELETE /api/health/data/{id} - 删除健康记录
   - GET /api/health/stats - 获取健康统计数据（平均值/趋势）

2. 开发预约管理API
   - GET /api/appointment/list - 获取我的预约列表（按状态筛选：待确认/已确认/已完成/已取消）
   - POST /api/appointment/create - 创建新预约
   - PUT /api/appointment/cancel/{id} - 取消预约
   - GET /api/appointment/detail/{id} - 获取预约详情

3. 开发用药管理API
   - GET /api/medication/list - 获取用药列表
   - POST /api/medication/add - 添加药品
   - PUT /api/medication/update/{id} - 更新药品信息（含提醒开关）
   - DELETE /api/medication/delete/{id} - 删除药品

**Day 3 结束后的交付物：**
- ✅ 12个业务API接口开发完成
- ✅ Postman测试全部通过（返回正确数据）

**Day 4 具体任务：**
1. 开发医院和科室查询API
   - GET /api/hospital/list - 医院列表（支持关键词搜索、距离排序、等级筛选）
   - GET /api/hospital/{id}/departments - 获取医院科室列表
   - GET /api/hospital/{id}/doctors - 获取科室医生列表（含号源情况）

2. 开发科普文章API
   - GET /api/article/list - 文章列表（支持分类筛选、分页）
   - GET /api/article/{id} - 文章详情（阅读量自动+1）
   - GET /api/article/categories - 获取文章分类列表

3. 开发设备管理和隐私相关API
   - GET /api/device/list - 获取已绑定设备列表
   - POST /api/device/bind - 绑定新设备
   - DELETE /api/device/unbind/{id} - 解绑设备
   - GET /api/privacy/logs - 获取隐私访问日志
   - PUT /api/privacy/permission/{id} - 修改权限开关状态

**Day 4 结束后的交付物：**
- ✅ 累计25个API接口全部完成
- ✅ 后端核心功能闭环（用户/健康/预约/用药/医院/科普/设备/隐私）

---

##### **B的任务（前端工程师）**
**Day 3 具体任务：**
1. 对接后端API - 用户认证流程
   - 修改Login.ets：将硬编码登录改为调用A的POST /api/auth/login接口
   - 实现Token存储：登录成功后将JWT Token存入AppStorage
   - 在HttpUtil.ets中封装统一的请求方法（自动携带Token）
   - 添加请求拦截器：401错误时自动跳转回登录页

2. 对接后端API - 首页数据加载
   - 修改HomePage.ets：从后端获取用户基本信息展示
   - 添加Loading状态：数据加载中显示Loading组件
   - 添加Error处理：网络失败时显示EmptyState组件

**Day 3 结束后的交付物：**
- ✅ 登录功能真正连接后端（输入正确账号密码可登录）
- ✅ 首页显示的数据来自数据库而非硬编码

**Day 4 具体任务：**
1. 对接后端API - 健康记录页面
   - 修改HealthRecords.ets：调用GET /api/health/data获取数据
   - 实现下拉刷新功能（调用PullRefresh组件触发重新请求）
   - 实现新增健康记录功能（调用POST /api/health/data）
   - 添加空状态处理：无数据时显示EmptyState提示

2. 对接后端API - 预约管理页面
   - 修改Appointments.ets：调用GET /api/appointment/list获取预约列表
   - 修改AddAppointmentPage.ets：调用POST /api/appointment/create提交表单
   - 实现取消预约功能（调用PUT /api/appointment/cancel/{id}）
   - 添加Toast提示：操作成功/失败弹出promptAction.showToast()

**Day 4 结束后的交付物：**
- ✅ 健康记录页面可查看/新增真实数据
- ✅ 预约管理页面可创建/取消预约

---

##### **C的任务（后端/AI工程师）**
**Day 3 具体任务：**
1. 补充剩余业务的Controller层
   - HealthDataController（健康数据6个接口）
   - AppointmentController（预约管理4个接口）
   - MedicationController（用药管理4个接口）

2. 编写单元测试
   - 使用JUnit 5编写Service层测试用例
   - 测试边界条件（空值/超长字符串/非法状态值）
   - 确保代码覆盖率≥60%

**Day 4 具体任务：**
1. 补充Controller层
   - HospitalController（医院查询3个接口）
   - ArticleController（科普文章3个接口）
   - DeviceController（设备管理3个接口）
   - PrivacyController（隐私相关2个接口）

2. 性能优化
   - 添加Redis缓存（热点数据：医院列表、文章分类）
   - 优化慢查询SQL（添加索引）
   - 配置连接池参数调优

---

##### **D的任务（产品/测试专员）**
**Day 3 具体任务：**
1. 接口测试（使用Postman）
   - 按照A提供的API文档，逐个测试25个接口
   - 验证请求参数合法性校验（必填项/格式/长度）
   - 验证返回数据完整性（字段齐全/类型正确）
   - 记录接口BUG（500错误/数据不一致/性能问题）

2. 前后端联调问题跟踪
   - 协助B排查前端调用后端报错的问题
   - 整理跨域问题、Token失效问题、字段名不一致问题
   - 维护问题跟踪表，每日更新解决进度

**Day 4 具体任务：**
1. 功能测试（黑盒测试）
   - 模拟用户完整操作流程：登录→首页→健康记录→新增数据→预约→用药
   - 验证业务逻辑正确性（如：取消预约后状态变为cancelled）
   - 测试异常场景（网络断开/服务器宕机/并发操作）

2. 编写测试报告Day3-Day4版
   - 统计BUG数量和严重程度分布
   - 标注已修复/待修复/延期处理的状态
   - 给出风险评估和建议

---

#### Day 3-4 结束后的里程碑检查点

**必须达成的目标：**
- [ ] A：25个API接口全部开发完成且测试通过
- [ ] B：登录、首页、健康记录、预约管理4个核心页面已对接后端
- [ ] C：所有Controller和Service完成，单元测试覆盖率达标
- [ ] D：接口测试和功能测试报告输出，BUG清零率≥80%
- [ ] 全队：前后端首次联调成功，主流程可走通

---

#### Day 5-6：高级功能与体验优化

##### **A的任务（全栈架构师）**
**Day 5 具体任务：**
1. 开发AI共病风险评估算法（简化版）
   - 设计风险评估算法逻辑（基于规则引擎，非深度学习）
   - 输入：用户的血压/血糖/体重/年龄/性别等健康数据
   - 输出：综合风险评分（0-100分）+ 风险等级（低/中/高）+ 各维度风险值
   - 实现GET /api/risk/assess接口

2. 开发语音助手规则匹配后端（简化版）
   - 设计关键词匹配引擎
   - 支持10种常见医疗问答场景（血压咨询/用药查询/挂号帮助/紧急求助等）
   - 实现POST /api/voice/query接口（接收文本，返回结构化回复）

**Day 6 具体任务：**
1. 分布式软总线设备发现功能（HarmonyOS特有）
   - 实现设备扫描和发现逻辑
   - 实现设备配对和连接
   - 准备多设备联动演示方案（手机+手表/手机+平板）

2. 数据导出功能（模拟PDF生成）
   - 实现GET /api/export/health-report接口
   - 返回模拟的PDF Base64数据或下载链接
   - 前端可展示"导出成功"提示

---

##### **B的任务（前端工程师）**
**Day 5 具体任务：**
1. 实现健康数据可视化图表（F4.01功能）
   - 在HealthRecords.ets顶部添加Canvas绘制的折线图
   - 展示近7天血压/血糖趋势
   - 支持点击数据点显示详细信息
   - 支持左右滑动切换时间范围（7天/30天/90天）

2. 增强AI语音助手页面（F4.02功能）
   - 修改VoiceAssistantPage.ets：调用后端POST /api/voice/query
   - 实现对话气泡UI（用户消息右对齐，AI回复左对齐）
   - 支持多轮对话历史记录显示
   - 添加紧急求助特殊处理（红色警告样式+拨打120按钮）

**Day 6 具体任务：**
1. 实现下拉刷新功能（F2.02功能）
   - 为8个列表页面集成PullRefresh组件：
     * HealthRecords、Appointments、Medications
     * HospitalPage、ScienceListPage、RehabListPage
     * DeviceDiscoveryPage、PrivacyPage
   - 下拉时显示刷新动画，1.5秒后重新请求数据

2. 实现Toast消息提示（F2.05功能）
   - 为所有操作型页面添加操作反馈：
     * 保存成功/保存失败
     * 删除确认/删除失败
     * 提交成功/提交失败
   - 使用promptAction.showToast()方法

---

##### **C的任务（后端/AI工程师）**
**Day 5 具体任务：**
1. 实现风险评估算法Service
   - RiskAssessmentServiceImpl：读取用户最近30天健康数据
   - 计算各项指标风险值（血压风险/血糖风险/BMI风险等）
   - 加权计算综合得分
   - 生成风险评估报告（含建议文案）

2. 实现语音助手规则引擎
   - VoiceAssistantServiceImpl：维护IntentRule规则列表
   - 关键词匹配+优先级排序
   - 模板回复生成（支持变量替换，如{userName}/{bloodPressure}）

**Day 6 具体任务：**
1. 实现数据统计和分析接口
   - GET /api/stats/overview - 首页统计数据（今日步数/本周预约数/健康评分）
   - GET /api/health/trend - 健康数据趋势（近7天/30天折线图数据）
   - GET /api/notification/list - 通知消息列表（预约提醒/用药提醒/系统通知）

2. 定时任务开发
   - 用药提醒定时推送（每天按时发送通知）
   - 预约前一天提醒（提前一天下午6点推送）
   - 健康数据异常预警（超出正常范围自动告警）

---

##### **D的任务（产品/测试专员）**
**Day 5 具体任务：**
1. 高级功能测试
   - 测试AI风险评估准确性（构造不同健康数据组合，验证评分合理性）
   - 测试语音助手回复质量（输入各种问法，检查是否能正确识别意图）
   - 测试图表渲染性能（大量数据点时是否卡顿）

2. 用户体验测试
   - 邀请1-2位真实用户（最好是老年人）进行试用
   - 观察操作流程是否顺畅
   - 收集反馈意见（字体大小是否合适/按钮是否容易点击/颜色对比度是否足够）

**Day 6 具体任务：**
1. 性能测试
   - 使用JMeter模拟并发请求（100并发用户）
   - 监控接口响应时间（目标：<500ms for 95% requests）
   - 监控服务器资源占用（CPU/内存/数据库连接数）

2. 安全性测试
   - 测试SQL注入防护（在输入框输入特殊字符）
   - 测试XSS攻击防护（在文本域输入脚本标签）
   - 测试越权访问（普通用户尝试访问管理员接口）
   - 测试Token安全性（过期Token/伪造Token/重放攻击）

---

#### Day 5-6 结束后的里程碑检查点

**必须达成的目标：**
- [ ] A：风险评估和语音助手后端算法完成，分布式设备发现可用
- [ ] B：图表可视化、语音对话UI、下拉刷新、Toast提示全部实现
- [ ] C：算法Service完成，定时任务运行正常
- [ ] D：高级功能和性能测试报告输出
- [ ] 全队：应用功能丰富度达到大赛演示标准

---

#### Day 7：联调修复与Demo版本打包

##### **全体成员任务**

**A的任务：**
1. 解决Day 3-6遗留的技术债和BUG
2. 打包HAP文件（DevEco Studio → Build HAP(s)/APP(s) → Build HAP(s)）
3. 确保HAP可在鸿蒙模拟器或真机上正常运行
4. 准备多设备联动演示环境（两台设备配对成功）

**B的任务：**
1. 修复D提交的所有UI BUG
2. 统一所有页面的视觉风格（确保一致性）
3. 补全缺省页和空状态页面的美化
4. 优化页面跳转动画（淡入淡出效果）

**C的任务：**
1. 修复D提交的所有后端BUG
2. 补充测试数据让演示更逼真（更多医院/文章/案例）
3. 优化数据库查询性能
4. 确保服务稳定运行不崩溃

**D的任务：**
1. 全流程回归测试（登录→首页→所有子页面→退出）
2. BUG清零行动（严重BUG必须归零，次要BUG≤3个）
3. 录制演示视频（屏幕录制+配音解说）
4. 整理第二周任务清单和进度报告

**Day 7 结束后的里程碑：第一周Demo版本V0.1发布**

**V0.1版本包含的功能：**
- ✅ 用户登录/注册（JWT认证）
- ✅ 首页展示（用户信息+快捷入口）
- ✅ 健康记录管理（查看/新增/图表可视化）
- ✅ 预约管理（创建/查看/取消）
- ✅ 用药管理（查看/添加/编辑）
- ✅ 医院查询（列表/搜索/科室）
- ✅ 科普文章（列表/详情/分类）
- ✅ 设备管理（发现/绑定/解绑）
- ✅ 风险评估（AI算法评分）
- ✅ 语音助手（规则匹配对话）
- ✅ 隐私中心（权限管理/访问日志）
- ✅ 老年模式全局适配
- ✅ 下拉刷新/Toast提示/点击反馈

---

### 第2周（Day 8-14）：核心功能攻坚与创新亮点

#### 总目标
**完成分布式协同、AR导航、3D康复、古迹复原四大创新功能，冲击专项奖**

#### Day 8-9：跨院数据协同 + AI共病联合评估

##### **A的任务（全栈架构师）- 重点工作日**

**Day 8 具体任务：**
1. 设计跨院数据协同架构
   - 基于鸿蒙分布式软总线的设备间通信协议
   - 数据传输格式定义（JSON + AES加密）
   - 设备身份认证机制（设备证书+用户授权）

2. 实现转院申请功能
   - 数据库新增transfer_apply表（如未创建）
   - 开发转院申请API：
     * POST /api/transfer/apply - 提交转院申请
     * GET /api/transfer/my-list - 我的转院申请列表
     * PUT /api/transfer/approve/{id} - 审批转院申请（医生角色）
     * GET /api/transfer/records - 转院病历数据同步记录

3. 实现病历数据脱敏逻辑
   - 编写数据脱敏工具类（姓名/电话/身份证号/地址脱敏规则）
   - 在转院数据传输前自动调用脱敏
   - 确保敏感信息不以明文形式传输

**Day 9 具体任务：**
1. 实现分布式数据同步
   - 使用HarmonyOS DistributedDataManager实现跨设备数据同步
   - 设备A发起同步请求 → 设备B接收并解析 → 返回确认
   - 同步内容包括：脱敏病历、检查报告、诊断结论

2. AI共病联合风险评估增强
   - 扩展原有单病种评估为多病种联合评估
   - 新增评估维度：高血压+糖尿病+衰弱+肌少症+跌倒风险
   - 输出综合风险矩阵（而非单一分数）
   - 生成个性化干预建议

**Day 8-9 结束后的交付物：**
- ✅ 转院申请流程可走通（前端提交→后端存储→医生审批）
- ✅ 两台鸿蒙设备间可同步脱敏病历数据
- ✅ 共病风险评估报告更全面准确

---

##### **B的任务（前端工程师）- 重点工作日**

**Day 8 具体任务：**
1. 开发转院申请页面
   - 新建TransferApplyPage.ets页面
   - 表单字段：原医院→目标医院→转院原因→上传附件→提交
   - 表单验证：必填项检查、日期合理性检查
   - 提交成功后跳转到申请列表页

2. 开发转院申请列表页面
   - 新建TransferListPage.ets页面
   - 展示申请状态（待审核/已通过/已拒绝）
   - 支持查看申请详情和审批进度
   - 已通过的申请显示数据同步状态

**Day 9 具体任务：**
1. 开发病历查看页面（支持脱敏展示）
   - 新建MedicalRecordViewPage.ets页面
   - 展示病历基本信息（患者姓名显示为"张*"）
   - 展示诊断结论、治疗方案、检查报告
   - 敏感信息区域显示"***已脱敏***"标记

2. 增强风险评估页面
   - 修改RiskAssessmentPage.ets：展示多维度风险雷达图
   - 使用Canvas绘制五边形雷达图（5个顶点代表5种风险）
   - 不同风险等级用不同颜色填充
   - 底部显示综合建议文案

---

##### **C的任务（后端/AI工程师）- 重点工作日**

**Day 8 具体任务：**
1. 实现转院业务Service层
   - TransferApplyServiceImpl：创建申请/查询列表/审批逻辑
   - 审批权限校验（只有医生角色可审批）
   - 审批通过后触发数据同步准备

2. 实现数据脱敏Service
   - DataDesensitizationServiceImpl：根据字段类型选择脱敏规则
   - 手机号：138****1234
   - 姓名：张*
   - 身份证：110***********1234
   - 地址：北京市海淀区***

**Day 9 具体任务：**
1. 实现共病联合评估算法
   - ComorbidityRiskServiceImpl：多维度风险计算
   - 各维度权重配置（可通过数据库调整）
   - 风险等级划分阈值（低<30 / 30≤中<70 / 高≥70）
   - 干预建议模板库（根据风险组合匹配建议）

2. 编写算法测试用例
   - 构造典型病例数据（高血压+糖尿病患者）
   - 验证评估结果的合理性和一致性
   - 边界测试（极端数值/缺失数据）

---

##### **D的任务（产品/测试专员）**

**Day 8-9 具体任务：**
1. 测试跨院数据协同流程
   - 模拟患者提交转院申请
   - 模拟医生审批操作
   - 验证数据脱敏效果（检查敏感字段是否被遮蔽）
   - 验证两台设备间数据同步延迟（目标<100ms）

2. 测试AI共病评估准确性
   - 准备10组测试病例（涵盖不同病种组合）
   - 对比人工评估结果与算法输出
   - 记录偏差较大的case供A和C优化

3. 整理专项奖申报材料初稿
   - 隐私保护专项：数据脱敏方案、TEE可信环境说明
   - 全场景协同专项：分布式软总线应用案例
   - AI智能化专项：共病评估算法创新点

---

#### Day 10-11：智慧停车 + AR导航 + 3D康复演示

##### **A的任务（全栈架构师）**

**Day 10 具体任务：**
1. 集成华为Map Kit（地图服务）
   - 申请华为Map Kit API Key
   - 配置map_config.json
   - 实现地图基础展示（医院位置标注）

2. 实现停车场预约功能
   - 新增parking_lot表（车位ID/楼层/区域/状态/预约用户）
   - 开发停车场API：
     * GET /api/parking/lots - 车位列表
     * POST /api/parking/reserve - 预约车位
     * DELETE /api/parking/cancel/{id} - 取消预约

**Day 11 具体任务：**
1. 集成AR Engine（AR导航基础）
   - 申请AR Engine权限
   - 实现相机预览和AR场景初始化
   - 在ARNavigationPage.ets基础上添加AR渲染逻辑

2. 实现3D康复动作数据接口
   - 新增rehab_action表（动作ID/名称/描述/3D模型URL/视频URL）
   - 开发康复动作API：
     * GET /api/rehab/courses - 课程列表
     * GET /api/rehab/course/{id}/actions - 课程下的动作列表
     * GET /api/rehab/action/{id}/detail - 动作详情（含3D模型路径）

---

##### **B的任务（前端工程师）**

**Day 10 具体任务：**
1. 开发停车场预约页面
   - 新建ParkingReservationPage.ets页面
   - 展示车位平面图（楼层/区域/编号）
   - 可用车位绿色高亮，已占用灰色置灰
   - 点击车位弹出预约确认弹窗

2. 开发反向寻车功能
   - 在ParkingReservationPage.ets添加寻车按钮
   - 显示从当前位置到车位的步行路线（调用Map Kit路径规划）

**Day 11 具体任务：**
1. 增强AR导航页面
   - 修改ARNavigationPage.ets：叠加AR导航箭头
   - 实现实景画面上的虚拟路标指引
   - 添加语音播报"前方左转进入门诊楼"

2. 增强3D康复训练页面
   - 修改Rehab3DPage.ets：加载真实的3D模型文件（glTF格式）
   - 实现动作播放控制（播放/暂停/上一动作/下一动作）
   - 添加动作要领文字提示（配合3D动画同步显示）

---

##### **C的任务（后端/AI工程师）**

**Day 10 具体任务：**
1. 实现停车场业务逻辑
   - ParkingLotServiceImpl：车位查询/预约/释放
   - 并发控制（同一车位不能被两人同时预约）
   - 超时自动释放（预约后30分钟未到达自动取消）

2. 实现路径规划算法
   - PathPlanningServiceImpl：院内最短路径计算
   - 输入：起点坐标+终点坐标
   - 输出：途经节点列表+转向指示
   - 结合挂号时间智能推荐路线（避开拥堵区域）

**Day 11 具体任务：**
1. 实现康复课程和动作管理
   - RehabCourseServiceImpl：课程CRUD
   - RehabActionServiceImpl：动作CRUD+关联课程
   - 3D模型文件存储和管理（本地文件系统或对象存储）

2. 准备3D康复演示数据
   - 录制或下载4门课程的3D动作模型
   - 准备颈椎拉伸/太极/哑铃训练/平衡训练的标准动作数据
   - 确保模型文件可在前端正常加载和播放

---

##### **D的任务（产品/测试专员）**

**Day 10-11 具体任务：**
1. 测试AR导航功能
   - 在真机或模拟器上测试AR渲染效果
   - 验证导航箭头方向准确性
   - 测试不同光照条件下AR识别稳定性

2. 测试3D康复演示
   - 验证3D模型加载速度（目标<3秒）
   - 验证动作播放流畅度（不掉帧/不卡顿）
   - 验证动作要领文字与动画同步性

3. 更新专项奖材料
   - 3D空间化专项：AR导航+3D康复案例
   - 截图和录屏素材收集

---

#### Day 12-13：医疗知识学习 + 古迹AI复原 + 患者实时监控

##### **A的任务（全栈架构师）**

**Day 12 具体任务：**
1. 实现个性化内容推荐算法
   - 基于用户健康数据标签推荐相关文章
   - 高血压患者推荐心血管类文章
   - 糖尿病患者推荐内分泌类文章
   - 实现GET /api/article/recommend接口

2. 集成语音合成能力
   - 调用HarmonyOS TTS引擎
   - 文章详情页支持朗读功能
   - 康复动作要领支持语音播报

**Day 13 具体任务：**
1. 实现古迹AI复原功能（简化版演示）
   - 上传古医籍图片 → 调用图像增强API（华为云或阿里云）
   - 返回增强后的高清图片 + OCR识别的文字内容
   - 将识别内容转化为3D场景展示数据

2. 实现患者实时监控面板
   - 接收穿戴设备上报的心率/血氧/步数数据
   - 实时展示在监控Dashboard页面
   - 异常数据自动标红报警

---

##### **B的任务（前端工程师）**

**Day 12 具体任务：**
1. 增强科普文章页面
   - 修改ScienceDetailPage.ets：添加朗读按钮
   - 点击后调用TTS朗读文章全文
   - 显示朗读进度条和控制按钮（暂停/继续/停止）

2. 实现个性化推荐Tab
   - 在SciencePage.ets添加"为你推荐"Tab
   - 调用GET /api/article/recommend获取推荐文章
   - 展示推荐理由标签（"因为您关注血压健康"）

**Day 13 具体任务：**
1. 开发古迹AI复原页面
   - 新建AncientRestorationPage.ets页面
   - 图片上传区域（支持相册选取或拍照）
   - 上传后显示处理中动画（转圈+文字"AI正在复原..."）
   - 展示复原结果：原图 vs 复原图对比

2. 开发实时监控面板页面
   - 新建MonitoringDashboardPage.ets页面
   - 实时心率曲线图（每5秒刷新一次数据点）
   - 血氧饱和度仪表盘
   - 今日步数环形进度条
   - 异常数据红色闪烁警告

---

##### **C的任务（后端/AI工程师）**

**Day 12 具体任务：**
1. 实现推荐算法Service
   - RecommendationServiceImpl：基于标签匹配的推荐逻辑
   - 用户画像构建（从健康数据提取标签）
   - 文章标签体系维护

2. 集成第三方TTS服务
   - 封装华为云TTS SDK或阿里云语音合成API
   - 将文本转为音频流返回前端
   - 缓存常用文本的音频文件（避免重复调用）

**Day 13 具体任务：**
1. 实现古迹复原Service
   - AncientRestorationServiceImpl：调用图像增强API
   - 调用OCR API提取文字
   - 结果存储和返回

2. 实现实时数据接收和处理
   - DeviceDataReceiver：接收MQTT或HTTP POST上报的设备数据
   - 数据解析和入库
   - 异常检测规则引擎（心率>120或<50则报警）

---

##### **D的任务（产品/测试专员）**

**Day 12-13 具体任务：**
1. 测试推荐算法效果
   - 构造不同健康画像的用户
   - 验证推荐结果的相关性和多样性
   - A/B测试对比推荐vs随机展示的用户停留时长

2. 测试古迹复原功能
   - 准备5张不同质量的古医图测试
   - 验证复原清晰度提升效果
   - 验证OCR识别准确率

3. 测试实时监控
   - 模拟设备数据上报（使用Postman定时发送）
   - 验证Dashboard数据刷新实时性（延迟<2秒）
   - 验证异常报警触发准确性

---

#### Day 14：第2周功能联调（V0.5版本发布）

##### **全体成员任务**

**A的任务：**
1. 解决跨设备通信问题
2. 优化分布式同步性能
3. 最终打包HAP v0.5版本

**B的任务：**
1. 统一所有新页面的UI风格
2. 优化AR和3D页面的渲染性能
3. 修复D提交的所有UI问题

**C的任务：**
1. 确保所有新接口稳定运行
2. 优化算法性能（评估响应时间<500ms）
3. 补充演示用的测试数据

**D的任务：**
1. 全量功能回归测试
2. 输出完整的测试报告（含性能测试/安全测试/兼容性测试）
3. 整理第二周进度总结和第三周任务计划

**V0.5版本新增功能（相比V0.1）：**
- ✅ 跨院数据协同（转院申请/审批/数据同步）
- ✅ AI共病联合风险评估（多维度/个性化建议）
- ✅ 停车场预约和反向寻车
- ✅ AR院内实景导航（基础版）
- ✅ 3D康复动作演示（4门课程）
- ✅ 个性化科普内容推荐
- ✅ 古迹AI复原（演示版）
- ✅ 患者实时监控Dashboard
- ✅ 文章语音朗读功能

---

### 第3周（Day 15-21）：专项冲刺 + 大赛提交准备

#### 总目标
**强化专项奖功能、UI/UX精细化打磨、小艺智能体对接、赛事材料准备、模拟答辩**

#### Day 15-16：专项奖功能强化 + UI/UX打磨

##### **A的任务（全栈架构师）**

**Day 15 具体任务：**
1. 强化隐私保护功能（隐私保护专项奖）
   - 实现数据分级脱敏策略（公开/内部/机密/绝密四级）
   - 实现数据访问审计日志（谁/何时/何地/看了什么）
   - 实现数据生命周期管理（创建→使用→存档→销毁）
   - 实现用户可撤销授权（一键切断第三方数据共享）

2. 强化超级终端接续（全场景协同专项奖）
   - 实现手机→平板的视频通话接续
   - 实现手机→手表的健康数据自动同步
   - 实现多设备任务流转（手机选课程→大屏播放→手表监测心率）

**Day 16 具体任务：**
1. 完善权限管理体系
   - 细粒度权限控制（字段级/记录级）
   - 角色权限矩阵（普通用户/家属/医生/管理员）
   - 权限变更审批流程

2. 性能优化和稳定性加固
   - 内存泄漏检测和修复
   - ANR（Application Not Responding）问题排查
   - 电量消耗优化（后台任务最小化）

---

##### **B的任务（前端工程师）**

**Day 15 具体任务：**
1. 老年模式深度优化
   - 所有页面支持超大字体模式（最大36px）
   - 所有按钮高度增加至老年友好尺寸（最小60px高度）
   - 图标和文字间距加大（避免误触）
   - 高对比度配色方案（白底黑字/黄底黑字可选）

2. 多端自适应布局优化
   - 手机竖屏/横屏自适应
   - 平板适配（2列布局/3列布局）
   - 折叠屏适配（展开/折叠状态切换）
   - 手表端简化界面（只保留核心功能）

**Day 16 具体任务：**
1. UI细节打磨
   - 统一所有页面的间距规范（严格遵循GlobalTheme）
   - 优化Loading动画效果（使用骨架屏替代传统菊花转）
   - 优化空状态页面插图（绘制SVG矢量插画）
   - 优化页面过渡动画（路由跳转使用自定义动画曲线）

2. 无障碍功能增强
   - 支持屏幕阅读器（TalkBack）
   - 支持高对比度模式
   - 支持字体大小动态调整（滑块控制11-36px）

---

##### **C的任务（后端/AI工程师）**

**Day 15 具体任务：**
1. AI模型性能优化
   - MindSpore Lite模型压缩（量化/剪枝）
   - 端侧推理速度优化（目标：<200ms/次）
   - 模型热更新机制（无需重新安装APP即可更新模型）

2. 数据加密增强
   - 敏感字段AES-256加密存储
   - 传输层TLS 1.3加密
   - 密钥定期轮换机制

**Day 16 具体任务：**
1. 数据自动销毁机制
   - 过期数据自动归档（超过1年的详细数据）
   - 用户注销后数据彻底删除（7天内物理擦除）
   - 操作日志保留期限管理（最少180天）

2. 接口限流和防刷
   - 基于用户ID的接口频率限制（每秒最多5次请求）
   - 基于IP的黑名单机制（恶意请求自动封禁）
   - 验证码机制（登录/敏感操作需要图形验证码）

---

##### **D的任务（产品/测试专员）**

**Day 15-16 具体任务：**
1. 专项奖功能验收测试
   - 隐私保护专项：逐项检查数据脱敏/审计日志/权限控制
   - 全场景协同专项：测试多设备联动流程完整性
   - AI智能化专项：测试AI评估准确率和响应速度
   - 3D空间化专项：测试AR导航和3D康复演示效果

2. 用户体验评审
   - 组织团队内部用户体验评审会
   - 每个人扮演不同角色（老年人/年轻人/医生/家属）
   - 收集改进意见并分类整理

3. 专项奖申报材料撰写
   - 四个专项奖的申报文档初稿
   - 创新点阐述和技术难点说明
   - 应用截图和演示视频片段

---

#### Day 17-18：小艺智能体对接 + 全量测试

##### **A的任务（全栈架构师）**

**Day 17 具体任务：**
1. 小艺Skill/MCP对接
   - 注册医疗专属技能包（skill_id: harmony.healthcare.assistant）
   - 定义语音指令schema（intent/slots/utterances）
   - 实现Skill处理逻辑（接收语音→解析意图→执行操作→返回结果）

2. 医疗专属指令集实现
   - "小艺小艺，帮我挂心内科的号" → 触发预约流程
   - "小艺小艺，我的血压怎么样" → 查询最新血压数据
   - "小艺小艺，阿莫西林怎么吃" → 查询药品用法
   - "小艺小艺，我不舒服" → 触发紧急求助流程

**Day 18 具体任务：**
1. 多设备联动语音控制
   - "小艺小艺，把康复课程投到大屏上" → 触发超级终端流转
   - "小艺小艺，打开卧室灯" → 智能家居联动（演示用）
   - 语音唤醒和连续对话支持

2. 小艺智能体测试和调试
   - 真机语音测试（使用华为手机/平板）
   - 优化识别准确率（调整方言支持/噪声抑制）
   - 处理边缘case（口齿不清/背景嘈杂/专业术语）

---

##### **B的任务（前端工程师）**

**Day 17 具体任务：**
1. 开发语音交互UI
   - 修改VoiceAssistantPage.ets：集成小艺SDK
   - 语音波形动画（录音时显示声波跳动效果）
   - 识别结果实时显示（ASR中间结果）
   - TTS回复语音播放

2. 开发多设备联动控制界面
   - 新建MultiDeviceControlPage.ets页面
   - 展示已发现的周边设备列表
   - 一键流转按钮（将当前内容推送到指定设备）
   - 流转状态提示（发送中/已接收/播放中/已完成）

**Day 18 具体任务：**
1. 语音交互体验优化
   - 添加语音引导提示语（"请问有什么可以帮您？"）
   - 添加常见问题快捷入口（点击气泡直接发送）
   - 添加语音设置选项（唤醒词/音量/语速）

2. 全量UI回归测试
   - 逐页检查所有30+页面的显示效果
   - 验证老年模式/普通模式的切换流畅性
   - 验证深色模式（如有）的显示效果
   - 修复最后一批视觉问题

---

##### **C的任务（后端/AI工程师）**

**Day 17 具体任务：**
1. 实现语音指令解析服务
   - VoiceIntentParserServiceImpl：NLU自然语言理解
   - 意图识别（分类：查询/操作/导航/紧急）
   - 槽位提取（提取实体：科室名/药品名/时间/症状）
   - 对话上下文管理（支持多轮对话）

2. 实现语音指令执行引擎
   - CommandExecutorServiceImpl：根据意图分发到对应Service
   - 查询类指令：读数据库返回结果
   - 操作类指令：写数据库返回操作结果
   - 导航类指令：返回目标页面URL

**Day 18 具体任务：**
1. 对话模板库扩展
   - 新增50+常用医疗问答模板
   - 支持变量替换（{userName}/{drugName}/{dosage}）
   - 支持条件分支（根据用户画像返回不同建议）

2. 全量接口压力测试
   - 使用JMeter模拟1000并发用户
   - 监控QPS（Queries Per Second）、响应时间P99、错误率
   - 定位性能瓶颈并优化（慢SQL/锁竞争/内存泄漏）

---

##### **D的任务（产品/测试专员）**

**Day 17-18 具体任务：**
1. 小艺智能体功能测试
   - 测试30+条语音指令的识别准确率
   - 测试多轮对话上下文保持能力
   - 测试多设备联动流程完整性
   - 测试边缘case（方言/噪音/快速连说）

2. 全量功能测试（最终版）
   - 执行完整的功能测试用例集（300+ case）
   - 执行兼容性测试（不同HarmonyOS版本/不同机型）
   - 执行稳定性测试（长时间运行24小时不崩溃）
   - 输出最终测试报告（BUG清零/遗留问题清单/风险评估）

3. 演示视频制作
   - 录制核心功能演示视频（5-8分钟）
   - 剪辑和添加字幕
   - 配音解说（突出创新点和优势）
   - 输出1080P高清MP4文件

---

#### Day 19-20：赛事材料准备 + 答辩演练

##### **D的任务（主要责任人，全员配合）**

**Day 19 具体任务：**
1. 完成所有大赛文档
   - 项目说明书（Word/PDF，5000-8000字）
   - 技术架构图（Visio/Draw.io绘制）
   - API接口文档（Swagger导出PDF）
   - 数据库设计文档（ER图+表结构说明）
   - 用户手册（操作指南+截图）

2. 完成PPT制作（答辩用）
   - 幻灯片30-40页
   - 结构：项目背景→痛点分析→解决方案→技术创新→演示视频→商业价值→未来规划
   - 视觉风格统一（使用项目主题色#1677FF）
   - 动画效果适度（不要过于花哨）

**Day 20 具体任务：**
1. 准备答辩讲稿
   - 8分钟演讲稿（配合PPT翻页节奏）
   - 开场白（吸引评委注意力）
   - 核心亮点讲解（重点突出4大创新）
   - 演示环节串词（自然过渡到视频）
   - 结尾升华（社会价值+商业前景）

2. 模拟答辩演练
   - 全队参与（A主讲技术架构、B主讲前端体验、C主讲后端算法、D主讲产品和测试）
   - 邀请外部听众（同学/老师）提意见
   - 录制演练视频复盘改进
   - 准备评委可能提问的Q&A清单（20个预测问题+标准答案）

##### **A/B/C的任务（配合D）**

- **A**：提供稳定可运行的HAP安装包，确保演示环境就绪，解答技术架构相关问题
- **B**：提供美观的演示界面截图和录屏素材，准备UI/UX相关的答辩内容
- **C**：确保后端服务稳定运行，准备AI算法和数据处理相关的答辩材料

---

#### Day 21：最终提交 + 正式答辩

##### **全体成员任务**

**上午：**
1. 最终检查所有提交材料
   - HAP安装包（签名完整，可在任意鸿蒙设备安装）
   - 源代码（Git仓库整理干净，无无用文件）
   - 项目文档（说明书/PPT/视频/架构图）
   - 测试报告（最终版）

2. 大赛平台提交
   - 按照要求格式打包上传
   - 填写在线报名表
   - 确认收到回执

**下午：**
1. 正式答辩
   - 提前30分钟到场调试设备
   - 按照演练流程进行8分钟演讲
   - 播放5分钟演示视频
   - 回答评委提问（5-10分钟）

2. 赛后总结
   - 整理评委反馈意见
   - 团队复盘会议（总结经验教训）
   - 规划后续迭代方向（如果获奖则继续完善）

---

## 四、前后端对接详细说明

### 4.1 当前可使用Mock数据的页面（后端未完成时）

以下页面在后端API尚未开发完成前，**继续使用现有的Mock数据**，不影响演示效果：

| 页面名称 | Mock数据来源 | 是否需要改动 | 说明 |
|----------|--------------|--------------|------|
| **HospitalPage** | @State hospitals[] 硬编码 | ❌ 不需要 | 医院列表相对固定，Mock数据已够用 |
| **ScienceListPage** | @State articles[] 硬编码 | ❌ 不需要 | 科普文章内容型数据，Mock即可 |
| **ScienceDetailPage** | router.getParams() 或硬编码 | ❌ 不需要 | 文章详情静态展示 |
| **RehabListPage** | @State courses[] 硬编码 | ❌ 不需要 | 康复课程列表固定 |
| **Rehab3DPage** | @State courseConfigs[] 硬编码 | ❌ 不需要 | 3D演示数据固定 |
| **DepartmentPage** | @State departments[] 硬编码 | ❌ 不需要 | 科室列表固定 |
| **ARNavigationPage** | 无数据交互 | ❌ 不需要 | AR导航纯前端渲染 |

### 4.2 必须对接后端API的页面（P0优先级）

以下页面涉及用户个人数据，**必须在Day 3-4完成前后端联调**：

| 页面名称 | 需要调用的API | 对接时机 | 替代方案（如后端延迟） |
|----------|--------------|----------|----------------------|
| **Login** | POST /api/auth/login | Day 3 | 继续硬编码判断（username=admin && password=123456） |
| **HomePage** | GET /api/user/info + GET /api/stats/overview | Day 3 | 使用固定Mock用户数据 |
| **HealthRecords** | GET/POST /api/health/data | Day 4 | 使用扩充后的Mock数据（12条） |
| **Appointments** | GET/POST /api/appointment/* | Day 4 | 使用扩充后的Mock数据（6条） |
| **AddAppointmentPage** | POST /api/appointment/create | Day 4 | 表单提交后仅本地提示成功，不持久化 |
| **Medications** | GET/POST /api/medication/* | Day 4 | 使用扩充后的Mock数据（8条） |
| **Profile** | GET/PUT /api/user/profile | Day 4 | 使用固定Mock个人信息 |
| **PrivacyPage** | GET /api/privacy/logs | Day 5 | 使用扩充后的Mock日志（10条） |
| **DeviceDiscoveryPage** | GET/POST /api/device/* | Day 5 | 使用扩充后的Mock设备（8台） |
| **RiskAssessmentPage** | GET /api/risk/assess | Day 5 | 使用固定Mock评分（75分/中等风险） |
| **VoiceAssistantPage** | POST /api/voice/query | Day 5 | 使用前端规则匹配（if-else硬编码） |

### 4.3 建议对接后端API的页面（P1优先级，可延后）

| 页面名称 | 需要调用的API | 对接时机 | 价值说明 |
|----------|--------------|----------|----------|
| **TransferApplyPage** | POST /api/transfer/apply | Day 8 | 跨院协同核心功能 |
| **MedicalRecordViewPage** | GET /api/medical/record/{id} | Day 8 | 隐私保护展示 |
| **ParkingReservationPage** | GET/POST /api/parking/* | Day 10 | 智慧停车功能 |
| **AncientRestorationPage** | POST /api/ancient/restore | Day 12 | 古迹AI复原功能 |
| **MonitoringDashboardPage** | WebSocket /api/monitor/realtime | Day 13 | 实时监控展示 |

### 4.4 前后端数据格式约定

#### 统一返回格式（后端→前端）

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    // 具体业务数据
  },
  "timestamp": 1744281600000
}
```

**错误码约定：**
- 200：成功
- 400：请求参数错误
- 401：未登录或Token过期
- 403：无权限访问
- 404：资源不存在
- 500：服务器内部错误

#### 分页请求格式（前端→后端）

**请求：**
```
GET /api/health/data?pageNum=1&pageSize=10&type=blood_pressure
```

**响应：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "list": [...],
    "total": 56,
    "pageNum": 1,
    "pageSize": 10,
    "pages": 6
  }
}
```

#### Token传递方式

**前端请求头携带：**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**后端拦截器校验：**
- 从Header中提取Token
- 解析JWT获取userId
- 将userId存入ThreadLocal供Service层使用
- Token无效或过期返回401

---

## 五、风险控制和应急预案

### 5.1 技术风险

| 风险项 | 可能性 | 影响 | 应对措施 |
|--------|--------|------|----------|
| 后端开发进度滞后 | 中 | 高 | B继续使用Mock数据，降低联调优先级，先保证前端演示效果 |
| HarmonyOS API兼容性问题 | 低 | 高 | 提前在真机上测试，准备降级方案（去掉不稳定的API） |
| AI模型推理性能不达标 | 中 | 中 | 简化为规则引擎，去除深度学习，保证功能可用 |
| 多设备联动调试困难 | 高 | 高 | 准备单设备演示方案，多设备作为加分项展示 |
| 第三方API调用失败（Map Kit/AR Engine） | 中 | 中 | 使用模拟数据和静态图片替代，在答辩中说明技术方案 |

### 5.2 进度风险

| 风险项 | 应对预案 |
|--------|----------|
| Day 1-2环境搭建超时 | A优先保证数据库和登录接口，其他接口可延后 |
| Day 3-4联调问题多 | D协助排查，建立每日Bug清零机制 |
| Day 8-9创新功能复杂度高 | 降低实现深度，保证UI和流程可演示即可 |
| Day 19-20时间不够 | D提前准备文档模板，A/B/C提供素材 |

### 5.3 团队协作风险

| 风险项 | 预防措施 |
|--------|----------|
| 成员之间沟通不畅 | 每日站会10分钟，及时同步阻塞点 |
| 接口定义不一致 | A强制制定API文档，B/C严格按照文档开发 |
| 代码合并冲突 | A负责Code Review，每日合并一次 |
| 成员突发状况 | D作为备份人员，了解整体进度可临时补位 |

---

## 六、质量标准和验收准则

### 6.1 代码质量标准

**前端代码规范：**
- 所有页面必须使用GlobalTheme统一样式（不允许硬编码颜色/字号/间距）
- 组件化率≥70%（重复UI抽取为独立组件）
- TypeScript类型覆盖率100%（禁止使用any类型）
- 单个文件行数≤500行（过长需拆分）

**后端代码规范：**
- 遵循RESTful API设计规范
- Service层必须有接口和实现类分离
- 禁止在Controller中写业务逻辑
- SQL必须使用MyBatis-Plus Wrapper（禁止手写拼接SQL）

### 6.2 功能验收标准

**P0功能（必须完成，否则无法演示）：**
- [ ] 用户可登录系统
- [ ] 首页可正常展示
- [ ] 健康记录可查看和新增
- [ ] 预约可创建和查看
- [ ] 用药管理可查看和添加
- [ ] 医院列表可浏览
- [ ] 科普文章可阅读
- [ ] 老年模式可切换且生效
- [ ] 所有页面无崩溃/无白屏

**P1功能（强烈推荐，影响评分）：**
- [ ] 健康数据可视化图表
- [ ] AI风险评估报告
- [ ] 语音助手基础对话
- [ ] 下拉刷新和Toast提示
- [ ] 跨院数据协同流程
- [ ] AR导航演示
- [ ] 3D康复演示

**P2功能（加分项，锦上添花）：**
- [ ] 小艺语音智能体对接
- [ ] 古迹AI复原功能
- [ ] 患者实时监控Dashboard
- [ ] 停车场预约功能
- [ ] 深色模式支持
- [ ] 数据导出PDF报告

### 6.3 性能验收标准

| 指标 | 验收标准 | 测试方法 |
|------|----------|----------|
| 页面加载时间 | 首屏<2秒，子页面<1秒 | DevEco Studio Profiler |
| API响应时间 | P95 < 500ms | JMeter压测 |
| 内存占用 | 稳定运行<200MB | HarmonyOS Profiler |
| 包体积 | HAP < 50MB | DevEco Studio Build Output |
| 崩溃率 | 24小时运行0崩溃 | 长时间稳定性测试 |
| 电池消耗 | 后台运行<5%/小时 | DevEco Energy Profiler |

---

## 七、附录

### 附录A：数据库表结构DDL（17张核心表）

**1. 用户信息表 user_info**
```sql
CREATE TABLE user_info (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(100) NOT NULL COMMENT '密码（BCrypt加密）',
    name VARCHAR(50) COMMENT '真实姓名',
    avatar VARCHAR(255) COMMENT '头像URL',
    age INT COMMENT '年龄',
    gender ENUM('male','female','other') DEFAULT 'other' COMMENT '性别',
    phone VARCHAR(20) COMMENT '手机号',
    role_type ENUM('user','doctor','admin') DEFAULT 'user' COMMENT '角色类型',
    is_deleted TINYINT(1) DEFAULT 0 COMMENT '逻辑删除',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';
```

**2. 健康数据表 health_data**
```sql
CREATE TABLE health_data (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    type ENUM('blood_pressure','blood_sugar','heart_rate','temperature','weight','oxygen','steps','calories') NOT NULL COMMENT '数据类型',
    value VARCHAR(50) NOT NULL COMMENT '数值',
    unit VARCHAR(20) COMMENT '单位',
    record_time DATETIME NOT NULL COMMENT '记录时间',
    notes TEXT COMMENT '备注',
    device VARCHAR(100) COMMENT '数据来源设备',
    is_deleted TINYINT(1) DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_record_time (record_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康数据表';
```

**3. 预约管理表 appointment**
```sql
CREATE TABLE appointment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    doctor_name VARCHAR(50) NOT NULL COMMENT '医生姓名',
    specialty VARCHAR(50) NOT NULL COMMENT '科室',
    hospital VARCHAR(100) NOT NULL COMMENT '医院名称',
    appointment_date DATE NOT NULL COMMENT '预约日期',
    appointment_time TIME NOT NULL COMMENT '预约时间',
    status ENUM('pending','confirmed','completed','cancelled') DEFAULT 'pending' COMMENT '状态',
    location VARCHAR(200) COMMENT '就诊地点',
    notes TEXT COMMENT '备注',
    is_deleted TINYINT(1) DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_appointment_date (appointment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约管理表';
```

**4. 用药管理表 medication**
```sql
CREATE TABLE medication (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    name VARCHAR(100) NOT NULL COMMENT '药品名称',
    dosage VARCHAR(50) COMMENT '剂量',
    frequency VARCHAR(50) COMMENT '频率',
    times JSON COMMENT '服用时间数组',
    status ENUM('taken','pending','missed') DEFAULT 'pending' COMMENT '状态',
    reminder TINYINT(1) DEFAULT 1 COMMENT '是否开启提醒',
    start_date DATE NOT NULL COMMENT '开始日期',
    end_date DATE COMMENT '结束日期',
    notes TEXT COMMENT '备注',
    is_deleted TINYINT(1) DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用药管理表';
```

**5-17. 其他12张表的DDL语句（略）**

*包括：hospital_info（医院信息）、hospital_dept（科室）、article（文章）、article_category（文章分类）、device_info（设备绑定）、privacy_log（隐私日志）、transfer_apply（转院申请）、rehab_plan（康复计划）、rehab_action（康复动作）、risk_assess（风险评估）、notification（通知）、sys_oper_log（操作日志）*

### 附录B：API接口清单（总计45+个接口）

**认证模块（2个）：**
- POST /api/auth/login - 用户登录
- POST /api/auth/register - 用户注册

**用户模块（4个）：**
- GET /api/user/info - 获取当前用户信息
- PUT /api/user/profile - 修改个人信息
- PUT /api/user/password - 修改密码
- GET /api/user/avatar - 获取头像

**健康数据模块（6个）：**
- GET /api/health/data - 获取健康数据列表
- POST /api/health/data - 新增健康记录
- PUT /api/health/data/{id} - 修改健康记录
- DELETE /api/health/data/{id} - 删除健康记录
- GET /api/health/stats - 健康统计
- GET /api/health/trend - 健康趋势

**预约管理模块（5个）：**
- GET /api/appointment/list - 预约列表
- POST /api/appointment/create - 创建预约
- GET /api/appointment/detail/{id} - 预约详情
- PUT /api/appointment/cancel/{id} - 取消预约
- PUT /api/appointment/complete/{id} - 完成预约

**用药管理模块（5个）：**
- GET /api/medication/list - 用药列表
- POST /api/medication/add - 添加药品
- PUT /api/medication/update/{id} - 更新药品
- DELETE /api/medication/delete/{id} - 删除药品
- PUT /api/medication/reminder/{id} - 切换提醒开关

**医院查询模块（4个）：**
- GET /api/hospital/list - 医院列表
- GET /api/hospital/{id} - 医院详情
- GET /api/hospital/{id}/departments - 科室列表
- GET /api/hospital/{id}/doctors - 医生列表

**科普文章模块（4个）：**
- GET /api/article/list - 文章列表
- GET /api/article/{id} - 文章详情
- GET /api/article/categories - 分类列表
- GET /api/article/recommend - 个性化推荐

**设备管理模块（4个）：**
- GET /api/device/list - 设备列表
- POST /api/device/bind - 绑定设备
- DELETE /api/device/unbind/{id} - 解绑设备
- PUT /api/device/sync/{id} - 同步设备数据

**隐私安全模块（3个）：**
- GET /api/privacy/logs - 访问日志
- PUT /api/privacy/permission/{id} - 修改权限
- GET /api/privacy/export - 导出隐私报告

**AI智能模块（4个）：**
- GET /api/risk/assess - 风险评估
- POST /api/voice/query - 语音助手查询
- GET /api/stats/overview - 首页统计
- GET /api/notification/list - 通知列表

**创新功能模块（4个+）：**
- POST /api/transfer/apply - 转院申请
- GET /api/parking/lots - 车位列表
- POST /api/parking/reserve - 预约车位
- POST /api/ancient/restore - 古迹复原
- ... （其他创新接口）

### 附录C：Mock数据扩充示例

**HealthRecords 扩充后12条数据示例：**

```typescript
{
  id: 'HR001',
  type: '血压',
  value: '138/88',
  unit: 'mmHg',
  date: '2026-04-10',
  time: '07:30',
  notes: '晨起测量，昨晚熬夜至23:30，血压略偏高',
  icon: '🩺',
  color: '#FAAD14',  // 黄色警告
  status: 'warning'
},
{
  id: 'HR002',
  type: '血糖',
  value: '6.8',
  unit: 'mmol/L',
  date: '2026-04-10',
  time: '08:00',
  notes: '空腹血糖，早餐前测量',
  icon: '💉',
  color: '#52C41A',  // 绿色正常
  status: 'normal'
}
// ... 共12条，涵盖血压×2、血糖×2、心率×2、体温×2、体重×2、睡眠×2
```

**Appointments 扩充后6条数据示例：**

```typescript
{
  id: 'APT001',
  doctor: '王建国 主任医师',
  specialty: '心血管内科',
  hospital: '北京协和医院',
  hospitalLevel: '三级甲等',
  date: '2026-04-15',
  time: '09:30',
  status: 'confirmed',
  location: '门诊楼A座3层 心内科诊室302',
  queueNumber: 'A028',
  estimatedWaitTime: '约45分钟'
}
// ... 共6条，覆盖内科/外科/骨科/儿科/妇科/眼科
```

### 附录D：每日站会模板

**会议时间：** 每天22:00（或团队约定时间）
**会议时长：** 10-15分钟
**参会人员：** A、B、C、D全员

**站会议程：**

1. **进度同步（每人2分钟）**
   - 今天完成了什么？
   - 正在做什么？
   - 进度是否按计划？

2. **阻塞问题（重点讨论）**
   - 遇到了什么困难？
   - 需要谁的帮助？
   - 是否影响整体进度？

3. **明日计划（每人1分钟）**
   - 明天计划做什么？
   - 需要什么前置条件？

4. **风险预警（D负责记录）**
   - 发现了什么潜在风险？
   - 需要提前准备什么预案？

**站会输出物：**
- D更新任务看板（Trello/飞书/Excel）
- A更新技术阻塞项清单
- 全队确认明日目标对齐

---

## 八、总结与展望

### 8.1 本规划书的核心价值

1. **基于实际进度的实事求是**：不是从零开始的理想化规划，而是基于已完成的78%前端工作量的延续性规划
2. **前后端分离的清晰边界**：明确每个人的独立交付物，避免互相等待和依赖
3. **分阶段的风险可控**：每个Day结束都有明确的里程碑检查点，问题早发现早解决
4. **Mock数据作为保底方案**：即使后端延迟，前端也能用丰富数据演示，保证大赛不翻车
5. **专项奖导向的功能设计**：围绕2026 HarmonyOS创新赛四大主题（全场景协同/AI智能化/3D空间化/安全隐私）布局功能

### 8.2 成功关键因素

- **A的技术领导力**：架构设计、API规范制定、技术难题攻关
- **B的执行力**：快速完成GlobalTheme适配、UI打磨、交互优化
- **C的后端稳定性**：数据库设计、API开发、算法实现
- **D的质量保障**：测试全面性、文档完整性、答辩准备充分度

### 8.3 预期成果

**第一周末（V0.1版本）：**
- 可运行的MVP应用，主流程走通
- 登录→首页→健康记录→预约→用药→医院→科普→设备→隐私

**第二周末（V0.5版本）：**
- 四大创新功能可演示
- 分布式协同 + AI评估 + AR导航 + 3D康复 + 古迹复原

**第三周末（最终提交版本）：**
- 功能完善、性能稳定、文档齐全
- 可冲击主赛前三及四大专项奖

---

> **文档维护说明：**
> - 本规划书由D（产品/测试专员）负责维护和更新
> - 每日站会后根据实际情况调整后续计划
> - 重大变更需经过全体成员讨论确认
> - 版本号规则：V3.0 → V3.1（小改）→ V4.0（大改）

**祝星云医疗助手团队在2026 HarmonyOS创新赛中取得优异成绩！🚀**