# 多端隔离医疗健康管理系统 - 技术设计文档

**版本**: v1.0
**创建日期**: 2025-01-15
**最后更新**: 2025-01-15
**作者**: System
**状态**: 草稿

## 1. 设计概述

### 1.1 设计目标

本技术设计旨在实现一个基于鸿蒙OS的多端隔离医疗健康管理系统，核心设计目标包括：

1. **多端隔离架构**：实现医生端、患者端、护士端、家属端、管理员端五个独立终端应用，确保页面级隔离但数据可共享
2. **实时通信能力**：构建高性能WebSocket通信层，支持跨端实时聊天和紧急通知
3. **智能联动机制**：实现医嘱自动联动（开药→提醒）和突发情况自动通知
4. **数据同步保障**：多设备数据实时同步，支持离线缓存和冲突解决
5. **安全合规**：满足医疗数据安全规范，实现分级权限控制和数据加密

### 1.2 技术选型

| 技术领域 | 选型方案 | 选型理由 |
|---------|---------|---------|
| **开发平台** | HarmonyOS Next | 鸿蒙原生开发框架，支持多设备协同 |
| **开发语言** | ArkTS | 鸿蒙官方语言，类型安全，性能优异 |
| **UI框架** | ArkUI | 声明式UI，支持响应式设计和状态管理 |
| **后端服务** | Node.js + Express | 高并发性能，适合实时通信场景 |
| **数据库** | MySQL + Redis + InfluxDB | 关系型+缓存+时序数据库组合 |
| **实时通信** | WebSocket + Socket.io | 全双工通信，支持房间和广播机制 |
| **消息队列** | RabbitMQ | 异步消息处理，解耦系统模块 |
| **认证方案** | JWT + 生物识别 | 无状态认证，支持指纹/面容登录 |
| **加密算法** | AES-256 + RSA-2048 | 医疗数据加密存储和传输 |
| **文件存储** | MinIO | 对象存储，支持图片、文档附件 |

### 1.3 设计约束

**技术约束**：
- 必须基于HarmonyOS Next开发，支持API Version 12及以上
- 所有代码必须使用ArkTS，禁止使用any类型
- 前端模块大小控制在300-500行代码
- 后端API响应时间<500ms（P95）

**业务约束**：
- 医疗数据存储和传输必须加密
- 患者隐私数据访问需授权验证
- 紧急通知必须保证送达，失败自动重试3次
- 电子处方需符合《电子病历应用管理规范》

**性能约束**：
- 聊天消息传输延迟<2秒
- 紧急通知推送延迟<1秒
- 数据同步延迟<3秒
- 支持1000用户并发在线

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        客户端层（五端隔离）                        │
├──────────┬──────────┬──────────┬──────────┬──────────┤
│  医生端   │  患者端   │  护士端   │  家属端   │ 管理员端  │
│  Doctor  │  Patient │  Nurse   │  Family  │  Admin   │
└──────────┴──────────┴──────────┴──────────┴──────────┘
         │           │           │           │           │
         └───────────┴───────────┴───────────┴───────────┘
                              │
                    ┌─────────▼─────────┐
                    │   API Gateway     │
                    │  (路由/限流/鉴权)  │
                    └─────────┬─────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
    ┌────▼────┐         ┌─────▼─────┐       ┌─────▼─────┐
    │  Auth   │         │  Business │       │ Notification│
    │ Service │         │  Service  │       │  Service   │
    └────┬────┘         └─────┬─────┘       └─────┬─────┘
         │                    │                    │
    ┌────▼────┐         ┌─────▼─────┐       ┌─────▼─────┐
    │  User   │         │   Chat    │       │  Emergency │
    │ Module  │         │  Module   │       │   Module   │
    └─────────┘         └───────────┘       └───────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   Data Layer      │
                    ├─────────┬─────────┤
                    │  MySQL  │  Redis  │ InfluxDB │ MinIO │
                    └─────────┴─────────┴──────────┴───────┘
```

**架构说明**：

1. **客户端层**：五个独立终端应用，页面隔离，通过统一API Gateway访问后端服务
2. **API Gateway**：统一入口，负责路由、限流、鉴权、日志记录
3. **服务层**：微服务架构，按业务领域划分（认证、业务、通知）
4. **数据层**：多数据库架构，关系型+缓存+时序+对象存储

### 2.2 模块划分

#### 2.2.1 客户端模块（五端）

```
entry/src/main/ets/
├── terminals/                    # 五端应用入口
│   ├── doctor/                   # 医生端
│   │   ├── pages/                # 医生端页面
│   │   │   ├── HomePage.ets      # 首页
│   │   │   ├── PatientListPage.ets # 患者列表
│   │   │   ├── MedicalRecordPage.ets # 病历查看
│   │   │   ├── PrescriptionPage.ets # 开处方
│   │   │   ├── ChatPage.ets      # 聊天
│   │   │   └── EmergencyPage.ets # 紧急通知
│   │   ├── viewmodels/           # 视图模型
│   │   └── DoctorEntry.ets       # 医生端入口
│   │
│   ├── patient/                  # 患者端
│   │   ├── pages/
│   │   │   ├── HomePage.ets      # 首页
│   │   │   ├── HealthMonitorPage.ets # 健康监测
│   │   │   ├── MedicationReminderPage.ets # 用药提醒
│   │   │   ├── ChatPage.ets      # 聊天
│   │   │   ├── EmergencyHelpPage.ets # 紧急求助
│   │   │   └── MedicalRecordViewPage.ets # 病历查看
│   │   ├── viewmodels/
│   │   └── PatientEntry.ets
│   │
│   ├── nurse/                    # 护士端
│   │   ├── pages/
│   │   │   ├── HomePage.ets
│   │   │   ├── PatientCareListPage.ets # 护理列表
│   │   │   ├── ChatPage.ets
│   │   │   └── EmergencyResponsePage.ets # 紧急响应
│   │   ├── viewmodels/
│   │   └── NurseEntry.ets
│   │
│   ├── family/                   # 家属端
│   │   ├── pages/
│   │   │   ├── HomePage.ets
│   │   │   ├── PatientDetailPage.ets # 患者详情
│   │   │   ├── HealthInfoSubmitPage.ets # 健康信息提交
│   │   │   ├── ChatPage.ets
│   │   │   └── EmergencyNoticePage.ets # 紧急通知
│   │   ├── viewmodels/
│   │   └── FamilyEntry.ets
│   │
│   └── admin/                    # 管理员端
│       ├── pages/
│       │   ├── DashboardPage.ets # 数据看板
│       │   ├── UserManagePage.ets # 用户管理
│       │   ├── DataAuditPage.ets # 数据审计
│       │   └── SystemMonitorPage.ets # 系统监控
│       ├── viewmodels/
│       └── AdminEntry.ets
│
├── common/                       # 公共模块
│   ├── components/               # 通用组件
│   │   ├── ChatComponent.ets     # 聊天组件
│   │   ├── NotificationComponent.ets # 通知组件
│   │   ├── EmergencyAlertComponent.ets # 紧急告警组件
│   │   └── LoadingComponent.ets  # 加载组件
│   │
│   ├── services/                 # 公共服务
│   │   ├── ApiService.ets        # API服务
│   │   ├── WebSocketService.ets  # WebSocket服务
│   │   ├── AuthService.ets       # 认证服务
│   │   ├── StorageService.ets    # 存储服务
│   │   └── SyncService.ets       # 同步服务
│   │
│   ├── models/                   # 数据模型
│   │   ├── User.ts               # 用户模型
│   │   ├── Patient.ts            # 患者模型
│   │   ├── MedicalRecord.ts      # 病历模型
│   │   ├── Prescription.ts       # 处方模型
│   │   ├── ChatMessage.ts        # 聊天消息模型
│   │   └── Notification.ts       # 通知模型
│   │
│   ├── utils/                    # 工具函数
│   │   ├── HttpUtil.ets          # HTTP工具
│   │   ├── CryptoUtil.ets        # 加密工具
│   │   ├── DateUtil.ets          # 日期工具
│   │   └── ValidatorUtil.ets     # 验证工具
│   │
│   └── constants/                # 常量定义
│       ├── ApiConstants.ets      # API常量
│       ├── RoleConstants.ets     # 角色常量
│       └── NotificationConstants.ets # 通知常量
│
└── entryability/                 # 应用入口
    └── EntryAbility.ets          # 统一入口，根据角色分发
```

#### 2.2.2 后端模块

```
server/
├── gateway/                      # API网关
│   ├── routes/                   # 路由配置
│   ├── middleware/               # 中间件
│   │   ├── authMiddleware.js     # 认证中间件
│   │   ├── rateLimitMiddleware.js # 限流中间件
│   │   └── logMiddleware.js      # 日志中间件
│   └── app.js                    # 网关入口
│
├── services/                     # 微服务
│   ├── auth-service/             # 认证服务
│   │   ├── controllers/
│   │   ├── models/
│   │   └── routes/
│   │
│   ├── user-service/             # 用户服务
│   │   ├── controllers/
│   │   ├── models/
│   │   └── routes/
│   │
│   ├── chat-service/             # 聊天服务
│   │   ├── controllers/
│   │   ├── handlers/             # WebSocket处理器
│   │   ├── models/
│   │   └── routes/
│   │
│   ├── medical-service/          # 医疗服务
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── services/             # 业务逻辑
│   │   └── routes/
│   │
│   ├── notification-service/     # 通知服务
│   │   ├── controllers/
│   │   ├── handlers/
│   │   ├── models/
│   │   └── routes/
│   │
│   └── sync-service/             # 同步服务
│       ├── controllers/
│       ├── handlers/
│       └── routes/
│
├── message-queue/                # 消息队列
│   ├── producers/                # 消息生产者
│   └── consumers/                # 消息消费者
│
└── shared/                       # 共享模块
    ├── utils/
    ├── constants/
    └── middlewares/
```

### 2.3 依赖关系

```
┌─────────────────────────────────────────┐
│           客户端依赖关系                  │
├─────────────────────────────────────────┤
│  Pages → ViewModels → Services → Models │
│  Pages → Components                     │
│  Services → Utils                       │
│  Services → Constants                   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│           后端依赖关系                    │
├─────────────────────────────────────────┤
│  Gateway → Services                     │
│  Services → MessageQueue                │
│  Services → Database                    │
│  Services → Shared                      │
└─────────────────────────────────────────┘
```

**依赖原则**：
- 单向依赖，禁止循环依赖
- 跨模块通信通过服务层或消息队列
- 客户端各端独立，不直接依赖其他端

## 3. 模块详细设计

### 3.1 认证模块（Auth Module）

#### 3.1.1 职责定义

负责用户身份认证、授权管理、Token生成和验证，实现基于角色的访问控制（RBAC）。

#### 3.1.2 接口设计

```typescript
// 认证服务接口
interface IAuthService {
  // 用户登录
  login(credentials: LoginCredentials): Promise<AuthResult>;
  
  // 用户登出
  logout(token: string): Promise<void>;
  
  // Token刷新
  refreshToken(refreshToken: string): Promise<TokenPair>;
  
  // 权限验证
  validatePermission(userId: string, resource: string, action: string): Promise<boolean>;
  
  // 生物识别认证
  biometricAuth(userId: string, biometricData: BiometricData): Promise<AuthResult>;
}

// 登录凭证
interface LoginCredentials {
  username: string;
  password: string;
  role: UserRole; // DOCTOR | PATIENT | NURSE | FAMILY | ADMIN
  deviceId: string;
}

// 认证结果
interface AuthResult {
  success: boolean;
  token?: string;
  refreshToken?: string;
  expiresIn?: number;
  user?: UserInfo;
  terminal?: TerminalType;
}

