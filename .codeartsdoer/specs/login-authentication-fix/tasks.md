# 登录认证系统修复 - 编码任务规划

**版本**: v1.0
**创建日期**: 2026-05-08
**最后更新**: 2026-05-08
**作者**: 项目经理
**状态**: 待执行

## 任务概述

本文档将登录认证系统修复需求分解为具体的编码任务，按照优先级和依赖关系组织，确保开发人员能够按顺序执行。

**任务统计**：
- 主任务：8个
- 子任务：24个
- 预计总工时：7个工作日

---

## 任务1: 数据库表结构验证与修复

**优先级**: P0
**预计工时**: 0.5天
**依赖**: 无

### 任务描述
验证family_member表和nurse表的结构是否满足登录认证需求，必要时执行数据库迁移脚本。

### 输入
- 现有数据库表结构
- `sql/family_login_complete.sql`脚本

### 输出
- 验证通过的数据库表结构
- 数据库迁移执行报告

### 验收标准
- [ ] family_member表包含password、login_enabled、login_fail_count、lock_until、last_login_time字段
- [ ] nurse表包含password、status字段
- [ ] family_auth_log表存在
- [ ] phone字段已建立索引
- [ ] 示例数据已正确插入

### 子任务

#### 1.1 检查family_member表结构
**描述**: 连接数据库，检查family_member表是否存在必需字段
**执行步骤**:
1. 执行`DESC family_member`查看表结构
2. 验证password、login_enabled、login_fail_count、lock_until、last_login_time字段存在
3. 若字段缺失，记录需要补充的字段

#### 1.2 检查nurse表结构
**描述**: 连接数据库，检查nurse表是否存在必需字段
**执行步骤**:
1. 执行`DESC nurse`查看表结构
2. 验证password、status字段存在
3. 若字段缺失，记录需要补充的字段

#### 1.3 执行数据库迁移
**描述**: 若表结构不完整，执行迁移脚本
**执行步骤**:
1. 备份现有数据
2. 执行`sql/family_login_complete.sql`脚本
3. 验证迁移结果
4. 记录迁移日志

### 代码生成提示
```
请检查数据库表结构，执行以下SQL验证：

-- 检查family_member表
DESC family_member;

-- 检查nurse表
DESC nurse;

-- 检查family_auth_log表
DESC family_auth_log;

-- 验证索引
SHOW INDEX FROM family_member;

若表结构不完整，请执行sql/family_login_complete.sql脚本进行迁移。
```

---

## 任务2: 后端JwtUtil工具类扩展

**优先级**: P0
**预计工时**: 0.5天
**依赖**: 任务1

### 任务描述
扩展JwtUtil工具类，确保家属和护士Token生成、验证方法完整。

### 输入
- 现有JwtUtil.java代码
- Token结构设计规范

### 输出
- 更新后的JwtUtil.java
- 单元测试用例

### 验收标准
- [ ] generateFamilyToken方法存在且正确生成Token
- [ ] generateNurseToken方法存在且正确生成Token
- [ ] isFamilyToken方法能正确判断Token类型
- [ ] isNurseToken方法能正确判断Token类型
- [ ] getFamilyId方法能正确提取家属ID
- [ ] getNurseId方法能正确提取护士ID
- [ ] Token包含正确的subject标识（FAMILY/NURSE）

### 子任务

#### 2.1 验证家属Token方法
**描述**: 检查JwtUtil中家属Token相关方法是否完整
**执行步骤**:
1. 打开`src/main/java/com/example/medical/common/JwtUtil.java`
2. 检查generateFamilyToken、isFamilyToken、getFamilyId方法
3. 若方法缺失或不正确，进行补充或修正

#### 2.2 验证护士Token方法
**描述**: 检查JwtUtil中护士Token相关方法是否完整
**执行步骤**:
1. 检查generateNurseToken、isNurseToken、getNurseId方法
2. 若方法缺失或不正确，进行补充或修正

