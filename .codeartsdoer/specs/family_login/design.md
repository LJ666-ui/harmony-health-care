# 技术设计文档 - 家属登录功能

## 1. 实现模型

### 1.1 上下文视图

家属登录功能在系统中的位置和交互关系：

```
┌─────────────────────────────────────────────────────────────┐
│                      HarmonyOS 前端应用                      │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  用户登录页   │  │  家属登录页   │  │  管理员登录页 │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
│                  ┌─────────▼─────────┐                       │
│                  │  AuthManager      │                       │
│                  │  (认证管理器)      │                       │
│                  └─────────┬─────────┘                       │
└────────────────────────────┼────────────────────────────────┘
                             │
                    HTTP请求 │
                             │
┌────────────────────────────▼────────────────────────────────┐
│                    Spring Boot 后端服务                      │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐  │
│  │              FamilyAuthController                     │  │
│  │              (家属认证控制器)                          │  │
│  └───────────────────────┬──────────────────────────────┘  │
│                          │                                  │
│  ┌───────────────────────▼──────────────────────────────┐  │
│  │              FamilyAuthService                        │  │
│  │              (家属认证服务)                            │  │
│  └───────────────────────┬──────────────────────────────┘  │
│                          │                                  │
│         ┌────────────────┼────────────────┐                │
│         │                │                │                │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌─────▼─────┐         │
│  │ JwtUtil     │  │ BCryptPwd   │  │ FamilyMapper│         │
│  │ (JWT工具)   │  │ (密码加密)   │  │ (数据访问)  │         │
│  └─────────────┘  └─────────────┘  └───────────┘         │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  MySQL 数据库   │
                    │ - family_member│
                    │ - family_auth_log│
                    └────────────────┘
```

### 1.2 服务/组件总体架构

#### 前端架构（HarmonyOS）

```
entry/src/main/ets/
├── pages/
│   └── FamilyLogin.ets          # 家属登录页面
├── models/
│   ├── FamilyMember.ets         # 家属数据模型（扩展）
│   └── FamilyLoginRequest.ets   # 登录请求模型
├── services/
│   └── FamilyAuthService.ets    # 家属认证服务
├── utils/
│   └── AuthManager.ets          # 认证管理器（扩展）
└── common/
    └── constants/
        └── FamilyConstants.ets  # 家属相关常量
```

#### 后端架构（Spring Boot）

```
src/main/java/com/example/medical/
├── controller/
│   └── FamilyAuthController.java    # 家属认证控制器
├── service/
│   ├── FamilyAuthService.java       # 家属认证服务接口
│   └── impl/
│       └── FamilyAuthServiceImpl.java # 家属认证服务实现
├── mapper/
│   ├── FamilyMemberMapper.java      # 家属数据访问（扩展）
│   └── FamilyAuthLogMapper.java     # 家属认证日志访问
├── entity/
│   ├── FamilyMember.java            # 家属实体（扩展）
│   └── FamilyAuthLog.java           # 家属认证日志实体
├── dto/
│   ├── FamilyLoginRequest.java      # 登录请求DTO
│   └── FamilyLoginResponse.java     # 登录响应DTO
├── common/
│   ├── JwtUtil.java                 # JWT工具（扩展）
│   └── Result.java                  # 统一响应对象
└── config/
    └── FamilySecurityConfig.java    # 家属安全配置
```

### 1.3 实现设计文档

#### 1.3.1 前端实现设计

**FamilyLogin.ets - 家属登录页面**