// 用户信息
interface UserInfo {
  id: string;
  name: string;
  role: UserRole;
  avatar?: string;
  permissions: Permission[];
}

// 权限定义
interface Permission {
  resource: string;
  actions: string[];
}
```

#### 3.1.3 关键方法

```typescript
// 登录流程
async login(credentials: LoginCredentials): Promise<AuthResult> {
  // 1. 验证用户名密码
  const user = await this.validateCredentials(credentials);
  
  // 2. 验证角色与终端匹配
  this.validateRoleTerminal(credentials.role, credentials.deviceId);
  
  // 3. 生成JWT Token
  const token = this.generateJWT(user);
  const refreshToken = this.generateRefreshToken(user.id);
  
  // 4. 记录登录日志
  await this.logLogin(user.id, credentials.deviceId);
  
  // 5. 返回认证结果
  return {
    success: true,
    token,
    refreshToken,
    expiresIn: 7200,
    user,
    terminal: this.getTerminalType(credentials.role)
  };
}

// 权限验证
async validatePermission(
  userId: string, 
  resource: string, 
  action: string
): Promise<boolean> {
  // 1. 获取用户角色
  const user = await this.getUserById(userId);
  
  // 2. 获取角色权限列表
  const permissions = await this.getRolePermissions(user.role);
  
  // 3. 检查权限
  const hasPermission = permissions.some(
    p => p.resource === resource && p.actions.includes(action)
  );
  
  return hasPermission;
}
```

#### 3.1.4 数据流

```
用户输入 → 登录请求 → API Gateway
    ↓
验证凭证 → 查询数据库 → 验证密码
    ↓
生成Token → JWT签名 → 返回Token
    ↓
客户端存储 → LocalStorage → 后续请求携带Token
```

### 3.2 聊天模块（Chat Module）

#### 3.2.1 职责定义

负责跨端实时聊天通信，支持文字、图片、语音消息，管理聊天会话和历史记录。

#### 3.2.2 接口设计

```typescript
// 聊天服务接口
interface IChatService {
  // 发送消息
  sendMessage(message: ChatMessage): Promise<MessageResult>;
  
  // 接收消息（WebSocket回调）
  onMessage(callback: (message: ChatMessage) => void): void;
  
  // 获取聊天历史
  getChatHistory(sessionId: string, params: QueryParams): Promise<ChatMessage[]>;
  
  // 创建聊天会话
  createSession(participants: string[]): Promise<ChatSession>;
  
  // 标记已读
  markAsRead(sessionId: string, messageId: string): Promise<void>;
  
  // 上传附件
  uploadAttachment(file: File): Promise<AttachmentInfo>;
}

// 聊天消息
interface ChatMessage {
  id: string;
  sessionId: string;
  senderId: string;
  senderRole: UserRole;
  receiverId: string;
  receiverRole: UserRole;
  content: MessageContent;
  timestamp: Date;
  status: MessageStatus; // SENDING | SENT | DELIVERED | READ
  patientId?: string; // 关联患者ID
}

// 消息内容
interface MessageContent {
  type: MessageType; // TEXT | IMAGE | VOICE | FILE
  text?: string;
  mediaUrl?: string;
  duration?: number; // 语音时长
  fileSize?: number;
  fileName?: string;
}

// 聊天会话
interface ChatSession {
  id: string;
  participants: Participant[];
  lastMessage?: ChatMessage;
  unreadCount: number;
  createdAt: Date;
  updatedAt: Date;
}

// 参与者
interface Participant {
  id: string;
  role: UserRole;
  name: string;
  avatar?: string;
}
```

#### 3.2.3 关键方法

```typescript
// 发送消息流程
async sendMessage(message: ChatMessage): Promise<MessageResult> {
  // 1. 验证发送权限
  await this.validateChatPermission(
    message.senderId, 
    message.receiverId
  );
  
  // 2. 保存消息到数据库
  const savedMessage = await this.saveMessage(message);
  
  // 3. 通过WebSocket推送消息
  await this.pushMessage(message.receiverId, savedMessage);
  
  // 4. 更新会话最后消息
  await this.updateSessionLastMessage(
    message.sessionId, 
    savedMessage
  );
  
  // 5. 发送推送通知（如果用户离线）
  if (!await this.isUserOnline(message.receiverId)) {
    await this.sendPushNotification(message.receiverId, savedMessage);
  }
  
  return { success: true, messageId: savedMessage.id };
}

// WebSocket消息处理
handleWebSocketMessage(ws: WebSocket, data: string): void {
  const message = JSON.parse(data) as ChatMessage;
  
  switch (message.type) {
    case 'SEND_MESSAGE':
      this.sendMessage(message);
      break;
    case 'MARK_READ':
      this.markAsRead(message.sessionId, message.id);
      break;
    case 'TYPING':
      this.notifyTyping(message.sessionId, message.senderId);
      break;
  }
}
```

#### 3.2.4 数据流

```
发送方 → 输入消息 → WebSocket连接
    ↓
消息验证 → 权限检查 → 保存数据库
    ↓
WebSocket推送 → 接收方WebSocket → 消息显示
    ↓
更新会话 → 更新未读数 → 通知更新
```

### 3.3 医疗服务模块（Medical Service Module）

#### 3.3.1 职责定义

负责病历管理、处方开具、诊断记录、用药提醒等核心医疗业务功能。

#### 3.3.2 接口设计

```typescript
// 医疗服务接口
interface IMedicalService {
  // 查看病历
  getMedicalRecord(patientId: string): Promise<MedicalRecord>;
  
  // 开具处方
  createPrescription(prescription: PrescriptionData): Promise<Prescription>;
  
  // 记录诊断
  recordDiagnosis(diagnosis: DiagnosisData): Promise<Diagnosis>;
  
  // 获取用药提醒
  getMedicationReminders(patientId: string): Promise<MedicationReminder[]>;
  
  // 确认服药
  confirmMedication(reminderId: string, action: MedicationAction): Promise<void>;
  
  // 提交家属健康信息
  submitFamilyHealthInfo(info: FamilyHealthInfo): Promise<void>;
}

// 病历
interface MedicalRecord {
  id: string;
  patientId: string;
  patientInfo: PatientInfo;
  medicalHistory: MedicalHistory[];
  allergies: Allergy[];
  diagnoses: Diagnosis[];
  prescriptions: Prescription[];
  testReports: TestReport[];
  surgeries: Surgery[];
  createdAt: Date;
  updatedAt: Date;
}

// 处方
interface Prescription {
  id: string;
  patientId: string;
  doctorId: string;
  medications: MedicationItem[];
  diagnosis: string;
  notes?: string;
  status: PrescriptionStatus; // ACTIVE | COMPLETED | CANCELLED
  createdAt: Date;
  validUntil: Date;
}

// 药品项
interface MedicationItem {
  name: string;
  dosage: string; // 剂量
  frequency: string; // 频次
  duration: number; // 疗程天数
  instructions: string; // 用法说明
  warnings?: string[]; // 注意事项
}

// 用药提醒
interface MedicationReminder {
  id: string;
  prescriptionId: string;
  patientId: string;
  medication: MedicationItem;
  scheduledTime: Date;
  status: ReminderStatus; // PENDING | TAKEN | SKIPPED | DELAYED
  actualTime?: Date;
  notificationId?: string;
}

// 诊断
interface Diagnosis {
  id: string;
  patientId: string;
  doctorId: string;
  symptoms: string[];
  examinationResults: string;
  diagnosis: string;
  treatmentPlan: string;
  createdAt: Date;
}
```

#### 3.3.3 关键方法

```typescript
// 开具处方流程（触发自动提醒）
async createPrescription(
  prescriptionData: PrescriptionData
): Promise<Prescription> {
  // 1. 验证医生权限
  await this.validateDoctorPermission(prescriptionData.doctorId);
  
  // 2. 验证处方合理性
  await this.validatePrescription(prescriptionData);
  
  // 3. 保存处方
  const prescription = await this.savePrescription(prescriptionData);
  
  // 4. 生成用药提醒
  const reminders = await this.generateMedicationReminders(prescription);
  
  // 5. 推送提醒到患者端
  await this.pushMedicationReminders(
    prescriptionData.patientId, 
    reminders
  );
  
  // 6. 发送消息队列事件（用于通知服务）
  await this.publishEvent('PRESCRIPTION_CREATED', prescription);
  
  return prescription;
}

// 生成用药提醒
async generateMedicationReminders(
  prescription: Prescription
): Promise<MedicationReminder[]> {
  const reminders: MedicationReminder[] = [];
  
  for (const medication of prescription.medications) {
    // 根据频次计算提醒时间
    const times = this.calculateReminderTimes(
      medication.frequency, 
      medication.duration
    );
    
    for (const time of times) {
      reminders.push({
        id: generateUUID(),
        prescriptionId: prescription.id,
        patientId: prescription.patientId,
        medication,
        scheduledTime: time,
        status: 'PENDING'
      });
    }
  }
  
  // 批量保存提醒
  await this.saveReminders(reminders);
  
  return reminders;
}

// 确认服药
async confirmMedication(
  reminderId: string, 
  action: MedicationAction
): Promise<void> {
  // 1. 更新提醒状态
  const reminder = await this.updateReminderStatus(reminderId, action);
  
  // 2. 记录服药记录
  await this.recordMedicationHistory(reminder);
  
  // 3. 同步到医生端和护士端
  await this.syncMedicationRecord(reminder);
  
  // 4. 如果是延迟服药，重新调度提醒
  if (action === 'DELAYED') {
    await this.rescheduleReminder(reminder);
  }
}
```

#### 3.3.4 数据流

```
医生开处方 → 验证处方 → 保存数据库
    ↓
生成提醒 → 计算时间 → 创建提醒记录
    ↓
推送患者端 → 显示提醒 → 定时通知
    ↓
患者确认 → 更新状态 → 同步医护端
```

### 3.4 通知模块（Notification Module）

#### 3.4.1 职责定义

负责紧急通知推送、普通消息通知、通知状态管理，支持多端同时推送和送达保证。

#### 3.4.2 接口设计

```typescript
// 通知服务接口
interface INotificationService {
  // 发送紧急通知
  sendEmergencyNotification(notification: EmergencyNotification): Promise<void>;
  
  // 发送普通通知
  sendNotification(notification: Notification): Promise<void>;
  
  // 获取通知列表
  getNotifications(userId: string, params: QueryParams): Promise<Notification[]>;
  
  // 标记通知已读
  markNotificationRead(notificationId: string): Promise<void>;
  
  // 订阅通知（WebSocket）
  subscribe(userId: string, callback: (notification: Notification) => void): void;
}

// 紧急通知
interface EmergencyNotification {
  id: string;
  type: EmergencyType; // HEALTH_ANOMALY | PATIENT_HELP | CRITICAL_ALERT
  patientId: string;
  patientName: string;
  patientLocation?: Location;
  severity: Severity; // LOW | MEDIUM | HIGH | CRITICAL
  title: string;
  content: string;
  vitalSigns?: VitalSigns; // 生命体征
  medicalSummary?: string; // 病历摘要
  recipients: NotificationRecipient[];
  createdAt: Date;
}

// 通知接收者
interface NotificationRecipient {
  userId: string;
  role: UserRole;
  status: DeliveryStatus; // PENDING | DELIVERED | READ | FAILED
  deliveredAt?: Date;
  readAt?: Date;
}

// 生命体征
interface VitalSigns {
  heartRate?: number;
  bloodPressure?: string;
  temperature?: number;
  bloodOxygen?: number;
  respiratoryRate?: number;
}