#### 2.3 编写单元测试
**描述**: 为Token方法编写单元测试
**执行步骤**:
1. 创建JwtUtilTest.java测试类
2. 测试Token生成、解析、验证功能
3. 验证Token过期时间正确

### 代码生成提示
```
JwtUtil.java已包含家属和护士Token方法，请验证以下代码：

// 家属Token
public static String generateFamilyToken(Long familyId, String phone) {
    Map<String, Object> claims = new HashMap<>();
    claims.put("familyId", familyId);
    claims.put("phone", phone);
    return Jwts.builder()
            .setClaims(claims)
            .setSubject("FAMILY")
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + EXPIRE_TIME))
            .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
            .compact();
}

// 护士Token类似，subject为"NURSE"

若方法缺失，请补充实现。
```

---

## 任务3: 后端FamilyAuthService服务完善

**优先级**: P0
**预计工时**: 1天
**依赖**: 任务1, 任务2

### 任务描述
完善FamilyAuthService服务实现，确保登录验证、权限检查、失败处理逻辑正确。

### 输入
- 现有FamilyAuthServiceImpl.java代码
- 登录业务逻辑规范

### 输出
- 更新后的FamilyAuthServiceImpl.java
- 登录流程测试用例

### 验收标准
- [ ] login方法正确验证手机号、权限、密码
- [ ] login_enabled字段检查逻辑正确
- [ ] 登录失败次数正确累加
- [ ] 连续失败3次账号锁定30分钟
- [ ] 登录成功后清除失败次数和锁定时间
- [ ] 认证日志正确记录

### 子任务

#### 3.1 验证登录方法逻辑
**描述**: 检查login方法的完整流程
**执行步骤**:
1. 打开`src/main/java/com/example/medical/service/impl/FamilyAuthServiceImpl.java`
2. 检查login方法是否包含：手机号查询、权限检查、账号锁定检查、密码验证
3. 验证错误提示信息准确

#### 3.2 完善登录失败处理
**描述**: 确保handleLoginFail方法正确实现
**执行步骤**:
1. 检查login_fail_count累加逻辑
2. 检查lock_until设置逻辑（失败3次锁定30分钟）
3. 检查认证日志记录

#### 3.3 完善登录成功处理
**描述**: 确保登录成功后正确更新状态
**执行步骤**:
1. 检查login_fail_count清零
2. 检查lock_until清空
3. 检查last_login_time更新
4. 检查Token生成和返回

#### 3.4 完善权限管理接口
**描述**: 确保updateLoginEnabled方法正确实现
**执行步骤**:
1. 检查login_enabled字段更新
2. 检查默认密码设置（BCrypt加密）
3. 验证权限更新后家属能正常登录

### 代码生成提示
```
请检查FamilyAuthServiceImpl.java的login方法，确保包含以下逻辑：

public FamilyLoginResponse login(FamilyLoginRequest request) {
    // 1. 查询家属信息
    FamilyMember family = familyMemberMapper.selectByPhone(request.getPhone());
    if (family == null) {
        throw new RuntimeException("手机号不存在");
    }
    
    // 2. 检查登录权限
    if (family.getLoginEnabled() == null || family.getLoginEnabled() != 1) {
        throw new RuntimeException("家属登录功能未开启，请联系用户开启");
    }
    
    // 3. 检查账号锁定
    if (family.getLockUntil() != null && family.getLockUntil().after(new Date())) {
        throw new RuntimeException("账号已锁定，请稍后再试");
    }
    
    // 4. 验证密码
    if (!BCryptUtil.matches(request.getPassword(), family.getPassword())) {
        handleLoginFail(family);
        throw new RuntimeException("密码错误");
    }
    
    // 5-8. 生成Token、更新状态、记录日志、构建响应
    // ...
}

若逻辑不完整，请补充实现。
```

---

## 任务4: 后端NurseService服务完善

**优先级**: P0
**预计工时**: 0.5天
**依赖**: 任务1, 任务2

