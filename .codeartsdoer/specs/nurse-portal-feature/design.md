# 护士端功能 - 技术设计文档

**版本**: v1.0
**创建日期**: 2025-01-09
**最后更新**: 2025-01-09
**作者**: SDD Agent
**状态**: 草稿

## 1. 设计概述

### 1.1 设计目标

将护士端功能无缝集成到现有医疗健康护理系统中，实现：
- **数据层**：创建护士实体表，与现有用户体系建立关联关系
- **服务层**：提供护士认证、信息管理等RESTful API
- **表现层**：开发护士专属页面，保持UI风格一致性
- **安全层**：实现基于JWT的护士身份认证和权限控制

### 1.2 技术选型

| 技术领域 | 技术方案 | 选型理由 |
|---------|---------|---------|
| 前端框架 | HarmonyOS ArkTS (Stage模型) | 与现有项目保持一致，支持跨设备部署 |
| 后端框架 | Spring Boot 2.x + MyBatis Plus | 现有项目已采用，开发效率高 |
| 数据库 | MySQL 8.0+ | 现有数据库，支持事务和外键 |
| 认证方案 | JWT Token (HS256) | 与现有认证体系一致，无状态易扩展 |
| 密码加密 | BCrypt (强度因子10) | 业界标准，防彩虹表攻击 |
| API规范 | RESTful + JSON | 轻端友好，易于前后端联调 |

### 1.3 设计约束

**技术约束**：
- 必须复用现有User表，通过user_id外键关联
- 必须遵循现有Controller-Service-Mapper三层架构
- 必须使用现有的JwtUtil工具类生成Token
- 前端页面必须复用现有组件（Header、Footer、Loading等）

**业务约束**：
- 护士工号全局唯一，格式：字母+数字组合
- 护士账号只能由管理员创建，不可自助注册
- 护士登录后user_type=3，系统据此识别身份

**兼容性约束**：
- 数据库变更需提供SQL迁移脚本
- API变更需保持向后兼容
- 前端路由需在RouteConfig中注册

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                      前端层 (HarmonyOS)                       │
├─────────────────────────────────────────────────────────────┤
│  NurseLogin.ets  │  NurseHomePage.ets  │  NurseProfile.ets  │
│  (护士登录页)     │  (护士工作台)        │  (个人中心)         │
└────────┬─────────┴─────────┬──────────┴──────────┬──────────┘
         │                   │                     │
         └───────────────────┴─────────────────────┘
                             │ HTTP/HTTPS
         ┌───────────────────┴─────────────────────┐
         │              API网关层                    │
         └───────────────────┬─────────────────────┘
                             │
┌────────────────────────────┴────────────────────────────────┐
│                     后端层 (Spring Boot)                      │
├─────────────────────────────────────────────────────────────┤
│  NurseAuthController  │  NurseController                     │
│  (认证控制器)          │  (信息管理控制器)                     │
├───────────────────────┴─────────────────────────────────────┤
│  NurseAuthService  │  NurseService                           │
│  (认证服务)         │  (业务服务)                              │
├────────────────────┴────────────────────────────────────────┤
│  NurseMapper  │  UserMapper                                   │
│  (护士数据访问) │  (用户数据访问)                              │
└────────────────┬────────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────────┐
│                    数据层 (MySQL)                             │
├─────────────────────────────────────────────────────────────┤
│  user表 (用户基础表)  ←────外键关联────→  nurse表 (护士信息表)  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

| 模块名称 | 职责说明 | 关键文件 |
|---------|---------|---------|
| **数据模型模块** | 定义护士实体和数据传输对象 | Nurse.java, NurseLoginRequest.java |
| **数据访问模块** | 封装护士表CRUD操作 | NurseMapper.java, NurseMapper.xml |
| **业务服务模块** | 实现护士业务逻辑 | NurseAuthService.java, NurseService.java |
| **控制器模块** | 提供RESTful API接口 | NurseAuthController.java, NurseController.java |
| **前端页面模块** | 实现护士端UI界面 | NurseLogin.ets, NurseHomePage.ets |
| **前端服务模块** | 封装护士API调用 | NurseService.ets |