// 普通通知
interface Notification {
  id: string;
  type: NotificationType;
  receiverId: string;
  title: string;
  content: string;
  data?: Record<string, any>;
  priority: Priority; // LOW | NORMAL | HIGH
  status: NotificationStatus;
  createdAt: Date;
}
```

#### 3.4.3 关键方法

```typescript
// 发送紧急通知（多端同时推送）
async sendEmergencyNotification(
  notification: EmergencyNotification
): Promise<void> {
  // 1. 保存紧急通知
  await this.saveEmergencyNotification(notification);
  
  // 2. 并行推送给所有接收者
  const pushPromises = notification.recipients.map(recipient =>
    this.pushToRecipient(recipient, notification)
  );
  
  // 3. 等待所有推送完成
  const results = await Promise.allSettled(pushPromises);
  
  // 4. 处理推送失败（重试机制）
  for (let i = 0; i < results.length; i++) {
    if (results[i].status === 'rejected') {
      await this.retryPush(
        notification.recipients[i], 
        notification,
        3 // 重试3次
      );
    }
  }
  
  // 5. 记录推送日志
  await this.logNotificationDelivery(notification, results);
}

// 推送给接收者
async pushToRecipient(
  recipient: NotificationRecipient, 
  notification: EmergencyNotification
): Promise<void> {
  // 1. 检查用户在线状态
  const isOnline = await this.isUserOnline(recipient.userId);
  
  if (isOnline) {
    // 2a. WebSocket实时推送
    await this.pushViaWebSocket(recipient.userId, notification);
  } else {
    // 2b. 系统级推送通知
    await this.pushViaSystemNotification(recipient.userId, notification);
  }
  
  // 3. 更新送达状态
  await this.updateDeliveryStatus(
    notification.id, 
    recipient.userId, 
    'DELIVERED'
  );
}

// 重试推送
async retryPush(
  recipient: NotificationRecipient,
  notification: EmergencyNotification,
  maxRetries: number
): Promise<void> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await this.pushToRecipient(recipient, notification);
      return; // 成功则退出
    } catch (error) {
      if (i === maxRetries - 1) {
        // 最后一次重试失败，记录错误
        await this.logPushFailure(recipient, notification, error);
      } else {
        // 等待后重试
        await this.sleep(1000 * (i + 1));
      }
    }
  }
}
```

#### 3.4.4 数据流

```
触发紧急事件 → 创建紧急通知 → 保存数据库
    ↓
查询接收者 → 护士+医生+家属 → 并行推送
    ↓
WebSocket推送 → 实时送达 → 显示告警
    ↓
推送失败 → 重试机制 → 保证送达
    ↓
记录日志 → 更新状态 → 审计追踪
```

### 3.5 同步模块（Sync Module）

#### 3.5.1 职责定义

负责多设备数据同步、离线数据管理、冲突解决，保证数据一致性。

#### 3.5.2 接口设计

```typescript
// 同步服务接口
interface ISyncService {
  // 同步数据
  syncData(syncRequest: SyncRequest): Promise<SyncResult>;
  
  // 获取离线数据
  getOfflineData(userId: string, dataType: string): Promise<any[]>;
  
  // 上传离线变更
  uploadOfflineChanges(changes: DataChange[]): Promise<void>;
  
  // 解决冲突
  resolveConflict(conflict: SyncConflict): Promise<void>;
  
  // 订阅数据变更
  subscribeDataChange(
    userId: string, 
    dataType: string, 
    callback: (change: DataChange) => void
  ): void;
}

// 同步请求
interface SyncRequest {
  userId: string;
  deviceId: string;
  dataType: string;
  lastSyncTime: Date;
  clientChanges?: DataChange[];
}

// 数据变更
interface DataChange {
  id: string;
  dataType: string;
  dataId: string;
  operation: Operation; // CREATE | UPDATE | DELETE
  data: any;
  timestamp: Date;
  deviceId: string;
}

// 同步结果
interface SyncResult {
  success: boolean;
  serverChanges: DataChange[];
  syncTime: Date;
  conflicts?: SyncConflict[];
}

// 同步冲突
interface SyncConflict {
  id: string;
  dataType: string;
  dataId: string;
  clientData: any;
  serverData: any;
  resolution: ConflictResolution; // CLIENT_WINS | SERVER_WINS | MERGE
}
```

#### 3.5.3 关键方法

```typescript
// 数据同步流程
async syncData(syncRequest: SyncRequest): Promise<SyncResult> {
  // 1. 获取服务端变更
  const serverChanges = await this.getServerChanges(
    syncRequest.userId,
    syncRequest.dataType,
    syncRequest.lastSyncTime
  );
  
  // 2. 上传客户端变更
  const conflicts: SyncConflict[] = [];
  if (syncRequest.clientChanges) {
    for (const change of syncRequest.clientChanges) {
      const conflict = await this.applyClientChange(change);
      if (conflict) {
        conflicts.push(conflict);
      }
    }
  }
  
  // 3. 解决冲突
  for (const conflict of conflicts) {
    await this.resolveConflict(conflict);
  }
  
  // 4. 更新同步时间
  const syncTime = new Date();
  await this.updateSyncTime(
    syncRequest.userId,
    syncRequest.deviceId,
    syncTime
  );
  
  return {
    success: true,
    serverChanges,
    syncTime,
    conflicts
  };
}

// 应用客户端变更
async applyClientChange(change: DataChange): Promise<SyncConflict | null> {
  // 1. 检查冲突
  const serverData = await this.getData(change.dataType, change.dataId);
  
  if (serverData && serverData.updatedAt > change.timestamp) {
    // 2. 存在冲突，返回冲突信息
    return {
      id: generateUUID(),
      dataType: change.dataType,
      dataId: change.dataId,
      clientData: change.data,
      serverData,
      resolution: 'SERVER_WINS' // 默认服务端优先
    };
  }
  
  // 3. 无冲突，应用变更
  await this.applyChange(change);
  return null;
}
```

#### 3.5.4 数据流

```
客户端请求同步 → 发送最后同步时间 → 服务端查询变更
    ↓
返回服务端变更 → 客户端应用变更 → 上传客户端变更
    ↓
检测冲突 → 解决冲突 → 更新数据
    ↓
返回同步结果 → 客户端更新同步时间 → 完成同步
```

## 4. 数据模型设计

### 4.1 核心数据结构

```typescript
// 用户基类
interface User {
  id: string;
  username: string;
  password: string; // 加密存储
  name: string;
  role: UserRole;
  phone: string;
  email?: string;
  avatar?: string;
  status: UserStatus; // ACTIVE | INACTIVE | DISABLED
  createdAt: Date;
  updatedAt: Date;
}

// 患者
interface Patient extends User {
  role: 'PATIENT';
  idNumber: string; // 身份证号（加密）
  dateOfBirth: Date;
  gender: Gender;
  bloodType?: string;
  emergencyContact: EmergencyContact;
  medicalRecordId: string;
  deviceIds: string[]; // 绑定设备
}

// 医生
interface Doctor extends User {
  role: 'DOCTOR';
  employeeId: string;
  department: string;
  title: string; // 职称
  specialization?: string;
  schedule?: DoctorSchedule[];
}

// 护士
interface Nurse extends User {
  role: 'NURSE';
  employeeId: string;
  department: string;
  ward?: string; // 负责病区
  patients?: string[]; // 负责患者ID列表
}

// 家属
interface Family extends User {
  role: 'FAMILY';
  relatedPatients: FamilyPatientRelation[];
}

// 家属-患者关系
interface FamilyPatientRelation {
  patientId: string;
  relationship: string; // 关系：父子、配偶等
  authorizationLevel: number; // 授权等级1-3
  authorizedAt: Date;
}

// 管理员
interface Admin extends User {
  role: 'ADMIN';
  permissions: string[];
  department?: string;
}

// 病历
interface MedicalRecord {
  id: string;
  patientId: string;
  
  // 基本信息
  basicInfo: {
    height?: number;
    weight?: number;
    bloodType?: string;
    allergies: Allergy[];
  };
  
  // 既往病史
  medicalHistory: {
    disease: string;
    diagnosedAt: Date;
    status: string;
    notes?: string;
  }[];
  
  // 诊断记录
  diagnoses: Diagnosis[];
  
  // 处方记录
  prescriptions: Prescription[];
  
  // 检查报告
  testReports: TestReport[];
  
  // 手术记录
  surgeries: Surgery[];
  
  // 家属健康信息
  familyHealthInfo: FamilyHealthInfo[];
  
  createdAt: Date;
  updatedAt: Date;
}

// 过敏信息
interface Allergy {
  allergen: string; // 过敏原
  reaction: string; // 反应
  severity: 'MILD' | 'MODERATE' | 'SEVERE';
}

// 检查报告
interface TestReport {
  id: string;
  type: string; // 检查类型
  result: string;
  attachmentUrl?: string;
  conductedAt: Date;
  doctorId: string;
}

// 手术记录
interface Surgery {
  id: string;
  name: string;
  date: Date;
  surgeon: string;
  notes?: string;
}

// 家属健康信息
interface FamilyHealthInfo {
  id: string;
  familyMemberId: string;
  type: string; // 症状描述、检查报告、家族病史
  content: string;
  attachments?: string[];
  submittedAt: Date;
}

// 聊天会话
interface ChatSession {
  id: string;
  type: SessionType; // PRIVATE | GROUP
  participants: {
    userId: string;
    role: UserRole;
    joinedAt: Date;
    lastReadAt: Date;
  }[];
  lastMessage?: {
    content: string;
    senderId: string;
    timestamp: Date;
  };
  relatedPatientId?: string; // 关联患者
  createdAt: Date;
  updatedAt: Date;
}

// 聊天消息
interface ChatMessage {
  id: string;
  sessionId: string;
  senderId: string;
  senderRole: UserRole;
  content: {
    type: MessageType;
    text?: string;
    mediaUrl?: string;
    duration?: number;
    fileSize?: number;
    fileName?: string;
  };
  replyTo?: string; // 回复消息ID
  status: MessageStatus;
  timestamp: Date;
}

// 通知
interface Notification {
  id: string;
  type: NotificationType;
  receiverId: string;
  receiverRole: UserRole;
  title: string;
  content: string;
  data?: Record<string, any>;
  priority: Priority;
  status: NotificationStatus;
  readAt?: Date;
  createdAt: Date;
}

// 紧急通知
interface EmergencyNotification {
  id: string;
  type: EmergencyType;
  patientId: string;
  patientName: string;
  patientLocation?: {
    latitude: number;
    longitude: number;
    address: string;
  };
  severity: Severity;
  title: string;
  content: string;
  vitalSigns?: VitalSigns;
  medicalSummary?: string;
  recipients: {
    userId: string;
    role: UserRole;
    status: DeliveryStatus;
    deliveredAt?: Date;
    readAt?: Date;
  }[];
  handledBy?: string;
  handledAt?: Date;
  createdAt: Date;
}

// 用药提醒
interface MedicationReminder {
  id: string;
  prescriptionId: string;
  patientId: string;
  medication: {
    name: string;
    dosage: string;
    instructions: string;
    warnings?: string[];
  };
  scheduledTime: Date;
  status: ReminderStatus;
  actualTime?: Date;
  action?: MedicationAction;
  notificationId?: string;
  createdAt: Date;
}

// 健康数据（时序数据）
interface HealthData {
  id: string;
  patientId: string;
  type: HealthDataType; // HEART_RATE | BLOOD_PRESSURE | TEMPERATURE | BLOOD_OXYGEN
  value: number;
  unit: string;
  deviceId?: string;
  timestamp: Date;
  isAbnormal: boolean;
}