### 任务描述
完善NurseService服务实现，确保护士登录验证逻辑正确。

### 输入
- 现有NurseServiceImpl.java代码
- 护士登录业务逻辑规范

### 输出
- 更新后的NurseServiceImpl.java
- 护士登录测试用例

### 验收标准
- [ ] login方法正确验证手机号、状态、密码
- [ ] status字段检查逻辑正确（status=1才允许登录）
- [ ] Token正确生成并返回
- [ ] 护士信息正确关联用户信息

### 子任务

#### 4.1 验证护士登录方法
**描述**: 检查NurseService的login方法实现
**执行步骤**:
1. 打开`src/main/java/com/example/medical/service/impl/NurseServiceImpl.java`
2. 检查login方法逻辑
3. 验证status字段检查
4. 验证Token生成

#### 4.2 完善护士信息关联
**描述**: 确保返回数据包含关联用户信息
**执行步骤**:
1. 检查relatedUser字段查询
2. 验证响应数据结构完整

### 代码生成提示
```
请检查NurseServiceImpl.java的login方法，确保包含以下逻辑：

public NurseLoginResponse login(NurseLoginRequest request) {
    // 1. 查询护士信息
    Nurse nurse = nurseMapper.selectByPhone(request.getPhone());
    if (nurse == null) {
        throw new RuntimeException("手机号不存在");
    }
    
    // 2. 检查账号状态
    if (nurse.getStatus() == null || nurse.getStatus() != 1) {
        throw new RuntimeException("账号已禁用");
    }
    
    // 3. 验证密码
    if (!BCryptUtil.matches(request.getPassword(), nurse.getPassword())) {
        throw new RuntimeException("密码错误");
    }
    
    // 4. 生成Token
    String token = JwtUtil.generateNurseToken(nurse.getId(), nurse.getPhone());
    
    // 5. 构建响应
    // ...
}

若逻辑不完整，请补充实现。
```

---

## 任务5: 前端SettingsUtil持久化存储扩展

**优先级**: P0
**预计工时**: 0.5天
**依赖**: 无

### 任务描述
扩展SettingsUtil工具类，新增家属和护士Token、用户信息的存储方法。

### 输入
- 现有SettingsUtil.ets代码
- 持久化存储需求

### 输出
- 更新后的SettingsUtil.ets

### 验收标准
- [ ] saveFamilyToken方法存在且正确保存
- [ ] getFamilyTokenSync方法存在且正确读取
- [ ] saveFamilyInfo方法存在且正确保存
- [ ] getFamilyInfoSync方法存在且正确读取
- [ ] clearFamilyToken方法存在且正确清除
- [ ] 护士相关方法（saveNurseToken等）完整
- [ ] 存储键名不与现有键名冲突

### 子任务

#### 5.1 添加家属Token存储方法
**描述**: 在SettingsUtil中添加家属Token相关方法
**执行步骤**:
1. 打开`entry/src/main/ets/utils/SettingsUtil.ets`
2. 添加saveFamilyToken、getFamilyTokenSync、clearFamilyToken方法
3. 使用Preferences API存储，键名为'family_token'

#### 5.2 添加家属信息存储方法
**描述**: 在SettingsUtil中添加家属信息存储方法
**执行步骤**:
1. 添加saveFamilyInfo、getFamilyInfoSync方法
2. 家属信息序列化为JSON存储，键名为'family_info'

#### 5.3 添加护士Token和信息存储方法
**描述**: 在SettingsUtil中添加护士相关存储方法
**执行步骤**:
1. 添加saveNurseToken、getNurseTokenSync、clearNurseToken方法
2. 添加saveNurseInfo、getNurseInfoSync方法
3. 使用独立键名避免冲突

