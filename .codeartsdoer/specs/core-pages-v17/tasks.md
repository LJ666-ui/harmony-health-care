# 星云医疗助手 V17.0 - 8个核心页面实施任务清单

**版本**: v1.0
**创建日期**: 2026-05-06
**最后更新**: 2026-05-06
**作者**: SDD Agent
**状态**: 待执行

---

## 任务概览

本文档将技术设计转化为可执行的实施任务，共规划**8个主任务**，包含**32个子任务**，覆盖全部34个功能需求。

**任务优先级**：
- **P0（必须实现）**：Login、Register、HomePage响应式布局
- **P1（重要功能）**：AiChatPage、ImageAnalysisPage、RiskAssessmentPage
- **P2（增强功能）**：AncientMedicalImgPage、DistributedCollaborationPage

**预计工期**：7个工作日

---

## 任务1：Login.ets 登录页面实现 [P0]

**任务描述**：实现完整的用户登录功能，包括表单验证、JWT认证、Token存储和状态管理。

**输入**：
- 需求规格：FR-004, FR-005, FR-006, FR-007
- 技术设计：3.2节 Login.ets设计
- 后端接口：POST /api/user/login

**输出**：
- 完整可用的Login.ets页面
- AuthService服务类
- 表单验证工具函数

**验收标准**：
- [ ] 手机号实时验证（11位，1开头）
- [ ] 密码实时验证（6-20位）
- [ ] 登录按钮loading状态正确显示
- [ ] JWT Token成功存储到AppStorage
- [ ] 登录成功跳转HomePage
- [ ] 登录失败显示错误提示
- [ ] "忘记密码"和"注册账号"链接可用

### 子任务1.1：创建Login.ets页面骨架

**描述**：创建Login.ets文件，搭建页面基本结构。

**实施步骤**：
1. 在 `entry/src/main/ets/pages/` 目录创建 `Login.ets` 文件
2. 定义页面状态变量：
   ```typescript
   @State phone: string = '';
   @State password: string = '';
   @State phoneError: string = '';
   @State passwordError: string = '';
   @State isLoading: boolean = false;
   @State showPassword: boolean = false;
   ```
3. 创建页面布局结构：
   - Logo和标题区域
   - 表单输入区域
   - 登录按钮区域
   - 辅助链接区域
4. 设置页面样式：背景色#F5F5F5，主色调#4A90E2

**代码生成提示**：
```
创建HarmonyOS ArkTS登录页面，包含：
- 顶部Logo和"登录"标题
- 手机号输入框（InputType.Number，maxLength: 11，带清除按钮）
- 密码输入框（InputType.Password，maxLength: 20，带显示/隐藏切换）
- 登录按钮（宽度100%，高度48vp，支持loading状态）
- "忘记密码"和"注册账号"链接
使用@State装饰器管理状态，使用Column和Row布局组件。
```

### 子任务1.2：实现表单实时验证

**描述**：实现手机号和密码的实时验证逻辑。

**实施步骤**：
1. 定义验证正则表达式：
   ```typescript
   private phoneRegex: RegExp = /^1[3-9]\d{9}$/;
   ```
2. 实现手机号验证函数：
   ```typescript
   private validatePhone(): void {
     if (!this.phone) {
       this.phoneError = '';
     } else if (!this.phoneRegex.test(this.phone)) {
       this.phoneError = '请输入正确的手机号';
     } else {
       this.phoneError = '';
     }
   }
   ```
3. 实现密码验证函数：
   ```typescript
   private validatePassword(): void {
     if (!this.password) {
       this.passwordError = '';
     } else if (this.password.length < 6 || this.password.length > 20) {
       this.passwordError = '密码长度为6-20位';
     } else {
       this.passwordError = '';
     }
   }
   ```
4. 在TextInput的onChange回调中调用验证函数
5. 根据错误状态更新输入框边框颜色（错误时为#F5222D）

**代码生成提示**：
```
在Login.ets中添加表单验证逻辑：
- 手机号验证：正则/^1[3-9]\d{9}$/，错误提示"请输入正确的手机号"
- 密码验证：长度6-20位，错误提示"密码长度为6-20位"
- 在TextInput.onChange中调用验证函数
- 错误时输入框borderColor设为#F5222D，显示错误Text组件
```

### 子任务1.3：创建AuthService服务类

**描述**：创建认证服务类，封装登录API调用。

**实施步骤**：
1. 在 `entry/src/main/ets/services/` 目录创建 `AuthService.ets` 文件
2. 定义服务类：
   ```typescript
   export class AuthService {
     private static readonly BASE_URL = '/api/user';
     
     static async login(request: UserLoginRequest): Promise<ApiResponse<LoginResponse>> {
       return await HttpUtil.post(`${this.BASE_URL}/login`, request);
     }
     
     static logout(): void {
       AppStorage.delete('userToken');
       AppStorage.delete('userInfo');
       router.replaceUrl({ url: 'pages/Login' });
     }
   }
   ```
3. 定义数据模型接口：
   ```typescript
   interface UserLoginRequest {
     phone: string;
     password: string;
   }
   
   interface LoginResponse {
     token: string;
     userInfo: UserInfo;
   }
   ```