// 设备
interface Device {
  id: string;
  userId: string;
  type: DeviceType; // PHONE | TABLET | WATCH
  name: string;
  os: string;
  osVersion: string;
  pushToken?: string;
  lastActiveAt: Date;
  createdAt: Date;
}
```

### 4.2 数据关系（ER图）

```
┌─────────────┐         ┌─────────────┐
│    User     │─────────│   Patient   │
└─────────────┘         └─────────────┘
      │                        │
      │                        │
      ├────────────────────────┤
      │                        │
      │                  ┌─────▼─────┐
      │                  │  Medical  │
      │                  │  Record   │
      │                  └─────┬─────┘
      │                        │
      │            ┌───────────┼───────────┐
      │            │           │           │
      │      ┌─────▼─────┐ ┌───▼───┐ ┌─────▼─────┐
      │      │Prescription│ │Diagnosis│ │TestReport│
      │      └─────┬─────┘ └───────┘ └───────────┘
      │            │
      │      ┌─────▼─────┐
      │      │ Medication│
      │      │  Reminder │
      │      └───────────┘
      │
      ├──────────────────────────┐
      │                          │
┌─────▼─────┐              ┌─────▼─────┐
│ChatSession│──────────────│ChatMessage│
└───────────┘              └───────────┘
      │
      │
┌─────▼─────┐
│Notification│
└───────────┘
```

### 4.3 数据存储

#### 4.3.1 MySQL（关系型数据）

**存储内容**：用户数据、病历数据、处方数据、诊断数据、聊天会话

**表设计**：
- `users` - 用户表
- `patients` - 患者表
- `doctors` - 医生表
- `nurses` - 护士表
- `families` - 家属表
- `admins` - 管理员表
- `medical_records` - 病历表
- `prescriptions` - 处方表
- `diagnoses` - 诊断表
- `chat_sessions` - 聊天会话表
- `chat_messages` - 聊天消息表
- `notifications` - 通知表
- `emergency_notifications` - 紧急通知表
- `medication_reminders` - 用药提醒表

**索引策略**：
- 用户表：`username`（唯一索引）、`role`（普通索引）
- 病历表：`patient_id`（索引）、`created_at`（索引）
- 聊天消息表：`session_id, timestamp`（复合索引）
- 通知表：`receiver_id, status, created_at`（复合索引）

#### 4.3.2 Redis（缓存）

**存储内容**：
- 用户Session和Token
- 在线用户状态
- WebSocket连接映射
- 聊天会话缓存
- 实时数据缓存

**数据结构**：
```
// 用户Token
user:token:{userId} -> {token, refreshToken, expiresIn}

// 在线状态
user:online:{userId} -> {deviceId, lastActiveAt}

// WebSocket连接
ws:connection:{userId} -> {socketId, deviceId}

// 聊天会话缓存
chat:session:{sessionId} -> {participants, lastMessage}

// 未读消息数
chat:unread:{userId}:{sessionId} -> count
```

#### 4.3.3 InfluxDB（时序数据）

**存储内容**：
- 健康监测数据（心率、血压、体温等）
- 系统性能指标
- 用户行为日志

**Measurement设计**：
- `health_data` - 健康数据
  - tags: `patient_id`, `type`, `device_id`
  - fields: `value`, `is_abnormal`
  - timestamp: 测量时间

- `system_metrics` - 系统指标
  - tags: `service`, `endpoint`
  - fields: `response_time`, `status_code`
  - timestamp: 请求时间

#### 4.3.4 MinIO（对象存储）

**存储内容**：
- 聊天附件（图片、语音、文件）
- 检查报告附件
- 用户头像

**Bucket设计**：
- `chat-attachments` - 聊天附件
- `medical-reports` - 医疗报告
- `user-avatars` - 用户头像

**访问策略**：
- 生成临时访问URL（有效期1小时）
- 支持断点续传
- 自动清理过期文件

## 5. API设计

### 5.1 内部API（模块间接口）

#### 5.1.1 认证API

```typescript
// POST /api/auth/login
// 用户登录
Request:
{
  "username": "string",
  "password": "string",
  "role": "DOCTOR | PATIENT | NURSE | FAMILY | ADMIN",
  "deviceId": "string"
}
Response:
{
  "success": true,
  "token": "string",
  "refreshToken": "string",
  "expiresIn": 7200,
  "user": {
    "id": "string",
    "name": "string",
    "role": "string",
    "avatar": "string",
    "permissions": []
  }
}

// POST /api/auth/logout
// 用户登出
Request:
{
  "token": "string"
}
Response:
{
  "success": true
}

// POST /api/auth/refresh
// 刷新Token
Request:
{
  "refreshToken": "string"
}
Response:
{
  "token": "string",
  "refreshToken": "string",
  "expiresIn": 7200
}

// POST /api/auth/biometric
// 生物识别认证
Request:
{
  "userId": "string",
  "biometricType": "FINGERPRINT | FACE",
  "biometricData": "string"
}
Response:
{
  "success": true,
  "token": "string"
}
```

#### 5.1.2 聊天API

```typescript
// WebSocket /ws/chat
// 聊天WebSocket连接
Message Types:
{
  "type": "SEND_MESSAGE",
  "data": {
    "sessionId": "string",
    "receiverId": "string",
    "content": {
      "type": "TEXT | IMAGE | VOICE",
      "text": "string",
      "mediaUrl": "string"
    }
  }
}

{
  "type": "MESSAGE_RECEIVED",
  "data": {
    "messageId": "string",
    "sessionId": "string",
    "senderId": "string",
    "content": {},
    "timestamp": "Date"
  }
}

{
  "type": "MARK_READ",
  "data": {
    "sessionId": "string",
    "messageId": "string"
  }
}

{
  "type": "TYPING",
  "data": {
    "sessionId": "string",
    "isTyping": true
  }
}

// GET /api/chat/sessions
// 获取聊天会话列表
Query: {
  "userId": "string",
  "page": 1,
  "limit": 20
}
Response: {
  "sessions": [
    {
      "id": "string",
      "participants": [],
      "lastMessage": {},
      "unreadCount": 0
    }
  ],
  "total": 100
}

// GET /api/chat/messages/:sessionId
// 获取聊天历史
Query: {
  "before": "Date",
  "limit": 50
}
Response: {
  "messages": [],
  "hasMore": true
}

// POST /api/chat/upload
// 上传聊天附件
Request: FormData {
  "file": File,
  "type": "IMAGE | VOICE | FILE"
}
Response: {
  "url": "string",
  "fileSize": 1024,
  "duration": 10
}
```

#### 5.1.3 医疗API

```typescript
// GET /api/medical/records/:patientId
// 获取患者病历
Response:
{
  "id": "string",
  "patientId": "string",
  "basicInfo": {},
  "medicalHistory": [],
  "allergies": [],
  "diagnoses": [],
  "prescriptions": [],
  "testReports": []
}

// POST /api/medical/prescriptions
// 开具处方
Request:
{
  "patientId": "string",
  "doctorId": "string",
  "medications": [
    {
      "name": "string",
      "dosage": "string",
      "frequency": "string",
      "duration": 7,
      "instructions": "string",
      "warnings": []
    }
  ],
  "diagnosis": "string",
  "notes": "string"
}
Response:
{
  "id": "string",
  "status": "ACTIVE",
  "reminders": []
}

// POST /api/medical/diagnoses
// 记录诊断
Request:
{
  "patientId": "string",
  "doctorId": "string",
  "symptoms": [],
  "examinationResults": "string",
  "diagnosis": "string",
  "treatmentPlan": "string"
}
Response:
{
  "id": "string",
  "createdAt": "Date"
}

// GET /api/medical/reminders/:patientId
// 获取用药提醒
Response:
{
  "reminders": [
    {
      "id": "string",
      "medication": {},
      "scheduledTime": "Date",
      "status": "PENDING"
    }
  ]
}

// POST /api/medical/reminders/:reminderId/confirm
// 确认服药
Request:
{
  "action": "TAKEN | SKIPPED | DELAYED",
  "delayMinutes": 30
}
Response:
{
  "success": true
}

// POST /api/medical/family-health
// 提交家属健康信息
Request:
{
  "patientId": "string",
  "familyMemberId": "string",
  "type": "string",
  "content": "string",
  "attachments": []
}
Response:
{
  "success": true
}
```

#### 5.1.4 通知API

```typescript
// WebSocket /ws/notification
// 通知WebSocket连接
Message Types:
{
  "type": "SUBSCRIBE",
  "data": {
    "userId": "string"
  }
}

{
  "type": "NOTIFICATION",
  "data": {
    "id": "string",
    "type": "string",
    "title": "string",
    "content": "string",
    "priority": "HIGH",
    "data": {}
  }
}

{
  "type": "EMERGENCY",
  "data": {
    "id": "string",
    "patientId": "string",
    "patientName": "string",
    "severity": "CRITICAL",
    "title": "string",
    "content": "string",
    "vitalSigns": {},
    "medicalSummary": "string"
  }
}

// GET /api/notifications
// 获取通知列表
Query: {
  "userId": "string",
  "type": "string",
  "status": "UNREAD",
  "page": 1,
  "limit": 20
}
Response: {
  "notifications": [],
  "total": 50
}

// POST /api/notifications/:id/read
// 标记已读
Response: {
  "success": true
}

// POST /api/notifications/emergency
// 触发紧急通知
Request:
{
  "type": "HEALTH_ANOMALY | PATIENT_HELP",
  "patientId": "string",
  "severity": "HIGH",
  "content": "string",
  "vitalSigns": {}
}
Response: {
  "id": "string",
  "recipients": []
}
```

#### 5.1.5 同步API

```typescript
// POST /api/sync
// 数据同步
Request:
{
  "userId": "string",
  "deviceId": "string",
  "dataType": "string",
  "lastSyncTime": "Date",
  "clientChanges": []
}
Response:
{
  "success": true,
  "serverChanges": [],
  "syncTime": "Date",
  "conflicts": []
}

// GET /api/sync/offline/:dataType
// 获取离线数据
Query: {
  "userId": "string"
}
Response: {
  "data": []
}

// POST /api/sync/conflicts/:conflictId/resolve
// 解决冲突
Request:
{
  "resolution": "CLIENT_WINS | SERVER_WINS | MERGE",
  "mergedData": {}
}
Response: {
  "success": true
}
```

### 5.2 外部API

#### 5.2.1 健康设备接入API

```typescript
// MQTT Topic: health/device/{deviceId}/data
// 健康设备数据上报
Message:
{
  "patientId": "string",
  "type": "HEART_RATE | BLOOD_PRESSURE | TEMPERATURE",
  "value": 75,
  "unit": "bpm",
  "timestamp": "Date",
  "deviceInfo": {
    "manufacturer": "string",
    "model": "string"
  }
}

// POST /api/devices/bind
// 绑定健康设备
Request:
{
  "patientId": "string",
  "deviceId": "string",
  "deviceType": "WATCH | BLOOD_PRESSURE_MONITOR",
  "deviceName": "string"
}
Response:
{
  "success": true
}
```

#### 5.2.2 HIS系统对接API（可选）

```typescript
// POST /api/his/sync/patient
// 同步患者信息
Request:
{
  "patientId": "string",
  "hisPatientId": "string"
}
Response:
{
  "success": true,
  "syncedData": []
}

// GET /api/his/records/:hisPatientId
// 查询HIS病历
Response:
{
  "records": []
}
```

### 5.3 API规范

#### 5.3.1 请求格式

```typescript
// 统一请求头
Headers: {
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json",
  "X-Device-ID": "string",
  "X-Request-ID": "string"
}