### 代码生成提示
```
请在SettingsUtil.ets中添加以下方法：

// ========== 家属相关方法 ==========

async saveFamilyToken(token: string): Promise<void> {
  await this.preferences.put('family_token', token);
  await this.preferences.flush();
}

getFamilyTokenSync(): string {
  return this.preferences.getSync('family_token', '') as string;
}

async saveFamilyInfo(familyInfo: FamilyInfo): Promise<void> {
  await this.preferences.put('family_info', JSON.stringify(familyInfo));
  await this.preferences.flush();
}

getFamilyInfoSync(): FamilyInfo | null {
  const json = this.preferences.getSync('family_info', '') as string;
  if (json && json.length > 0) {
    return JSON.parse(json) as FamilyInfo;
  }
  return null;
}

async clearFamilyToken(): Promise<void> {
  await this.preferences.delete('family_token');
  await this.preferences.delete('family_info');
  await this.preferences.flush();
}

// ========== 护士相关方法（类似实现） ==========
```

---

## 任务6: 前端HttpUtil多角色Token支持

**优先级**: P0
**预计工时**: 1天
**依赖**: 任务5

### 任务描述
扩展HttpUtil工具类，支持多角色Token获取和智能401错误处理。

### 输入
- 现有HttpUtil.ets代码
- 多角色Token管理设计

### 输出
- 更新后的HttpUtil.ets

### 验收标准
- [ ] getFamilyToken方法存在且正确获取Token
- [ ] getNurseToken方法存在且正确获取Token
- [ ] detectCurrentRole方法能正确检测当前角色
- [ ] 401错误处理支持家属和护士角色
- [ ] Token清除方法完整
- [ ] 不影响现有用户和管理员Token逻辑

### 子任务

#### 6.1 添加家属Token获取方法
**描述**: 在HttpUtil中添加getFamilyToken方法
**执行步骤**:
1. 打开`entry/src/main/ets/common/utils/HttpUtil.ets`
2. 添加getFamilyToken方法，优先从AppStorage获取，其次从SettingsUtil获取
3. 添加saveFamilyToken、clearFamilyToken方法

#### 6.2 添加护士Token获取方法
**描述**: 在HttpUtil中添加getNurseToken方法
**执行步骤**:
1. 添加getNurseToken方法
2. 添加saveNurseToken、clearNurseToken方法

#### 6.3 实现角色检测方法
**描述**: 添加detectCurrentRole方法，检测当前登录角色
**执行步骤**:
1. 添加detectCurrentRole私有方法
2. 按优先级检测：family > nurse > admin > user > guest
3. 检测AppStorage中的登录状态标识

#### 6.4 优化401错误处理
**描述**: 修改handleResponse方法，支持多角色401处理
**执行步骤**:
1. 找到handleResponse方法中的401处理逻辑
2. 使用detectCurrentRole检测当前角色
3. 根据角色类型清除对应Token并跳转对应登录页
4. 确保不重复处理（isHandling401标志）

### 代码生成提示
```
请在HttpUtil.ets中添加/修改以下方法：

// 添加家属Token获取
static getFamilyToken(): string | null {
  try {
    const tokenFromAppStorage: string | undefined = AppStorage.get<string>('familyToken');
    if (tokenFromAppStorage && tokenFromAppStorage.length > 0) {
      return tokenFromAppStorage;
    }
    const settings: SettingsUtil = SettingsUtil.getInstance();
    const tokenFromPrefs: string = settings.getFamilyTokenSync();
    if (tokenFromPrefs && tokenFromPrefs.length > 0) {
      AppStorage.setOrCreate<string>('familyToken', tokenFromPrefs);
      return tokenFromPrefs;
    }
    return null;
  } catch (error) {
    console.error('[HttpUtil] 获取家属Token失败:', error);
    return null;
  }
}

// 添加角色检测
private static detectCurrentRole(): string {
  if (AppStorage.get<boolean>('isFamilyLoggedIn')) return 'family';
  if (AppStorage.get<boolean>('isNurseLoggedIn')) return 'nurse';
  if (AppStorage.get<boolean>('isAdminLoggedIn')) return 'admin';
  if (AppStorage.get<boolean>('isLoggedIn')) return 'user';
  return 'guest';
}

// 修改401处理逻辑
if (response.responseCode === 401) {
  if (!isHandling401) {
    isHandling401 = true;
    const role = this.detectCurrentRole();
    
    switch (role) {
      case 'family':
        this.clearFamilyToken();
        AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);
        this.showToast('登录已过期，请重新登录');
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/FamilyLogin' });
          isHandling401 = false;
        }, 1500);
        break;
      case 'nurse':
        // 类似处理
        break;
      // ... 其他角色
    }
  }
  return new BaseResponse<T>(false, '登录已过期，请重新登录', undefined, 401);
}
```