**代码生成提示**：
```
创建AuthService.ets服务类，包含：
- login方法：调用HttpUtil.post('/api/user/login', request)
- logout方法：清除AppStorage中的token和userInfo，跳转Login页面
- isTokenValid方法：检查token是否存在
定义UserLoginRequest和LoginResponse接口。
```

### 子任务1.4：实现登录流程

**描述**：实现完整的登录流程，包括API调用、Token存储和页面跳转。

**实施步骤**：
1. 实现表单有效性检查：
   ```typescript
   private isFormValid(): boolean {
     return this.phoneRegex.test(this.phone) &&
            this.password.length >= 6 &&
            this.password.length <= 20;
   }
   ```
2. 实现登录处理函数：
   ```typescript
   private async handleLogin(): Promise<void> {
     this.isLoading = true;
     
     try {
       const response = await AuthService.login({
         phone: this.phone,
         password: this.password
       });
       
       if (response.code === 200) {
         AppStorage.setOrCreate('userToken', response.data.token);
         AppStorage.setOrCreate('userInfo', response.data.userInfo);
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
   ```
3. 绑定登录按钮onClick事件
4. 实现辅助链接功能：
   - "忘记密码"：显示Toast提示"请联系客服重置密码"
   - "注册账号"：router.pushUrl({ url: 'pages/Register' })

**代码生成提示**：
```
实现Login.ets的handleLogin方法：
- 设置isLoading=true，禁用按钮
- 调用AuthService.login({phone, password})
- 成功：AppStorage.setOrCreate存储token和userInfo，router.replaceUrl跳转HomePage
- 失败：promptAction.showToast显示错误信息
- finally设置isLoading=false
绑定登录按钮onClick，实现"忘记密码"和"注册账号"链接功能。
```

---

## 任务2：Register.ets 注册页面实现 [P0]

**任务描述**：实现完整的用户注册功能，包括验证码流程、密码强度检测、用户协议确认和自动登录。

**输入**：
- 需求规格：FR-008, FR-009, FR-010, FR-011, FR-012
- 技术设计：3.3节 Register.ets设计
- 后端接口：POST /api/user/register, POST /api/user/send-code

**输出**：
- 完整可用的Register.ets页面
- 验证码倒计时逻辑
- 密码强度检测算法

**验收标准**：
- [ ] 四个表单字段正确显示和验证
- [ ] 验证码60秒倒计时正确运行
- [ ] 密码强度指示器正确显示（弱/中/强）
- [ ] 用户协议Checkbox必须勾选才能注册
- [ ] 两次密码一致性校验
- [ ] 注册成功自动登录并跳转首页

### 子任务2.1：创建Register.ets页面骨架

**描述**：创建Register.ets文件，搭建页面基本结构。

**实施步骤**：
1. 在 `entry/src/main/ets/pages/` 目录创建 `Register.ets` 文件
2. 定义页面状态变量：
   ```typescript
   @State phone: string = '';
   @State password: string = '';
   @State confirmPassword: string = '';
   @State verificationCode: string = '';
   @State agreedToTerms: boolean = false;
   @State countdown: number = 0;
   @State passwordStrength: 'weak' | 'medium' | 'strong' = 'weak';
   @State isLoading: boolean = false;
   ```
3. 创建页面布局结构：
   - Logo和标题区域
   - 表单输入区域（手机号、验证码、密码、确认密码）
   - 密码强度指示器
   - 用户协议区域
   - 注册按钮区域

**代码生成提示**：
```
创建HarmonyOS ArkTS注册页面，包含：
- 顶部Logo和"注册"标题
- 手机号输入框（InputType.Number，maxLength: 11）
- 验证码输入框（maxLength: 6）+ 获取验证码按钮
- 密码输入框（InputType.Password，maxLength: 20）
- 确认密码输入框（InputType.Password，maxLength: 20）
- 密码强度指示器（弱/中/强，颜色：红/黄/绿）
- 用户协议Checkbox + "我已阅读并同意《用户协议》"
- 注册按钮
使用@State管理状态，countdown用于验证码倒计时。
```

### 子任务2.2：实现验证码倒计时

**描述**：实现验证码发送和60秒倒计时功能。

**实施步骤**：
1. 在AuthService中添加发送验证码方法：
   ```typescript
   static async sendVerificationCode(phone: string): Promise<ApiResponse<void>> {
     return await HttpUtil.post(`${this.BASE_URL}/send-code`, { phone });
   }
   ```
2. 实现发送验证码函数：
   ```typescript
   private async sendVerificationCode(): Promise<void> {
     try {
       const response = await AuthService.sendVerificationCode(this.phone);
       if (response.code === 200) {
         promptAction.showToast({ message: '验证码已发送' });
         this.startCountdown();
       }
     } catch (error) {
       promptAction.showToast({ message: '网络错误' });
     }
   }
   ```
3. 实现倒计时函数：
   ```typescript
   private startCountdown(): void {
     this.countdown = 60;
     this.countdownTimer = setInterval(() => {
       this.countdown--;
       if (this.countdown <= 0) {
         clearInterval(this.countdownTimer);
       }
     }, 1000);
   }
   ```
4. 在aboutToDisappear中清除定时器
5. 更新按钮状态：倒计时期间禁用，显示剩余秒数

