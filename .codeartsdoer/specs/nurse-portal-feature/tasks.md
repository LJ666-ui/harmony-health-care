# 护士端功能 - 任务规划文档

**版本**: v1.0
**创建日期**: 2025-01-09
**最后更新**: 2025-01-09
**作者**: SDD Agent
**状态**: 待执行

## 任务概述

本文档将护士端功能开发分解为可执行的任务单元，按照数据库→后端→前端的顺序组织，确保依赖关系清晰、任务粒度合理。

**任务统计**：
- 主任务：8个
- 子任务：24个
- 预计工期：6个工作日

---

## 任务1: 数据库设计与初始化

**任务描述**：创建护士表并建立与用户表的关联关系，为后续开发提供数据基础。

**输入**：
- 现有user表结构
- 需求规格中的数据模型定义

**输出**：
- SQL建表脚本文件
- 测试数据初始化脚本

**验收标准**：
- nurse表创建成功，包含所有必需字段
- 外键约束正确建立
- 索引正确创建
- 测试数据可正常插入

### 1.1 创建护士表SQL脚本

**任务描述**：编写CREATE TABLE语句，定义nurse表的完整结构。

**实施步骤**：
1. 在项目根目录创建`sql/nurse_schema.sql`文件
2. 编写CREATE TABLE语句，包含字段定义、主键、外键、索引
3. 添加字段注释说明
4. 设置默认值和约束条件

**代码生成提示**：
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

**预计耗时**：0.5小时

### 1.2 创建测试数据脚本

**任务描述**：编写INSERT语句，插入测试护士账号数据。

**实施步骤**：
1. 创建`sql/nurse_testdata.sql`文件
2. 插入user表记录（user_type=3）
3. 插入nurse表关联记录
4. 密码使用BCrypt加密后的值

**代码生成提示**：
```sql
-- 插入测试护士账号
-- 密码：123456，BCrypt加密后的值
INSERT INTO user (username, password, user_type, phone, create_time, is_deleted)
VALUES ('N20230001', '$2a$10$N9qo8uLOickgx2ZMRZoMy.Mrq7H7j9fD9KJFjJZJZJZJZJZJZJZJZ', 3, '13800138001', NOW(), 0);

INSERT INTO nurse (user_id, nurse_number, real_name, phone, department, title, status, create_time, is_deleted)
VALUES (LAST_INSERT_ID(), 'N20230001', '张护士', '13800138001', '内科', '护师', 1, NOW(), 0);
```

**预计耗时**：0.5小时

### 1.3 执行SQL脚本并验证

**任务描述**：在数据库中执行SQL脚本，验证表结构正确性。

**实施步骤**：
1. 连接MySQL数据库
2. 执行nurse_schema.sql创建表
3. 执行nurse_testdata.sql插入测试数据
4. 使用DESC命令验证表结构
5. 使用SELECT验证数据插入

**验证命令**：
```sql
DESC nurse;
SELECT * FROM nurse WHERE nurse_number = 'N20230001';
```

**预计耗时**：0.5小时

---

## 任务2: 后端实体类与DTO创建

**任务描述**：创建护士相关的实体类和数据传输对象，定义数据结构。

**输入**：
- 数据库表结构
- 现有实体类规范（参考Doctor.java）

**输出**：
- Nurse.java实体类
- NurseLoginRequest.java DTO
- NurseLoginResponse.java DTO
- NurseUpdateRequest.java DTO

**验收标准**：
- 实体类字段与数据库表一致
- 注解配置正确
- DTO包含验证规则

### 2.1 创建Nurse实体类

**任务描述**：创建护士实体类，映射nurse表。

**实施步骤**：
1. 在`src/main/java/com/example/medical/entity/`创建Nurse.java
2. 使用@Data、@TableName注解
3. 定义所有字段并添加@TableField注解
4. 参考Doctor.java的结构