页面结构：
```
@Component
struct FamilyLogin {
  @State phone: string = ''
  @State password: string = ''
  @State isLoading: boolean = false
  @State rememberPassword: boolean = false
  
  build() {
    Column() {
      // Logo和标题
      Image($r('app.media.family_logo'))
      Text('家属登录')
      
      // 手机号输入框
      TextInput({ placeholder: '请输入手机号' })
        .type(InputType.PhoneNumber)
        .onChange((value) => { this.phone = value })
      
      // 密码输入框
      TextInput({ placeholder: '请输入密码' })
        .type(InputType.Password)
        .onChange((value) => { this.password = value })
      
      // 记住密码复选框
      Checkbox({ name: 'rememberPassword' })
      
      // 登录按钮
      Button('登录')
        .onClick(() => { this.handleLogin() })
      
      // 提示信息
      Text('家属登录功能需由用户在"家属管理"中开启')
    }
  }
  
  async handleLogin() {
    // 1. 验证输入
    if (!this.validateInput()) return
    
    // 2. 调用登录接口
    this.isLoading = true
    const result = await FamilyAuthService.login(this.phone, this.password)
    
    // 3. 处理登录结果
    if (result.success) {
      // 保存Token和家属信息
      await AuthManager.saveFamilyToken(result.data.token)
      await AuthManager.saveFamilyInfo(result.data.familyInfo)
      
      // 跳转到家属主页
      router.pushUrl({ url: 'pages/FamilyHome' })
    } else {
      // 显示错误提示
      prompt.showToast({ message: result.message })
    }
    
    this.isLoading = false
  }
}
```

**FamilyAuthService.ets - 家属认证服务**

```typescript
export class FamilyAuthService {
  private static readonly BASE_URL = 'http://localhost:8080/api/family'
  
  static async login(phone: string, password: string): Promise<ApiResponse> {
    const response = await HttpUtil.post(`${this.BASE_URL}/login`, {
      phone: phone,
      password: password
    })
    return response
  }
  
  static async getFamilyInfo(): Promise<ApiResponse> {
    const response = await HttpUtil.get(`${this.BASE_URL}/info`, {
      headers: { 'Authorization': `Bearer ${AuthManager.getFamilyToken()}` }
    })
    return response
  }
  
  static async getHealthRecords(): Promise<ApiResponse> {
    const response = await HttpUtil.get(`${this.BASE_URL}/health-records`, {
      headers: { 'Authorization': `Bearer ${AuthManager.getFamilyToken()}` }
    })
    return response
  }
}
```

**AuthManager.ets - 认证管理器扩展**

```typescript
export class AuthManager {
  // 现有用户Token管理
  private static readonly USER_TOKEN_KEY = 'user_token'
  private static readonly ADMIN_TOKEN_KEY = 'admin_token'
  
  // 新增家属Token管理
  private static readonly FAMILY_TOKEN_KEY = 'family_token'
  private static readonly FAMILY_INFO_KEY = 'family_info'
  
  // 保存家属Token
  static async saveFamilyToken(token: string): Promise<void> {
    await SettingsUtil.put(this.FAMILY_TOKEN_KEY, token)
  }
  
  // 获取家属Token
  static getFamilyToken(): string {
    return SettingsUtil.get(this.FAMILY_TOKEN_KEY, '')
  }
  
  // 保存家属信息
  static async saveFamilyInfo(info: FamilyMember): Promise<void> {
    await SettingsUtil.put(this.FAMILY_INFO_KEY, JSON.stringify(info))
  }
  
  // 获取家属信息
  static getFamilyInfo(): FamilyMember | null {
    const infoStr = SettingsUtil.get(this.FAMILY_INFO_KEY, '')
    return infoStr ? JSON.parse(infoStr) : null
  }
  
  // 清除家属登录信息
  static async clearFamilyAuth(): Promise<void> {
    await SettingsUtil.delete(this.FAMILY_TOKEN_KEY)
    await SettingsUtil.delete(this.FAMILY_INFO_KEY)
  }
  
  // 判断是否为家属登录
  static isFamilyLogin(): boolean {
    return this.getFamilyToken() !== ''
  }
}
```

#### 1.3.2 后端实现设计

**FamilyAuthController.java - 家属认证控制器**

