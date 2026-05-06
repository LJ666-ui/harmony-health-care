# 星云医疗助手 V17.0 - 8个核心页面技术设计文档

**版本**: v1.0
**创建日期**: 2026-05-06
**最后更新**: 2026-05-06
**作者**: SDD Agent
**状态**: 草稿

---

## 1. 设计概述

### 1.1 设计目标

本技术设计文档将需求规格（WHAT）转化为可实施的架构设计（HOW），为8个核心页面提供：
- 清晰的模块划分和职责定义
- 完整的组件设计和接口规范
- 数据流和状态管理方案
- 性能优化和安全设计策略
- 可测试的架构设计

### 1.2 技术选型

| 技术领域 | 选型方案 | 选型理由 |
|---------|---------|---------|
| **前端框架** | HarmonyOS NEXT + ArkTS + ArkUI | 华为原生应用开发框架，性能优异，API丰富 |
| **响应式布局** | BreakpointSystem + Grid组件 | 官方推荐的多设备适配方案，支持sm/md/lg三断点 |
| **状态管理** | @State/@Prop/@Link + AppStorage | ArkUI原生状态管理，轻量高效 |
| **网络请求** | HttpUtil封装fetch API | 统一请求拦截、错误处理、Token注入 |
| **数据持久化** | Preferences + SQLite | Preferences用于轻量配置，SQLite用于结构化数据 |
| **AI集成** | MedicalAgent + ConversationMemory | 自研医疗AI代理，支持RAG检索和多轮对话 |
| **图表可视化** | 自定义Canvas绘制 | 雷达图、仪表盘等医学图表组件 |
| **影像处理** | ImagePicker + Canvas + FormData | 支持拍照/相册选择，Canvas标注，FormData上传 |
| **分布式协同** | DistributedDeviceKit + DataTransferService | HarmonyOS分布式能力，设备发现和数据传输 |

### 1.3 设计约束

**技术约束**：
- ArkTS不支持运行时反射，需使用静态类型
- HarmonyOS NEXT API 5.0+，部分API需权限申请
- LazyForEach需实现IDataSource接口
- Canvas绘制需在组件onReady后执行

**性能约束**：
- 首页加载时间 < 2秒
- AI响应时间 < 5秒
- 影像上传 < 15秒（10MB文件）
- 列表滚动帧率 ≥ 60fps

**安全约束**：
- JWT Token存储使用AppStorage，不暴露给非授权组件
- 敏感数据传输使用HTTPS
- 分布式数据传输前必须脱敏

---

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    星云医疗助手 V17.0 架构                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    页面层 (Pages)                           │  │
│  │  HomePage │ Login │ Register │ AiChatPage │ ImageAnalysis  │  │
│  │  RiskAssessment │ AncientMedicalImg │ DistributedCollab    │  │
│  └───────────────────────┬───────────────────────────────────┘  │
│                           │                                       │
│  ┌────────────────────────▼───────────────────────────────────┐  │
│  │                    组件层 (Components)                      │  │
│  │  FormInput │ ChatBubble │ ImagePreview │ StepperWizard     │  │
│  │  RadarChart │ GaugeChart │ AnnotationTool │ DeviceList     │  │
│  └───────────────────────┬───────────────────────────────────┘  │
│                           │                                       │
│  ┌────────────────────────▼───────────────────────────────────┐  │
│  │                    服务层 (Services)                        │  │
│  │  AuthService │ AiChatService │ ImageAnalysisService         │  │
│  │  RiskAssessService │ DistributedService                     │  │
│  └───────────────────────┬───────────────────────────────────┘  │
│                           │                                       │
│  ┌────────────────────────▼───────────────────────────────────┐  │
│  │                    Agent层 (AI Agents)                      │  │
│  │  MedicalAgent │ ConversationMemory │ RAGRetriever           │  │
│  └───────────────────────┬───────────────────────────────────┘  │
│                           │                                       │
│  ┌────────────────────────▼───────────────────────────────────┐  │
│  │                    工具层 (Utils)                            │  │
│  │  HttpUtil │ ValidatorUtil │ StorageUtil │ Desensitization   │  │
│  └───────────────────────┬───────────────────────────────────┘  │
│                           │                                       │
│  ┌────────────────────────▼───────────────────────────────────┐  │
│  │                    数据层 (Models)                           │  │
│  │  UserInfo │ ChatMessage │ ImageAnalysisResult │ RiskResult  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