**代码生成提示**：
```java
package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.util.Date;

@Data
@TableName("nurse")
public class Nurse {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("user_id")
    private Long userId;
    
    @TableField("nurse_number")
    private String nurseNumber;
    
    @TableField("real_name")
    private String realName;
    
    private String phone;
    private String department;
    private String title;
    private String avatar;
    private Integer status;
    
    @TableField("create_time")
    private Date createTime;
    
    @TableField("update_time")
    private Date updateTime;
    
    @TableField("is_deleted")
    private Integer isDeleted;
}
```

**预计耗时**：0.5小时

### 2.2 创建登录请求DTO

**任务描述**：创建护士登录请求数据传输对象。

**实施步骤**：
1. 在`src/main/java/com/example/medical/dto/`创建NurseLoginRequest.java
2. 添加验证注解（@NotBlank、@Pattern、@Size）
3. 定义工号和密码字段

**代码生成提示**：
```java
package com.example.medical.dto;

import lombok.Data;
import javax.validation.constraints.*;

@Data
public class NurseLoginRequest {
    @NotBlank(message = "工号不能为空")
    @Pattern(regexp = "^[A-Za-z0-9]{4,20}$", message = "工号格式不正确")
    private String nurseNumber;
    
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度必须在6-20位之间")
    private String password;
}
```

**预计耗时**：0.5小时

### 2.3 创建登录响应DTO

**任务描述**：创建护士登录响应数据传输对象。

**实施步骤**：
1. 在`src/main/java/com/example/medical/dto/`创建NurseLoginResponse.java
2. 定义Token和护士基本信息字段

**代码生成提示**：
```java
package com.example.medical.dto;

import lombok.Data;

@Data
public class NurseLoginResponse {
    private String token;
    private Long nurseId;
    private String realName;
    private String department;
    private String title;
    private String avatar;
}
```

**预计耗时**：0.5小时

### 2.4 创建更新请求DTO

**任务描述**：创建护士信息更新请求数据传输对象。

**实施步骤**：
1. 创建NurseUpdateRequest.java
2. 定义可更新字段（手机号、头像）

**代码生成提示**：
```java
package com.example.medical.dto;

import lombok.Data;
import javax.validation.constraints.Pattern;

@Data
public class NurseUpdateRequest {
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;
    
    private String avatar;
}
```

**预计耗时**：0.5小时

---

## 任务3: 后端数据访问层实现

**任务描述**：创建Mapper接口，实现护士数据的CRUD操作。

**输入**：
- Nurse实体类
- MyBatis Plus规范

**输出**：
- NurseMapper.java接口
- NurseMapper.xml（可选）

**验收标准**：
- Mapper接口继承BaseMapper
- 自定义查询方法正确实现
- SQL语句可正常执行

### 3.1 创建NurseMapper接口

**任务描述**：创建护士数据访问接口。

**实施步骤**：
1. 在`src/main/java/com/example/medical/mapper/`创建NurseMapper.java
2. 继承BaseMapper<Nurse>
3. 定义自定义查询方法（按工号查询、按用户ID查询）

**代码生成提示**：
```java
package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.Nurse;
import org.apache.ibatis.annotations.*;

public interface NurseMapper extends BaseMapper<Nurse> {
    @Select("SELECT n.*, u.username, u.password FROM nurse n " +
            "LEFT JOIN user u ON n.user_id = u.id " +
            "WHERE n.nurse_number = #{nurseNumber} AND n.is_deleted = 0")
    Nurse selectByNurseNumber(@Param("nurseNumber") String nurseNumber);
    
    @Select("SELECT * FROM nurse WHERE user_id = #{userId} AND is_deleted = 0")
    Nurse selectByUserId(@Param("userId") Long userId);
    
    @Update("UPDATE nurse SET status = #{status}, update_time = NOW() WHERE id = #{id}")
    int updateStatus(@Param("id") Long id, @Param("status") Integer status);
}
```