// 统一查询参数
Query: {
  "page": 1,
  "limit": 20,
  "sort": "createdAt",
  "order": "desc"
}
```

#### 5.3.2 响应格式

```typescript
// 成功响应
{
  "success": true,
  "data": {},
  "message": "操作成功"
}

// 错误响应
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": {}
  }
}

// 分页响应
{
  "success": true,
  "data": [],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

#### 5.3.3 错误码定义

```typescript
enum ErrorCode {
  // 认证错误 1xxx
  AUTH_INVALID_CREDENTIALS = 1001,
  AUTH_TOKEN_EXPIRED = 1002,
  AUTH_PERMISSION_DENIED = 1003,
  
  // 用户错误 2xxx
  USER_NOT_FOUND = 2001,
  USER_ALREADY_EXISTS = 2002,
  USER_INVALID_ROLE = 2003,
  
  // 医疗错误 3xxx
  MEDICAL_RECORD_NOT_FOUND = 3001,
  PRESCRIPTION_INVALID = 3002,
  PATIENT_NOT_AUTHORIZED = 3003,
  
  // 聊天错误 4xxx
  CHAT_SESSION_NOT_FOUND = 4001,
  CHAT_PERMISSION_DENIED = 4002,
  
  // 通知错误 5xxx
  NOTIFICATION_SEND_FAILED = 5001,
  EMERGENCY_HANDLER_NOT_FOUND = 5002,
  
  // 系统错误 9xxx
  SYSTEM_INTERNAL_ERROR = 9001,
  SYSTEM_DATABASE_ERROR = 9002,
  SYSTEM_NETWORK_ERROR = 9003
}
```

## 6. 关键算法设计

### 6.1 用药提醒时间计算算法

#### 算法原理

根据处方中的用药频次（如"一日三次"、"每8小时一次"）和疗程周期，计算所有提醒时间点。

#### 伪代码

```
算法: calculateReminderTimes(frequency, duration, startTime)
输入: frequency - 用药频次字符串
      duration - 疗程天数
      startTime - 开始时间
输出: times - 提醒时间数组

1. 解析频次:
   if frequency contains "一日一次":
     timesPerDay = 1
     defaultHours = [8]
   else if frequency contains "一日两次":
     timesPerDay = 2
     defaultHours = [8, 20]
   else if frequency contains "一日三次":
     timesPerDay = 3
     defaultHours = [8, 12, 18]
   else if frequency contains "每N小时":
     interval = extractNumber(frequency)
     timesPerDay = 24 / interval
     defaultHours = [0, interval, 2*interval, ...]

2. 生成提醒时间:
   times = []
   for day from 0 to duration-1:
     for hour in defaultHours:
       reminderTime = startTime + day天 + hour小时
       times.append(reminderTime)

3. 返回 times
```

#### 复杂度分析

- 时间复杂度：O(duration × timesPerDay)
- 空间复杂度：O(duration × timesPerDay)

### 6.2 紧急通知路由算法

#### 算法原理

根据患者信息和紧急类型，确定通知接收者列表，优先级排序，并选择最佳通知渠道。

#### 伪代码

```
算法: routeEmergencyNotification(patientId, emergencyType, severity)
输入: patientId - 患者ID
      emergencyType - 紧急类型
      severity - 严重程度
输出: recipients - 接收者列表

1. 查询患者关联人员:
   patient = getPatient(patientId)
   
   // 负责护士
   nurses = getAssignedNurses(patientId)
   
   // 主治医生
   doctors = getAttendingDoctors(patientId)
   
   // 授权家属
   families = getAuthorizedFamilies(patientId)

2. 根据严重程度过滤:
   if severity == "CRITICAL":
     // 所有人都通知
     recipients = nurses + doctors + families
   else if severity == "HIGH":
     // 护士和医生
     recipients = nurses + doctors
   else:
     // 仅护士
     recipients = nurses

3. 优先级排序:
   recipients.sort((a, b) => {
     // 医生优先
     if a.role == "DOCTOR" and b.role != "DOCTOR": return -1
     // 护士次之
     if a.role == "NURSE" and b.role == "FAMILY": return -1
     // 在线优先
     if isOnline(a) and !isOnline(b): return -1
     return 0
   })

4. 返回 recipients
```

#### 复杂度分析

- 时间复杂度：O(n log n)，n为关联人员数量
- 空间复杂度：O(n)

### 6.3 数据同步冲突检测算法

#### 算法原理

比较客户端数据和服务端数据的时间戳，检测是否存在冲突，并根据业务规则自动解决或标记冲突。

#### 伪代码

```
算法: detectConflict(clientChange, serverData)
输入: clientChange - 客户端变更
      serverData - 服务端数据
输出: conflict - 冲突信息或null

1. 检查数据是否存在:
   if serverData == null:
     // 服务端无数据，无冲突
     return null

2. 比较时间戳:
   if clientChange.timestamp > serverData.updatedAt:
     // 客户端更新，无冲突
     return null
   
   if clientChange.timestamp < serverData.updatedAt:
     // 服务端已更新，存在冲突
     return createConflict(clientChange, serverData)

3. 检查内容是否相同:
   if isEqual(clientChange.data, serverData.data):
     // 内容相同，无冲突
     return null
   
   // 内容不同，存在冲突
   return createConflict(clientChange, serverData)


算法: resolveConflict(conflict, strategy)
输入: conflict - 冲突信息
      strategy - 解决策略
输出: resolvedData - 解决后的数据

1. 根据策略解决:
   switch strategy:
     case "CLIENT_WINS":
       return conflict.clientData
     case "SERVER_WINS":
       return conflict.serverData
     case "MERGE":
       // 字段级合并
       return mergeData(conflict.clientData, conflict.serverData)

2. 记录冲突解决日志:
   logConflictResolution(conflict, strategy)

3. 返回 resolvedData
```

#### 复杂度分析

- 时间复杂度：O(m)，m为数据字段数量
- 空间复杂度：O(m)

## 7. UI/UX设计

### 7.1 页面结构

#### 7.1.1 医生端页面结构

```
医生端
├── 首页（HomePage）
│   ├── 今日待诊患者列表
│   ├── 紧急通知入口
│   └── 快捷功能入口
│
├── 患者管理（PatientListPage）
│   ├── 患者搜索
│   ├── 患者列表
│   └── 患者详情入口
│
├── 病历查看（MedicalRecordPage）
│   ├── 患者基本信息
│   ├── 既往病史
│   ├── 过敏史
│   ├── 检查报告
│   ├── 历史处方
│   └── 诊断记录
│
├── 开处方（PrescriptionPage）
│   ├── 患者选择
│   ├── 诊断输入
│   ├── 药品选择
│   ├── 用法用量设置
│   └── 处方提交
│
├── 聊天（ChatPage）
│   ├── 会话列表
│   ├── 聊天界面
│   └── 患者信息侧栏
│
└── 紧急通知（EmergencyPage）
    ├── 紧急事件列表
    ├── 事件详情
    └── 处理记录
```

#### 7.1.2 患者端页面结构

```
患者端
├── 首页（HomePage）
│   ├── 健康概览
│   ├── 今日用药提醒
│   ├── 紧急求助按钮
│   └── 快捷功能入口
│
├── 健康监测（HealthMonitorPage）
│   ├── 实时健康数据
│   ├── 历史趋势图表
│   └── 异常告警
│
├── 用药提醒（MedicationReminderPage）
│   ├── 今日提醒列表
│   ├── 提醒详情
│   ├── 确认服药
│   └── 用药历史
│
├── 病历查看（MedicalRecordViewPage）
│   ├── 就医记录
│   ├── 检查报告
│   └── 处方记录
│
├── 聊天（ChatPage）
│   ├── 会话列表
│   └── 聊天界面
│
└── 紧急求助（EmergencyHelpPage）
    ├── 一键求助
    ├── 求助记录
    └── 联系方式
```

#### 7.1.3 护士端页面结构

```
护士端
├── 首页（HomePage）
│   ├── 护理任务列表
│   ├── 紧急通知入口
│   └── 今日工作概览
│
├── 护理列表（PatientCareListPage）
│   ├── 负责患者列表
│   ├── 护理任务
│   └── 患者状态
│
├── 聊天（ChatPage）
│   ├── 会话列表
│   └── 聊天界面
│
└── 紧急响应（EmergencyResponsePage）
    ├── 紧急事件列表
    ├── 事件详情
    └── 响应处理
```

#### 7.1.4 家属端页面结构

```
家属端
├── 首页（HomePage）
│   ├── 关联患者列表
│   ├── 紧急通知入口
│   └── 快捷功能入口
│
├── 患者详情（PatientDetailPage）
│   ├── 患者健康状态
│   ├── 就医记录
│   ├── 用药情况
│   └── 医生诊断
│
├── 健康信息提交（HealthInfoSubmitPage）
│   ├── 信息类型选择
│   ├── 内容输入
│   ├── 附件上传
│   └── 提交确认
│
├── 聊天（ChatPage）
│   ├── 会话列表
│   └── 聊天界面
│
└── 紧急通知（EmergencyNoticePage）
    ├── 紧急事件列表
    └── 事件详情
```

#### 7.1.5 管理员端页面结构

```
管理员端
├── 数据看板（DashboardPage）
│   ├── 用户统计
│   ├── 活跃度分析
│   ├── 消息量统计
│   └── 异常事件统计
│
├── 用户管理（UserManagePage）
│   ├── 用户列表
│   ├── 用户详情
│   ├── 权限管理
│   └── 操作日志
│
├── 数据审计（DataAuditPage）
│   ├── 数据访问记录
│   ├── 敏感操作日志
│   └── 数据脱敏设置
│
└── 系统监控（SystemMonitorPage）
    ├── 服务状态
    ├── 性能指标
    └── 告警配置
```

### 7.2 组件设计

#### 7.2.1 通用组件

```typescript
// 聊天组件（ChatComponent）
@Component
struct ChatComponent {
  @Prop sessionId: string;
  @Prop currentUserId: string;
  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  
  // 发送消息
  sendMessage(): void;
  
  // 上传图片
  uploadImage(): void;
  
  // 录制语音
  recordVoice(): void;
  
  // 滚动到底部
  scrollToBottom(): void;
}

// 通知组件（NotificationComponent）
@Component
struct NotificationComponent {
  @Prop notification: Notification;
  @State isRead: boolean = false;
  
  // 标记已读
  markAsRead(): void;
  
  // 执行动作
  executeAction(): void;
}

// 紧急告警组件（EmergencyAlertComponent）
@Component
struct EmergencyAlertComponent {
  @Prop emergency: EmergencyNotification;
  @State isHandling: boolean = false;
  
  // 显示详情
  showDetails(): void;
  
  // 处理事件
  handleEmergency(): void;
  
  // 播放告警音
  playAlertSound(): void;
}

// 用药提醒组件（MedicationReminderComponent）
@Component
struct MedicationReminderComponent {
  @Prop reminder: MedicationReminder;
  @State action: MedicationAction = 'PENDING';
  
  // 确认服药
  confirmTaken(): void;
  
  // 延迟服药
  delayMedication(): void;
  
  // 跳过服药
  skipMedication(): void;
}

// 健康数据图表组件（HealthChartComponent）
@Component
struct HealthChartComponent {
  @Prop dataType: HealthDataType;
  @Prop data: HealthData[];
  @Prop timeRange: TimeRange;
  
  // 渲染图表
  renderChart(): void;
  
  // 切换时间范围
  changeTimeRange(): void;
}
```

#### 7.2.2 组件属性定义

```typescript
// 聊天组件属性
interface ChatComponentProps {
  sessionId: string;          // 会话ID
  currentUserId: string;      // 当前用户ID
  placeholder?: string;       // 输入框占位符
  enableVoice?: boolean;      // 是否启用语音
  enableImage?: boolean;      // 是否启用图片
  maxHeight?: number;         // 最大高度
}

// 通知组件属性
interface NotificationComponentProps {
  notification: Notification;  // 通知对象
  showActions?: boolean;      // 是否显示操作按钮
  autoRead?: boolean;         // 是否自动标记已读
  onClick?: () => void;       // 点击回调
}

// 紧急告警组件属性
interface EmergencyAlertComponentProps {
  emergency: EmergencyNotification;  // 紧急通知对象
  autoPlay?: boolean;         // 是否自动播放告警音
  showLocation?: boolean;     // 是否显示位置
  onHandle?: () => void;      // 处理回调
}

// 用药提醒组件属性
interface MedicationReminderComponentProps {
  reminder: MedicationReminder;  // 提醒对象
  showDetails?: boolean;      // 是否显示详情
  enableDelay?: boolean;      // 是否允许延迟
  onConfirm?: () => void;     // 确认回调
}
```

### 7.3 交互流程

#### 7.3.1 医生开处方流程

```
┌──────────┐
│ 选择患者  │
└─────┬────┘
      │
┌─────▼────┐
│ 查看病历  │
└─────┬────┘
      │
┌─────▼────┐
│ 输入诊断  │
└─────┬────┘
      │
┌─────▼────┐
│ 选择药品  │
└─────┬────┘
      │
┌─────▼────┐
│ 设置用法  │
└─────┬────┘
      │
┌─────▼────┐
│ 提交处方  │
└─────┬────┘
      │
┌─────▼────┐
│ 确认提交  │──→ 患者端收到提醒
└──────────┘
```

#### 7.3.2 患者紧急求助流程

```
┌──────────┐
│ 点击求助  │
└─────┬────┘
      │
┌─────▼────┐
│ 确认求助  │
└─────┬────┘
      │
┌─────▼────┐
│ 发送请求  │──→ 护士端收到通知
│          │──→ 医生端收到通知
│          │──→ 家属端收到通知
└─────┬────┘
      │
┌─────▼────┐
│ 等待响应  │
└─────┬────┘
      │
┌─────▼────┐
│ 收到响应  │
└──────────┘
```

#### 7.3.3 跨端聊天流程

```
┌──────────┐
│ 打开聊天  │
└─────┬────┘
      │
┌─────▼────┐
│ 选择联系人│
└─────┬────┘
      │
┌─────▼────┐
│ 加载历史  │
└─────┬────┘
      │
┌─────▼────┐
│ 输入消息  │
└─────┬────┘
      │
┌─────▼────┐
│ 发送消息  │──→ WebSocket推送
└─────┬────┘
      │
┌─────▼────┐
│ 显示已发送│
└─────┬────┘
      │
┌─────▼────┐
│ 对方已读  │──→ 更新已读状态
└──────────┘
```

## 8. 性能设计

### 8.1 性能目标

| 性能指标 | 目标值 | 测量方法 |
|---------|--------|---------|
| 聊天消息传输延迟 | < 2秒 | 消息发送到接收的时间差 |
| 紧急通知推送延迟 | < 1秒 | 事件触发到各端收到通知的时间 |
| 数据同步延迟 | < 3秒 | 数据变更到同步完成的时间 |
| API响应时间（P95） | < 500ms | API请求到响应的时间 |
| 首屏加载时间 | < 3秒 | 应用启动到首屏渲染完成 |
| 交互响应时间 | < 300ms | 用户操作到界面响应 |
| 动画帧率 | ≥ 60fps | 动画流畅度 |
| 并发用户数 | ≥ 1000 | 同时在线用户数 |
| 并发聊天会话 | ≥ 500 | 同时进行的聊天会话数 |

### 8.2 优化策略

#### 8.2.1 前端优化

```typescript
// 1. 虚拟滚动（大列表优化）
@Component
struct VirtualListComponent {
  @State items: any[] = [];
  private scroller: Scroller = new Scroller();
  
  build() {
    List({ scroller: this.scroller }) {
      ForEach(this.items, (item: any) => {
        ListItem() {
          // 渲染项
        }
      }, (item: any) => item.id)
    }
    .cachedItemCount(5)  // 缓存5项
    .lanes(1)
  }
}

// 2. 懒加载（图片优化）
@Component
struct LazyImageComponent {
  @Prop imageUrl: string;
  @State loaded: boolean = false;
  
  aboutToAppear() {
    // 预加载图片
    this.preloadImage();
  }
  
  build() {
    if (this.loaded) {
      Image(this.imageUrl)
        .width('100%')
        .height('100%');
    } else {
      // 占位图
      Image($r('app.media.placeholder'))
        .width('100%')
        .height('100%');
    }
  }
}

// 3. 防抖和节流
function debounce(func: Function, delay: number): Function {
  let timer: number;
  return (...args: any[]) => {
    clearTimeout(timer);
    timer = setTimeout(() => func.apply(this, args), delay);
  };
}

function throttle(func: Function, delay: number): Function {
  let lastTime: number = 0;
  return (...args: any[]) => {
    const now = Date.now();
    if (now - lastTime >= delay) {
      func.apply(this, args);
      lastTime = now;
    }
  };
}

// 4. 数据缓存
class DataCache {
  private cache: Map<string, { data: any, expireAt: number }> = new Map();
  
  get(key: string): any | null {
    const item = this.cache.get(key);
    if (item && item.expireAt > Date.now()) {
      return item.data;
    }
    this.cache.delete(key);
    return null;
  }
  
  set(key: string, data: any, ttl: number): void {
    this.cache.set(key, {
      data,
      expireAt: Date.now() + ttl
    });
  }
}
```

#### 8.2.2 后端优化

```typescript
// 1. 数据库查询优化
// 使用索引
CREATE INDEX idx_patient_created ON medical_records(patient_id, created_at);
CREATE INDEX idx_session_time ON chat_messages(session_id, timestamp);

// 查询优化
async function getPatientRecords(patientId: string): Promise<MedicalRecord[]> {
  // 使用索引查询
  const records = await db.query(`
    SELECT * FROM medical_records
    WHERE patient_id = ?
    ORDER BY created_at DESC
    LIMIT 100
  `, [patientId]);
  
  return records;
}

// 2. 连接池配置
const pool = mysql.createPool({
  connectionLimit: 100,  // 连接数
  acquireTimeout: 10000,  // 获取连接超时
  timeout: 60000,  // 查询超时
  host: 'localhost',
  user: 'root',
  password: 'password',
  database: 'healthcare'
});

// 3. Redis缓存
async function getUserWithCache(userId: string): Promise<User> {
  // 先查缓存
  const cached = await redis.get(`user:${userId}`);
  if (cached) {
    return JSON.parse(cached);
  }
  
  // 查数据库
  const user = await db.getUser(userId);
  
  // 写入缓存
  await redis.setex(`user:${userId}`, 3600, JSON.stringify(user));
  
  return user;
}

// 4. 批量操作
async function batchInsertMessages(messages: ChatMessage[]): Promise<void> {
  // 批量插入，减少数据库连接
  const values = messages.map(m => [m.id, m.sessionId, m.content, m.timestamp]);
  await db.batchInsert('chat_messages', values);
}
```

#### 8.2.3 网络优化

```typescript
// 1. WebSocket连接池
class WebSocketManager {
  private connections: Map<string, WebSocket> = new Map();
  private reconnectAttempts: Map<string, number> = new Map();
  
  connect(userId: string): WebSocket {
    if (this.connections.has(userId)) {
      return this.connections.get(userId)!;
    }
    
    const ws = new WebSocket(`wss://api.example.com/ws?userId=${userId}`);
    
    ws.onclose = () => {
      // 自动重连
      this.reconnect(userId);
    };
    
    this.connections.set(userId, ws);
    return ws;
  }
  
  reconnect(userId: string): void {
    const attempts = this.reconnectAttempts.get(userId) || 0;
    if (attempts < 5) {
      setTimeout(() => {
        this.connect(userId);
        this.reconnectAttempts.set(userId, attempts + 1);
      }, 1000 * Math.pow(2, attempts));  // 指数退避
    }
  }
}