### 2.3 依赖关系

```
前端页面 → 前端服务 → HTTP工具 → 后端控制器 → 业务服务 → 数据访问 → 数据库
    ↓           ↓           ↓           ↓           ↓
  组件层      工具层      网络层      接口层      业务层
```

**依赖规则**：
- 上层可依赖下层，下层不可依赖上层
- 同层模块间通过接口通信
- 跨层通信必须通过服务层中转

## 3. 模块详细设计

### 3.1 数据模型模块

#### 3.1.1 职责定义
定义护士相关的实体类、DTO类，负责数据结构定义和验证规则。

#### 3.1.2 类/接口设计

**Nurse实体类**：
```java
@Data
@TableName("nurse")
public class Nurse {
    @TableId(type = IdType.AUTO)
    private Long id;                    // 主键ID
    
    @TableField("user_id")
    private Long userId;                // 关联用户ID（外键）
    
    @TableField("nurse_number")
    private String nurseNumber;         // 护士工号（唯一）
    
    @TableField("real_name")
    private String realName;            // 真实姓名
    
    private String phone;               // 手机号
    
    private String department;          // 所属科室
    
    private String title;               // 职称
    
    private String avatar;              // 头像URL
    
    private Integer status;             // 状态：0-待激活，1-正常，2-禁用
    
    @TableField("create_time")
    private Date createTime;            // 创建时间
    
    @TableField("update_time")
    private Date updateTime;            // 更新时间
    
    @TableField("is_deleted")
    private Integer isDeleted;          // 逻辑删除标记
}
```

**NurseLoginRequest DTO**：
```java
@Data
public class NurseLoginRequest {
    @NotBlank(message = "工号不能为空")
    @Pattern(regexp = "^[A-Za-z0-9]{4,20}$", message = "工号格式不正确")
    private String nurseNumber;         // 护士工号
    
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度必须在6-20位之间")
    private String password;            // 密码
}
```

**NurseLoginResponse DTO**：
```java
@Data
public class NurseLoginResponse {
    private String token;               // JWT Token
    private Long nurseId;               // 护士ID
    private String realName;            // 真实姓名
    private String department;          // 所属科室
    private String title;               // 职称
    private String avatar;              // 头像URL
}
```

#### 3.1.3 关键方法
- `validate()`: 数据验证方法
- `toMap()`: 转换为Map用于JSON序列化

### 3.2 数据访问模块

#### 3.2.1 职责定义
封装护士表的数据库操作，提供CRUD和查询功能。

#### 3.2.2 接口设计

**NurseMapper接口**：
```java
public interface NurseMapper extends BaseMapper<Nurse> {
    /**
     * 根据工号查询护士
     */
    @Select("SELECT n.*, u.username, u.password FROM nurse n " +
            "LEFT JOIN user u ON n.user_id = u.id " +
            "WHERE n.nurse_number = #{nurseNumber} AND n.is_deleted = 0")
    Nurse selectByNurseNumber(@Param("nurseNumber") String nurseNumber);
    
    /**
     * 根据用户ID查询护士
     */
    @Select("SELECT * FROM nurse WHERE user_id = #{userId} AND is_deleted = 0")
    Nurse selectByUserId(@Param("userId") Long userId);
    
    /**
     * 更新护士状态
     */
    @Update("UPDATE nurse SET status = #{status}, update_time = NOW() " +
            "WHERE id = #{id}")
    int updateStatus(@Param("id") Long id, @Param("status") Integer status);
}
```

#### 3.2.3 数据流
```
Service调用 → Mapper接口 → SQL执行 → 结果映射 → 返回实体
```

### 3.3 业务服务模块

#### 3.3.1 职责定义
实现护士认证、信息管理等核心业务逻辑。

#### 3.3.2 类设计

