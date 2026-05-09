# 实现方案文档 - 医生认证隔离与功能修复

## 1. 实现模型

### 1.1 上下文视图

本方案针对HarmonyOS健康护理系统的三个核心问题：
1. **医生认证隔离**：建立独立的医生token管理和登录状态维护机制
2. **聊天功能修复**：修复家属和患者页面的消息通信问题
3. **添加功能改进**：支持从数据库选择数据，增强数据验证

系统上下文：
```
┌─────────────────────────────────────────────────────────┐
│                    HarmonyOS 前端应用                     │
├─────────────────────────────────────────────────────────┤
│  医生模块  │  家属模块  │  患者模块  │  通用组件模块      │
└─────┬─────────┬─────────┬─────────┬─────────────────────┘
      │         │         │         │
      └─────────┴─────────┴─────────┘
                    │
              HTTP/HTTPS
                    │
      ┌─────────────┴─────────────┐
      │   Spring Boot 后端服务     │
      ├───────────────────────────┤
      │  认证服务  │  消息服务  │  数据服务  │
      └─────────────┬─────────────┘
                    │
              JDBC/ORM
                    │
      ┌─────────────┴─────────────┐
      │      关系型数据库          │
      └───────────────────────────┘
```

### 1.2 服务/组件总体架构

#### 前端架构（HarmonyOS ArkTS）

```
entry/src/main/ets/
├── common/utils/
│   ├── HttpUtil.ets          # HTTP请求工具（Token管理核心）
│   └── TokenManager.ets      # 新增：统一Token管理器
├── utils/
│   ├── AuthManager.ets       # 认证管理器（角色判断）
│   ├── SettingsUtil.ets      # 持久化存储工具
│   └── RdbHelper.ets         # 本地数据库帮助类
├── pages/
│   ├── DoctorLogin.ets       # 医生登录页面
│   ├── FamilyDoctorChatPage.ets  # 家属聊天页面
│   ├── PatientDoctorChatPage.ets # 患者聊天页面
│   ├── AddHealthRecord.ets   # 添加健康记录
│   └── AddAppointmentPage.ets # 添加预约
└── components/
    ├── DataSelector.ets      # 新增：数据库选择组件
    └── ChatMessage.ets       # 聊天消息组件
```

#### 后端架构（Spring Boot）

```
src/main/java/com/example/medical/
├── common/
│   ├── JwtUtil.java          # JWT工具类
│   └── Result.java           # 统一响应结果
├── controller/
│   ├── UserController.java   # 用户控制器
│   ├── DoctorController.java # 新增：医生控制器
│   ├── FamilyAuthController.java  # 家属认证
│   └── NurseController.java  # 护士控制器
├── service/
│   ├── UserService.java      # 用户服务
│   ├── MessageService.java   # 消息服务
│   └── DataService.java      # 新增：数据查询服务
└── entity/
    ├── User.java             # 用户实体
    └── Message.java          # 消息实体
```

### 1.3 实现设计文档

#### 1.3.1 医生Token隔离实现

**核心机制**：
1. **独立Token存储**：使用`doctorToken`作为独立存储key
2. **JWT生成策略**：Token包含`subject: "doctor"`标识
3. **自动检测机制**：HttpUtil优先检测医生Token
4. **过期处理**：401错误自动跳转医生登录页

**实现流程**：
```
医生登录请求
    ↓
后端验证账号密码
    ↓
生成JWT Token（subject="doctor"）
    ↓
前端保存到 doctorToken
    ↓
设置 isLoggedInAsDoctor = true
    ↓
缓存医生信息到 doctorInfo
```

#### 1.3.2 聊天功能修复实现

**问题诊断**：
- Token传递不正确导致权限验证失败
- 消息轮询机制未正确初始化
- 角色标识未正确传递