---

## 任务7: 前端登录页面完善

**优先级**: P1
**预计工时**: 1天
**依赖**: 任务5, 任务6

### 任务描述
完善FamilyLogin和NurseLogin页面，确保登录流程正确，Token存储和状态管理完整。

### 输入
- 现有FamilyLogin.ets和NurseLogin.ets代码
- 登录页面设计规范

### 输出
- 更新后的FamilyLogin.ets
- 更新后的NurseLogin.ets

### 验收标准
- [ ] FamilyLogin页面表单验证正确
- [ ] FamilyLogin登录成功后Token正确存储
- [ ] FamilyLogin登录成功后跳转FamilyHome
- [ ] NurseLogin页面表单验证正确
- [ ] NurseLogin登录成功后Token正确存储
- [ ] NurseLogin登录成功后跳转NurseWorkbench
- [ ] 错误提示信息准确友好

### 子任务

#### 7.1 完善FamilyLogin页面
**描述**: 检查并完善FamilyLogin页面的登录流程
**执行步骤**:
1. 打开`entry/src/main/ets/pages/FamilyLogin.ets`
2. 检查handleLogin方法
3. 确保登录成功后：
   - 调用SettingsUtil.saveFamilyToken保存Token
   - 调用SettingsUtil.saveFamilyInfo保存家属信息
   - 设置AppStorage：familyToken、familyInfo、isFamilyLoggedIn
   - 跳转到FamilyHome页面

#### 7.2 完善NurseLogin页面
**描述**: 检查并完善NurseLogin页面的登录流程
**执行步骤**:
1. 打开`entry/src/main/ets/pages/NurseLogin.ets`
2. 检查handleLogin方法
3. 确保登录成功后：
   - 调用SettingsUtil.saveNurseToken保存Token
   - 调用SettingsUtil.saveNurseInfo保存护士信息
   - 设置AppStorage：nurseToken、nurseInfo、isNurseLoggedIn
   - 跳转到NurseWorkbench页面

#### 7.3 优化错误提示
**描述**: 确保错误提示信息准确友好
**执行步骤**:
1. 检查各种错误场景的提示信息
2. 确保"家属登录功能未开启"提示正确显示
3. 确保网络错误提示友好

### 代码生成提示
```
请检查FamilyLogin.ets的handleLogin方法，确保包含以下逻辑：

private async handleLogin(): Promise<void> {
  // 验证输入
  const isPhoneValid = this.validatePhone();
  const isPasswordValid = this.validatePassword();
  
  if (!isPhoneValid || !isPasswordValid) {
    return;
  }
  
  this.isLoading = true;
  this.errorMessage = '';
  
  try {
    const requestData: FamilyLoginRequestData = {
      phone: this.phone,
      password: this.password
    };
    
    const options: RequestOptions = { skipAuth: true };
    const response = await HttpUtil.post<FamilyLoginResponseData>('/family/login', requestData, options);
    
    if (response.success && response.data) {
      // 保存Token和家属信息
      const settings = SettingsUtil.getInstance();
      await settings.saveFamilyToken(response.data.token);
      await settings.saveFamilyInfo(response.data.familyInfo);
      
      // 更新全局状态
      AppStorage.setOrCreate<string>('familyToken', response.data.token);
      AppStorage.setOrCreate<FamilyInfo>('familyInfo', response.data.familyInfo);
      AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', true);
      
      ToastUtil.showSuccess('登录成功');
      
      // 跳转到家属主页
      router.replaceUrl({
        url: 'pages/FamilyHome'
      });
    } else {
      this.errorMessage = response.message || '登录失败，请重试';
      ToastUtil.showError(this.errorMessage);
    }
  } catch (error) {
    console.error('家属登录失败:', error);
    this.errorMessage = '登录失败，请检查网络连接';
    ToastUtil.showError(this.errorMessage);
  } finally {
    this.isLoading = false;
  }
}

NurseLogin.ets类似实现。
```