**NurseAuthService认证服务**：
```java
@Service
public class NurseAuthService {
    @Autowired
    private NurseMapper nurseMapper;
    
    @Autowired
    private UserMapper userMapper;
    
    /**
     * 护士登录认证
     * @param request 登录请求
     * @return 登录响应（含Token）
     */
    public NurseLoginResponse login(NurseLoginRequest request) {
        // 1. 根据工号查询护士
        Nurse nurse = nurseMapper.selectByNurseNumber(request.getNurseNumber());
        if (nurse == null) {
            throw new BusinessException("工号不存在");
        }
        
        // 2. 检查护士状态
        if (nurse.getStatus() != 1) {
            throw new BusinessException("账号未激活或已禁用");
        }
        
        // 3. 查询关联用户并验证密码
        User user = userMapper.selectById(nurse.getUserId());
        if (!BCryptUtil.checkpw(request.getPassword(), user.getPassword())) {
            throw new BusinessException("密码错误");
        }
        
        // 4. 生成JWT Token
        String token = JwtUtil.generateNurseToken(nurse.getId(), nurse.getNurseNumber());
        
        // 5. 构建响应
        NurseLoginResponse response = new NurseLoginResponse();
        response.setToken(token);
        response.setNurseId(nurse.getId());
        response.setRealName(nurse.getRealName());
        response.setDepartment(nurse.getDepartment());
        response.setTitle(nurse.getTitle());
        response.setAvatar(nurse.getAvatar());
        
        return response;
    }
    
    /**
     * 获取护士信息
     */
    public Nurse getNurseInfo(Long nurseId) {
        Nurse nurse = nurseMapper.selectById(nurseId);
        if (nurse == null) {
            throw new BusinessException("护士信息不存在");
        }
        return nurse;
    }
}
```

**NurseService业务服务**：
```java
@Service
public class NurseService {
    @Autowired
    private NurseMapper nurseMapper;
    
    /**
     * 更新护士信息
     */
    public boolean updateNurseInfo(Long nurseId, NurseUpdateRequest request) {
        Nurse nurse = nurseMapper.selectById(nurseId);
        if (nurse == null) {
            throw new BusinessException("护士不存在");
        }
        
        // 只允许更新部分字段
        if (request.getPhone() != null) {
            nurse.setPhone(request.getPhone());
        }
        if (request.getAvatar() != null) {
            nurse.setAvatar(request.getAvatar());
        }
        nurse.setUpdateTime(new Date());
        
        return nurseMapper.updateById(nurse) > 0;
    }
    
    /**
     * 注册护士（管理员调用）
     */
    @Transactional
    public Long registerNurse(NurseRegisterRequest request) {
        // 1. 检查工号是否已存在
        Nurse existing = nurseMapper.selectByNurseNumber(request.getNurseNumber());
        if (existing != null) {
            throw new BusinessException("工号已存在");
        }
        
        // 2. 创建用户记录
        User user = new User();
        user.setUsername(request.getNurseNumber());
        user.setPassword(BCryptUtil.hashpw(request.getPassword(), BCryptUtil.gensalt(10)));
        user.setPhone(request.getPhone());
        user.setUserType(3);  // 护士类型
        user.setCreateTime(new Date());
        user.setIsDeleted(0);
        userMapper.insert(user);
        
        // 3. 创建护士记录
        Nurse nurse = new Nurse();
        nurse.setUserId(user.getId());
        nurse.setNurseNumber(request.getNurseNumber());
        nurse.setRealName(request.getRealName());
        nurse.setPhone(request.getPhone());
        nurse.setDepartment(request.getDepartment());
        nurse.setTitle(request.getTitle());
        nurse.setStatus(0);  // 待激活
        nurse.setCreateTime(new Date());
        nurse.setIsDeleted(0);
        nurseMapper.insert(nurse);
        
        return nurse.getId();
    }
}
```

### 3.4 控制器模块

#### 3.4.1 职责定义
提供RESTful API接口，处理HTTP请求和响应。

#### 3.4.2 接口设计