**预计耗时**：1小时

---

## 任务4: 后端业务服务层实现

**任务描述**：实现护士认证和信息管理的业务逻辑。

**输入**：
- NurseMapper接口
- JwtUtil工具类
- BCryptUtil工具类

**输出**：
- NurseAuthService.java
- NurseService.java

**验收标准**：
- 登录逻辑正确实现
- Token生成和验证正确
- 事务处理正确

### 4.1 创建NurseAuthService认证服务

**任务描述**：实现护士登录认证业务逻辑。

**实施步骤**：
1. 在`src/main/java/com/example/medical/service/`创建NurseAuthService.java
2. 实现login方法：查询护士→验证状态→验证密码→生成Token
3. 实现getNurseInfo方法
4. 添加@Service注解和依赖注入

**代码生成提示**：
```java
package com.example.medical.service;

import com.example.medical.common.BusinessException;
import com.example.medical.common.JwtUtil;
import com.example.medical.dto.NurseLoginRequest;
import com.example.medical.dto.NurseLoginResponse;
import com.example.medical.entity.Nurse;
import com.example.medical.entity.User;
import com.example.medical.mapper.NurseMapper;
import com.example.medical.mapper.UserMapper;
import com.example.medical.common.BCryptUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NurseAuthService {
    @Autowired
    private NurseMapper nurseMapper;
    
    @Autowired
    private UserMapper userMapper;
    
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
    
    public Nurse getNurseInfo(Long nurseId) {
        Nurse nurse = nurseMapper.selectById(nurseId);
        if (nurse == null) {
            throw new BusinessException("护士信息不存在");
        }
        return nurse;
    }
}
```

**预计耗时**：2小时

### 4.2 扩展JwtUtil支持护士Token

**任务描述**：在JwtUtil中添加护士Token生成和验证方法。

**实施步骤**：
1. 打开JwtUtil.java
2. 添加NURSE_TOKEN_PREFIX常量
3. 实现generateNurseToken方法
4. 实现isNurseToken方法
5. 实现getNurseId方法

**代码生成提示**：
```java
// 在JwtUtil.java中添加以下方法

private static final String NURSE_TOKEN_PREFIX = "NURSE_";

public static String generateNurseToken(Long nurseId, String nurseNumber) {
    Map<String, Object> claims = new HashMap<>();
    claims.put("nurseId", nurseId);
    claims.put("nurseNumber", nurseNumber);
    claims.put("type", NURSE_TOKEN_PREFIX);
    
    return Jwts.builder()
        .setClaims(claims)
        .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION))
        .signWith(SignatureAlgorithm.HS256, SECRET)
        .compact();
}

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

public static Long getNurseId(String token) {
    try {
        Claims claims = Jwts.parser()
            .setSigningKey(SECRET)
            .parseClaimsJws(token)
            .getBody();
        return claims.get("nurseId", Long.class);
    } catch (Exception e) {
        return null;
    }
}
```

**预计耗时**：1小时

### 4.3 创建NurseService业务服务

**任务描述**：实现护士信息管理和注册业务逻辑。

**实施步骤**：
1. 创建NurseService.java
2. 实现updateNurseInfo方法
3. 实现registerNurse方法（带事务）
4. 添加参数验证和异常处理