| 模块名称 | 职责说明 | 包含文件 |
|---------|---------|---------|
| **pages/** | 页面入口，负责UI渲染和用户交互 | 8个核心页面.ets文件 |
| **components/** | 可复用UI组件，无业务逻辑 | FormInput, ChatBubble, ImagePreview等 |
| **services/** | 业务服务，封装API调用和数据处理 | AuthService, AiChatService等 |
| **agents/** | AI代理，提供智能问答能力 | MedicalAgent, ConversationMemory |
| **utils/** | 工具函数，提供通用能力 | HttpUtil, ValidatorUtil等 |
| **models/** | 数据模型，定义数据结构 | 各业务实体接口定义 |

### 2.3 依赖关系

```
pages → components → services → agents → utils → models
  │                       │
  └─────── AppStorage ─────┘
```

**依赖规则**：
- 页面依赖组件和服务，不直接依赖utils
- 组件只依赖models，不依赖services
- services依赖agents和utils
- 禁止循环依赖

---

## 3. 模块详细设计

### 3.1 HomePage.ets - 首页响应式布局

#### 3.1.1 职责定义
负责根据设备类型自适应显示首页布局，提供13个功能入口卡片，展示用户健康摘要信息。

#### 3.1.2 组件结构

```typescript
// HomePage.ets 组件结构
@Entry
@Component
struct HomePage {
  @State currentBreakpoint: string = 'md';  // 当前断点 sm/md/lg
  @State userInfo: UserInfo | null = null;   // 用户信息
  @State healthSummary: HealthSummary | null = null;  // 健康摘要
  
  private breakpointSystem: BreakpointSystem;  // 断点系统
  
  aboutToAppear() {
    // 初始化断点系统
    this.breakpointSystem = new BreakpointSystem();
    this.breakpointSystem.onBreakpointChange = (bp) => {
      this.currentBreakpoint = bp;
    };
    
    // 加载用户信息
    this.userInfo = AppStorage.get('userInfo');
    if (this.userInfo) {
      this.loadHealthSummary();
    }
  }
  
  build() {
    Column() {
      // 顶部用户信息区
      this.HeaderSection();
      
      // 功能卡片网格区
      this.FunctionGridSection();
      
      // 健康摘要区
      if (this.healthSummary) {
        this.HealthSummarySection();
      }
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder HeaderSection() {
    Row() {
      if (this.userInfo) {
        Image(this.userInfo.avatar).width(48).height(48).borderRadius(24);
        Text(this.userInfo.nickname).fontSize(18).fontWeight(FontWeight.Bold);
      } else {
        Button('登录/注册').onClick(() => {
          router.pushUrl({ url: 'pages/Login' });
        });
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 });
  }
  
  @Builder FunctionGridSection() {
    Grid() {
      ForEach(this.getFunctionCards(), (card: FunctionCard) => {
        GridItem() {
          FunctionCardComponent({ card: card });
        }
      });
    }
    .columnsTemplate(this.getGridColumns())  // 根据断点动态设置列数
    .rowsGap(12)
    .columnsGap(12)
    .padding(16);
  }
  
  // 根据断点返回Grid列模板
  private getGridColumns(): string {
    switch (this.currentBreakpoint) {
      case 'sm': return '1fr 1fr';           // 2列
      case 'md': return '1fr 1fr 1fr';       // 3列
      case 'lg': return '1fr 1fr 1fr 1fr';   // 4列
      default: return '1fr 1fr 1fr';
    }
  }
  
  // 获取13个功能卡片数据
  private getFunctionCards(): FunctionCard[] {
    return [
      { id: 1, title: '健康档案', icon: $r('app.media.ic_health'), route: 'pages/HealthRecords' },
      { id: 2, title: '医疗服务', icon: $r('app.media.ic_medical'), route: 'pages/MedicalPage' },
      { id: 3, title: '药品服务', icon: $r('app.media.ic_medicine'), route: 'pages/MedicationPage' },
      { id: 4, title: 'AI问诊', icon: $r('app.media.ic_ai'), route: 'pages/AiChatPage' },
      { id: 5, title: '风险评估', icon: $r('app.media.ic_risk'), route: 'pages/RiskAssessmentPage' },
      { id: 6, title: '影像分析', icon: $r('app.media.ic_image'), route: 'pages/ImageAnalysisPage' },
      { id: 7, title: '康复训练', icon: $r('app.media.ic_rehab'), route: 'pages/RehabPage' },
      { id: 8, title: '智慧病房', icon: $r('app.media.ic_ward'), route: 'pages/MonitoringDashboard' },
      { id: 9, title: 'AR导航', icon: $r('app.media.ic_ar'), route: 'pages/ARNavigationPage' },
      { id: 10, title: '数字孪生', icon: $r('app.media.ic_twin'), route: 'pages/DigitalTwinPage' },
      { id: 11, title: '停车导航', icon: $r('app.media.ic_parking'), route: 'pages/ParkingListPage' },
      { id: 12, title: '分布式协同', icon: $r('app.media.ic_distributed'), route: 'pages/DistributedCollaborationPage' },
      { id: 13, title: '设置', icon: $r('app.media.ic_settings'), route: 'pages/Profile' }
    ];
  }
}
```

#### 3.1.3 关键技术点

**BreakpointSystem断点系统**：
```typescript
class BreakpointSystem {
  private currentBreakpoint: string = 'md';
  onBreakpointChange: (breakpoint: string) => void = () => {};
  
  constructor() {
    // 监听窗口尺寸变化
    window.getLastWindow(getContext()).then((win) => {
      win.on('windowSizeChange', (size) => {
        const breakpoint = this.calculateBreakpoint(size.width);
        if (breakpoint !== this.currentBreakpoint) {
          this.currentBreakpoint = breakpoint;
          this.onBreakpointChange(breakpoint);
        }
      });
    });
  }
  
  private calculateBreakpoint(width: number): string {
    if (width < 600) return 'sm';
    if (width < 840) return 'md';
    return 'lg';
  }
}
```

#### 3.1.4 数据流

```
用户打开应用
    ↓
HomePage.aboutToAppear()
    ↓
初始化BreakpointSystem → 监听窗口尺寸变化
    ↓
获取AppStorage中的userInfo
    ↓
如果已登录 → 调用HealthService.getSummary() → 更新healthSummary
    ↓
根据currentBreakpoint渲染Grid布局
```

---

### 3.2 Login.ets - 登录页面

#### 3.2.1 职责定义
提供用户登录表单，实现手机号密码验证、JWT认证、Token存储和登录状态管理。

#### 3.2.2 组件结构

```typescript
@Entry
@Component
struct Login {
  @State phone: string = '';
  @State password: string = '';
  @State phoneError: string = '';
  @State passwordError: string = '';
  @State isLoading: boolean = false;
  @State showPassword: boolean = false;
  
  private phoneRegex: RegExp = /^1[3-9]\d{9}$/;
  
  build() {
    Column() {
      // Logo和标题
      this.LogoSection();
      
      // 表单区域
      this.FormSection();
      
      // 登录按钮
      this.LoginButton();
      
      // 辅助链接
      this.HelperLinks();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  @Builder FormSection() {
    Column() {
      // 手机号输入框
      TextInput({ placeholder: '请输入手机号', text: this.phone })
        .type(InputType.Number)
        .maxLength(11)
        .onChange((value) => {
          this.phone = value;
          this.validatePhone();
        })
        .borderColor(this.phoneError ? '#F5222D' : '#E0E0E0');
      
      if (this.phoneError) {
        Text(this.phoneError).fontSize(12).fontColor('#F5222D');
      }
      
      // 密码输入框
      Row() {
        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(this.showPassword ? InputType.Normal : InputType.Password)
          .maxLength(20)
          .onChange((value) => {
            this.password = value;
            this.validatePassword();
          });
        
        Toggle({ type: ToggleType.Checkbox, isOn: this.showPassword })
          .onChange((isOn) => {
            this.showPassword = isOn;
          });
      }
    }
    .padding(16);
  }
  
  @Builder LoginButton() {
    Button(this.isLoading ? '登录中...' : '登录')
      .width('100%')
      .height(48)
      .enabled(!this.isLoading && this.isFormValid())
      .backgroundColor(this.isFormValid() ? '#4A90E2' : '#CCCCCC')
      .onClick(() => {
        this.handleLogin();
      });
  }
  
  // 验证手机号
  private validatePhone(): void {
    if (!this.phone) {
      this.phoneError = '';
    } else if (!this.phoneRegex.test(this.phone)) {
      this.phoneError = '请输入正确的手机号';
    } else {
      this.phoneError = '';
    }
  }
  
  // 验证密码
  private validatePassword(): void {
    if (!this.password) {
      this.passwordError = '';
    } else if (this.password.length < 6 || this.password.length > 20) {
      this.passwordError = '密码长度为6-20位';
    } else {
      this.passwordError = '';
    }
  }
  
  // 表单是否有效
  private isFormValid(): boolean {
    return this.phoneRegex.test(this.phone) &&
           this.password.length >= 6 &&
           this.password.length <= 20;
  }
  
  // 处理登录
  private async handleLogin(): Promise<void> {
    this.isLoading = true;
    
    try {
      const response = await AuthService.login({
        phone: this.phone,
        password: this.password
      });
      
      if (response.code === 200) {
        // 存储Token和用户信息
        AppStorage.setOrCreate('userToken', response.data.token);
        AppStorage.setOrCreate('userInfo', response.data.userInfo);
        
        // 跳转首页
        router.replaceUrl({ url: 'pages/HomePage' });
      } else {
        promptAction.showToast({ message: response.message || '登录失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络错误，请重试' });
    } finally {
      this.isLoading = false;
    }
  }
}
```

#### 3.2.3 AuthService服务设计

```typescript
// services/AuthService.ets
export class AuthService {
  private static readonly BASE_URL = '/api/user';
  
  /**
   * 用户登录
   * @param request 登录请求参数
   * @returns 登录响应
   */
  static async login(request: UserLoginRequest): Promise<ApiResponse<LoginResponse>> {
    return await HttpUtil.post(`${this.BASE_URL}/login`, request);
  }
  
  /**
   * 用户注册
   * @param request 注册请求参数
   * @returns 注册响应
   */
  static async register(request: UserRegisterRequest): Promise<ApiResponse<{ userId: number }>> {
    return await HttpUtil.post(`${this.BASE_URL}/register`, request);
  }
  
  /**
   * 发送验证码
   * @param phone 手机号
   * @returns 发送结果
   */
  static async sendVerificationCode(phone: string): Promise<ApiResponse<void>> {
    return await HttpUtil.post(`${this.BASE_URL}/send-code`, { phone });
  }
  
  /**
   * 检查Token是否有效
   * @returns 是否有效
   */
  static isTokenValid(): boolean {
    const token = AppStorage.get<string>('userToken');
    if (!token) return false;
    
    // 解析JWT检查过期时间（简化版，实际应解析JWT payload）
    return true;
  }
  
  /**
   * 登出
   */
  static logout(): void {
    AppStorage.delete('userToken');
    AppStorage.delete('userInfo');
    router.replaceUrl({ url: 'pages/Login' });
  }
}
```

#### 3.2.4 数据流

```
用户输入手机号/密码
    ↓