**NurseAuthController认证控制器**：
```java
@RestController
@RequestMapping("/nurse")
@CrossOrigin
@Validated
public class NurseAuthController {
    @Autowired
    private NurseAuthService nurseAuthService;
    
    /**
     * 护士登录
     * POST /nurse/login
     */
    @PostMapping("/login")
    public Result<?> login(@Valid @RequestBody NurseLoginRequest request) {
        try {
            NurseLoginResponse response = nurseAuthService.login(request);
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
    
    /**
     * 获取护士信息
     * GET /nurse/info
     */
    @GetMapping("/info")
    public Result<?> getNurseInfo(HttpServletRequest request) {
        try {
            String token = extractToken(request);
            if (!JwtUtil.isNurseToken(token)) {
                return Result.error("无效的护士Token");
            }
            
            Long nurseId = JwtUtil.getNurseId(token);
            Nurse nurseInfo = nurseAuthService.getNurseInfo(nurseId);
            return Result.success(nurseInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
    
    private String extractToken(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            return token.substring(7);
        }
        return token;
    }
}
```

**NurseController信息管理控制器**：
```java
@RestController
@RequestMapping("/nurse")
@CrossOrigin
public class NurseController {
    @Autowired
    private NurseService nurseService;
    
    /**
     * 更新护士信息
     * PUT /nurse/info
     */
    @PutMapping("/info")
    public Result<?> updateNurseInfo(
            HttpServletRequest request,
            @RequestBody NurseUpdateRequest updateRequest) {
        try {
            String token = extractToken(request);
            Long nurseId = JwtUtil.getNurseId(token);
            
            boolean success = nurseService.updateNurseInfo(nurseId, updateRequest);
            return success ? Result.success("更新成功") : Result.error("更新失败");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
    
    /**
     * 注册护士（管理员调用）
     * POST /nurse/register
     */
    @PostMapping("/register")
    public Result<?> registerNurse(@RequestBody NurseRegisterRequest request) {
        try {
            Long nurseId = nurseService.registerNurse(request);
            Map<String, Object> result = new HashMap<>();
            result.put("nurseId", nurseId);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
```

### 3.5 前端页面模块

#### 3.5.1 职责定义
实现护士端UI界面，处理用户交互和页面跳转。

#### 3.5.2 页面设计

**NurseLogin.ets（护士登录页）**：
```typescript
@Entry
@Component
struct NurseLogin {
  @State nurseNumber: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  
  // 核心方法
  private async handleLogin(): Promise<void> {
    // 1. 验证输入
    // 2. 调用登录API
    // 3. 保存Token和护士信息
    // 4. 跳转到工作台
  }
  
  build() {
    Column() {
      Header({ title: '护士登录' })
      
      // 工号输入框
      TextInput({ placeholder: '请输入工号', text: this.nurseNumber })
        .onChange((value) => { this.nurseNumber = value; })
      
      // 密码输入框
      TextInput({ placeholder: '请输入密码', text: this.password })
        .type(InputType.Password)
        .onChange((value) => { this.password = value; })
      
      // 登录按钮
      Button('登录')
        .onClick(() => this.handleLogin())
    }
  }
}
```

**NurseHomePage.ets（护士工作台）**：
```typescript
@Entry
@Component
struct NurseHomePage {
  @State nurseInfo: NurseInfo | null = null;
  @State patientList: Patient[] = [];
  
  async aboutToAppear() {
    // 加载护士信息
    // 加载患者列表
  }
  
  build() {
    Column() {
      // 顶部导航栏
      this.buildHeader();
      
      // 工作台内容
      Scroll() {
        Column() {
          // 欢迎卡片
          this.buildWelcomeCard();
          
          // 今日任务
          this.buildTaskList();
          
          // 患者列表
          this.buildPatientList();
        }
      }
      
      // 底部导航
      this.buildBottomNav();
    }
  }
}
```

## 4. 数据模型设计

### 4.1 核心数据结构

**护士信息接口（前端）**：
```typescript
interface NurseInfo {
  id: number;
  nurseNumber: string;
  realName: string;
  phone: string;
  department: string;
  title: string;
  avatar: string;
  status: number;
}
```

**登录响应接口（前端）**：
```typescript
interface NurseLoginResponse {
  token: string;
  nurseId: number;
  realName: string;
  department: string;
  title: string;
  avatar: string;
}
```

### 4.2 数据关系

