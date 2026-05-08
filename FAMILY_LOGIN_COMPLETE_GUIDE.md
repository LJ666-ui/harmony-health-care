# 家属登录功能 - 完整使用指南

## ✅ 功能已完成

家属登录功能已全部开发完成，包括：
- ✅ 数据库配置
- ✅ 后端接口
- ✅ 前端页面
- ✅ 路由配置

---

## 🎯 家属登录入口

### 方式1：直接访问家属登录页面
```
pages/FamilyLogin.ets
```

### 方式2：在用户登录页面添加入口（推荐）

修改 `pages/Login.ets`，在登录按钮下方添加：

```typescript
// 在登录按钮后添加
Button('家属登录')
  .fontSize(14)
  .fontColor(GlobalTheme.colors.primary)
  .backgroundColor(Color.Transparent)
  .margin({ top: 20 })
  .onClick(() => {
    router.pushUrl({
      url: 'pages/FamilyLogin'
    });
  })
```

---

## 📱 家属专属页面

### 1. 家属登录页面
**文件：** `pages/FamilyLogin.ets`

**功能：**
- 手机号输入
- 密码输入
- 登录验证
- Token保存
- 跳转到家属主页

**访问方式：**
```typescript
router.pushUrl({ url: 'pages/FamilyLogin' });
```

### 2. 家属主页
**文件：** `pages/FamilyHome.ets`

**功能：**
- 显示家属个人信息
- 显示健康状况
- 功能菜单（健康记录、关联用户、修改密码等）
- 退出登录

**访问方式：**
- 登录成功后自动跳转
- 或直接访问：`router.pushUrl({ url: 'pages/FamilyHome' });`

---

## 🔐 可登录的家属账号

根据数据库配置，以下家属可以登录：

| 姓名 | 手机号 | 密码 | 关系 | 状态 |
|------|--------|------|------|------|
| 王秀英 | 13912345001 | 123456 | 配偶 | ✅ 可登录 |
| 李强 | 13812345003 | 123456 | 配偶 | ✅ 可登录 |

**说明：**
- 这两位是紧急联系人，已自动开启登录权限
- 其他家属需要用户在"家属管理"页面手动开启

---

## 🚀 使用流程

### 家属登录流程：

1. **打开APP**
   - 在用户登录页面点击"家属登录"
   - 或直接访问家属登录页面

2. **输入账号信息**
   - 手机号：13912345001（王秀英）
   - 密码：123456

3. **点击登录**
   - 系统验证手机号和密码
   - 检查登录权限（login_enabled）
   - 生成JWT Token
   - 保存登录状态

4. **进入家属主页**
   - 显示家属个人信息
   - 显示健康状况
   - 提供功能菜单

5. **使用功能**
   - 查看健康记录
   - 查看关联用户信息
   - 修改密码
   - 接收健康提醒

---

## 📡 后端接口

### 1. 家属登录
```
POST /family/login
```

**请求：**
```json
{
  "phone": "13912345001",
  "password": "123456"
}
```

**响应：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "familyInfo": {
      "id": 1,
      "name": "王秀英",
      "phone": "13912345001",
      "relation": "配偶",
      "isEmergencyContact": 1
    },
    "relatedUser": {
      "id": 1,
      "username": "王建国"
    }
  }
}
```

### 2. 获取家属信息
```
GET /family/info
Authorization: Bearer {token}
```

### 3. 开启/关闭登录权限
```
PUT /family/{familyId}/login-enabled
Authorization: Bearer {user_token}
```

**请求：**
```json
{
  "loginEnabled": 1,
  "defaultPassword": "123456"
}
```

---

## 📂 文件结构

### 后端文件：
```
src/main/java/com/example/medical/
├── controller/
│   └── FamilyAuthController.java       # 家属认证控制器
├── service/
│   ├── FamilyAuthService.java          # 家属认证服务接口
│   └── impl/
│       └── FamilyAuthServiceImpl.java  # 家属认证服务实现
├── mapper/
│   ├── FamilyMemberMapper.java         # 家属数据访问
│   └── FamilyAuthLogMapper.java        # 认证日志访问
├── entity/
│   ├── FamilyMember.java               # 家属实体
│   └── FamilyAuthLog.java              # 认证日志实体
├── dto/
│   ├── FamilyLoginRequest.java         # 登录请求DTO
│   └── FamilyLoginResponse.java        # 登录响应DTO
└── common/
    └── JwtUtil.java                    # JWT工具（已扩展）