// 2. 请求合并
class RequestBatcher {
  private queue: Map<string, any[]> = new Map();
  private timer: Map<string, number> = new Map();
  
  add(key: string, request: any): void {
    if (!this.queue.has(key)) {
      this.queue.set(key, []);
    }
    this.queue.get(key)!.push(request);
    
    // 延迟执行
    if (!this.timer.has(key)) {
      this.timer.set(key, setTimeout(() => this.flush(key), 100));
    }
  }
  
  flush(key: string): void {
    const requests = this.queue.get(key);
    if (requests && requests.length > 0) {
      // 批量发送
      this.sendBatch(key, requests);
      this.queue.delete(key);
    }
    this.timer.delete(key);
  }
}
```

### 8.3 监控方案

```typescript
// 1. 性能监控
class PerformanceMonitor {
  // 记录API响应时间
  recordApiResponse(endpoint: string, duration: number): void {
    InfluxDB.write('api_metrics', {
      tags: { endpoint },
      fields: { duration },
      timestamp: Date.now()
    });
  }
  
  // 记录WebSocket消息延迟
  recordWsLatency(messageId: string, latency: number): void {
    InfluxDB.write('ws_metrics', {
      tags: { messageId },
      fields: { latency },
      timestamp: Date.now()
    });
  }
  
  // 记录错误
  recordError(error: Error, context: any): void {
    InfluxDB.write('errors', {
      tags: { type: error.name },
      fields: { message: error.message, context: JSON.stringify(context) },
      timestamp: Date.now()
    });
  }
}

// 2. 告警规则
const alertRules = [
  {
    name: 'API响应时间过长',
    condition: 'api_metrics.duration > 1000',
    action: 'sendAlert',
    severity: 'WARNING'
  },
  {
    name: 'WebSocket连接断开',
    condition: 'ws_metrics.connections < 100',
    action: 'sendAlert',
    severity: 'CRITICAL'
  },
  {
    name: '错误率过高',
    condition: 'errors.count > 100',
    action: 'sendAlert',
    severity: 'CRITICAL'
  }
];
```

## 9. 安全设计

### 9.1 数据安全

#### 9.1.1 数据加密

```typescript
// AES-256加密
class CryptoUtil {
  private static algorithm = 'aes-256-cbc';
  private static key = process.env.ENCRYPTION_KEY;  // 32字节密钥
  
  // 加密
  static encrypt(text: string): string {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(
      this.algorithm, 
      Buffer.from(this.key), 
      iv
    );
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return iv.toString('hex') + ':' + encrypted;
  }
  