**代码生成提示**：
```
实现Register.ets的验证码功能：
- sendVerificationCode方法：调用AuthService.sendVerificationCode(phone)
- startCountdown方法：设置countdown=60，setInterval每秒减1
- aboutToDisappear中clearInterval清除定时器
- 获取验证码按钮：countdown>0时显示"{countdown}秒"并禁用，否则显示"获取验证码"
- 按钮enabled条件：countdown===0 && 手机号格式正确
```

### 子任务2.3：实现密码强度检测

**描述**：实现密码强度实时检测算法。

**实施步骤**：
1. 实现密码强度计算函数：
   ```typescript
   private calculatePasswordStrength(): void {
     const pwd = this.password;
     
     if (pwd.length < 8 || /^\d+$/.test(pwd)) {
       this.passwordStrength = 'weak';
     } else if (pwd.length >= 8 && pwd.length <= 12 && 
                /[a-zA-Z]/.test(pwd) && /\d/.test(pwd)) {
       this.passwordStrength = 'medium';
     } else if (pwd.length > 12 && /[!@#$%^&*]/.test(pwd)) {
       this.passwordStrength = 'strong';
     } else {
       this.passwordStrength = 'medium';
     }
   }
   ```
2. 在密码输入框onChange中调用强度计算
3. 创建密码强度指示器组件：
   ```typescript
   @Builder PasswordStrengthIndicator() {
     Row() {
       Text('密码强度：').fontSize(12);
       Text(this.passwordStrength === 'weak' ? '弱' : 
            this.passwordStrength === 'medium' ? '中' : '强')
         .fontSize(12)
         .fontColor(this.passwordStrength === 'weak' ? '#F5222D' :
                    this.passwordStrength === 'medium' ? '#FAAD14' : '#52C41A');
     }
   }
   ```

**代码生成提示**：
```
实现Register.ets的密码强度检测：
- calculatePasswordStrength方法：
  - 弱：长度<8 或 纯数字
  - 中：长度8-12 且 包含字母和数字
  - 强：长度>12 且 包含特殊字符
- 在密码输入框onChange中调用
- 显示强度指示器：弱(红色#F5222D)、中(黄色#FAAD14)、强(绿色#52C41A)
```

### 子任务2.4：实现注册流程

**描述**：实现完整的注册流程，包括验证、提交和自动登录。

**实施步骤**：
1. 在AuthService中添加注册方法：
   ```typescript
   static async register(request: UserRegisterRequest): Promise<ApiResponse<{ userId: number }>> {
     return await HttpUtil.post(`${this.BASE_URL}/register`, request);
   }
   ```
2. 实现注册处理函数：
   ```typescript
   private async handleRegister(): Promise<void> {
     // 验证用户协议
     if (!this.agreedToTerms) {
       promptAction.showToast({ message: '请先同意用户协议' });
       return;
     }
     
     // 验证密码一致性
     if (this.password !== this.confirmPassword) {
       promptAction.showToast({ message: '两次密码输入不一致' });
       return;
     }
     
     this.isLoading = true;
     
     try {
       // 注册
       const response = await AuthService.register({
         phone: this.phone,
         password: this.password,
         verificationCode: this.verificationCode,
         agreedToTerms: this.agreedToTerms
       });
       
       if (response.code === 200) {
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
       }
     } catch (error) {
       promptAction.showToast({ message: '网络错误' });
     } finally {
       this.isLoading = false;
     }
   }
   ```

**代码生成提示**：
```
实现Register.ets的handleRegister方法：
- 验证用户协议：未勾选显示"请先同意用户协议"
- 验证密码一致性：不一致显示"两次密码输入不一致"
- 调用AuthService.register({phone, password, verificationCode, agreedToTerms})
- 成功后自动调用AuthService.login进行登录
- 登录成功存储token和userInfo，跳转HomePage
- 失败显示错误Toast
```

---

## 任务3：HomePage.ets 响应式布局实现 [P0]

**任务描述**：实现首页响应式布局，支持phone/tablet/2in1三种设备类型自适应。

**输入**：
- 需求规格：FR-001, FR-002, FR-003
- 技术设计：3.1节 HomePage.ets设计
- BreakpointSystem断点系统

**输出**：
- 完整可用的HomePage.ets页面
- BreakpointSystem工具类
- FunctionCardComponent组件

**验收标准**：
- [ ] sm断点（<600vp）显示2列Grid布局
- [ ] md断点（600-840vp）显示3列Grid布局
- [ ] lg断点（≥840vp）显示4列Grid布局
- [ ] 13个功能卡片正确显示和跳转
- [ ] 用户信息区域根据登录状态显示

### 子任务3.1：创建BreakpointSystem工具类

**描述**：创建响应式断点系统工具类。

**实施步骤**：
1. 在 `entry/src/main/ets/utils/` 目录创建 `BreakpointSystem.ets` 文件
2. 实现断点系统类：
   ```typescript
   export class BreakpointSystem {
     private currentBreakpoint: string = 'md';
     onBreakpointChange: (breakpoint: string) => void = () => {};
     
     constructor() {
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
     
     getCurrentBreakpoint(): string {
       return this.currentBreakpoint;
     }
   }
   ```