**修复方案**：
1. **Token传递**：确保聊天请求携带正确的角色Token
2. **权限验证**：后端验证Token中的角色标识
3. **消息隔离**：根据用户ID和角色过滤消息
4. **轮询机制**：使用setInterval确保消息实时更新

#### 1.3.3 添加功能改进实现

**改进方案**：
1. **数据库选择组件**：创建通用的DataSelector组件
2. **动态加载**：从后端API获取可选数据列表
3. **搜索筛选**：支持关键字搜索和条件筛选
4. **数据验证**：前后端双重验证机制

## 2. 接口设计

### 2.1 总体设计

**认证流程**：
```
客户端 → 登录接口 → JWT生成 → Token返回 → 客户端存储
```

**消息流程**：
```
发送方 → 消息接口 → 权限验证 → 数据库存储 → 接收方轮询获取
```

**数据选择流程**：
```
客户端 → 查询接口 → 数据库查询 → 列表返回 → 客户端展示
```

### 2.2 接口清单

#### 2.2.1 医生认证接口

**登录接口**
```
POST /doctor/login
Request:
{
  "phone": "string",     // 手机号
  "password": "string"   // 密码
}
Response:
{
  "code": 200,
  "msg": "登录成功",
  "data": {
    "token": "eyJhbGc...",  // JWT Token
    "doctorInfo": {
      "id": 1,
      "name": "张医生",
      "phone": "13800138000",
      "department": "内科"
    }
  }
}
```

**Token验证接口**
```
GET /doctor/verify
Headers:
  Authorization: Bearer {token}
Response:
{
  "code": 200,
  "msg": "验证成功",
  "data": {
    "valid": true,
    "doctorInfo": {...}
  }
}
```

#### 2.2.2 消息接口

**发送消息**
```
POST /message/send
Headers:
  Authorization: Bearer {token}
Request:
{
  "receiverId": 1,        // 接收者ID
  "content": "string",    // 消息内容
  "senderRole": "family"  // 发送者角色：family/patient/doctor
}
Response:
{
  "code": 200,
  "msg": "发送成功",
  "data": {
    "messageId": 123,
    "sendTime": "2024-01-01 10:00:00"
  }
}
```

**获取消息历史**
```
GET /message/history?userId={userId}&role={role}
Headers:
  Authorization: Bearer {token}
Response:
{
  "code": 200,
  "data": {
    "messages": [
      {
        "id": 1,
        "senderId": 1,
        "senderRole": "family",
        "receiverId": 2,
        "content": "你好医生",
        "sendTime": "2024-01-01 10:00:00",
        "isRead": true
      }
    ]
  }
}
```

#### 2.2.3 数据选择接口

**获取患者列表**
```
GET /data/patients?keyword={keyword}
Headers:
  Authorization: Bearer {token}
Response:
{
  "code": 200,
  "data": {
    "patients": [
      {
        "id": 1,
        "name": "张三",
        "phone": "13800138000",
        "age": 45
      }
    ]
  }
}
```

**获取医生列表**
```
GET /data/doctors?department={department}
Headers:
  Authorization: Bearer {token}
Response:
{
  "code": 200,
  "data": {
    "doctors": [
      {
        "id": 1,
        "name": "李医生",
        "department": "内科",
        "title": "主任医师"
      }
    ]
  }
}
```

**获取医院列表**
```
GET /data/hospitals?city={city}
Headers:
  Authorization: Bearer {token}
Response:
{
  "code": 200,
  "data": {
    "hospitals": [
      {
        "id": 1,
        "name": "北京协和医院",
        "address": "北京市东城区",
        "level": "三甲"
      }
    ]
  }
}
```

## 3. 数据模型

### 3.1 设计目标

- 支持多角色用户隔离
- 消息数据按角色隔离存储
- 支持高效的数据查询和筛选
- 保证数据一致性和完整性

### 3.2 模型实现

#### 3.2.1 用户表（User）