  // 解密
  static decrypt(encrypted: string): string {
    const [ivHex, data] = encrypted.split(':');
    const iv = Buffer.from(ivHex, 'hex');
    const decipher = crypto.createDecipheriv(
      this.algorithm, 
      Buffer.from(this.key), 
      iv
    );
    let decrypted = decipher.update(data, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  }
}

// 敏感数据加密存储
async function savePatient(patient: Patient): Promise<void> {
  // 加密身份证号
  patient.idNumber = CryptoUtil.encrypt(patient.idNumber);
  
  // 加密联系方式
  patient.phone = CryptoUtil.encrypt(patient.phone);
  
  await db.insert('patients', patient);
}
```

#### 9.1.2 数据脱敏

```typescript
// 数据脱敏规则
const desensitizationRules = {
  // 身份证号：保留前3位和后4位
  idNumber: (value: string) => {
    return value.substring(0, 3) + '***********' + value.substring(14);
  },
  
  // 手机号：保留前3位和后4位
  phone: (value: string) => {
    return value.substring(0, 3) + '****' + value.substring(7);
  },
  
  // 姓名：保留姓
  name: (value: string) => {
    return value.substring(0, 1) + '**';
  },
  
  // 地址：仅显示省市
  address: (value: string) => {
    return value.substring(0, value.indexOf('市') + 1) + '***';
  }
};

// 管理员查看数据时脱敏
function desensitizeData(data: any, fields: string[]): any {
  const result = { ...data };
  for (const field of fields) {
    if (result[field] && desensitizationRules[field]) {
      result[field] = desensitizationRules[field](result[field]);
    }
  }
  return result;
}
```

### 9.2 权限控制

#### 9.2.1 RBAC权限模型

```typescript
// 角色定义
enum Role {
  DOCTOR = 'DOCTOR',
  PATIENT = 'PATIENT',
  NURSE = 'NURSE',
  FAMILY = 'FAMILY',
  ADMIN = 'ADMIN'
}

// 权限定义
const permissions = {
  [Role.DOCTOR]: [
    'patient:read',
    'patient:write',
    'medical_record:read',
    'medical_record:write',
    'prescription:create',
    'diagnosis:create',
    'chat:doctor_patient',
    'notification:receive'
  ],
  [Role.PATIENT]: [
    'medical_record:read_own',
    'prescription:read_own',
    'medication_reminder:read_own',
    'medication_reminder:write_own',
    'chat:patient_doctor',
    'notification:receive',
    'emergency:trigger'
  ],
  [Role.NURSE]: [
    'patient:read',
    'medical_record:read',
    'medication_record:read',
    'chat:nurse_patient',
    'notification:receive',
    'emergency:handle'
  ],
  [Role.FAMILY]: [
    'patient:read_authorized',
    'medical_record:read_authorized',
    'family_health_info:submit',
    'chat:family_doctor',
    'notification:receive'
  ],
  [Role.ADMIN]: [
    'user:read',
    'user:write',
    'data:read_all',
    'data:audit',
    'system:monitor'
  ]
};

// 权限检查中间件
function checkPermission(resource: string, action: string) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const user = req.user;
    
    // 获取用户权限列表
    const userPermissions = permissions[user.role];
    
    // 检查权限
    const hasPermission = userPermissions.some(
      p => p === `${resource}:${action}` || 
           p === `${resource}:*` ||
           p === '*'
    );
    
    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'AUTH_PERMISSION_DENIED',
          message: '权限不足'
        }
      });
    }
    
    next();
  };
}
```

#### 9.2.2 数据访问控制

```typescript
// 患者数据访问控制
async function canAccessPatient(
  userId: string, 
  userRole: Role, 
  patientId: string
): Promise<boolean> {
  switch (userRole) {
    case Role.DOCTOR:
      // 医生：检查是否为主治医生
      return await isAttendingDoctor(userId, patientId);
    
    case Role.NURSE:
      // 护士：检查是否为负责护士
      return await isAssignedNurse(userId, patientId);
    
    case Role.FAMILY:
      // 家属：检查是否获得授权
      return await isAuthorizedFamily(userId, patientId);
    
    case Role.PATIENT:
      // 患者：只能访问自己的数据
      return userId === patientId;
    
    case Role.ADMIN:
      // 管理员：可以访问所有数据
      return true;
    
    default:
      return false;
  }
}

// 数据访问审计
async function auditDataAccess(
  userId: string,
  resource: string,
  resourceId: string,
  action: string
): Promise<void> {
  await db.insert('data_access_logs', {
    userId,
    resource,
    resourceId,
    action,
    timestamp: new Date(),
    ipAddress: getRequestIP()
  });
}
```

### 9.3 安全审计

#### 9.3.1 审计日志

```typescript
// 审计日志记录
class AuditLogger {
  // 记录登录
  static async logLogin(
    userId: string, 
    deviceId: string, 
    success: boolean
  ): Promise<void> {
    await db.insert('audit_logs', {
      type: 'LOGIN',
      userId,
      deviceId,
      success,
      timestamp: new Date(),
      ipAddress: getRequestIP()
    });
  }
  
  // 记录数据访问
  static async logDataAccess(
    userId: string,
    resource: string,
    resourceId: string,
    action: string
  ): Promise<void> {
    await db.insert('audit_logs', {
      type: 'DATA_ACCESS',
      userId,
      resource,
      resourceId,
      action,
      timestamp: new Date()
    });
  }
  
  // 记录敏感操作
  static async logSensitiveOperation(
    userId: string,
    operation: string,
    details: any
  ): Promise<void> {
    await db.insert('audit_logs', {
      type: 'SENSITIVE_OPERATION',
      userId,
      operation,
      details: JSON.stringify(details),
      timestamp: new Date()
    });
  }
}
```

#### 9.3.2 安全检查点

```typescript
// 安全检查中间件
const securityChecks = {
  // SQL注入检查
  checkSqlInjection: (req: Request, res: Response, next: NextFunction) => {
    const sqlPatterns = [
      /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER)\b)/gi,
      /(--)|(\/\*)|(\*\/)/g,
      /(\bOR\b|\bAND\b).*?=/gi
    ];
    
    const checkValue = (value: string): boolean => {
      return sqlPatterns.some(pattern => pattern.test(value));
    };
    
    const checkObject = (obj: any): boolean => {
      for (const key in obj) {
        if (typeof obj[key] === 'string' && checkValue(obj[key])) {
          return true;
        }
        if (typeof obj[key] === 'object' && checkObject(obj[key])) {
          return true;
        }
      }
      return false;
    };
    
    if (checkObject(req.body) || checkObject(req.query)) {
      return res.status(400).json({
        success: false,
        error: { code: 'SECURITY_VIOLATION', message: '非法输入' }
      });
    }
    
    next();
  },
  
  // XSS检查
  checkXSS: (req: Request, res: Response, next: NextFunction) => {
    const xssPatterns = [
      /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,
      /javascript:/gi,
      /on\w+\s*=/gi
    ];
    
    const sanitize = (value: string): string => {
      let result = value;
      for (const pattern of xssPatterns) {
        result = result.replace(pattern, '');
      }
      return result;
    };
    
    // 递归清理对象
    const sanitizeObject = (obj: any): any => {
      for (const key in obj) {
        if (typeof obj[key] === 'string') {
          obj[key] = sanitize(obj[key]);
        } else if (typeof obj[key] === 'object') {
          obj[key] = sanitizeObject(obj[key]);
        }
      }
      return obj;
    };
    
    req.body = sanitizeObject(req.body);
    req.query = sanitizeObject(req.query);
    
    next();
  },
  
  // 请求频率限制
  rateLimit: (maxRequests: number, windowMs: number) => {
    const requests = new Map<string, number[]>();
    
    return (req: Request, res: Response, next: NextFunction) => {
      const key = req.ip;
      const now = Date.now();
      
      if (!requests.has(key)) {
        requests.set(key, []);
      }
      
      const userRequests = requests.get(key)!;
      
      // 清理过期请求
      while (userRequests.length > 0 && userRequests[0] < now - windowMs) {
        userRequests.shift();
      }
      
      // 检查频率
      if (userRequests.length >= maxRequests) {
        return res.status(429).json({
          success: false,
          error: { code: 'RATE_LIMIT_EXCEEDED', message: '请求过于频繁' }
        });
      }
      
      userRequests.push(now);
      next();
    };
  }
};
```

## 10. 测试设计

### 10.1 测试策略

**测试金字塔**：
- 单元测试（70%）：测试函数、类方法、工具函数
- 集成测试（20%）：测试模块交互、API接口
- E2E测试（10%）：测试用户关键流程

**测试重点**：
1. 核心业务逻辑：处方开具、用药提醒、紧急通知
2. 数据同步：多设备同步、冲突解决
3. 权限控制：角色权限、数据访问控制
4. 性能测试：并发、响应时间、吞吐量
5. 安全测试：加密、注入、XSS

### 10.2 测试用例

#### 10.2.1 单元测试用例

```typescript
// 用药提醒时间计算测试
describe('MedicationReminder', () => {
  test('should calculate correct times for once daily', () => {
    const frequency = '一日一次';
    const duration = 7;
    const startTime = new Date('2025-01-15 08:00:00');
    
    const times = calculateReminderTimes(frequency, duration, startTime);
    
    expect(times.length).toBe(7);
    expect(times[0].getHours()).toBe(8);
  });
  
  test('should calculate correct times for three times daily', () => {
    const frequency = '一日三次';
    const duration = 3;
    const startTime = new Date('2025-01-15 00:00:00');
    
    const times = calculateReminderTimes(frequency, duration, startTime);
    
    expect(times.length).toBe(9);
    expect(times[0].getHours()).toBe(8);
    expect(times[1].getHours()).toBe(12);
    expect(times[2].getHours()).toBe(18);
  });
});

// 权限检查测试
describe('PermissionCheck', () => {
  test('should allow doctor to read patient record', async () => {
    const doctorId = 'doctor-001';
    const patientId = 'patient-001';
    
    // 设置医生为患者的主治医生
    await setAttendingDoctor(doctorId, patientId);
    
    const hasPermission = await canAccessPatient(
      doctorId, 
      Role.DOCTOR, 
      patientId
    );
    
    expect(hasPermission).toBe(true);
  });
  
  test('should deny family without authorization', async () => {
    const familyId = 'family-001';
    const patientId = 'patient-001';
    
    const hasPermission = await canAccessPatient(
      familyId, 
      Role.FAMILY, 
      patientId
    );
    
    expect(hasPermission).toBe(false);
  });
});

// 数据加密测试
describe('DataEncryption', () => {
  test('should encrypt and decrypt correctly', () => {
    const original = '敏感数据';
    
    const encrypted = CryptoUtil.encrypt(original);
    const decrypted = CryptoUtil.decrypt(encrypted);
    
    expect(decrypted).toBe(original);
    expect(encrypted).not.toBe(original);
  });
});
```

#### 10.2.2 集成测试用例

```typescript
// 处方开具流程测试
describe('PrescriptionFlow', () => {
  test('should create prescription and trigger reminders', async () => {
    // 1. 医生登录
    const doctorToken = await login('doctor-001', 'password');
    
    // 2. 开具处方
    const prescription = await createPrescription(doctorToken, {
      patientId: 'patient-001',
      medications: [{
        name: '阿莫西林',
        dosage: '500mg',
        frequency: '一日三次',
        duration: 7
      }]
    });
    
    expect(prescription.status).toBe('ACTIVE');
    
    // 3. 检查患者端是否收到提醒
    const reminders = await getMedicationReminders('patient-001');
    expect(reminders.length).toBeGreaterThan(0);
    
    // 4. 检查提醒时间是否正确
    const firstReminder = reminders[0];
    expect(firstReminder.medication.name).toBe('阿莫西林');
  });
});

// 紧急通知流程测试
describe('EmergencyNotificationFlow', () => {
  test('should send emergency notification to all recipients', async () => {
    // 1. 患者触发紧急求助
    const patientToken = await login('patient-001', 'password');
    
    const emergency = await triggerEmergency(patientToken, {
      type: 'PATIENT_HELP',
      severity: 'CRITICAL'
    });
    
    // 2. 检查护士、医生、家属是否收到通知
    const nurseNotifications = await getNotifications('nurse-001');
    const doctorNotifications = await getNotifications('doctor-001');
    const familyNotifications = await getNotifications('family-001');
    
    expect(nurseNotifications.length).toBeGreaterThan(0);
    expect(doctorNotifications.length).toBeGreaterThan(0);
    expect(familyNotifications.length).toBeGreaterThan(0);
  });
});