---

## 任务8: 登录状态恢复与登出功能

**优先级**: P1
**预计工时**: 1天
**依赖**: 任务5, 任务6, 任务7

### 任务描述
实现应用重启后登录状态自动恢复，以及完善的登出功能。

### 输入
- SettingsUtil持久化存储
- HttpUtil Token管理

### 输出
- 应用启动时的状态恢复逻辑
- 登出功能实现

### 验收标准
- [ ] 应用重启后家属登录状态正确恢复
- [ ] 应用重启后护士登录状态正确恢复
- [ ] Token过期时正确跳转登录页
- [ ] 登出功能正确清除所有状态
- [ ] 登出后跳转对应登录页

### 子任务

#### 8.1 实现应用启动状态恢复
**描述**: 在应用启动时检查并恢复登录状态
**执行步骤**:
1. 在EntryAbility.ets的onCreate或aboutToAppear中添加状态恢复逻辑
2. 从SettingsUtil读取Token和用户信息
3. 验证Token有效性（可选，或延迟到首次请求时验证）
4. 恢复AppStorage状态

#### 8.2 实现家属登出功能
**描述**: 在FamilyHome页面添加登出功能
**执行步骤**:
1. 在FamilyHome页面添加登出按钮
2. 实现登出逻辑：
   - 调用HttpUtil.clearFamilyToken清除Token
   - 清除AppStorage：familyToken、familyInfo、isFamilyLoggedIn
   - 跳转到FamilyLogin页面

#### 8.3 实现护士登出功能
**描述**: 在NurseWorkbench页面添加登出功能
**执行步骤**:
1. 在NurseWorkbench页面添加登出按钮
2. 实现登出逻辑（类似家属登出）

### 代码生成提示
```
应用启动状态恢复（在EntryAbility.ets或Index.ets中）：

async aboutToAppear(): Promise<void> {
  // 恢复家属登录状态
  const settings = SettingsUtil.getInstance();
  const familyToken = settings.getFamilyTokenSync();
  const familyInfo = settings.getFamilyInfoSync();
  
  if (familyToken && familyToken.length > 0 && familyInfo) {
    AppStorage.setOrCreate<string>('familyToken', familyToken);
    AppStorage.setOrCreate<FamilyInfo>('familyInfo', familyInfo);
    AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', true);
  }
  
  // 恢复护士登录状态（类似）
  const nurseToken = settings.getNurseTokenSync();
  const nurseInfo = settings.getNurseInfoSync();
  
  if (nurseToken && nurseToken.length > 0 && nurseInfo) {
    AppStorage.setOrCreate<string>('nurseToken', nurseToken);
    AppStorage.setOrCreate<NurseInfo>('nurseInfo', nurseInfo);
    AppStorage.setOrCreate<boolean>('isNurseLoggedIn', true);
  }
}

登出功能实现：

async handleLogout(): Promise<void> {
  // 清除Token
  await HttpUtil.clearFamilyToken();
  
  // 清除AppStorage
  AppStorage.setOrCreate<string>('familyToken', '');
  AppStorage.setOrCreate<FamilyInfo | null>('familyInfo', null);
  AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);
  
  // 跳转登录页
  router.replaceUrl({ url: 'pages/FamilyLogin' });
}
```

---

## 任务依赖关系图