```sql
CREATE TABLE user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  phone VARCHAR(20) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(50),
  role VARCHAR(20) NOT NULL,  -- 'doctor', 'family', 'patient', 'nurse', 'admin'
  department VARCHAR(50),
  title VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_phone (phone),
  INDEX idx_role (role)
);
```

#### 3.2.2 消息表（Message）

```sql
CREATE TABLE message (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  sender_id BIGINT NOT NULL,
  sender_role VARCHAR(20) NOT NULL,  -- 'family', 'patient', 'doctor'
  receiver_id BIGINT NOT NULL,
  receiver_role VARCHAR(20) NOT NULL,
  content TEXT NOT NULL,
  send_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_read BOOLEAN DEFAULT FALSE,
  expire_time TIMESTAMP,  -- 48小时过期
  INDEX idx_sender (sender_id, sender_role),
  INDEX idx_receiver (receiver_id, receiver_role),
  INDEX idx_time (send_time),
  FOREIGN KEY (sender_id) REFERENCES user(id),
  FOREIGN KEY (receiver_id) REFERENCES user(id)
);
```

#### 3.2.3 Token缓存表（TokenCache）

```sql
CREATE TABLE token_cache (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  role VARCHAR(20) NOT NULL,
  token VARCHAR(500) NOT NULL,
  expire_time TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_role (user_id, role),
  INDEX idx_expire (expire_time),
  FOREIGN KEY (user_id) REFERENCES user(id)
);
```

#### 3.2.4 健康记录表（HealthRecord）

```sql
CREATE TABLE health_record (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  record_type VARCHAR(20) NOT NULL,  -- 'blood_pressure', 'blood_sugar', 'heart_rate', 'weight'
  value VARCHAR(100) NOT NULL,
  unit VARCHAR(20),
  record_time TIMESTAMP NOT NULL,
  created_by BIGINT,  -- 创建者ID（医生或家属）
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_patient (patient_id),
  INDEX idx_type (record_type),
  INDEX idx_time (record_time),
  FOREIGN KEY (patient_id) REFERENCES user(id)
);
```

#### 3.2.5 预约表（Appointment）

```sql
CREATE TABLE appointment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  doctor_id BIGINT,
  hospital_id BIGINT,
  department VARCHAR(50),
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',  -- 'pending', 'confirmed', 'cancelled'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_patient (patient_id),
  INDEX idx_doctor (doctor_id),
  INDEX idx_date (appointment_date),
  FOREIGN KEY (patient_id) REFERENCES user(id),
  FOREIGN KEY (doctor_id) REFERENCES user(id)
);
```

## 4. 关键技术实现

### 4.1 Token管理核心代码

**前端Token管理器（TokenManager.ets）**：
```typescript
export class TokenManager {
  // 获取当前角色的Token
  static getCurrentToken(): string | null {
    // 优先级：家属 > 护士 > 医生 > 普通用户
    if (AuthManager.isFamily()) {
      return SettingsUtil.get('familyToken');
    } else if (AuthManager.isNurse()) {
      return SettingsUtil.get('nurseToken');
    } else if (AuthManager.isDoctor()) {
      return SettingsUtil.get('doctorToken');
    } else {
      return SettingsUtil.get('token');
    }
  }
  
  // 保存医生Token
  static saveDoctorToken(token: string, doctorInfo: any) {
    SettingsUtil.put('doctorToken', token);
    SettingsUtil.put('isLoggedInAsDoctor', true);
    SettingsUtil.put('doctorInfo', JSON.stringify(doctorInfo));
  }
  
  // 清除医生Token
  static clearDoctorToken() {
    SettingsUtil.delete('doctorToken');
    SettingsUtil.put('isLoggedInAsDoctor', false);
    SettingsUtil.delete('doctorInfo');
  }
}
```