// 聊天功能测试
describe('ChatFlow', () => {
  test('should send and receive message in real-time', async () => {
    // 1. 建立WebSocket连接
    const doctorWs = await connectWebSocket('doctor-001');
    const patientWs = await connectWebSocket('patient-001');
    
    // 2. 医生发送消息
    const message = await sendMessage(doctorWs, {
      receiverId: 'patient-001',
      content: { type: 'TEXT', text: '您好' }
    });
    
    // 3. 患者接收消息
    const received = await receiveMessage(patientWs, 5000);
    
    expect(received.content.text).toBe('您好');
    expect(received.senderId).toBe('doctor-001');
  });
});
```

#### 10.2.3 E2E测试用例

```typescript
// 医生开处方完整流程
describe('DoctorPrescriptionE2E', () => {
  test('complete prescription workflow', async () => {
    // 1. 打开医生端应用
    await page.goto('https://doctor.healthcare.com');
    
    // 2. 登录
    await page.fill('#username', 'doctor-001');
    await page.fill('#password', 'password');
    await page.click('#login-button');
    
    // 3. 选择患者
    await page.click('#patient-list');
    await page.click('[data-patient-id="patient-001"]');
    
    // 4. 查看病历
    await page.click('#view-medical-record');
    await expect(page.locator('#medical-record')).toBeVisible();
    
    // 5. 开具处方
    await page.click('#create-prescription');
    await page.fill('#diagnosis', '上呼吸道感染');
    await page.fill('#medication-name', '阿莫西林');
    await page.fill('#dosage', '500mg');
    await page.fill('#frequency', '一日三次');
    await page.fill('#duration', '7');
    await page.click('#submit-prescription');
    
    // 6. 确认提交
    await page.click('#confirm-button');
    
    // 7. 验证处方创建成功
    await expect(page.locator('.success-message')).toBeVisible();
  });
});

// 患者紧急求助完整流程
describe('PatientEmergencyE2E', () => {
  test('complete emergency help workflow', async () => {
    // 1. 打开患者端应用
    await page.goto('https://patient.healthcare.com');
    
    // 2. 登录
    await page.fill('#username', 'patient-001');
    await page.fill('#password', 'password');
    await page.click('#login-button');
    
    // 3. 点击紧急求助
    await page.click('#emergency-help-button');
    
    // 4. 确认求助
    await page.click('#confirm-help');
    
    // 5. 验证求助发送成功
    await expect(page.locator('.help-sent-message')).toBeVisible();
    
    // 6. 验证收到响应（模拟护士响应）
    // ... 等待护士响应
    await expect(page.locator('.help-response')).toBeVisible({ timeout: 30000 });
  });
});
```

### 10.3 Mock数据

```typescript
// Mock用户数据
const mockUsers = {
  doctor: {
    id: 'doctor-001',
    username: 'doctor001',
    name: '张医生',
    role: Role.DOCTOR,
    department: '内科',
    title: '主治医师'
  },
  patient: {
    id: 'patient-001',
    username: 'patient001',
    name: '李患者',
    role: Role.PATIENT,
    dateOfBirth: '1990-01-01',
    gender: 'MALE'
  },
  nurse: {
    id: 'nurse-001',
    username: 'nurse001',
    name: '王护士',
    role: Role.NURSE,
    department: '内科'
  },
  family: {
    id: 'family-001',
    username: 'family001',
    name: '李家属',
    role: Role.FAMILY,
    relatedPatients: ['patient-001']
  }
};

// Mock病历数据
const mockMedicalRecord = {
  id: 'record-001',
  patientId: 'patient-001',
  basicInfo: {
    height: 175,
    weight: 70,
    bloodType: 'A',
    allergies: [{ allergen: '青霉素', reaction: '皮疹', severity: 'MODERATE' }]
  },
  medicalHistory: [
    { disease: '高血压', diagnosedAt: '2020-01-01', status: '控制中' }
  ],
  diagnoses: [],
  prescriptions: []
};

// Mock聊天消息
const mockChatMessages = [
  {
    id: 'msg-001',
    sessionId: 'session-001',
    senderId: 'doctor-001',
    content: { type: 'TEXT', text: '您好，有什么不舒服吗？' },
    timestamp: '2025-01-15T10:00:00Z'
  },
  {
    id: 'msg-002',
    sessionId: 'session-001',
    senderId: 'patient-001',
    content: { type: 'TEXT', text: '医生您好，我有点头痛' },
    timestamp: '2025-01-15T10:01:00Z'
  }
];

// Mock紧急通知
const mockEmergencyNotification = {
  id: 'emergency-001',
  type: 'PATIENT_HELP',
  patientId: 'patient-001',
  patientName: '李患者',
  severity: 'CRITICAL',
  title: '患者紧急求助',
  content: '患者李患者触发紧急求助',
  recipients: [
    { userId: 'nurse-001', role: Role.NURSE, status: 'PENDING' },
    { userId: 'doctor-001', role: Role.DOCTOR, status: 'PENDING' },
    { userId: 'family-001', role: Role.FAMILY, status: 'PENDING' }
  ],
  createdAt: '2025-01-15T10:00:00Z'
};
```

## 11. 部署设计

### 11.1 环境要求

#### 11.1.1 客户端环境

- **操作系统**：HarmonyOS 3.0及以上
- **设备类型**：手机、平板、手表
- **网络**：支持WiFi、4G/5G
- **存储**：至少100MB可用空间
- **权限**：相机、麦克风、存储、位置（可选）

#### 11.1.2 服务端环境

- **操作系统**：Linux (Ubuntu 20.04 LTS)
- **Node.js**：v18.0.0及以上
- **MySQL**：8.0及以上
- **Redis**：6.0及以上
- **InfluxDB**：2.0及以上
- **MinIO**：最新稳定版
- **RabbitMQ**：3.8及以上

### 11.2 配置管理

```yaml
# 应用配置
app:
  name: HealthcareSystem
  version: 1.0.0
  env: production

# 服务器配置
server:
  port: 3000
  host: 0.0.0.0
  cors:
    origins:
      - https://doctor.healthcare.com
      - https://patient.healthcare.com
      - https://nurse.healthcare.com
      - https://family.healthcare.com
      - https://admin.healthcare.com

# 数据库配置
database:
  mysql:
    host: mysql.healthcare.com
    port: 3306
    database: healthcare
    username: ${MYSQL_USERNAME}
    password: ${MYSQL_PASSWORD}
    pool:
      min: 10
      max: 100
  
  redis:
    host: redis.healthcare.com
    port: 6379
    password: ${REDIS_PASSWORD}
    db: 0
  
  influxdb:
    url: http://influxdb.healthcare.com:8086
    token: ${INFLUXDB_TOKEN}
    org: healthcare
    bucket: health_data
  
  minio:
    endpoint: minio.healthcare.com
    port: 9000
    accessKey: ${MINIO_ACCESS_KEY}
    secretKey: ${MINIO_SECRET_KEY}
    useSSL: true

# WebSocket配置
websocket:
  port: 3001
  path: /ws
  heartbeat:
    interval: 30000
    timeout: 60000

# JWT配置
jwt:
  secret: ${JWT_SECRET}
  expiresIn: 7200
  refreshExpiresIn: 604800

# 加密配置
encryption:
  algorithm: aes-256-cbc
  key: ${ENCRYPTION_KEY}

# 消息队列配置
rabbitmq:
  url: amqp://rabbitmq.healthcare.com
  exchanges:
    - name: healthcare.events
      type: topic
  queues:
    - name: prescription.events
    - name: notification.events
    - name: emergency.events

# 日志配置
logging:
  level: info
  format: json
  outputs:
    - type: file
      path: /var/log/healthcare/app.log
    - type: elasticsearch
      host: elasticsearch.healthcare.com
      index: healthcare-logs

# 监控配置
monitoring:
  enabled: true
  metrics:
    port: 9090
    path: /metrics
  tracing:
    enabled: true
    serviceName: healthcare-api
    jaeger:
      host: jaeger.healthcare.com
      port: 6831

# 告警配置
alerting:
  enabled: true
  channels:
    - type: email
      recipients:
        - admin@healthcare.com
    - type: sms
      recipients:
        - '+8613800138000'
  rules:
    - name: high_error_rate
      condition: error_rate > 0.05
      severity: critical
    - name: slow_response
      condition: response_time_p95 > 1000
      severity: warning
```

### 11.3 发布流程

#### 11.3.1 客户端发布流程

```
1. 代码审查
   └─> Pull Request审核
   └─> 代码质量检查
   └─> 安全扫描

2. 构建打包
   └─> 执行单元测试
   └─> 执行集成测试
   └─> 构建HAP包
   └─> 签名打包

3. 测试验证
   └─> 部署到测试环境
   └─> 执行E2E测试
   └─> 用户验收测试

4. 发布上线
   └─> 提交应用市场审核
   └─> 灰度发布（10%用户）
   └─> 全量发布
   └─> 监控告警
```

#### 11.3.2 服务端发布流程

```
1. 代码审查
   └─> Pull Request审核
   └─> 代码质量检查
   └─> 安全扫描

2. 构建镜像
   └─> 执行单元测试
   └─> 执行集成测试
   └─> 构建Docker镜像
   └─> 推送到镜像仓库

3. 部署测试
   └─> 部署到测试环境
   └─> 执行E2E测试
   └─> 性能测试
   └─> 安全测试

4. 生产部署
   └─> 数据库迁移
   └─> 蓝绿部署
   └─> 健康检查
   └─> 流量切换
   └─> 监控告警

5. 发布后验证
   └─> 冒烟测试
   └─> 监控指标检查
   └─> 日志检查
```

## 12. 附录

### 12.1 术语表

| 术语 | 定义 |
|-----|------|
| 多端隔离 | 五个独立终端应用，页面相互隔离，数据可共享 |
| 跨端通信 | 不同终端用户之间的消息通信 |
| 医嘱联动 | 医生开药后自动触发患者端用药提醒 |
| 紧急通知 | 突发情况时向多端同时推送的高优先级通知 |
| 数据同步 | 多设备间数据实时或准实时同步 |
| 页面隔离 | 不同终端页面无法直接跳转，保持独立性 |
| RBAC | Role-Based Access Control，基于角色的访问控制 |
| JWT | JSON Web Token，无状态认证令牌 |
| WebSocket | 全双工通信协议，用于实时消息传输 |
| ArkTS | 鸿蒙OS官方开发语言，TypeScript的超集 |
| ArkUI | 鸿蒙OS声明式UI框架 |
| HAP | HarmonyOS Ability Package，鸿蒙应用包格式 |

### 12.2 参考资料

- HarmonyOS应用开发指南：https://developer.harmonyos.com/cn/docs/documentation/doc-guides/application-dev-guide-0000001281349865
- 鸿蒙OS ArkTS语言规范：https://developer.harmonyos.com/cn/docs/documentation/doc-references/arkts-getting-started-0000001504769321
- 《医疗机构病历管理规定（2013版）》
- 《电子病历应用管理规范（试行）》
- 《个人信息保护法》
- WebSocket协议规范：RFC 6455
- JWT规范：RFC 7519

### 12.3 变更历史

| 版本 | 日期 | 变更内容 | 变更人 |
|-----|------|---------|--------|
| v1.0 | 2025-01-15 | 初始版本，完成技术设计文档 | System |