**代码生成提示**：
```java
package com.example.medical.service;

import com.example.medical.common.BusinessException;
import com.example.medical.common.BCryptUtil;
import com.example.medical.dto.NurseUpdateRequest;
import com.example.medical.entity.Nurse;
import com.example.medical.entity.User;
import com.example.medical.mapper.NurseMapper;
import com.example.medical.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Date;

@Service
public class NurseService {
    @Autowired
    private NurseMapper nurseMapper;
    
    @Autowired
    private UserMapper userMapper;
    
    public boolean updateNurseInfo(Long nurseId, NurseUpdateRequest request) {
        Nurse nurse = nurseMapper.selectById(nurseId);
        if (nurse == null) {
            throw new BusinessException("护士不存在");
        }
        
        if (request.getPhone() != null) {
            nurse.setPhone(request.getPhone());
        }
        if (request.getAvatar() != null) {
            nurse.setAvatar(request.getAvatar());
        }
        nurse.setUpdateTime(new Date());
        
        return nurseMapper.updateById(nurse) > 0;
    }
    
    @Transactional
    public Long registerNurse(NurseRegisterRequest request) {
        // 检查工号是否已存在
        Nurse existing = nurseMapper.selectByNurseNumber(request.getNurseNumber());
        if (existing != null) {
            throw new BusinessException("工号已存在");
        }
        
        // 创建用户记录
        User user = new User();
        user.setUsername(request.getNurseNumber());
        user.setPassword(BCryptUtil.hashpw(request.getPassword(), BCryptUtil.gensalt(10)));
        user.setPhone(request.getPhone());
        user.setUserType(3);
        user.setCreateTime(new Date());
        user.setIsDeleted(0);
        userMapper.insert(user);
        
        // 创建护士记录
        Nurse nurse = new Nurse();
        nurse.setUserId(user.getId());
        nurse.setNurseNumber(request.getNurseNumber());
        nurse.setRealName(request.getRealName());
        nurse.setPhone(request.getPhone());
        nurse.setDepartment(request.getDepartment());
        nurse.setTitle(request.getTitle());
        nurse.setStatus(0);
        nurse.setCreateTime(new Date());
        nurse.setIsDeleted(0);
        nurseMapper.insert(nurse);
        
        return nurse.getId();
    }
}
```

**预计耗时**：2小时

---

## 任务5: 后端控制器层实现

**任务描述**：创建RESTful API接口，处理HTTP请求。

**输入**：
- NurseAuthService服务
- NurseService服务

**输出**：
- NurseAuthController.java
- NurseController.java

**验收标准**：
- 接口路径正确
- 参数验证生效
- 返回格式统一
- 异常处理完善

### 5.1 创建NurseAuthController认证控制器

**任务描述**：实现护士登录和信息查询接口。

**实施步骤**：
1. 在`src/main/java/com/example/medical/controller/`创建NurseAuthController.java
2. 实现POST /nurse/login接口
3. 实现GET /nurse/info接口
4. 添加Token验证逻辑
5. 统一异常处理

**代码生成提示**：
```java
package com.example.medical.controller;

import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.dto.NurseLoginRequest;
import com.example.medical.dto.NurseLoginResponse;
import com.example.medical.entity.Nurse;
import com.example.medical.service.NurseAuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

@RestController
@RequestMapping("/nurse")
@CrossOrigin
@Validated
public class NurseAuthController {
    @Autowired
    private NurseAuthService nurseAuthService;
    
    @PostMapping("/login")
    public Result<?> login(@Valid @RequestBody NurseLoginRequest request) {
        try {
            NurseLoginResponse response = nurseAuthService.login(request);
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
    
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

**预计耗时**：1.5小时

### 5.2 创建NurseController信息管理控制器

**任务描述**：实现护士信息更新和注册接口。

**实施步骤**：
1. 创建NurseController.java
2. 实现PUT /nurse/info接口
3. 实现POST /nurse/register接口
4. 添加权限验证

**代码生成提示**：
```java
package com.example.medical.controller;

import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.dto.NurseUpdateRequest;
import com.example.medical.service.NurseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/nurse")
@CrossOrigin
public class NurseController {
    @Autowired
    private NurseService nurseService;
    
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
    