**后端JWT生成（JwtUtil.java）**：
```java
public class JwtUtil {
  // 生成医生Token
  public static String generateDoctorToken(Long doctorId, String phone) {
    return Jwts.builder()
      .setSubject("doctor")  // 角色标识
      .claim("userId", doctorId)
      .claim("phone", phone)
      .setIssuedAt(new Date())
      .setExpiration(new Date(System.currentTimeMillis() + 7 * 24 * 60 * 60 * 1000))  // 7天过期
      .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
      .compact();
  }
  
  // 验证Token角色
  public static boolean validateRole(String token, String expectedRole) {
    Claims claims = Jwts.parser()
      .setSigningKey(SECRET_KEY)
      .parseClaimsJws(token)
      .getBody();
    return expectedRole.equals(claims.getSubject());
  }
}
```

### 4.2 消息隔离实现

**后端消息查询（MessageService.java）**：
```java
public List<Message> getMessageHistory(Long userId, String role) {
  return messageRepository.findBySenderIdAndSenderRoleOrReceiverIdAndReceiverRole(
    userId, role, userId, role
  );
}
```

**前端消息轮询（FamilyDoctorChatPage.ets）**：
```typescript
aboutToAppear() {
  // 验证家属权限
  if (!AuthManager.isFamily()) {
    router.pushUrl({ url: 'pages/FamilyLogin' });
    return;
  }
  
  // 启动消息轮询
  this.messageInterval = setInterval(() => {
    this.loadMessages();
  }, 3000);
}

aboutToDisappear() {
  // 清除轮询
  if (this.messageInterval) {
    clearInterval(this.messageInterval);
  }
}
```

### 4.3 数据选择组件

**DataSelector组件（DataSelector.ets）**：
```typescript
@Component
export struct DataSelector {
  @Prop dataType: string;  // 'patient', 'doctor', 'hospital'
  @State dataList: any[] = [];
  @State keyword: string = '';
  @Link selectedId: number;
  
  async aboutToAppear() {
    await this.loadData();
  }
  
  async loadData() {
    let url = '';
    if (this.dataType === 'patient') {
      url = `/data/patients?keyword=${this.keyword}`;
    } else if (this.dataType === 'doctor') {
      url = `/data/doctors?keyword=${this.keyword}`;
    } else if (this.dataType === 'hospital') {
      url = `/data/hospitals?keyword=${this.keyword}`;
    }
    
    const response = await HttpUtil.get(url);
    this.dataList = response.data;
  }
  
  build() {
    Column() {
      // 搜索框
      TextInput({ placeholder: '搜索...' })
        .onChange((value) => {
          this.keyword = value;
          this.loadData();
        });
      
      // 数据列表
      List() {
        ForEach(this.dataList, (item) => {
          ListItem() {
            this.buildItem(item);
          }
          .onClick(() => {
            this.selectedId = item.id;
          });
        });
      }
    }
  }
}
```

## 5. 实施步骤

### 5.1 第一阶段：医生Token隔离
1. 修改JwtUtil.java，为医生生成独立Token
2. 创建TokenManager.ets统一管理Token
3. 修改HttpUtil.ets，优先检测医生Token
4. 修改DoctorLogin.ets，使用新的Token保存机制
5. 测试医生登录和Token验证

### 5.2 第二阶段：聊天功能修复
1. 修改FamilyDoctorChatPage.ets，确保Token正确传递
2. 修改PatientDoctorChatPage.ets，确保Token正确传递
3. 修改后端MessageService.java，增强权限验证
4. 测试消息发送和接收
5. 测试消息隔离机制

### 5.3 第三阶段：添加功能改进
1. 创建DataSelector组件
2. 实现后端数据查询接口
3. 修改AddHealthRecord.ets，集成DataSelector
4. 修改AddAppointmentPage.ets，集成DataSelector
5. 测试数据选择和验证

### 5.4 第四阶段：集成测试
1. 测试多角色登录切换
2. 测试消息功能完整性
3. 测试数据添加流程
4. 性能测试和优化