**代码生成提示**：
```
创建BreakpointSystem.ets工具类：
- 监听窗口尺寸变化：window.getLastWindow().on('windowSizeChange')
- calculateBreakpoint方法：width<600返回'sm'，width<840返回'md'，否则返回'lg'
- onBreakpointChange回调函数，断点变化时通知页面
- getCurrentBreakpoint方法返回当前断点
```

### 子任务3.2：创建HomePage.ets页面骨架

**描述**：创建HomePage.ets文件，搭建页面基本结构。

**实施步骤**：
1. 在 `entry/src/main/ets/pages/` 目录创建或更新 `HomePage.ets` 文件
2. 定义页面状态变量：
   ```typescript
   @State currentBreakpoint: string = 'md';
   @State userInfo: UserInfo | null = null;
   @State healthSummary: HealthSummary | null = null;
   ```
3. 在aboutToAppear中初始化：
   ```typescript
   aboutToAppear() {
     const bpSystem = new BreakpointSystem();
     bpSystem.onBreakpointChange = (bp) => {
       this.currentBreakpoint = bp;
     };
     
     this.userInfo = AppStorage.get('userInfo');
   }
   ```
4. 创建页面布局结构：
   - 顶部用户信息区域
   - 功能卡片Grid区域
   - 健康摘要区域（可选）

**代码生成提示**：
```
创建或更新HomePage.ets：
- 使用BreakpointSystem监听断点变化
- @State currentBreakpoint存储当前断点
- 顶部区域：已登录显示头像+昵称，未登录显示"登录/注册"按钮
- 中部Grid区域：显示13个功能卡片
- 底部区域：显示健康摘要（如果已登录）
```

### 子任务3.3：实现Grid动态列布局

**描述**：根据断点动态设置Grid列数。

**实施步骤**：
1. 实现列模板计算函数：
   ```typescript
   private getGridColumns(): string {
     switch (this.currentBreakpoint) {
       case 'sm': return '1fr 1fr';           // 2列
       case 'md': return '1fr 1fr 1fr';       // 3列
       case 'lg': return '1fr 1fr 1fr 1fr';   // 4列
       default: return '1fr 1fr 1fr';
     }
   }
   ```
2. 创建Grid组件：
   ```typescript
   Grid() {
     ForEach(this.getFunctionCards(), (card: FunctionCard) => {
       GridItem() {
         FunctionCardComponent({ card: card });
       }
     });
   }
   .columnsTemplate(this.getGridColumns())
   .rowsGap(12)
   .columnsGap(12)
   .padding(16);
   ```

**代码生成提示**：
```
实现HomePage.ets的Grid动态布局：
- getGridColumns方法：sm返回'1fr 1fr'，md返回'1fr 1fr 1fr'，lg返回'1fr 1fr 1fr 1fr'
- Grid组件使用columnsTemplate绑定getGridColumns()
- ForEach渲染13个功能卡片
- 设置rowsGap和columnsGap为12，padding为16
```

### 子任务3.4：实现功能卡片组件

**描述**：创建可复用的功能卡片组件。

**实施步骤**：
1. 在 `entry/src/main/ets/components/` 目录创建 `FunctionCardComponent.ets` 文件
2. 定义卡片组件：
   ```typescript
   @Component
   export struct FunctionCardComponent {
     @Prop card: FunctionCard;
     
     build() {
       Column() {
         Image(this.card.icon)
           .width(48)
           .height(48);
         
         Text(this.card.title)
           .fontSize(14)
           .margin({ top: 8 });
       }
       .width('100%')
       .padding(16)
       .backgroundColor('#FFFFFF')
       .borderRadius(8)
       .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
       .onClick(() => {
         router.pushUrl({ url: this.card.route });
       });
     }
   }
   ```
3. 定义功能卡片数据：
   ```typescript
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
   ```

**代码生成提示**：
```
创建FunctionCardComponent.ets组件：
- @Prop card: FunctionCard接收卡片数据
- Column布局：Image(48x48) + Text(标题)
- 样式：白色背景，圆角8，阴影效果
- onClick跳转：router.pushUrl({ url: card.route })
在HomePage中定义getFunctionCards方法返回13个功能卡片数据。
```

---

## 任务4：AiChatPage.ets AI聊天界面实现 [P1]

**任务描述**：实现AI医疗助手对话界面，集成MedicalAgent，支持Markdown渲染和打字动画。

**输入**：
- 需求规格：FR-013, FR-014, FR-015, FR-016, FR-017
- 技术设计：3.4节 AiChatPage.ets设计
- MedicalAgent和ConversationMemory

**输出**：
- 完整可用的AiChatPage.ets页面
- ChatBubble组件
- MedicalAgent代理类
- ConversationMemory记忆管理类

**验收标准**：
- [ ] 消息列表正确显示（用户右对齐蓝色，AI左对齐白色）
- [ ] LazyForEach虚拟滚动正常工作
- [ ] Markdown内容正确渲染
- [ ] 打字动画流畅显示
- [ ] 多轮对话上下文正确保持
- [ ] 对话历史持久化存储

### 子任务4.1：创建MedicalAgent和ConversationMemory

**描述**：创建AI代理和对话记忆管理类。