```
任务1 (数据库表结构)
  │
  ├─> 任务2 (JwtUtil扩展)
  │     │
  │     └─> 任务3 (FamilyAuthService)
  │     └─> 任务4 (NurseService)
  │
  └─> 任务5 (SettingsUtil扩展)
        │
        └─> 任务6 (HttpUtil多角色支持)
              │
              └─> 任务7 (登录页面完善)
                    │
                    └─> 任务8 (状态恢复与登出)
```

---

## 任务执行顺序建议

### 第一阶段：基础设施（第1天）
1. 执行任务1：数据库表结构验证与修复
2. 执行任务2：后端JwtUtil工具类扩展

### 第二阶段：后端服务（第2-3天）
3. 执行任务3：后端FamilyAuthService服务完善
4. 执行任务4：后端NurseService服务完善

### 第三阶段：前端基础（第4天）
5. 执行任务5：前端SettingsUtil持久化存储扩展
6. 执行任务6：前端HttpUtil多角色Token支持

### 第四阶段：前端页面（第5-6天）
7. 执行任务7：前端登录页面完善
8. 执行任务8：登录状态恢复与登出功能

### 第五阶段：测试验证（第7天）
- 执行集成测试
- 验证所有验收标准
- 修复发现的问题

---

## 验收检查清单

### 功能验收
- [ ] 家属能正常登录（手机号+密码）
- [ ] 护士能正常登录（手机号+密码）
- [ ] 登录权限未开启时提示正确
- [ ] 密码错误时提示正确
- [ ] 连续失败3次账号锁定
- [ ] Token过期后跳转登录页
- [ ] 应用重启后登录状态恢复
- [ ] 登出功能正常

### 安全验收
- [ ] 密码BCrypt加密存储
- [ ] Token包含正确的角色标识
- [ ] Token有效期24小时
- [ ] 401错误正确处理

### 性能验收
- [ ] 登录响应时间 < 3秒
- [ ] Token验证时间 < 100ms

### 兼容性验收
- [ ] 不影响现有用户登录
- [ ] 不影响管理员登录
- [ ] 多角色Token互不干扰

---

## 风险与应对

### 风险1：数据库迁移失败
**应对措施**：
- 迁移前完整备份数据
- 准备回滚脚本
- 在测试环境先验证

### 风险2：Token冲突导致其他角色登录失效
**应对措施**：
- 使用独立的存储键名
- 充分测试多角色并发登录
- 保留原有Token逻辑不变

### 风险3：401处理逻辑影响现有功能
**应对措施**：
- 保持向后兼容
- 优先检测新角色，不影响原有逻辑
- 充分回归测试

---

## 附录

### 相关文件清单

**后端文件**：
- `src/main/java/com/example/medical/common/JwtUtil.java`
- `src/main/java/com/example/medical/service/impl/FamilyAuthServiceImpl.java`
- `src/main/java/com/example/medical/service/impl/NurseServiceImpl.java`
- `src/main/java/com/example/medical/controller/FamilyAuthController.java`
- `src/main/java/com/example/medical/controller/NurseController.java`

**前端文件**：
- `entry/src/main/ets/common/utils/HttpUtil.ets`
- `entry/src/main/ets/utils/SettingsUtil.ets`
- `entry/src/main/ets/pages/FamilyLogin.ets`
- `entry/src/main/ets/pages/NurseLogin.ets`
- `entry/src/main/ets/pages/FamilyHome.ets`
- `entry/src/main/ets/pages/NurseWorkbench.ets`

**数据库文件**：
- `sql/family_login_complete.sql`

### 测试账号

**家属测试账号**：
- 手机号：13800138001
- 密码：123456
- 状态：login_enabled=1（已开启登录）

**护士测试账号**：
- 手机号：13900139001
- 密码：123456
- 状态：status=1（正常）

---

**文档结束**

本任务规划文档提供了完整的编码任务分解，开发人员可按照任务顺序逐步实施。每个任务都包含详细的执行步骤、验收标准和代码生成提示，确保实施过程清晰可控。