onChange触发 → 实时验证 → 更新错误提示状态
    ↓
用户点击登录按钮
    ↓
验证表单有效性 → 设置isLoading=true
    ↓
调用AuthService.login()
    ↓
HttpUtil.post() → 携带请求体发送到后端
    ↓
后端返回响应
    ↓
成功：存储Token到AppStorage → 跳转HomePage
失败：显示错误Toast
    ↓
设置isLoading=false
```

---

### 3.3 Register.ets - 注册页面

#### 3.3.1 职责定义
提供用户注册表单，实现验证码流程、密码强度检测、用户协议确认和注册成功自动登录。

#### 3.3.2 组件结构

```typescript
@Entry
@Component
struct Register {
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State verificationCode: string = '';
  @State agreedToTerms: boolean = false;
  
  @State countdown: number = 0;  // 验证码倒计时
  @State passwordStrength: 'weak' | 'medium' | 'strong' = 'weak';
  @State isLoading: boolean = false;
  
  private countdownTimer: number = -1;
  
  aboutToDisappear() {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
    }
  }
  
  build() {
    Column() {
      // Logo和标题
      this.LogoSection();
      
      // 表单区域
      this.FormSection();
      
      // 用户协议
      this.TermsSection();
      
      // 注册按钮
      this.RegisterButton();
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder FormSection() {
    Column() {
      // 手机号
      TextInput({ placeholder: '手机号', text: this.phone })
        .type(InputType.Number)
        .maxLength(11);
      
      // 验证码
      Row() {
        TextInput({ placeholder: '验证码', text: this.verificationCode })
          .type(InputType.Number)
          .maxLength(6)
          .layoutWeight(1);
        
        Button(this.countdown > 0 ? `${this.countdown}秒` : '获取验证码')
          .enabled(this.countdown === 0 && /^1[3-9]\d{9}$/.test(this.phone))
          .onClick(() => {
            this.sendVerificationCode();
          });
      }
      
      // 密码
      TextInput({ placeholder: '密码', text: this.password })
        .type(InputType.Password)
        .maxLength(20)
        .onChange((value) => {
          this.password = value;
          this.calculatePasswordStrength();
        });
      
      // 密码强度指示器
      this.PasswordStrengthIndicator();
      
      // 确认密码
      TextInput({ placeholder: '确认密码', text: this.confirmPassword })
        .type(InputType.Password)
        .maxLength(20);
    }
    .padding(16);
  }
  
  @Builder PasswordStrengthIndicator() {
    Row() {
      Text('密码强度：')
        .fontSize(12);
      
      Text(this.passwordStrength === 'weak' ? '弱' : 
           this.passwordStrength === 'medium' ? '中' : '强')
        .fontSize(12)
        .fontColor(this.passwordStrength === 'weak' ? '#F5222D' :
                   this.passwordStrength === 'medium' ? '#FAAD14' : '#52C41A');
    }
    .width('100%')
    .margin({ top: 4, bottom: 8 });
  }
  
  @Builder TermsSection() {
    Row() {
      Toggle({ type: ToggleType.Checkbox, isOn: this.agreedToTerms })
        .onChange((isOn) => {
          this.agreedToTerms = isOn;
        });
      
      Text() {
        Span('我已阅读并同意');
        Span('《用户协议》')
          .fontColor('#4A90E2')
          .decoration({ type: TextDecorationType.Underline });
      }
      .fontSize(12);
    }
    .width('100%')
    .padding(16);
  }
  
  // 计算密码强度
  private calculatePasswordStrength(): void {
    const pwd = this.password;
    
    if (pwd.length < 8 || /^\d+$/.test(pwd)) {
      this.passwordStrength = 'weak';
    } else if (pwd.length >= 8 && pwd.length <= 12 && /[a-zA-Z]/.test(pwd) && /\d/.test(pwd)) {
      this.passwordStrength = 'medium';
    } else if (pwd.length > 12 && /[!@#$%^&*]/.test(pwd)) {
      this.passwordStrength = 'strong';
    } else {
      this.passwordStrength = 'medium';
    }
  }
  
  // 发送验证码
  private async sendVerificationCode(): Promise<void> {
    try {
      const response = await AuthService.sendVerificationCode(this.phone);
      
      if (response.code === 200) {
        promptAction.showToast({ message: '验证码已发送' });
        this.startCountdown();
      } else {
        promptAction.showToast({ message: response.message || '发送失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络错误' });
    }
  }
  
  // 开始倒计时
  private startCountdown(): void {
    this.countdown = 60;
    this.countdownTimer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.countdownTimer);
        this.countdownTimer = -1;
      }
    }, 1000);
  }
  
  // 处理注册
  private async handleRegister(): Promise<void> {
    // 验证
    if (!this.agreedToTerms) {
      promptAction.showToast({ message: '请先同意用户协议' });
      return;
    }
    
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次密码输入不一致' });
      return;
    }
    
    this.isLoading = true;
    
    try {
      const response = await AuthService.register({
        phone: this.phone,
        password: this.password,
        verificationCode: this.verificationCode,
        agreedToTerms: this.agreedToTerms
      });
      
      if (response.code === 200) {
        promptAction.showToast({ message: '注册成功' });
        
        // 自动登录
        const loginResponse = await AuthService.login({
          phone: this.phone,
          password: this.password
        });
        
        if (loginResponse.code === 200) {
          AppStorage.setOrCreate('userToken', loginResponse.data.token);
          AppStorage.setOrCreate('userInfo', loginResponse.data.userInfo);
          router.replaceUrl({ url: 'pages/HomePage' });
        }
      } else {
        promptAction.showToast({ message: response.message || '注册失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络错误' });
    } finally {
      this.isLoading = false;
    }
  }
}
```

---

### 3.4 AiChatPage.ets - AI聊天界面

#### 3.4.1 职责定义
提供AI医疗助手对话界面，集成MedicalAgent，支持Markdown渲染、打字动画和多轮对话上下文管理。

#### 3.4.2 组件结构

```typescript
@Entry
@Component
struct AiChatPage {
  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State isTyping: boolean = false;
  @State displayedText: string = '';  // 打字动画当前显示文本
  