**实施步骤**：
1. 在 `entry/src/main/ets/agents/` 目录创建 `ConversationMemory.ets` 文件：
   ```typescript
   export class ConversationMemory {
     private messages: ChatMessage[] = [];
     private sessionId: string = '';
     private maxContextLength: number = 10;
     
     constructor() {
       this.sessionId = Date.now().toString();
     }
     
     addMessage(message: ChatMessage): void {
       this.messages.push(message);
       if (this.messages.length > this.maxContextLength * 2) {
         this.messages = this.messages.slice(-this.maxContextLength * 2);
       }
     }
     
     getContext(rounds: number): ChatMessage[] {
       return this.messages.slice(-rounds * 2);
     }
     
     getSessionId(): string {
       return this.sessionId;
     }
     
     clear(): void {
       this.messages = [];
       this.sessionId = Date.now().toString();
     }
   }
   ```
2. 创建 `MedicalAgent.ets` 文件：
   ```typescript
   export class MedicalAgent {
     private ragRetriever: RAGRetriever;
     
     constructor() {
       this.ragRetriever = new RAGRetriever();
     }
     
     async chat(question: string, memory: ConversationMemory): Promise<{ reply: string; markdown: boolean }> {
       const relevantKnowledge = await this.ragRetriever.retrieve(question);
       const context = memory.getContext(10);
       const systemPrompt = this.buildSystemPrompt(relevantKnowledge);
       
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
       return `你是一位专业的医疗AI助手...
参考知识库：
${knowledge.join('\n')}`;
     }
   }
   ```

**代码生成提示**：
```
创建ConversationMemory.ets：
- messages数组存储对话历史
- addMessage方法：添加消息，超过maxContextLength*2时截断
- getContext方法：返回最近N轮对话
- getSessionId和clear方法

创建MedicalAgent.ets：
- chat方法：调用RAGRetriever检索知识，构建systemPrompt，调用AiChatService
- buildSystemPrompt方法：构建医疗AI系统提示词
```

### 子任务4.2：创建ChatBubble组件

**描述**：创建聊天消息气泡组件。