    private String extractToken(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            return token.substring(7);
        }
        return token;
    }
}
```

**预计耗时**：1小时

---

## 任务6: 前端护士登录页面开发

**任务描述**：开发护士独立登录页面，实现登录功能。

**输入**：
- 现有Login.ets和FamilyLogin.ets参考
- GlobalTheme样式规范

**输出**：
- NurseLogin.ets页面

**验收标准**：
- 页面样式与现有登录页一致
- 输入验证正确
- 登录流程完整
- 错误提示友好

### 6.1 创建NurseLogin页面

**任务描述**：实现护士登录页面UI和交互逻辑。

**实施步骤**：
1. 在`entry/src/main/ets/pages/`创建NurseLogin.ets
2. 定义状态变量（工号、密码、加载状态）
3. 实现输入验证方法
4. 实现登录请求方法
5. 构建UI界面（参考FamilyLogin.ets）

**代码生成提示**：
```typescript
import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

interface NurseLoginResponse {
  token: string;
  nurseId: number;
  realName: string;
  department: string;
  title: string;
  avatar: string;
}

@Entry
@Component
struct NurseLogin {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State nurseNumber: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State showPassword: boolean = false;

  private async handleLogin(): Promise<void> {
    // 验证输入
    if (!this.nurseNumber || this.nurseNumber.length < 4) {
      ToastUtil.showError('请输入正确的工号');
      return;
    }
    if (!this.password || this.password.length < 6) {
      ToastUtil.showError('密码长度不能少于6位');
      return;
    }

    this.isLoading = true;
    try {
      const response = await HttpUtil.post<NurseLoginResponse>(
        '/nurse/login',
        { nurseNumber: this.nurseNumber, password: this.password },
        { skipAuth: true }
      );

      if (response.success && response.data) {
        // 保存Token和护士信息
        const settings = SettingsUtil.getInstance();
        await HttpUtil.saveToken(response.data.token);
        
        AppStorage.setOrCreate<string>('nurseToken', response.data.token);
        AppStorage.setOrCreate<NurseLoginResponse>('nurseInfo', response.data);
        AppStorage.setOrCreate<boolean>('isNurseLoggedIn', true);

        ToastUtil.loginSuccess();
        router.replaceUrl({ url: 'pages/NurseHomePage' });
      } else {
        this.errorMessage = response.message || '登录失败';
        ToastUtil.showError(this.errorMessage);
      }
    } catch (error) {
      this.errorMessage = '网络请求失败，请稍后重试';
      ToastUtil.showError(this.errorMessage);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Header({ title: '护士登录', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          // Logo和标题
          Column() {
            Text('👩‍⚕️')
              .fontSize(48)
              .margin({ bottom: 16 });
            Text('护士工作台')
              .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#FFFFFF');
          }
          .width('100%')
          .padding(40)
          .linearGradient({
            angle: 135,
            colors: [['#52C41A', 0], ['#73D13D', 1]]
          })
          .borderRadius({ bottomLeft: 32, bottomRight: 32 });

          // 工号输入框
          TextInput({ placeholder: '请输入工号', text: this.nurseNumber })
            .height(44)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#E8ECF2' })
            .padding({ left: 12, right: 12 })
            .onChange((value) => { this.nurseNumber = value; });

          // 密码输入框
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .height(44)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#E8ECF2' })
            .padding({ left: 12, right: 12 })
            .onChange((value) => { this.password = value; });

          // 登录按钮
          if (this.isLoading) {
            Loading();
          } else {
            Button('登 录')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .backgroundColor(GlobalTheme.THEME_COLOR)
              .borderRadius(GlobalTheme.RADIUS_MD)
              .onClick(() => this.handleLogin());
          }

          // 演示账号提示
          Row({ space: 8 }) {
            Text('💡')
              .fontSize(16);
            Column({ space: 2 }) {
              Text('演示账号')
                .fontSize(12)
                .fontWeight('bold');
              Text('工号：N20230001 / 密码：123456')
                .fontSize(11)
                .fontColor('#999999');
            }
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#F6FFED')
          .borderRadius(10);
        }
        .width('85%')
        .padding({ top: 20, bottom: 20 });
      }
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
```

**预计耗时**：2小时

### 6.2 在主登录页添加护士登录入口

**任务描述**：在Login.ets中添加护士登录按钮。

**实施步骤**：
1. 打开`entry/src/main/ets/pages/Login.ets`
2. 在"其他登录方式"区域添加护士登录按钮
3. 添加跳转逻辑

**代码生成提示**：
```typescript
// 在Login.ets的build方法中，其他登录方式区域添加：

Button('护士登录')
  .width('100%')
  .height(GlobalTheme.getButtonHeight(this.isElderMode))
  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
  .fontColor('#52C41A')
  .backgroundColor('#FFFFFF')
  .border({ width: 1, color: '#52C41A' })
  .borderRadius(GlobalTheme.RADIUS_MD)
  .onClick(() => {
    router.pushUrl({ url: 'pages/NurseLogin' });
  });
```

**预计耗时**：0.5小时

---

## 任务7: 前端护士工作台页面开发

**任务描述**：开发护士专属工作台页面，展示工作信息。

**输入**：
- DoctorHomePage.ets参考
- 护士信息接口

**输出**：
- NurseHomePage.ets页面

**验收标准**：
- 页面布局合理
- 信息展示正确
- 导航功能正常

### 7.1 创建NurseHomePage页面

**任务描述**：实现护士工作台主页面。

**实施步骤**：
1. 在`entry/src/main/ets/pages/`创建NurseHomePage.ets
2. 定义护士信息状态
3. 实现页面加载逻辑
4. 构建欢迎卡片、功能模块、底部导航

**代码生成提示**：
```typescript
import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface NurseInfo {
  id: number;
  nurseNumber: string;
  realName: string;
  phone: string;
  department: string;
  title: string;
  avatar: string;
}

@Entry
@Component
struct NurseHomePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State nurseInfo: NurseInfo | null = null;
  @State activeTab: number = 0;

  async aboutToAppear(): Promise<void> {
    await this.loadNurseInfo();
  }

  private async loadNurseInfo(): Promise<void> {
    try {
      const response = await HttpUtil.get<NurseInfo>('/nurse/info');
      if (response.success && response.data) {
        this.nurseInfo = response.data;
      }
    } catch (error) {
      console.error('加载护士信息失败:', error);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('👩‍⚕️ 护士工作台')
          .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#FFFFFF');
        Blank();
        Image(this.nurseInfo?.avatar || $r('app.media.default_avatar'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .onClick(() => {
            router.pushUrl({ url: 'pages/NurseProfile' });
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .linearGradient({
        angle: 90,
        colors: [['#52C41A', 0], ['#73D13D', 1]]
      });

      // 主内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 欢迎卡片
          Column() {
            Row() {
              Text(`你好，${this.nurseInfo?.realName || '护士'}`)
                .fontSize(20)
                .fontWeight('bold')
                .fontColor('#FFFFFF');
              Blank();
              Text(this.nurseInfo?.title || '护师')
                .fontSize(14)
                .fontColor('#FFFFFFCC');
            }
            .width('100%');
            
            Row() {
              Text(`科室：${this.nurseInfo?.department || '未分配'}`)
                .fontSize(14)
                .fontColor('#FFFFFFCC');
            }
            .width('100%')
            .margin({ top: 8 });
          }
          .width('100%')
          .padding(20)
          .linearGradient({
            angle: 135,
            colors: [['#52C41A', 0], ['#95DE64', 1]]
          })
          .borderRadius(12);

          // 功能模块
          Row({ space: 12 }) {
            this.buildFunctionCard('📋', '患者列表', 'pages/PatientList');
            this.buildFunctionCard('💊', '医嘱执行', 'pages/MedicationExec');
            this.buildFunctionCard('📝', '护理记录', 'pages/NursingRecord');
            this.buildFunctionCard('📊', '健康监测', 'pages/HealthMonitor');
          }
          .width('100%');

          // 今日任务
          Column() {
            Text('今日任务')
              .fontSize(16)
              .fontWeight('bold')
              .margin({ bottom: 12 });
            
            // 任务列表占位
            Text('暂无待办任务')
              .fontSize(14)
              .fontColor('#999999');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);
        }
        .width('100%')
        .padding(16);
      }
      .layoutWeight(1);

      // 底部导航栏
      this.buildBottomNav();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder
  buildFunctionCard(icon: string, title: string, url: string) {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(32);
      Text(title)
        .fontSize(12)
        .fontColor('#666666');
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .onClick(() => {
      ToastUtil.showInfo('功能开发中');
    });
  }

  @Builder
  buildBottomNav() {
    Row() {
      Column() {
        Text('🏠')
          .fontSize(24);
        Text('首页')
          .fontSize(12)
          .fontColor(this.activeTab === 0 ? '#52C41A' : '#999999');
      }
      .layoutWeight(1)
      .onClick(() => { this.activeTab = 0; });

      Column() {
        Text('👥')
          .fontSize(24);
        Text('患者')
          .fontSize(12)
          .fontColor(this.activeTab === 1 ? '#52C41A' : '#999999');
      }
      .layoutWeight(1)
      .onClick(() => { this.activeTab = 1; });

      Column() {
        Text('💬')
          .fontSize(24);
        Text('消息')
          .fontSize(12)
          .fontColor(this.activeTab === 2 ? '#52C41A' : '#999999');
      }
      .layoutWeight(1)
      .onClick(() => { this.activeTab = 2; });

      Column() {
        Text('👤')
          .fontSize(24);
        Text('我的')
          .fontSize(12)
          .fontColor(this.activeTab === 3 ? '#52C41A' : '#999999');
      }
      .layoutWeight(1)
      .onClick(() => {
        router.pushUrl({ url: 'pages/NurseProfile' });
      });
    }
    .width('100%')
    .height(60)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#E8E8E8' });
  }
}
```

**预计耗时**：3小时

---

## 任务8: 前端护士个人中心页面开发

**任务描述**：开发护士个人中心页面，支持查看和编辑个人信息。

**输入**：
- Profile.ets参考
- 护士信息更新接口

**输出**：
- NurseProfile.ets页面

**验收标准**：
- 信息展示正确
- 编辑功能正常
- 退出登录功能正常

### 8.1 创建NurseProfile页面

**任务描述**：实现护士个人中心页面。

**实施步骤**：
1. 在`entry/src/main/ets/pages/`创建NurseProfile.ets
2. 实现信息展示
3. 实现编辑功能
4. 实现退出登录

**代码生成提示**：
```typescript
import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil } from '../common/utils/HttpUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

interface NurseInfo {
  id: number;
  nurseNumber: string;
  realName: string;
  phone: string;
  department: string;
  title: string;
  avatar: string;
}

@Entry
@Component
struct NurseProfile {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State nurseInfo: NurseInfo | null = null;

  async aboutToAppear(): Promise<void> {
    await this.loadNurseInfo();
  }

  private async loadNurseInfo(): Promise<void> {
    try {
      const response = await HttpUtil.get<NurseInfo>('/nurse/info');
      if (response.success && response.data) {
        this.nurseInfo = response.data;
      }
    } catch (error) {
      console.error('加载护士信息失败:', error);
    }
  }

  private async handleLogout(): Promise<void> {
    try {
      const settings = SettingsUtil.getInstance();
      await settings.clearAllLoginData();
      
      AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
      AppStorage.setOrCreate<string>('nurseToken', '');
      
      ToastUtil.showInfo('已退出登录');
      router.replaceUrl({ url: 'pages/Login' });
    } catch (error) {
      console.error('退出登录失败:', error);
    }
  }

  build() {
    Column() {
      Header({ title: '个人中心', showBack: true });

      Scroll() {
        Column({ space: 16 }) {
          // 头像和基本信息
          Column() {
            Image(this.nurseInfo?.avatar || $r('app.media.default_avatar'))
              .width(80)
              .height(80)
              .borderRadius(40)
              .margin({ bottom: 12 });

            Text(this.nurseInfo?.realName || '护士')
              .fontSize(20)
              .fontWeight('bold');

            Text(this.nurseInfo?.title || '护师')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 4 });
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          // 信息列表
          Column() {
            this.buildInfoRow('工号', this.nurseInfo?.nurseNumber || '-');
            this.buildInfoRow('姓名', this.nurseInfo?.realName || '-');
            this.buildInfoRow('手机号', this.nurseInfo?.phone || '-');
            this.buildInfoRow('科室', this.nurseInfo?.department || '-');
            this.buildInfoRow('职称', this.nurseInfo?.title || '-');
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          // 功能菜单
          Column() {
            this.buildMenuItem('📝', '编辑个人信息', () => {
              ToastUtil.showInfo('功能开发中');
            });
            this.buildMenuItem('🔒', '修改密码', () => {
              ToastUtil.showInfo('功能开发中');
            });
            this.buildMenuItem('❓', '帮助与反馈', () => {
              ToastUtil.showInfo('功能开发中');
            });
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          // 退出登录按钮
          Button('退出登录')
            .width('100%')
            .height(44)
            .fontSize(16)
            .fontColor('#F5222D')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => this.handleLogout());
        }
        .width('100%')
        .padding(16);
      }
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(80);
      Text(value)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1);
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 });
  }

  @Builder
  buildMenuItem(icon: string, title: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(20)
        .margin({ right: 12 });
      Text(title)
        .fontSize(14)
        .layoutWeight(1);
      Text('>')
        .fontSize(16)
        .fontColor('#CCCCCC');
    }
    .width('100%')
    .padding(16)
    .onClick(onClick);
  }
}
```

**预计耗时**：2小时

---

## 任务9: 路由配置与集成测试

**任务描述**：配置页面路由，进行端到端测试。

**输入**：
- 所有新创建的页面

**输出**：
- 路由配置更新
- 测试报告

**验收标准**：
- 路由跳转正常
- 登录流程完整
- 接口调用正常

### 9.1 配置页面路由

**任务描述**：在路由配置中注册护士页面。

**实施步骤**：
1. 打开`entry/src/main/module.json5`或路由配置文件
2. 添加NurseLogin、NurseHomePage、NurseProfile路由
3. 验证路由配置正确

**预计耗时**：0.5小时

### 9.2 端到端测试

**任务描述**：测试完整的护士登录和使用流程。

**实施步骤**：
1. 启动后端服务
2. 启动前端应用
3. 测试护士登录流程
4. 测试信息查看和编辑
5. 测试退出登录
6. 记录测试结果

**测试用例**：
- 正常登录：工号N20230001，密码123456
- 查看个人信息
- 修改手机号
- 退出登录

**预计耗时**：2小时

---

## 任务依赖关系图

```
任务1 (数据库)
  ↓
任务2 (实体类) → 任务3 (Mapper) → 任务4 (Service) → 任务5 (Controller)
                                            ↓
任务6 (登录页) → 任务7 (工作台) → 任务8 (个人中心)
  ↓
任务9 (路由与测试)
```

---

## 任务执行建议

**执行顺序**：
1. 按任务编号顺序执行
2. 每完成一个主任务进行阶段性验证
3. 后端开发完成后启动服务测试接口
4. 前端开发完成后进行端到端测试

**风险提示**：
- 数据库外键约束可能导致插入失败，需先创建user记录
- JWT Token格式需与现有体系保持一致
- 前端页面样式需与现有页面保持一致

**质量检查点**：
- 代码符合项目规范
- 接口返回格式统一
- 错误处理完善
- 日志记录充分

---

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2025-01-09 | 初始版本，完成任务规划 | SDD Agent |