```java
@RestController
@RequestMapping("/api/family")
public class FamilyAuthController {
    
    @Autowired
    private FamilyAuthService familyAuthService;
    
    /**
     * 家属登录
     */
    @PostMapping("/login")
    public Result<FamilyLoginResponse> login(@RequestBody FamilyLoginRequest request) {
        // 1. 参数验证
        if (StringUtils.isEmpty(request.getPhone()) || StringUtils.isEmpty(request.getPassword())) {
            return Result.error("手机号和密码不能为空");
        }
        
        // 2. 调用登录服务
        FamilyLoginResponse response = familyAuthService.login(request);
        
        return Result.success(response);
    }
    
    /**
     * 获取家属信息
     */
    @GetMapping("/info")
    public Result<FamilyMember> getFamilyInfo(HttpServletRequest request) {
        // 从Token中获取家属ID
        Long familyId = JwtUtil.getFamilyIdFromRequest(request);
        
        FamilyMember familyInfo = familyAuthService.getFamilyInfo(familyId);
        return Result.success(familyInfo);
    }
    
    /**
     * 获取家属健康记录
     */
    @GetMapping("/health-records")
    public Result<List<HealthRecord>> getHealthRecords(HttpServletRequest request) {
        Long familyId = JwtUtil.getFamilyIdFromRequest(request);
        
        List<HealthRecord> records = familyAuthService.getHealthRecords(familyId);
        return Result.success(records);
    }
}
```

**FamilyAuthServiceImpl.java - 家属认证服务实现**

```java
@Service
public class FamilyAuthServiceImpl implements FamilyAuthService {
    
    @Autowired
    private FamilyMemberMapper familyMemberMapper;
    
    @Autowired
    private FamilyAuthLogMapper authLogMapper;
    
    @Autowired
    private BCryptPasswordEncoder passwordEncoder;
    
    @Override
    public FamilyLoginResponse login(FamilyLoginRequest request) {
        // 1. 查询家属信息
        FamilyMember family = familyMemberMapper.selectByPhone(request.getPhone());
        if (family == null) {
            throw new BusinessException("手机号不存在");
        }
        
        // 2. 检查登录权限
        if (family.getLoginEnabled() != 1) {
            throw new BusinessException("家属登录功能未开启，请联系用户开启");
        }
        
        // 3. 检查账号锁定
        if (family.getLockUntil() != null && family.getLockUntil().after(new Date())) {
            throw new BusinessException("账号已锁定，请稍后再试");
        }
        
        // 4. 验证密码
        if (!passwordEncoder.matches(request.getPassword(), family.getPassword())) {
            // 登录失败，增加失败次数
            handleLoginFail(family);
            throw new BusinessException("密码错误");
        }
        
        // 5. 登录成功，生成Token
        String token = JwtUtil.generateFamilyToken(family.getId(), family.getPhone());
        
        // 6. 更新登录信息
        family.setLoginFailCount(0);
        family.setLockUntil(null);
        family.setLastLoginTime(new Date());
        familyMemberMapper.updateById(family);
        
        // 7. 记录登录日志
        saveAuthLog(family.getId(), true, null);
        
        // 8. 构建响应
        FamilyLoginResponse response = new FamilyLoginResponse();
        response.setToken(token);
        response.setFamilyInfo(family);
        
        // 查询关联用户信息
        User relatedUser = userMapper.selectById(family.getUserId());
        response.setRelatedUser(relatedUser);
        
        return response;
    }
    
    private void handleLoginFail(FamilyMember family) {
        // 增加失败次数
        int failCount = family.getLoginFailCount() + 1;
        family.setLoginFailCount(failCount);
        
        // 失败3次，锁定30分钟
        if (failCount >= 3) {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.MINUTE, 30);
            family.setLockUntil(cal.getTime());
        }
        
        familyMemberMapper.updateById(family);
        
        // 记录失败日志
        saveAuthLog(family.getId(), false, "密码错误");
    }
    
    private void saveAuthLog(Long familyId, boolean success, String reason) {
        FamilyAuthLog log = new FamilyAuthLog();
        log.setFamilyId(familyId);
        log.setLoginTime(new Date());
        log.setLoginResult(success ? 1 : 0);
        log.setFailReason(reason);
        authLogMapper.insert(log);
    }
}
```

**JwtUtil.java - JWT工具扩展**