  private conversationMemory: ConversationMemory;
  private medicalAgent: MedicalAgent;
  private scrollView: Scroller = new Scroller();
  private typingTimer: number = -1;
  
  aboutToAppear() {
    this.conversationMemory = new ConversationMemory();
    this.medicalAgent = new MedicalAgent();
    
    // 加载历史对话
    this.loadHistory();
  }
  
  aboutToDisappear() {
    if (this.typingTimer !== -1) {
      clearInterval(this.typingTimer);
    }
  }
  
  build() {
    Column() {
      // 标题栏
      this.TitleBar();
      
      // 消息列表
      this.MessageList();
      
      // 输入区域
      this.InputArea();
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder MessageList() {
    List({ space: 12, scroller: this.scrollView }) {
      LazyForEach(new MessageDataSource(this.messages), (msg: ChatMessage) => {
        ListItem() {
          ChatBubble({ message: msg, displayedText: msg.id === this.messages[this.messages.length - 1]?.id ? this.displayedText : '' });
        }
      });
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 12, bottom: 12 });
  }
  
  @Builder InputArea() {
    Row() {
      TextInput({ placeholder: '输入健康问题...', text: this.inputText })
        .layoutWeight(1)
        .onChange((value) => {
          this.inputText = value;
        })
        .onSubmit(() => {
          this.sendMessage();
        });
      
      Button('发送')
        .enabled(this.inputText.trim().length > 0 && !this.isTyping)
        .onClick(() => {
          this.sendMessage();
        });
    }
    .width('100%')
    .padding(16);
  }
  
  // 发送消息
  private async sendMessage(): Promise<void> {
    const userMessage: ChatMessage = {
      id: Date.now().toString(),
      role: 'user',
      content: this.inputText,
      timestamp: Date.now()
    };
    
    this.messages.push(userMessage);
    this.inputText = '';
    this.isTyping = true;
    
    // 滚动到底部
    this.scrollView.scrollEdge(Edge.Bottom);
    
    try {
      // 调用MedicalAgent
      const response = await this.medicalAgent.chat(
        userMessage.content,
        this.conversationMemory
      );
      
      // 添加AI消息
      const aiMessage: ChatMessage = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: response.reply,
        timestamp: Date.now(),
        markdown: response.markdown
      };
      
      this.messages.push(aiMessage);
      
      // 更新对话记忆
      this.conversationMemory.addMessage(userMessage);
      this.conversationMemory.addMessage(aiMessage);
      
      // 打字动画
      this.startTypingAnimation(aiMessage.content);
      
    } catch (error) {
      promptAction.showToast({ message: 'AI服务暂时不可用' });
    } finally {
      this.isTyping = false;
    }
  }
  
  // 打字动画
  private startTypingAnimation(text: string): void {
    this.displayedText = '';
    let index = 0;
    
    this.typingTimer = setInterval(() => {
      if (index < text.length) {
        this.displayedText += text[index];
        index++;
      } else {
        clearInterval(this.typingTimer);
        this.typingTimer = -1;
      }
    }, 30);  // 30ms每字
  }
  
  // 加载历史对话
  private async loadHistory(): Promise<void> {
    const history = await PreferencesUtil.get<ChatMessage[]>('chat_history');
    if (history) {
      this.messages = history;
    }
  }
}
```

#### 3.4.3 MedicalAgent设计

```typescript
// agents/MedicalAgent.ets
export class MedicalAgent {
  private ragRetriever: RAGRetriever;
  
  constructor() {
    this.ragRetriever = new RAGRetriever();
  }
  
  /**
   * 与AI进行医疗对话
   * @param question 用户问题
   * @param memory 对话记忆
   * @returns AI回复
   */
  async chat(question: string, memory: ConversationMemory): Promise<{ reply: string; markdown: boolean }> {
    // 1. RAG检索相关医学知识
    const relevantKnowledge = await this.ragRetriever.retrieve(question);
    
    // 2. 构建上下文
    const context = memory.getContext(10);  // 最近10轮对话
    const systemPrompt = this.buildSystemPrompt(relevantKnowledge);
    
    // 3. 调用后端AI服务
    const response = await AiChatService.chat({
      message: question,
      sessionId: memory.getSessionId(),
      context: context,
      systemPrompt: systemPrompt
    });
    
    return {
      reply: response.data.reply,
      markdown: response.data.markdown
    };
  }
  
  private buildSystemPrompt(knowledge: string[]): string {
    return `你是一位专业的医疗AI助手，具备以下能力：
1. 提供常见疾病的症状、病因、治疗方法信息
2. 给出健康生活建议和预防措施
3. 解读医学检查报告和影像结果
4. 推荐就医科室和医生类型

参考知识库：
${knowledge.join('\n')}

请注意：
- 你的建议仅供参考，不能替代专业医生的诊断
- 对于严重症状，建议用户及时就医
- 回复使用Markdown格式，结构清晰`;
  }
}
```

#### 3.4.4 ConversationMemory设计

```typescript
// agents/ConversationMemory.ets
export class ConversationMemory {
  private messages: ChatMessage[] = [];
  private sessionId: string = '';
  private maxContextLength: number = 10;
  
  constructor() {
    this.sessionId = Date.now().toString();
  }
  
  /**
   * 添加消息到记忆
   */
  addMessage(message: ChatMessage): void {
    this.messages.push(message);
    
    // 限制上下文长度
    if (this.messages.length > this.maxContextLength * 2) {
      this.messages = this.messages.slice(-this.maxContextLength * 2);
    }
  }
  
  /**
   * 获取上下文
   * @param rounds 轮数
   */
  getContext(rounds: number): ChatMessage[] {
    return this.messages.slice(-rounds * 2);
  }
  
  /**
   * 获取会话ID
   */
  getSessionId(): string {
    return this.sessionId;
  }
  
  /**
   * 清空记忆
   */
  clear(): void {
    this.messages = [];
    this.sessionId = Date.now().toString();
  }
}
```

---

### 3.5 ImageAnalysisPage.ets - 影像分析上传

#### 3.5.1 职责定义
提供医学影像上传功能，调用AI分析服务，显示异常区域标注和诊断报告。

#### 3.5.2 组件结构

```typescript
@Entry
@Component
struct ImageAnalysisPage {
  @State imageUri: string = '';
  @State imageType: 'CT' | 'MRI' | 'XRay' | 'Ultrasound' = 'CT';
  @State isAnalyzing: boolean = false;
  @State analysisResult: ImageAnalysisResult | null = null;
  @State showAnnotation: boolean = true;
  