```
┌──────────────┐
│    user表     │
│  (用户基础)   │
├──────────────┤
│ id (PK)      │
│ username     │
│ password     │
│ user_type=3  │ ← 护士类型标识
│ phone        │
│ create_time  │
└──────┬───────┘
       │ 1:1
       │
       │ user_id (FK)
       │
┌──────┴───────┐
│   nurse表     │
│  (护士信息)   │
├──────────────┤
│ id (PK)      │
│ user_id (FK) │
│ nurse_number │ ← 工号（唯一）
│ real_name    │
│ department   │
│ title        │
│ avatar       │
│ status       │
│ create_time  │
└──────────────┘
```

### 4.3 数据存储

**数据库表创建SQL**：
```sql
-- 创建护士表
CREATE TABLE IF NOT EXISTS `nurse` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` BIGINT NOT NULL COMMENT '关联用户ID',
  `nurse_number` VARCHAR(50) NOT NULL COMMENT '护士工号',
  `real_name` VARCHAR(100) NOT NULL COMMENT '真实姓名',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `department` VARCHAR(100) DEFAULT NULL COMMENT '所属科室',
  `title` VARCHAR(50) DEFAULT NULL COMMENT '职称',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
  `status` TINYINT DEFAULT 0 COMMENT '状态：0-待激活，1-正常，2-禁用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_nurse_number` (`nurse_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_department` (`department`),
  CONSTRAINT `fk_nurse_user` FOREIGN KEY (`user_id`) 
    REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='护士信息表';
```

## 5. API设计

### 5.1 内部API

**护士认证API**：

| 接口 | 方法 | 路径 | 说明 |
|-----|------|------|------|
| 护士登录 | POST | /nurse/login | 工号+密码登录，返回Token |
| 获取信息 | GET | /nurse/info | 获取当前护士详细信息 |
| 验证Token | GET | /nurse/verify-token | 验证Token有效性 |

**护士管理API**：

| 接口 | 方法 | 路径 | 说明 |
|-----|------|------|------|
| 更新信息 | PUT | /nurse/info | 更新护士个人信息 |
| 注册护士 | POST | /nurse/register | 管理员创建护士账号 |

### 5.2 外部API

**与用户体系集成**：
- 复用User表存储护士账号密码
- 通过user_type=3标识护士身份
- 复用JwtUtil生成和验证Token

**与前端集成**：
- 所有接口返回统一格式：`{ code, message, data }`
- Token放在Header：`Authorization: Bearer {token}`
- 错误码遵循现有ResponseCode定义

### 5.3 API规范

**请求示例**：
```json
POST /nurse/login
Content-Type: application/json

{
  "nurseNumber": "N20230001",
  "password": "123456"
}
```

**响应示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "nurseId": 1,
    "realName": "张护士",
    "department": "内科",
    "title": "护师",
    "avatar": "https://example.com/avatar.jpg"
  }
}
```

## 6. 关键算法设计

### 6.1 护士身份识别算法

#### 算法原理
通过JWT Token的payload中的标识字段识别护士身份。

#### 实现逻辑
```java
public class JwtUtil {
    private static final String NURSE_TOKEN_PREFIX = "NURSE_";
    
    /**
     * 生成护士Token
     */
    public static String generateNurseToken(Long nurseId, String nurseNumber) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("nurseId", nurseId);
        claims.put("nurseNumber", nurseNumber);
        claims.put("type", NURSE_TOKEN_PREFIX);  // 护士标识
        
        return Jwts.builder()
            .setClaims(claims)
            .setExpiration(new Date(System.currentTimeMillis() + 24 * 60 * 60 * 1000))
            .signWith(SignatureAlgorithm.HS256, SECRET)
            .compact();
    }
    
    /**
     * 判断是否为护士Token
     */
    public static boolean isNurseToken(String token) {
        try {
            Claims claims = Jwts.parser()
                .setSigningKey(SECRET)
                .parseClaimsJws(token)
                .getBody();
            return NURSE_TOKEN_PREFIX.equals(claims.get("type"));
        } catch (Exception e) {
            return false;
        }
    }
}
```

#### 复杂度分析
- 时间复杂度：O(1)，Token解析为常数时间
- 空间复杂度：O(1)，只存储少量claims