```java
public class JwtUtil {
    private static final String SECRET_KEY = "your-secret-key";
    private static final long EXPIRATION = 24 * 60 * 60 * 1000; // 24小时
    
    // 生成家属Token
    public static String generateFamilyToken(Long familyId, String phone) {
        return Jwts.builder()
            .setSubject("FAMILY")
            .claim("familyId", familyId)
            .claim("phone", phone)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION))
            .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
            .compact();
    }
    
    // 从请求中获取家属ID
    public static Long getFamilyIdFromRequest(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            Claims claims = Jwts.parser()
                .setSigningKey(SECRET_KEY)
                .parseClaimsJws(token)
                .getBody();
            
            if ("FAMILY".equals(claims.getSubject())) {
                return claims.get("familyId", Long.class);
            }
        }
        throw new UnauthorizedException("无效的Token");
    }
}
```

## 2. 接口设计

### 2.1 总体设计

家属登录功能提供以下RESTful API接口：

- **认证接口**：登录、登出、Token验证
- **信息查询接口**：家属信息、关联用户信息、健康记录
- **权限管理接口**：开启/关闭登录权限、修改密码

所有接口遵循统一规范：
- 使用JSON格式传输数据
- 使用Bearer Token认证方式
- 统一响应格式：`{ code, message, data }`
- 统一错误处理机制

### 2.2 接口清单

#### 2.2.1 家属登录接口

**接口路径：** `POST /api/family/login`

**请求头：**
```
Content-Type: application/json
```

**请求参数：**
```json
{
  "phone": "13800138000",      // 必填，11位手机号
  "password": "123456"         // 必填，6-20位密码
}
```

**响应数据：**
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "familyInfo": {
      "id": 1,
      "name": "王秀英",
      "phone": "13800138000",
      "relation": "配偶",
      "age": 45,
      "gender": 2,
      "healthCondition": "健康",
      "isEmergencyContact": true
    },
    "relatedUser": {
      "id": 1,
      "name": "王建国",
      "phone": "13900139000",
      "healthCondition": "良好"
    }
  }
}
```

**错误响应：**
```json
{
  "code": 400,
  "message": "手机号不存在",
  "data": null
}
```

#### 2.2.2 获取家属信息接口

**接口路径：** `GET /api/family/info`

**请求头：**
```
Authorization: Bearer {token}
```

**响应数据：**
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "id": 1,
    "name": "王秀英",
    "phone": "13800138000",
    "relation": "配偶",
    "age": 45,
    "gender": 2,
    "idCard": "110101198001011234",
    "address": "北京市朝阳区",
    "healthCondition": "健康",
    "isEmergencyContact": true,
    "userId": 1,
    "createTime": "2026-01-15 10:30:00",
    "updateTime": "2026-03-20 15:45:00"
  }
}
```

#### 2.2.3 获取家属健康记录接口

**接口路径：** `GET /api/family/health-records`

**请求头：**
```
Authorization: Bearer {token}
```

**查询参数：**
```
?page=1&size=10&startDate=2026-01-01&endDate=2026-12-31
```