  private canvasContext: CanvasRenderingContext2D;
  
  build() {
    Column() {
      // 标题栏
      this.TitleBar();
      
      // 影像预览区
      this.ImagePreviewSection();
      
      // 分析结果区
      if (this.analysisResult) {
        this.ResultSection();
      }
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder ImagePreviewSection() {
    Stack() {
      // 影像图片
      if (this.imageUri) {
        Image(this.imageUri)
          .width('100%')
          .height(300)
          .objectFit(ImageFit.Contain);
      } else {
        // 上传提示
        Column() {
          Text('点击上传医学影像').fontSize(16).fontColor('#999');
          Text('支持CT、MRI、X光、超声').fontSize(12).fontColor('#CCC');
        }
        .width('100%')
        .height(300)
        .backgroundColor('#F0F0F0')
        .onClick(() => {
          this.showUploadOptions();
        });
      }
      
      // 异常区域标注层
      if (this.showAnnotation && this.analysisResult) {
        Canvas(this.canvasContext)
          .width('100%')
          .height(300)
          .onReady(() => {
            this.drawAnnotations();
          });
      }
    }
    .width('100%');
  }
  
  @Builder ResultSection() {
    Column() {
      // 诊断报告
      Text('诊断报告').fontSize(18).fontWeight(FontWeight.Bold);
      
      // 异常发现
      ForEach(this.analysisResult.abnormalities, (abnormality: AbnormalRegion) => {
        Row() {
          Text(`• ${abnormality.type}: ${abnormality.description}`)
            .fontSize(14);
        }
        .width('100%')
        .margin({ top: 8 });
      });
      
      // 可能诊断
      Text('可能诊断：').fontSize(14).fontWeight(FontWeight.Medium);
      ForEach(this.analysisResult.diagnosis.possibleDiagnoses, (diagnosis: string) => {
        Text(`  - ${diagnosis}`).fontSize(13);
      });
      
      // 建议
      Text('建议措施：').fontSize(14).fontWeight(FontWeight.Medium);
      ForEach(this.analysisResult.diagnosis.recommendations, (rec: string) => {
        Text(`  - ${rec}`).fontSize(13);
      });
      
      // 置信度
      Text(`置信度: ${(this.analysisResult.confidence * 100).toFixed(1)}%`)
        .fontSize(12)
        .fontColor('#999');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFF');
  }
  
  // 显示上传选项
  private showUploadOptions(): void {
    AlertDialog.show({
      title: '选择上传方式',
      buttons: [
        { text: '拍照', action: () => this.takePhoto() },
        { text: '从相册选择', action: () => this.pickFromGallery() }
      ]
    });
  }
  
  // 拍照
  private async takePhoto(): Promise<void> {
    const picker = new cameraPicker();
    const result = await picker.capture();
    if (result) {
      this.imageUri = result.uri;
    }
  }
  
  // 从相册选择
  private async pickFromGallery(): Promise<void> {
    const picker = new photoPicker();
    const result = await picker.select({ maxSelectNumber: 1 });
    if (result && result.length > 0) {
      this.imageUri = result[0].uri;
    }
  }
  
  // 开始分析
  private async startAnalysis(): Promise<void> {
    this.isAnalyzing = true;
    
    try {
      const result = await ImageAnalysisService.analyze({
        imageUri: this.imageUri,
        imageType: this.imageType
      });
      
      this.analysisResult = result.data;
    } catch (error) {
      promptAction.showToast({ message: '分析失败，请重试' });
    } finally {
      this.isAnalyzing = false;
    }
  }
  
  // 绘制标注
  private drawAnnotations(): void {
    if (!this.analysisResult) return;
    
    const ctx = this.canvasContext;
    ctx.strokeStyle = '#FF0000';
    ctx.lineWidth = 2;
    
    for (const abnormality of this.analysisResult.abnormalities) {
      const [x, y, width, height] = abnormality.bbox;
      ctx.strokeRect(x, y, width, height);
      
      // 标注类型
      ctx.fillStyle = '#FF0000';
      ctx.font = '12px sans-serif';
      ctx.fillText(abnormality.type, x, y - 5);
    }
  }
}
```

---

### 3.6 RiskAssessmentPage.ets - 风险评估问卷

#### 3.6.1 职责定义
提供4种健康风险评估类型，实现动态问卷引擎，展示可视化风险报告。

#### 3.6.2 组件结构

```typescript
@Entry
@Component
struct RiskAssessmentPage {
  @State selectedType: AssessmentType | null = null;
  @State currentStep: number = 0;
  @State answers: Map<string, string | number | boolean> = new Map();
  @State isSubmitting: boolean = false;
  @State assessmentResult: RiskAssessmentResult | null = null;
  
  private questionnaire: Questionnaire | null = null;
  
  build() {
    Column() {
      if (!this.selectedType) {
        // 评估类型选择
        this.TypeSelectionSection();
      } else if (!this.assessmentResult) {
        // 问卷区域
        this.QuestionnaireSection();
      } else {
        // 结果展示
        this.ResultSection();
      }
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder TypeSelectionSection() {
    Column() {
      Text('选择评估类型').fontSize(20).fontWeight(FontWeight.Bold);
      
      Grid() {
        ForEach(this.getAssessmentTypes(), (type: AssessmentType) => {
          GridItem() {
            Column() {
              Image(type.icon).width(48).height(48);
              Text(type.name).fontSize(14);
              Text(type.description).fontSize(12).fontColor('#999');
            }
            .padding(16)
            .backgroundColor('#FFF')
            .borderRadius(8)
            .onClick(() => {
              this.selectType(type);
            });
          }
        });
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(16)
      .columnsGap(16);
    }
    .padding(16);
  }
  
  @Builder QuestionnaireSection() {
    Column() {
      // Stepper步骤器
      Stepper() {
        ForEach(this.questionnaire?.steps || [], (step: QuestionStep, index: number) => {
          StepperItem() {
            Column() {
              Text(step.title).fontSize(16).fontWeight(FontWeight.Medium);
              
              ForEach(step.questions, (question: Question) => {
                this.QuestionItem(question);
              });
            }
            .padding(16);
          }
          .prevLabel(index === 0 ? '' : '上一步')
          .nextLabel(index === (this.questionnaire?.steps.length || 0) - 1 ? '提交' : '下一步');
        });
      }
      .onFinish(() => {
        this.submitAssessment();
      });
    }
  }
  
  @Builder QuestionItem(question: Question) {
    Column() {
      Text(question.text).fontSize(14);
      
      if (question.type === 'single-choice') {
        // 单选题
        ForEach(question.options || [], (option: string) => {
          Radio({ value: option, group: question.id })
            .text(option)
            .onChange((isChecked) => {
              if (isChecked) {
                this.answers.set(question.id, option);
              }
            });
        });
      } else if (question.type === 'number') {
        // 数值题
        TextInput({ text: this.answers.get(question.id)?.toString() || '' })
          .type(InputType.Number)
          .onChange((value) => {
            this.answers.set(question.id, Number(value));
          });
      } else if (question.type === 'boolean') {
        // 是非题
        Row() {
          Button('是').onClick(() => this.answers.set(question.id, true));
          Button('否').onClick(() => this.answers.set(question.id, false));
        }
      }
    }
    .width('100%')
    .margin({ top: 16 });
  }
  
  @Builder ResultSection() {
    Column() {
      Text('风险评估报告').fontSize(20).fontWeight(FontWeight.Bold);
      
      // 风险等级
      Text(`风险等级: ${this.getRiskLevelText()}`)
        .fontSize(18)
        .fontColor(this.getRiskLevelColor());
      
      // 雷达图
      RadarChart({ data: this.getRadarData() })
        .width(300)
        .height(300);
      
      // 仪表盘
      GaugeChart({ value: this.assessmentResult?.overallScore || 0 })
        .width(200)
        .height(200);
      
      // 建议
      Text('改善建议：').fontSize(16).fontWeight(FontWeight.Medium);
      ForEach(this.assessmentResult?.recommendations || [], (rec: string) => {
        Text(`• ${rec}`).fontSize(14);
      });
    }
    .padding(16);
  }
  
  // 选择评估类型
  private async selectType(type: AssessmentType): Promise<void> {
    this.selectedType = type;
    
    // 加载问卷
    this.questionnaire = await RiskAssessService.getQuestionnaire(type.id);
  }
  
  // 提交评估
  private async submitAssessment(): Promise<void> {
    this.isSubmitting = true;
    
    try {
      const result = await RiskAssessService.submit({
        assessmentType: this.selectedType!.id,
        answers: Array.from(this.answers.entries()).map(([questionId, answer]) => ({
          questionId,
          answer
        })),
        userId: AppStorage.get<UserInfo>('userInfo')?.userId || 0
      });
      
      this.assessmentResult = result.data;
    } catch (error) {
      promptAction.showToast({ message: '提交失败' });
    } finally {
      this.isSubmitting = false;
    }
  }
  
  // 获取评估类型列表
  private getAssessmentTypes(): AssessmentType[] {
    return [
      { id: 'cardiovascular', name: '心血管风险评估', icon: $r('app.media.ic_heart'), description: '评估心血管疾病风险' },
      { id: 'diabetes', name: '糖尿病风险评估', icon: $r('app.media.ic_diabetes'), description: '评估糖尿病发病风险' },
      { id: 'cancer', name: '癌症风险评估', icon: $r('app.media.ic_cancer'), description: '评估常见癌症风险' },
      { id: 'comprehensive', name: '综合健康评估', icon: $r('app.media.ic_health'), description: '全面健康状态评估' }
    ];
  }
}
```

---

### 3.7 AncientMedicalImgPage.ets - 古医影像处理

#### 3.7.1 职责定义
提供古籍医学影像上传、预处理、修复、OCR识别和标注功能。

#### 3.7.2 处理流水线设计

```typescript
// services/AncientImageService.ets
export class AncientImageService {
  /**
   * 执行完整的影像处理流水线
   */
  static async processPipeline(imageUri: string): Promise<AncientImageProcessResult> {
    // 1. 预处理
    const preprocessed = await this.preprocess(imageUri);
    
    // 2. 色彩恢复
    const colorRestored = await this.restoreColor(preprocessed);
    
    // 3. 超分辨率增强
    const enhanced = await this.superResolution(colorRestored);
    
    // 4. OCR识别
    const ocrResult = await this.ocrRecognize(enhanced);
    
    return {
      originalImage: imageUri,
      processedImage: enhanced,
      ocrText: ocrResult.text,
      confidence: ocrResult.confidence
    };
  }
  
  /**
   * 预处理：去噪、增强、二值化
   */
  private static async preprocess(imageUri: string): Promise<string> {
    // 调用ImagePreprocessor
    return await ImagePreprocessor.process(imageUri, {
      denoise: true,
      enhance: true,
      binarize: false
    });
  }
  
  /**
   * 色彩恢复
   */
  private static async restoreColor(imageUri: string): Promise<string> {
    // 调用ColorRestorer
    return await ColorRestorer.restore(imageUri);
  }
  
  /**
   * SRGAN超分辨率
   */
  private static async superResolution(imageUri: string): Promise<string> {
    // 调用SRGAN模型
    return await SRGANEnhancer.enhance(imageUri, { scale: 2 });
  }
  
  /**
   * OCR识别
   */
  private static async ocrRecognize(imageUri: string): Promise<{ text: string; confidence: number }> {
    // 调用NLP OCR引擎
    return await OCREngine.recognize(imageUri, { language: 'zh-Hant' });
  }
}
```

---

### 3.8 DistributedCollaborationPage.ets - 分布式协同

#### 3.8.1 职责定义
提供设备发现、配对、数据同步、权限管理和数据脱敏功能。

#### 3.8.2 服务设计

```typescript
// services/DistributedService.ets
export class DistributedService {
  private deviceManager: DistributedDeviceManager;
  private dataTransferService: DataTransferService;
  private permissionManager: PermissionManager;
  
  constructor() {
    this.deviceManager = new DistributedDeviceManager();
    this.dataTransferService = new DataTransferService();
    this.permissionManager = new PermissionManager();
  }
  
  /**
   * 发现附近设备
   */
  async discoverDevices(): Promise<DeviceInfo[]> {
    return await this.deviceManager.discover({
      timeout: 30000,
      filter: { deviceType: ['phone', 'tablet', '2in1'] }
    });
  }
  
  /**
   * 配对设备
   */
  async pairDevice(deviceId: string): Promise<boolean> {
    // 发起配对请求
    const result = await this.deviceManager.requestPairing(deviceId);
    
    if (result.accepted) {
      // 保存配对信息
      await this.permissionManager.savePairing(deviceId, result.permissions);
      return true;
    }
    
    return false;
  }
  
  /**
   * 同步数据
   */
  async syncData(deviceId: string, dataTypes: string[]): Promise<SyncResult> {
    // 检查权限
    const hasPermission = await this.permissionManager.checkPermission(deviceId, dataTypes);
    if (!hasPermission) {
      throw new Error('无权限访问该数据');
    }
    
    // 准备数据
    const data = await this.prepareData(dataTypes);
    
    // 脱敏处理
    const desensitizedData = DesensitizationUtil.desensitize(data);
    
    // 传输数据
    return await this.dataTransferService.transfer(deviceId, desensitizedData);
  }
  
  /**
   * 准备同步数据
   */
  private async prepareData(dataTypes: string[]): Promise<any> {
    const data: any = {};
    
    for (const type of dataTypes) {
      switch (type) {
        case 'health-records':
          data.healthRecords = await HealthRecordService.getAll();
          break;
        case 'medication-records':
          data.medicationRecords = await MedicationService.getAll();
          break;
        // ... 其他数据类型
      }
    }
    
    return data;
  }
}
```

#### 3.8.3 数据脱敏工具

```typescript
// utils/DesensitizationUtil.ets
export class DesensitizationUtil {
  /**
   * 数据脱敏
   */
  static desensitize(data: any): any {
    const desensitized = JSON.parse(JSON.stringify(data));
    
    // 递归处理
    this.processObject(desensitized);
    
    return desensitized;
  }
  
  private static processObject(obj: any): void {
    if (!obj || typeof obj !== 'object') return;
    
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        // 根据字段名判断是否需要脱敏
        if (this.isSensitiveField(key)) {
          obj[key] = this.maskValue(obj[key]);
        } else if (typeof obj[key] === 'object') {
          this.processObject(obj[key]);
        }
      }
    }
  }
  
  private static isSensitiveField(fieldName: string): boolean {
    const sensitiveFields = [
      'idCard', 'idCardNo', '身份证号',
      'phone', 'mobile', '手机号',
      'medicalRecordNo', '病历号',
      'realName', '姓名'
    ];
    
    return sensitiveFields.includes(fieldName.toLowerCase());
  }
  
  private static maskValue(value: string): string {
    if (!value || value.length < 4) return '***';
    
    // 保留首尾，中间用*替代
    const start = value.substring(0, 2);
    const end = value.substring(value.length - 2);
    const middle = '*'.repeat(Math.min(value.length - 4, 4));
    
    return `${start}${middle}${end}`;
  }
}
```

---

## 4. 数据模型设计

### 4.1 核心数据结构

所有数据模型已在需求规格文档第5章定义，此处补充实现细节。

### 4.2 数据关系

```
┌─────────────┐
│   UserInfo  │
│  (用户信息)  │
└──────┬──────┘
       │
       │ 1:N
       ▼
┌─────────────┐     ┌──────────────┐
│ ChatMessage │     │ HealthRecord │
│  (对话消息)  │     │  (健康档案)   │
└─────────────┘     └──────┬───────┘
                           │
                           │ 1:N
                           ▼
                    ┌──────────────┐
                    │ImageAnalysis │
                    │   (影像分析)  │
                    └──────────────┘
```

### 4.3 数据存储方案

| 数据类型 | 存储方式 | 存储位置 | 有效期 |
|---------|---------|---------|--------|
| JWT Token | AppStorage | 内存 | 24小时 |
| 用户信息 | AppStorage | 内存 | 持久 |
| 对话历史 | Preferences | 本地文件 | 持久 |
| 健康档案 | SQLite | 本地数据库 | 持久 |
| 影像文件 | 应用缓存 | cache目录 | 临时 |
| 风险评估结果 | SQLite | 本地数据库 | 持久 |

---

## 5. API设计

### 5.1 内部API（服务层）

```typescript
// services/ 服务接口定义

interface IAuthService {
  login(request: UserLoginRequest): Promise<ApiResponse<LoginResponse>>;
  register(request: UserRegisterRequest): Promise<ApiResponse<{ userId: number }>>;
  sendVerificationCode(phone: string): Promise<ApiResponse<void>>;
  isTokenValid(): boolean;
  logout(): void;
}

interface IAiChatService {
  chat(request: ChatRequest): Promise<ApiResponse<ChatResponse>>;
  getHistory(sessionId: string): Promise<ApiResponse<ChatMessage[]>>;
  clearHistory(sessionId: string): Promise<void>;
}

interface IImageAnalysisService {
  analyze(request: ImageAnalysisRequest): Promise<ApiResponse<ImageAnalysisResult>>;
  getHistory(userId: number): Promise<ApiResponse<ImageAnalysisResult[]>>;
}

interface IRiskAssessService {
  getQuestionnaire(type: string): Promise<Questionnaire>;
  submit(request: RiskAssessmentRequest): Promise<ApiResponse<RiskAssessmentResult>>;
  getHistory(userId: number): Promise<ApiResponse<RiskAssessmentResult[]>>;
}

interface IDistributedService {
  discoverDevices(): Promise<DeviceInfo[]>;
  pairDevice(deviceId: string): Promise<boolean>;
  syncData(deviceId: string, dataTypes: string[]): Promise<SyncResult>;
  managePermission(deviceId: string, permissions: string[]): Promise<void>;
}
```

### 5.2 外部API（后端接口）

所有后端接口已在需求规格文档第6.2节定义，此处补充请求/响应格式。

**请求拦截器设计**：
```typescript
// utils/HttpUtil.ets
export class HttpUtil {
  private static readonly BASE_URL = 'https://api.nebula-medical.com';
  
  /**
   * POST请求
   */
  static async post<T>(url: string, data: any): Promise<ApiResponse<T>> {
    const token = AppStorage.get<string>('userToken');
    
    const response = await fetch(`${this.BASE_URL}${url}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : ''
      },
      body: JSON.stringify(data)
    });
    
    const result = await response.json();
    
    // Token过期处理
    if (result.code === 401) {
      AuthService.logout();
      throw new Error('Token expired');
    }
    
    return result;
  }
}
```

---

## 6. 关键算法设计

### 6.1 密码强度算法

#### 算法原理
根据密码长度、字符类型多样性计算强度等级。

#### 实现代码
```typescript
function calculatePasswordStrength(password: string): 'weak' | 'medium' | 'strong' {
  let score = 0;
  
  // 长度评分
  if (password.length >= 8) score += 1;
  if (password.length >= 12) score += 1;
  if (password.length >= 16) score += 1;
  
  // 字符类型评分
  if (/[a-z]/.test(password)) score += 1;  // 小写字母
  if (/[A-Z]/.test(password)) score += 1;  // 大写字母
  if (/\d/.test(password)) score += 1;     // 数字
  if (/[!@#$%^&*]/.test(password)) score += 2;  // 特殊字符
  
  // 映射到强度等级
  if (score <= 3) return 'weak';
  if (score <= 5) return 'medium';
  return 'strong';
}
```

#### 复杂度分析
- 时间复杂度：O(n)，n为密码长度
- 空间复杂度：O(1)

### 6.2 断点计算算法

#### 算法原理
根据窗口宽度映射到预定义断点。

#### 实现代码
```typescript
function calculateBreakpoint(width: number): 'sm' | 'md' | 'lg' {
  const BREAKPOINTS = {
    sm: 600,   // < 600vp
    md: 840    // < 840vp
  };
  
  if (width < BREAKPOINTS.sm) return 'sm';
  if (width < BREAKPOINTS.md) return 'md';
  return 'lg';
}
```

---

## 7. UI/UX设计

### 7.1 页面结构

```
应用根
├── Login (登录页)
│   └── Register (注册页)
├── HomePage (首页)
│   ├── HealthRecords (健康档案)
│   ├── AiChatPage (AI聊天)
│   ├── ImageAnalysisPage (影像分析)
│   ├── RiskAssessmentPage (风险评估)
│   ├── AncientMedicalImgPage (古医影像)
│   └── DistributedCollaborationPage (分布式协同)
```

### 7.2 组件设计

| 组件名称 | 属性 | 用途 |
|---------|------|------|
| FormInput | placeholder, type, value, error, onChange | 通用表单输入框 |
| ChatBubble | message, displayedText | 聊天消息气泡 |
| ImagePreview | imageUri, annotations | 影像预览和标注 |
| StepperWizard | steps, onFinish | 步骤向导 |
| RadarChart | data | 雷达图 |
| GaugeChart | value | 仪表盘 |
| AnnotationTool | imageUri, onSave | 标注工具 |
| DeviceList | devices, onPair | 设备列表 |

### 7.3 交互流程

**登录流程**：
```
用户输入 → 实时验证 → 点击登录 → Loading状态 → 
成功：存储Token → 跳转首页
失败：显示错误 → 恢复输入状态
```

**AI对话流程**：
```
用户输入问题 → 发送 → 显示用户消息 → 
调用AI → 打字动画显示AI回复 → 保存对话历史
```

---

## 8. 性能设计

### 8.1 性能目标

| 指标 | 目标值 | 测量方法 |
|-----|--------|---------|
| 首页加载时间 | < 2秒 | onPageShow到渲染完成 |
| 断点切换响应 | < 300ms | 窗口尺寸变化到布局重排完成 |
| AI响应时间 | < 5秒 | 发送消息到AI回复显示 |
| 影像上传时间 | < 15秒 | 10MB文件上传完成 |
| 列表滚动帧率 | ≥ 60fps | LazyForEach虚拟滚动 |

### 8.2 优化策略

**首页优化**：
- 使用Grid组件的columnsTemplate动态列模板，避免条件渲染大量组件
- 功能卡片数据静态化，避免每次渲染重新创建

**AI聊天优化**：
- 使用LazyForEach实现消息列表虚拟滚动，仅渲染可见区域消息
- 对话历史分页加载，避免一次性加载全部历史

**影像分析优化**：
- 影像预览使用缩略图，分析时上传原图
- Canvas标注层独立于图片层，避免重绘整个图片

**风险评估优化**：
- 问卷数据按需加载，选择评估类型后才加载问卷
- 使用Stepper组件分步渲染，避免一次性渲染所有问题

### 8.3 监控方案

```typescript
// utils/PerformanceMonitor.ets
export class PerformanceMonitor {
  /**
   * 记录页面加载时间
   */
  static trackPageLoad(pageName: string): void {
    const startTime = Date.now();
    
    // 页面onPageShow时调用
    this.onPageShow = () => {
      const loadTime = Date.now() - startTime;
      console.info(`[Performance] ${pageName} loaded in ${loadTime}ms`);
      
      // 上报性能数据
      this.report({ pageName, loadTime });
    };
  }
}
```

---

## 9. 安全设计

### 9.1 数据安全

**JWT Token安全**：
- Token存储在AppStorage，不暴露给非授权组件
- Token不记录日志，不传输到非HTTPS接口
- Token过期自动登出，跳转登录页

**敏感数据保护**：
- 密码输入框使用InputType.Password，不显示明文
- 分布式数据传输前进行脱敏处理
- 影像文件不包含EXIF敏感信息

### 9.2 权限控制

**页面级权限**：
```typescript
// 路由守卫
router.beforePush((to) => {
  const requiresAuth = to.meta?.requiresAuth;
  const token = AppStorage.get<string>('userToken');
  
  if (requiresAuth && !token) {
    // 未登录，跳转登录页
    return { url: 'pages/Login' };
  }
  
  return true;
});
```

**API级权限**：
- 所有需认证的API请求携带Token
- Token无效（401）自动登出
- 权限不足（403）显示提示

### 9.3 安全审计

**审计点**：
- 登录/登出事件记录
- 敏感数据访问记录
- 分布式数据传输记录
- 异常错误记录

---

## 10. 测试设计

### 10.1 测试策略

- **单元测试（70%）**：测试工具函数、服务方法、算法
- **集成测试（20%）**：测试页面-服务-后端交互
- **E2E测试（10%）**：测试关键用户流程

### 10.2 测试用例

**登录页面测试用例**：
| 用例ID | 场景 | 输入 | 预期结果 |
|--------|------|------|---------|
| TC-001 | 有效登录 | 正确手机号和密码 | 登录成功，跳转首页 |
| TC-002 | 无效手机号 | 错误格式手机号 | 显示错误提示 |
| TC-003 | 密码错误 | 正确手机号，错误密码 | 显示"密码错误" |
| TC-004 | 网络异常 | 断网情况下登录 | 显示"网络错误" |

**AI聊天测试用例**：
| 用例ID | 场景 | 输入 | 预期结果 |
|--------|------|------|---------|
| TC-005 | 正常对话 | 健康问题 | AI返回专业回复 |
| TC-006 | Markdown渲染 | 包含Markdown的回复 | 正确显示格式 |
| TC-007 | 多轮对话 | 连续提问 | AI理解上下文 |

### 10.3 Mock数据

```typescript
// mock/AuthMock.ets
export const AuthMock = {
  login: async (request: UserLoginRequest): Promise<ApiResponse<LoginResponse>> => {
    return {
      code: 200,
      data: {
        token: 'mock-jwt-token-' + Date.now(),
        userInfo: {
          userId: 1,
          phone: request.phone,
          nickname: '测试用户',
          avatar: 'https://via.placeholder.com/48'
        }
      }
    };
  }
};
```

---

## 11. 部署设计

### 11.1 环境要求

**前端环境**：
- HarmonyOS NEXT API 5.0+
- DevEco Studio 4.0+
- Node.js 16+

**后端环境**：
- JDK 11+
- Spring Boot 2.7+
- MySQL 8.0+

### 11.2 配置管理

```typescript
// config/AppConfig.ets
export class AppConfig {
  static readonly API_BASE_URL = 'https://api.nebula-medical.com';
  static readonly AI_SERVICE_URL = 'https://ai.nebula-medical.com';
  static readonly TOKEN_EXPIRE_TIME = 24 * 60 * 60 * 1000;  // 24小时
  static readonly MAX_CONVERSATION_ROUNDS = 10;
  static readonly MAX_IMAGE_SIZE = 10 * 1024 * 1024;  // 10MB
}
```

### 11.3 发布流程

1. **代码审查**：PR合并前进行代码审查
2. **单元测试**：运行所有单元测试，覆盖率>80%
3. **集成测试**：运行集成测试，确保API交互正常
4. **构建打包**：`hvigorw assembleHap --mode release`
5. **签名发布**：使用正式签名证书签名
6. **上架应用市场**：提交HarmonyOS应用市场审核

---

## 12. 附录

### 12.1 术语表

| 术语 | 定义 |
|-----|------|
| BreakpointSystem | HarmonyOS响应式断点系统 |
| LazyForEach | ArkUI懒加载ForEach，用于虚拟滚动 |
| MedicalAgent | 医疗AI代理 |
| ConversationMemory | 对话记忆管理器 |
| SRGAN | 超分辨率生成对抗网络 |
| FormData | HTTP文件上传数据格式 |
| AppStorage | HarmonyOS应用全局状态存储 |
| Preferences | HarmonyOS轻量级数据持久化API |

### 12.2 参考资料

- HarmonyOS NEXT开发文档
- ArkUI组件参考
- Spring Boot官方文档
- JWT标准RFC 7519

### 12.3 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2026-05-06 | 初始版本，完成8个核心页面技术设计 | SDD Agent |