## 7. UI/UX设计

### 7.1 页面结构

```
护士端页面层级：
├── NurseLogin (护士登录页)
│   └── 跳转到 NurseHomePage
├── NurseHomePage (护士工作台)
│   ├── 欢迎卡片
│   ├── 今日任务列表
│   ├── 患者列表
│   └── 底部导航栏
│       ├── 首页 (当前页)
│       ├── 患者
│       ├── 消息
│       └── 我的 → NurseProfile
└── NurseProfile (个人中心)
    ├── 头像和基本信息
    ├── 功能菜单
    └── 退出登录
```

### 7.2 组件设计

**护士登录页组件**：

| 组件 | 属性 | 说明 |
|-----|------|------|
| Header | title='护士登录', showBack=true | 顶部导航栏 |
| TextInput | placeholder='请输入工号' | 工号输入框 |
| TextInput | type=Password | 密码输入框 |
| Button | text='登录' | 登录按钮 |
| Loading | visible=isLoading | 加载状态 |

**护士工作台组件**：

| 组件 | 属性 | 说明 |
|-----|------|------|
| NurseHeader | nurseInfo | 护士信息头部 |
| WelcomeCard | nurseName, department | 欢迎卡片 |
| TaskList | tasks[] | 今日任务列表 |
| PatientList | patients[] | 患者列表 |
| BottomNav | activeIndex=0 | 底部导航栏 |

### 7.3 交互流程

```
用户打开护士登录页
    ↓
输入工号和密码
    ↓
点击登录按钮
    ↓
前端验证输入格式
    ↓
调用POST /nurse/login
    ↓
后端验证工号和密码
    ↓
生成JWT Token
    ↓
返回Token和护士信息
    ↓
前端保存Token到本地存储
    ↓
跳转到护士工作台
    ↓
显示欢迎信息和功能模块
```

## 8. 性能设计

### 8.1 性能目标

| 指标 | 目标值 | 测量方法 |
|-----|--------|---------|
| 登录接口响应时间 | < 500ms | Postman/JMeter测试 |
| 页面首屏加载时间 | < 2s | DevTools Profiler |
| 列表滚动帧率 | ≥ 60fps | 性能监视器 |
| Token验证时间 | < 50ms | 单元测试 |

### 8.2 优化策略

**后端优化**：
- 数据库查询添加索引（nurse_number, user_id）
- 使用连接查询减少数据库访问次数
- Token验证使用缓存减少数据库查询

**前端优化**：
- 页面使用懒加载，按需加载数据
- 列表使用虚拟滚动处理大数据集
- 图片使用缓存和占位图
- 网络请求使用防抖避免重复调用

### 8.3 监控方案

- 后端：使用Spring Actuator监控接口性能
- 前端：使用HiLog记录关键操作耗时
- 数据库：开启慢查询日志，阈值1秒

## 9. 安全设计

### 9.1 数据安全

**密码安全**：
- 使用BCrypt加密，强度因子10
- 密码不明文存储，不记录日志
- 传输使用HTTPS加密

**Token安全**：
- JWT签名使用HS256算法
- Token有效期24小时
- Token包含用户类型标识，防止越权
- Token存储使用安全存储API

### 9.2 权限控制

**接口权限**：
```java
// 护士接口需要验证Token和用户类型
@GetMapping("/nurse/info")
public Result<?> getNurseInfo(HttpServletRequest request) {
    String token = extractToken(request);
    
    // 1. 验证Token有效性
    if (!JwtUtil.validateToken(token)) {
        return Result.error(401, "Token无效或已过期");
    }
    
    // 2. 验证是否为护士Token
    if (!JwtUtil.isNurseToken(token)) {
        return Result.error(403, "无权访问");
    }
    
    // 3. 执行业务逻辑
    // ...
}
```

**数据权限**：
- 护士只能查看和修改自己的信息
- 护士只能查看负责的患者信息
- 敏感字段（如密码）不返回给前端

### 9.3 安全审计

**审计点**：
- 登录成功/失败记录日志
- 信息修改记录操作日志
- 异常访问记录安全日志
- 定期审计护士账号状态