**响应数据：**
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "total": 25,
    "records": [
      {
        "id": 1,
        "familyId": 1,
        "recordType": "血压",
        "value": "120/80",
        "unit": "mmHg",
        "recordTime": "2026-03-20 08:30:00",
        "remark": "晨起测量"
      },
      {
        "id": 2,
        "familyId": 1,
        "recordType": "血糖",
        "value": "5.6",
        "unit": "mmol/L",
        "recordTime": "2026-03-20 07:00:00",
        "remark": "空腹血糖"
      }
    ]
  }
}
```

#### 2.2.4 开启/关闭家属登录权限接口

**接口路径：** `PUT /api/family/{familyId}/login-enabled`

**请求头：**
```
Authorization: Bearer {user_token}
Content-Type: application/json
```

**请求参数：**
```json
{
  "loginEnabled": 1,           // 0-关闭，1-开启
  "defaultPassword": "123456"  // 可选，设置初始密码
}
```

**响应数据：**
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

#### 2.2.5 家属修改密码接口

**接口路径：** `PUT /api/family/password`

**请求头：**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**请求参数：**
```json
{
  "oldPassword": "123456",
  "newPassword": "654321"
}
```

**响应数据：**
```json
{
  "code": 200,
  "message": "密码修改成功",
  "data": null
}
```

## 3. 数据模型

### 3.1 设计目标

数据模型设计遵循以下原则：
- **扩展性**：在现有family_member表基础上扩展，不影响现有功能
- **安全性**：密码使用BCrypt加密，Token使用JWT签名
- **可追溯性**：记录登录日志，便于安全审计
- **兼容性**：与现有用户系统、权限系统兼容

### 3.2 模型实现

#### 3.2.1 family_member表扩展

**现有字段（保持不变）：**
```sql
id                  BIGINT PRIMARY KEY AUTO_INCREMENT
user_id             BIGINT NOT NULL              -- 关联用户ID
name                VARCHAR(50) NOT NULL         -- 家属姓名
relation            VARCHAR(20) NOT NULL         -- 关系类型
phone               VARCHAR(20)                  -- 手机号
id_card             VARCHAR(18)                  -- 身份证号
gender              TINYINT                      -- 性别：1-男，2-女
age                 INT                          -- 年龄
address             VARCHAR(200)                 -- 地址
health_condition    VARCHAR(500)                 -- 健康状况
is_emergency_contact TINYINT DEFAULT 0           -- 是否紧急联系人
is_deleted          TINYINT DEFAULT 0            -- 逻辑删除标识
create_time         DATETIME                     -- 创建时间
update_time         DATETIME                     -- 更新时间
```

**新增字段：**
```sql
password            VARCHAR(255) NULL            -- 登录密码（BCrypt加密）
username            VARCHAR(50) NULL             -- 登录用户名（可选）
login_enabled       TINYINT(1) DEFAULT 0         -- 是否允许登录：0-否，1-是
login_fail_count    INT DEFAULT 0                -- 登录失败次数
lock_until          DATETIME NULL                -- 账号锁定截止时间
last_login_time     DATETIME NULL                -- 最后登录时间
```

**完整建表SQL：**
```sql
-- 备份现有数据
CREATE TABLE family_member_backup AS SELECT * FROM family_member;

-- 添加新字段
ALTER TABLE family_member 
ADD COLUMN password VARCHAR(255) NULL COMMENT '登录密码（BCrypt加密）',
ADD COLUMN username VARCHAR(50) NULL COMMENT '登录用户名',
ADD COLUMN login_enabled TINYINT(1) DEFAULT 0 COMMENT '是否允许登录',
ADD COLUMN login_fail_count INT DEFAULT 0 COMMENT '登录失败次数',
ADD COLUMN lock_until DATETIME NULL COMMENT '账号锁定截止时间',
ADD COLUMN last_login_time DATETIME NULL COMMENT '最后登录时间';