```

### 前端文件：
```
entry/src/main/ets/
├── pages/
│   ├── FamilyLogin.ets                 # 家属登录页面
│   └── FamilyHome.ets                  # 家属主页
└── utils/
    └── SettingsUtil.ets                # 设置工具（已扩展）
```

### 数据库文件：
```
sql/
├── family_login_upgrade_enhanced.sql   # 增强版升级脚本
├── family_login_rollback_enhanced.sql  # 回滚脚本
├── check_and_fix.sql                   # 修复脚本
└── FAMILY_LOGIN_GUIDE.md               # 使用指南
```

---

## ⚙️ 配置说明

### 1. 数据库配置
已自动完成：
- ✅ family_member表已添加登录字段
- ✅ family_auth_log表已创建
- ✅ 紧急联系人已开启登录权限

### 2. 后端配置
已自动完成：
- ✅ JwtUtil已扩展家属Token生成方法
- ✅ 所有接口已实现
- ✅ BCrypt密码验证已配置

### 3. 前端配置
已自动完成：
- ✅ SettingsUtil已扩展家属Token管理
- ✅ 登录页面已创建
- ✅ 家属主页已创建

---

## 🔧 开启其他家属登录权限

### 方式1：数据库直接修改
```sql
UPDATE family_member
SET login_enabled = 1
WHERE id = 家属ID;
```

### 方式2：通过接口（需开发管理页面）
```
PUT /family/{familyId}/login-enabled
```

---

## 🧪 测试步骤

### 1. 启动后端
```bash
cd src/main/java
mvn spring-boot:run
```

### 2. 启动前端
在DevEco Studio中运行项目

### 3. 测试登录
1. 打开APP
2. 点击"家属登录"
3. 输入手机号：13912345001
4. 输入密码：123456
5. 点击登录
6. 验证是否跳转到家属主页

### 4. 测试功能
1. 查看个人信息是否正确
2. 查看健康状况是否显示
3. 点击退出登录
4. 验证是否返回登录页面

---

## ⚠️ 注意事项

### 1. 密码安全
- 所有密码已BCrypt加密
- 后端使用BCrypt验证
- 前端传输明文密码（HTTPS）

### 2. Token管理
- 家属Token与用户Token分离
- Token有效期24小时
- Token存储在Preferences中

### 3. 权限控制
- 家属只能查看自己的信息
- 家属只能查看关联用户的信息
- 家属不能修改关联用户的信息

### 4. 登录权限
- 紧急联系人自动开启
- 其他家属需手动开启
- 用户在家属管理页面控制

---

## 📞 常见问题

### Q1: 家属无法登录？
**A:**
1. 检查login_enabled是否为1
2. 检查phone字段是否有值
3. 检查password字段是否有值
4. 检查后端是否正常运行

### Q2: Token验证失败？
**A:**
1. 检查Token是否过期
2. 检查Token是否为家属Token
3. 检查Authorization头是否正确

### Q3: 页面无法跳转？
**A:**
1. 检查路由配置
2. 检查页面路径是否正确
3. 检查是否有编译错误

---

## 🎉 完成！

家属登录功能已全部开发完成，现在可以：

1. ✅ 家属使用手机号和密码登录
2. ✅ 家属查看个人信息
3. ✅ 家属查看健康状况
4. ✅ 家属使用专属功能
5. ✅ 用户管理家属登录权限

**立即测试：**
1. 启动后端服务
2. 运行前端应用
3. 使用测试账号登录：13912345001 / 123456

🎯