**实施步骤**：
1. 在 `entry/src/main/ets/components/` 目录创建 `ChatBubble.ets` 文件
2. 定义气泡组件：
   ```typescript
   @Component
   export struct ChatBubble {
     @Prop message: ChatMessage;
     @Prop displayedText: string = '';
     
     build() {
       Row() {
         if (this.message.role === 'user') {
           // 用户消息：右对齐蓝色气泡
           Column() {
             Text(this.message.content)
               .fontSize(14)
               .fontColor('#FFFFFF');
             
             Text(this.formatTime(this.message.timestamp))
               .fontSize(10)
               .fontColor('#FFFFFF')
               .opacity(0.7);
           }
           .padding(12)
           .backgroundColor('#4A90E2')
           .borderRadius({ topLeft: 16, topRight: 4, bottomLeft: 16, bottomRight: 16 });
         } else {
           // AI消息：左对齐白色气泡
           Column() {
             if (this.message.markdown) {
               // Markdown渲染
               MarkdownText({ content: this.displayedText || this.message.content });
             } else {
               Text(this.displayedText || this.message.content)
                 .fontSize(14);
             }
           }
           .padding(12)
           .backgroundColor('#FFFFFF')
           .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 });
         }
       }
       .width('100%')
       .justifyContent(this.message.role === 'user' ? FlexAlign.End : FlexAlign.Start);
     }
     
     private formatTime(timestamp: number): string {
       const date = new Date(timestamp);
       return `${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`;
     }
   }
   ```

**代码生成提示**：
```
创建ChatBubble.ets组件：
- @Prop message: ChatMessage接收消息数据
- @Prop displayedText用于打字动画
- 用户消息：右对齐，蓝色背景#4A90E2，圆角(topLeft:16, topRight:4, bottomLeft:16, bottomRight:16)
- AI消息：左对齐，白色背景，圆角(topLeft:4, topRight:16, bottomLeft:16, bottomRight:16)
- 支持Markdown渲染（message.markdown为true时）
- 显示时间戳
```

### 子任务4.3：创建AiChatPage.ets页面

**描述**：创建AI聊天页面，实现消息列表和发送功能。

**实施步骤**：
1. 在 `entry/src/main/ets/pages/` 目录创建或更新 `AiChatPage.ets` 文件
2. 定义页面状态：
   ```typescript
   @State messages: ChatMessage[] = [];
   @State inputText: string = '';
   @State isTyping: boolean = false;
   @State displayedText: string = '';
   ```
3. 创建页面布局：
   - 标题栏（标题 + 清空对话按钮）
   - 消息列表（List + LazyForEach）
   - 输入区域（TextInput + 发送按钮）
4. 实现消息发送和打字动画

**代码生成提示**：
```
创建或更新AiChatPage.ets：
- 标题栏：Text('AI医疗助手') + Button('清空对话')
- 消息列表：List使用LazyForEach渲染messages，ChatBubble组件显示消息
- 输入区域：TextInput + Button('发送')
- sendMessage方法：添加用户消息，调用MedicalAgent.chat，添加AI消息，启动打字动画
- startTypingAnimation方法：setInterval逐字显示AI回复
```

---

## 任务5：ImageAnalysisPage.ets 影像分析实现 [P1]

**任务描述**：实现医学影像上传和AI分析功能，显示异常区域标注和诊断报告。

**输入**：
- 需求规格：FR-018, FR-019, FR-020, FR-021, FR-022
- 技术设计：3.5节 ImageAnalysisPage.ets设计
- ImagePicker和Canvas API

**输出**：
- 完整可用的ImageAnalysisPage.ets页面
- ImageAnalysisService服务类
- 异常区域标注功能

**验收标准**：
- [ ] 拍照和相册选择功能正常
- [ ] 影像预览正确显示
- [ ] AI分析结果正确返回
- [ ] 异常区域边界框正确绘制
- [ ] 诊断报告完整展示

### 子任务5.1：创建ImageAnalysisService服务类

**描述**：创建影像分析服务类。

**实施步骤**：
1. 在 `entry/src/main/ets/services/` 目录创建 `ImageAnalysisService.ets` 文件
2. 定义服务类：
   ```typescript
   export class ImageAnalysisService {
     private static readonly BASE_URL = '/api/medical-image';
     
     static async analyze(request: ImageAnalysisRequest): Promise<ApiResponse<ImageAnalysisResult>> {
       const formData = new FormData();
       formData.append('image', request.imageFile);
       formData.append('type', request.imageType);
       
       return await HttpUtil.postFormData(`${this.BASE_URL}/analyze`, formData);
     }
     
     static async getHistory(userId: number): Promise<ApiResponse<ImageAnalysisResult[]>> {
       return await HttpUtil.get(`${this.BASE_URL}/history/${userId}`);
     }
   }
   ```

**代码生成提示**：
```
创建ImageAnalysisService.ets：
- analyze方法：使用FormData上传影像文件，调用/api/medical-image/analyze
- getHistory方法：获取历史分析记录
定义ImageAnalysisRequest和ImageAnalysisResult接口。
```

### 子任务5.2：创建ImageAnalysisPage.ets页面

**描述**：创建影像分析页面，实现上传和分析功能。

**实施步骤**：
1. 在 `entry/src/main/ets/pages/` 目录创建或更新 `ImageAnalysisPage.ets` 文件
2. 定义页面状态：
   ```typescript
   @State imageUri: string = '';
   @State imageType: 'CT' | 'MRI' | 'XRay' | 'Ultrasound' = 'CT';
   @State isAnalyzing: boolean = false;
   @State analysisResult: ImageAnalysisResult | null = null;
   ```
3. 创建页面布局：
   - 标题栏
   - 影像预览区域（Stack: Image + Canvas标注层）
   - 分析结果区域（异常发现 + 可能诊断 + 建议）
4. 实现上传和分析功能

**代码生成提示**：
```
创建或更新ImageAnalysisPage.ets：
- 影像预览区域：Stack包含Image和Canvas
- 未上传时显示上传提示，点击弹出选择对话框（拍照/相册）
- 使用ImagePicker选择影像
- 选择后显示预览和"开始分析"按钮
- startAnalysis方法：调用ImageAnalysisService.analyze
- drawAnnotations方法：在Canvas上绘制异常区域边界框
- 结果区域：显示异常发现、可能诊断、建议措施、置信度
```

---

## 任务6：RiskAssessmentPage.ets 风险评估实现 [P1]

**任务描述**：实现健康风险评估问卷和结果可视化。

**输入**：
- 需求规格：FR-023, FR-024, FR-025, FR-026
- 技术设计：3.6节 RiskAssessmentPage.ets设计
- Stepper组件和图表组件

**输出**：
- 完整可用的RiskAssessmentPage.ets页面
- RiskAssessService服务类
- RadarChart和GaugeChart组件

**验收标准**：
- [ ] 4种评估类型可选
- [ ] 问卷Stepper分步正确
- [ ] 表单验证正确
- [ ] 风险结果可视化正确显示
- [ ] 雷达图和仪表盘正确渲染

### 子任务6.1：创建图表组件

**描述**：创建雷达图和仪表盘组件。

**实施步骤**：
1. 在 `entry/src/main/ets/components/` 目录创建 `RadarChart.ets` 文件
2. 实现雷达图组件（使用Canvas绘制）
3. 创建 `GaugeChart.ets` 文件
4. 实现仪表盘组件（使用Canvas绘制）

**代码生成提示**：
```
创建RadarChart.ets：
- @Prop data: Map<string, number>接收多维度数据
- 使用Canvas绘制雷达图：绘制多边形网格、数据区域、标签

创建GaugeChart.ets：
- @Prop value: number接收数值（0-100）
- 使用Canvas绘制仪表盘：绘制圆弧、指针、刻度
```

### 子任务6.2：创建RiskAssessmentPage.ets页面

**描述**：创建风险评估页面，实现问卷流程。

**实施步骤**：
1. 在 `entry/src/main/ets/pages/` 目录创建或更新 `RiskAssessmentPage.ets` 文件
2. 定义页面状态：
   ```typescript
   @State selectedType: AssessmentType | null = null;
   @State currentStep: number = 0;
   @State answers: Map<string, string | number | boolean> = new Map();
   @State assessmentResult: RiskAssessmentResult | null = null;
   ```
3. 创建页面布局：
   - 评估类型选择区域（4个卡片）
   - 问卷区域（Stepper分步）
   - 结果展示区域（雷达图 + 仪表盘 + 建议）
4. 实现问卷提交和结果展示

**代码生成提示**：
```
创建或更新RiskAssessmentPage.ets：
- 类型选择区域：Grid显示4个评估类型卡片（心血管、糖尿病、癌症、综合）
- 问卷区域：Stepper组件分步显示问题，每步包含若干QuestionItem
- QuestionItem：根据问题类型（single-choice/number/boolean）显示不同输入组件
- submitAssessment方法：调用RiskAssessService.submit提交问卷
- 结果区域：显示风险等级、RadarChart、GaugeChart、改善建议
```

---

## 任务7：AncientMedicalImgPage.ets 古医影像处理实现 [P2]

**任务描述**：实现古籍医学影像处理流水线，包括预处理、修复、OCR识别和标注。

**输入**：
- 需求规格：FR-027, FR-028, FR-029, FR-030
- 技术设计：3.7节 AncientMedicalImgPage.ets设计
- 图像处理和OCR引擎

**输出**：
- 完整可用的AncientMedicalImgPage.ets页面
- AncientImageService服务类
- 处理流水线

**验收标准**：
- [ ] 影像上传和预处理正确
- [ ] 色彩恢复效果符合预期
- [ ] SRGAN超分辨率增强正确
- [ ] OCR识别准确率>85%
- [ ] 标注工具完整可用

### 子任务7.1：创建AncientImageService服务类

**描述**：创建古医影像处理服务类。

**实施步骤**：
1. 在 `entry/src/main/ets/services/` 目录创建 `AncientImageService.ets` 文件
2. 实现处理流水线：
   ```typescript
   export class AncientImageService {
     static async processPipeline(imageUri: string): Promise<AncientImageProcessResult> {
       const preprocessed = await this.preprocess(imageUri);
       const colorRestored = await this.restoreColor(preprocessed);
       const enhanced = await this.superResolution(colorRestored);
       const ocrResult = await this.ocrRecognize(enhanced);
       
       return {
         originalImage: imageUri,
         processedImage: enhanced,
         ocrText: ocrResult.text,
         confidence: ocrResult.confidence
       };
     }
     
     private static async preprocess(imageUri: string): Promise<string> { ... }
     private static async restoreColor(imageUri: string): Promise<string> { ... }
     private static async superResolution(imageUri: string): Promise<string> { ... }
     private static async ocrRecognize(imageUri: string): Promise<{ text: string; confidence: number }> { ... }
   }
   ```

**代码生成提示**：
```
创建AncientImageService.ets：
- processPipeline方法：执行完整流水线（预处理→色彩恢复→超分辨率→OCR）
- preprocess方法：去噪、增强、二值化
- restoreColor方法：调用ColorRestorer恢复褪色区域
- superResolution方法：调用SRGAN模型提升清晰度
- ocrRecognize方法：调用OCR引擎识别文字
```

### 子任务7.2：创建AncientMedicalImgPage.ets页面

**描述**：创建古医影像处理页面。

**实施步骤**：
1. 在 `entry/src/main/ets/pages/` 目录创建或更新 `AncientMedicalImgPage.ets` 文件
2. 创建页面布局：
   - 影像上传区域
   - 处理进度显示
   - 处理结果展示（修复后影像 + OCR文本）
   - 标注工具区域
3. 实现处理流程和标注功能

**代码生成提示**：
```
创建或更新AncientMedicalImgPage.ets：
- 上传区域：支持拍照/相册选择
- 处理进度：显示当前处理步骤（预处理/色彩恢复/超分辨率/OCR）
- 结果展示：并排显示原图和修复后影像，OCR文本可编辑
- 标注工具：提供矩形框、圆形框、自由绘制、文本标注工具
```

---

## 任务8：DistributedCollaborationPage.ets 分布式协同实现 [P2]

**任务描述**：实现设备发现、配对、数据同步和权限管理功能。

**输入**：
- 需求规格：FR-031, FR-032, FR-033, FR-034
- 技术设计：3.8节 DistributedCollaborationPage.ets设计
- DistributedDeviceKit

**输出**：
- 完整可用的DistributedCollaborationPage.ets页面
- DistributedService服务类
- DesensitizationUtil工具类

**验收标准**：
- [ ] 设备发现和配对流程正确
- [ ] 数据同步进度正确显示
- [ ] 权限管理生效
- [ ] 敏感数据已脱敏

### 子任务8.1：创建DesensitizationUtil工具类

**描述**：创建数据脱敏工具类。

**实施步骤**：
1. 在 `entry/src/main/ets/utils/` 目录创建 `DesensitizationUtil.ets` 文件
2. 实现脱敏方法：
   ```typescript
   export class DesensitizationUtil {
     static desensitize(data: any): any {
       const desensitized = JSON.parse(JSON.stringify(data));
       this.processObject(desensitized);
       return desensitized;
     }
     
     private static processObject(obj: any): void {
       for (const key in obj) {
         if (this.isSensitiveField(key)) {
           obj[key] = this.maskValue(obj[key]);
         } else if (typeof obj[key] === 'object') {
           this.processObject(obj[key]);
         }
       }
     }
     
     private static isSensitiveField(fieldName: string): boolean {
       const sensitiveFields = ['idCard', 'phone', 'medicalRecordNo', 'realName'];
       return sensitiveFields.includes(fieldName.toLowerCase());
     }
     
     private static maskValue(value: string): string {
       if (!value || value.length < 4) return '***';
       const start = value.substring(0, 2);
       const end = value.substring(value.length - 2);
       return `${start}****${end}`;
     }
   }
   ```

**代码生成提示**：
```
创建DesensitizationUtil.ets：
- desensitize方法：深拷贝数据，递归处理对象
- isSensitiveField方法：判断是否为敏感字段（idCard, phone, medicalRecordNo, realName等）
- maskValue方法：保留首尾各2位，中间用****替代
```

### 子任务8.2：创建DistributedService服务类

**描述**：创建分布式协同服务类。

**实施步骤**：
1. 在 `entry/src/main/ets/services/` 目录创建 `DistributedService.ets` 文件
2. 实现服务方法：
   ```typescript
   export class DistributedService {
     async discoverDevices(): Promise<DeviceInfo[]> { ... }
     async pairDevice(deviceId: string): Promise<boolean> { ... }
     async syncData(deviceId: string, dataTypes: string[]): Promise<SyncResult> { ... }
     async managePermission(deviceId: string, permissions: string[]): Promise<void> { ... }
   }
   ```

**代码生成提示**：
```
创建DistributedService.ets：
- discoverDevices方法：调用DistributedDeviceManager.discover发现附近设备
- pairDevice方法：发起配对请求，保存配对信息
- syncData方法：检查权限，准备数据，调用DesensitizationUtil脱敏，传输数据
- managePermission方法：更新权限配置
```

### 子任务8.3：创建DistributedCollaborationPage.ets页面

**描述**：创建分布式协同页面。

**实施步骤**：
1. 在 `entry/src/main/ets/pages/` 目录创建或更新 `DistributedCollaborationPage.ets` 文件
2. 创建页面布局：
   - 设备发现区域（扫描按钮 + 设备列表）
   - 数据同步区域（数据类型选择 + 同步按钮 + 进度显示）
   - 权限管理区域
3. 实现设备发现、配对和同步功能

**代码生成提示**：
```
创建或更新DistributedCollaborationPage.ets：
- 设备发现区域：Button('发现设备') + List显示设备列表
- 点击设备发起配对，显示配对确认对话框
- 数据同步区域：Checkbox选择数据类型（健康档案、用药记录等）
- Button('开始同步')，显示同步进度
- 权限管理区域：显示已配对设备列表，可修改权限设置
```

---

## 任务依赖关系

```
任务1 (Login) ──────┐
                    ├──→ 任务3 (HomePage)
任务2 (Register) ───┘

任务4 (AiChatPage) ────→ 独立

任务5 (ImageAnalysis) ─→ 独立

任务6 (RiskAssessment) ─→ 独立

任务7 (AncientMedicalImg) ─→ 独立

任务8 (DistributedCollab) ─→ 独立
```

**执行顺序建议**：
1. Day 1：任务1 + 任务2（P0优先级，认证基础）
2. Day 2：任务3（P0优先级，首页入口）
3. Day 3：任务4（P1优先级，AI核心）
4. Day 4：任务5（P1优先级，影像分析）
5. Day 5：任务6（P1优先级，风险评估）
6. Day 6：任务7（P2优先级，古医影像）
7. Day 7：任务8（P2优先级，分布式协同）

---

## 验收检查清单

### 功能验收

- [ ] **Login.ets**：表单验证、JWT认证、Token存储、跳转正确
- [ ] **Register.ets**：验证码倒计时、密码强度、协议确认、自动登录
- [ ] **HomePage.ets**：三断点布局、13个卡片、用户信息显示
- [ ] **AiChatPage.ets**：消息列表、Markdown渲染、打字动画、上下文保持
- [ ] **ImageAnalysisPage.ets**：影像上传、AI分析、异常标注、报告展示
- [ ] **RiskAssessmentPage.ets**：评估类型、问卷流程、结果可视化
- [ ] **AncientMedicalImgPage.ets**：处理流水线、OCR识别、标注工具
- [ ] **DistributedCollaborationPage.ets**：设备发现、数据同步、权限管理

### 性能验收

- [ ] 首页加载时间 < 2秒
- [ ] 断点切换响应 < 300ms
- [ ] AI响应时间 < 5秒
- [ ] 影像上传时间 < 15秒（10MB）
- [ ] 列表滚动帧率 ≥ 60fps

### 安全验收

- [ ] JWT Token安全存储
- [ ] HTTPS传输
- [ ] 数据脱敏正确
- [ ] 权限控制生效

---

## 附录：代码生成提示词模板

每个子任务都提供了详细的代码生成提示，可直接用于AI辅助开发。使用时请：
1. 阅读提示词内容
2. 结合技术设计文档
3. 生成对应代码
4. 根据实际项目结构调整路径和导入

---

**文档状态**：✅ 已完成
**下一步**：按照任务顺序执行实施，建议从任务1和任务2开始（P0优先级）。