-- 添加索引
CREATE INDEX idx_phone ON family_member(phone);
CREATE INDEX idx_login_enabled ON family_member(login_enabled);
```

#### 3.2.2 family_auth_log表（新增）

**建表SQL：**
```sql
CREATE TABLE family_auth_log (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    family_id       BIGINT NOT NULL COMMENT '家属ID',
    login_time      DATETIME NOT NULL COMMENT '登录时间',
    login_ip        VARCHAR(50) NULL COMMENT '登录IP地址',
    login_device    VARCHAR(100) NULL COMMENT '登录设备信息',
    login_result    TINYINT NOT NULL COMMENT '登录结果：1-成功，0-失败',
    fail_reason     VARCHAR(200) NULL COMMENT '失败原因',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX idx_family_id (family_id),
    INDEX idx_login_time (login_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家属认证日志表';
```

#### 3.2.3 数据迁移脚本

```sql
-- 为现有家属生成默认密码（手机号后6位）
UPDATE family_member 
SET password = '$2a$10$...' -- BCrypt加密后的手机号后6位
WHERE password IS NULL AND phone IS NOT NULL;

-- 紧急联系人自动开启登录权限
UPDATE family_member 
SET login_enabled = 1 
WHERE is_emergency_contact = 1;

-- 记录迁移日志
INSERT INTO migration_log (table_name, operation, record_count, execute_time)
VALUES ('family_member', 'ADD_LOGIN_FIELDS', (SELECT COUNT(*) FROM family_member), NOW());
```

#### 3.2.4 实体类定义

**FamilyMember.java（扩展）**
```java
@Data
@TableName("family_member")
public class FamilyMember {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    private String name;
    private String relation;
    private String phone;
    private String idCard;
    private Integer gender;
    private Integer age;
    private String address;
    private String healthCondition;
    private Integer isEmergencyContact;
    private Integer isDeleted;
    private Date createTime;
    private Date updateTime;
    
    // 新增字段
    private String password;          // 登录密码
    private String username;          // 登录用户名
    private Integer loginEnabled;     // 是否允许登录
    private Integer loginFailCount;   // 登录失败次数
    private Date lockUntil;           // 账号锁定截止时间
    private Date lastLoginTime;       // 最后登录时间
}
```

**FamilyAuthLog.java（新增）**
```java
@Data
@TableName("family_auth_log")
public class FamilyAuthLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long familyId;
    private Date loginTime;
    private String loginIp;
    private String loginDevice;
    private Integer loginResult;
    private String failReason;
    private Date createTime;
}
```

**FamilyLoginRequest.java**
```java
@Data
public class FamilyLoginRequest {
    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;
    
    @NotBlank(message = "密码不能为空")
    @Length(min = 6, max = 20, message = "密码长度必须在6-20位之间")
    private String password;
}
```

**FamilyLoginResponse.java**
```java
@Data
public class FamilyLoginResponse {
    private String token;
    private FamilyMember familyInfo;
    private User relatedUser;
}
```

## 4. 安全设计

### 4.1 密码安全

- **加密算法**：使用BCrypt算法加密密码
- **盐值**：BCrypt自动生成随机盐值
- **强度**：使用强度10（默认值）
- **传输**：前端使用HTTPS传输，不进行额外加密

### 4.2 Token安全

- **算法**：使用HS256签名算法
- **有效期**：24小时
- **内容**：包含家属ID、手机号、过期时间
- **存储**：前端使用Preferences安全存储
- **验证**：每次请求验证Token有效性

### 4.3 登录安全

- **失败锁定**：连续失败3次，锁定30分钟
- **日志记录**：记录所有登录尝试
- **IP限制**：可选，限制同一IP登录频率
- **设备识别**：记录登录设备信息

### 4.4 权限控制

- **角色定义**：新增FAMILY角色
- **权限范围**：仅能查看自己和关联用户的信息
- **接口保护**：所有接口验证Token和权限
- **数据隔离**：家属只能访问自己的数据

## 5. 性能设计

### 5.1 数据库优化

- **索引**：为phone、login_enabled字段添加索引
- **连接池**：使用HikariCP连接池
- **缓存**：可选，使用Redis缓存Token和家属信息

### 5.2 接口优化

- **响应时间**：登录接口 < 2秒
- **并发支持**：支持100并发登录请求
- **数据分页**：健康记录查询支持分页

### 5.3 前端优化

- **懒加载**：登录页面按需加载
- **缓存**：家属信息本地缓存
- **预加载**：登录成功后预加载常用数据

## 6. 兼容性设计

### 6.1 向后兼容

- 现有family_member表数据不受影响
- 现有家属管理功能正常使用
- 现有用户登录不受影响

### 6.2 前端兼容

- 新增家属登录入口，不影响现有登录入口
- AuthManager支持多种Token类型
- 路由系统支持家属角色

### 6.3 后端兼容

- 新增接口，不影响现有接口
- JWT工具支持多种Token类型
- 权限系统支持FAMILY角色

## 7. 测试设计

### 7.1 单元测试

- 密码加密/解密测试
- Token生成/验证测试
- 登录逻辑测试
- 权限验证测试

### 7.2 集成测试

- 登录流程测试
- Token验证流程测试
- 权限控制测试
- 数据隔离测试

### 7.3 性能测试

- 登录接口响应时间测试
- 并发登录测试
- Token验证性能测试

### 7.4 安全测试

- 密码强度测试
- Token伪造测试
- 暴力破解测试
- SQL注入测试