## 10. 测试设计

### 10.1 测试策略

**测试金字塔**：
- 单元测试（70%）：Service层业务逻辑
- 集成测试（20%）：Controller层接口测试
- E2E测试（10%）：完整登录流程测试

### 10.2 测试用例

**护士登录测试用例**：

| 用例ID | 场景 | 输入 | 预期结果 |
|--------|------|------|---------|
| TC-001 | 正常登录 | 正确工号和密码 | 返回Token和护士信息 |
| TC-002 | 工号不存在 | 错误工号 | 返回"工号不存在" |
| TC-003 | 密码错误 | 正确工号，错误密码 | 返回"密码错误" |
| TC-004 | 账号未激活 | 未激活账号 | 返回"账号未激活" |
| TC-005 | 账号已禁用 | 已禁用账号 | 返回"账号已禁用" |
| TC-006 | 空工号 | 工号为空 | 返回"工号不能为空" |
| TC-007 | 空密码 | 密码为空 | 返回"密码不能为空" |

**护士信息管理测试用例**：

| 用例ID | 场景 | 输入 | 预期结果 |
|--------|------|------|---------|
| TC-008 | 获取信息 | 有效Token | 返回护士完整信息 |
| TC-009 | 无效Token | 无效Token | 返回401错误 |
| TC-010 | 更新手机号 | 新手机号 | 更新成功 |
| TC-011 | 更新头像 | 新头像URL | 更新成功 |

### 10.3 Mock数据

**护士测试数据**：
```sql
-- 测试护士账号
INSERT INTO user (username, password, user_type, phone, create_time, is_deleted)
VALUES ('N20230001', '$2a$10$...', 3, '13800138001', NOW(), 0);

INSERT INTO nurse (user_id, nurse_number, real_name, phone, department, title, status, create_time, is_deleted)
VALUES (LAST_INSERT_ID(), 'N20230001', '张护士', '13800138001', '内科', '护师', 1, NOW(), 0);
```

## 11. 部署设计

### 11.1 环境要求

**开发环境**：
- JDK 1.8+
- Maven 3.6+
- MySQL 8.0+
- HarmonyOS SDK 3.0+

**生产环境**：
- 服务器：2核4G以上
- 数据库：MySQL 8.0主从配置
- 网络：HTTPS，带宽10Mbps以上

### 11.2 配置管理

**后端配置**：
```yaml
# application.yml
jwt:
  secret: ${JWT_SECRET:your-secret-key}
  expiration: 86400000  # 24小时

nurse:
  default-password: 123456  # 初始密码
  token-prefix: NURSE_
```

**前端配置**：
```typescript
// config.ets
export const NurseConfig = {
  LOGIN_URL: '/nurse/login',
  INFO_URL: '/nurse/info',
  TOKEN_KEY: 'nurseToken',
  INFO_KEY: 'nurseInfo'
};
```

### 11.3 发布流程

**数据库发布**：
1. 备份现有数据库
2. 执行nurse表创建SQL
3. 验证表结构和索引

**后端发布**：
1. 编译打包：`mvn clean package`
2. 停止旧服务
3. 部署新JAR包
4. 启动服务并验证

**前端发布**：
1. 编译构建：`hvigorw assembleHap`
2. 安装测试：在测试设备验证
3. 发布HAP包

## 12. 附录

### 12.1 术语表

| 术语 | 定义 |
|-----|------|
| JWT | JSON Web Token，无状态身份认证令牌 |
| BCrypt | 基于Blowfish的密码哈希算法 |
| DTO | Data Transfer Object，数据传输对象 |
| ORM | Object-Relational Mapping，对象关系映射 |
| RESTful | 符合REST架构风格的Web API |

### 12.2 参考资料

- 现有认证实现：`FamilyAuthController.java`
- 现有登录页面：`FamilyLogin.ets`
- JWT工具类：`JwtUtil.java`
- 密码工具类：`BCryptUtil.java`
- MyBatis Plus文档：https://baomidou.com/

### 12.3 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2025-01-09 | 初始版本，完成护士端技术设计 | SDD Agent |
