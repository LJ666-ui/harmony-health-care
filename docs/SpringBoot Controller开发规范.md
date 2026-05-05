# Spring Boot Controller开发规范

## 版本信息
- **Spring Boot**: 2.x
- **Java**: 17+
- **MyBatis-Plus**: 3.x
- **适用项目**: 星云医疗助手

---

## 一、三层架构规范

### 1.1 架构层次

```
Controller层 (控制层)
    ↓ 调用
Service层 (业务逻辑层)
    ↓ 调用
Mapper层 (数据访问层)
    ↓ 操作
Entity层 (实体层)
```

### 1.2 各层职责

| 层级 | 职责 | 文件位置 |
|------|------|----------|
| **Controller** | 接收请求、参数校验、调用Service、返回响应 | controller/ |
| **Service** | 业务逻辑处理、事务管理 | service/ |
| **ServiceImpl** | Service接口实现 | service/impl/ |
| **Mapper** | 数据库操作、SQL映射 | mapper/ |
| **Entity** | 数据库实体映射 | entity/ |
| **DTO** | 数据传输对象 | dto/ |

---

## 二、Controller层规范

### 2.1 标准Controller模板

```java
package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.EntityName;
import com.example.medical.service.EntityNameService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

/**
 * 模块名称Controller
 * @author 开发者
 * @date 创建日期
 */
@RestController
@RequestMapping("/module")
@CrossOrigin
@Validated
@Api(tags = "模块名称管理")
public class ModuleController {

    @Autowired
    private ModuleService moduleService;

    /**
     * 创建资源
     */
    @PostMapping("/create")
    @ApiOperation(value = "创建资源", notes = "创建新的资源记录")
    public Result<?> create(@Valid @RequestBody EntityName entity) {
        // 参数校验
        if (entity.getName() == null || entity.getName().trim().isEmpty()) {
            return Result.error("名称不能为空");
        }

        // 调用Service
        if (moduleService.save(entity)) {
            return Result.success("创建成功");
        } else {
            return Result.error("创建失败");
        }
    }

    /**
     * 分页查询列表
     */
    @GetMapping("/list")
    @ApiOperation(value = "分页查询", notes = "分页查询资源列表")
    public Result<?> list(
        @ApiParam("当前页") @RequestParam(defaultValue = "1") Integer current,
        @ApiParam("每页数量") @RequestParam(defaultValue = "10") Integer size,
        @ApiParam("搜索关键词") @RequestParam(required = false) String keyword
    ) {
        Page<EntityName> page = new Page<>(current, size);
        LambdaQueryWrapper<EntityName> wrapper = new LambdaQueryWrapper<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.like(EntityName::getName, keyword);
        }

        Page<EntityName> result = moduleService.page(page, wrapper);
        return Result.success(result);
    }

    /**
     * 根据ID查询详情
     */
    @GetMapping("/{id}")
    @ApiOperation(value = "查询详情", notes = "根据ID查询资源详情")
    public Result<?> getById(@ApiParam("资源ID") @PathVariable Long id) {
        EntityName entity = moduleService.getById(id);
        if (entity == null) {
            return Result.error("资源不存在");
        }
        return Result.success(entity);
    }

    /**
     * 更新资源
     */
    @PutMapping("/{id}")
    @ApiOperation(value = "更新资源", notes = "根据ID更新资源信息")
    public Result<?> update(
        @ApiParam("资源ID") @PathVariable Long id,
        @Valid @RequestBody EntityName entity
    ) {
        entity.setId(id);
        if (moduleService.updateById(entity)) {
            return Result.success("更新成功");
        } else {
            return Result.error("更新失败");
        }
    }

    /**
     * 删除资源
     */
    @DeleteMapping("/{id}")
    @ApiOperation(value = "删除资源", notes = "根据ID删除资源")
    public Result<?> delete(@ApiParam("资源ID") @PathVariable Long id) {
        if (moduleService.removeById(id)) {
            return Result.success("删除成功");
        } else {
            return Result.error("删除失败");
        }
    }
}
```

### 2.2 Controller规范要点

#### 2.2.1 注解使用

```java
@RestController          // 标识为RESTful控制器
@RequestMapping("/path") // 基础路径
@CrossOrigin            // 跨域支持
@Validated              // 启用参数校验
@Api(tags = "模块名称")  // Swagger文档
```

#### 2.2.2 依赖注入

```java
@Autowired
private ModuleService moduleService;
```

#### 2.2.3 请求映射

| 注解 | HTTP方法 | 用途 |
|------|---------|------|
| `@GetMapping` | GET | 查询 |
| `@PostMapping` | POST | 创建 |
| `@PutMapping` | PUT | 更新 |
| `@DeleteMapping` | DELETE | 删除 |
| `@PatchMapping` | PATCH | 部分更新 |

#### 2.2.4 参数接收

```java
// 路径参数
@GetMapping("/{id}")
public Result<?> getById(@PathVariable Long id) { }

// 查询参数
@GetMapping("/list")
public Result<?> list(@RequestParam(defaultValue = "1") Integer current) { }

// 请求体
@PostMapping("/create")
public Result<?> create(@RequestBody Entity entity) { }

// 表单数据
@PostMapping("/form")
public Result<?> form(@RequestParam String name, @RequestParam String value) { }
```

#### 2.2.5 统一响应格式

```java
// 成功响应
return Result.success(data);
return Result.success("操作成功");
return Result.success(result);

// 错误响应
return Result.error("错误信息");
return Result.error(500, "服务器错误");
```

---

## 三、Service层规范

### 3.1 Service接口模板

```java
package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.EntityName;

/**
 * 模块Service接口
 * @author 开发者
 * @date 创建日期
 */
public interface ModuleService extends IService<EntityName> {
    // 自定义业务方法
    EntityName findByName(String name);
    List<EntityName> findByCondition(String keyword);
}
```

### 3.2 ServiceImpl实现模板

```java
package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.EntityName;
import com.example.medical.mapper.ModuleMapper;
import com.example.medical.service.ModuleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 模块Service实现
 * @author 开发者
 * @date 创建日期
 */
@Service
@Transactional
public class ModuleServiceImpl extends ServiceImpl<ModuleMapper, EntityName> implements ModuleService {

    @Autowired
    private ModuleMapper moduleMapper;

    @Override
    public EntityName findByName(String name) {
        LambdaQueryWrapper<EntityName> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(EntityName::getName, name);
        return moduleMapper.selectOne(wrapper);
    }

    @Override
    public List<EntityName> findByCondition(String keyword) {
        LambdaQueryWrapper<EntityName> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.like(EntityName::getName, keyword);
        }
        return moduleMapper.selectList(wrapper);
    }
}
```

### 3.3 Service规范要点

#### 3.3.1 继承IService

```java
// Service接口继承IService
public interface ModuleService extends IService<EntityName> { }

// ServiceImpl继承ServiceImpl
public class ModuleServiceImpl extends ServiceImpl<ModuleMapper, EntityName> implements ModuleService { }
```

#### 3.3.2 事务管理

```java
@Service
@Transactional  // 类级别事务
public class ModuleServiceImpl { }

// 方法级别事务
@Transactional(rollbackFor = Exception.class)
public void complexOperation() { }
```

#### 3.3.3 常用IService方法

```java
// 保存
save(T entity)                    // 插入一条记录
saveBatch(Collection<T> list)     // 批量插入

// 更新
updateById(T entity)              // 根据ID更新
update(T entity, Wrapper<T> wrapper) // 条件更新

// 删除
removeById(Serializable id)       // 根据ID删除
remove(Wrapper<T> wrapper)        // 条件删除

// 查询
getById(Serializable id)          // 根据ID查询
getOne(Wrapper<T> wrapper)        // 查询一条
list()                            // 查询所有
list(Wrapper<T> wrapper)          // 条件查询
page(Page<T> page, Wrapper<T> wrapper) // 分页查询
```

---

## 四、Mapper层规范

### 4.1 Mapper接口模板

```java
package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.EntityName;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 模块Mapper接口
 * @author 开发者
 * @date 创建日期
 */
@Mapper
public interface ModuleMapper extends BaseMapper<EntityName> {
    // 自定义SQL查询
    @Select("SELECT * FROM table_name WHERE field = #{value}")
    EntityName selectByField(@Param("value") String value);

    // 复杂查询使用XML映射
    List<EntityName> selectComplexQuery(@Param("param1") String param1, @Param("param2") Integer param2);
}
```

### 4.2 Mapper规范要点

#### 4.2.1 继承BaseMapper

```java
@Mapper
public interface ModuleMapper extends BaseMapper<EntityName> { }
```

#### 4.2.2 常用BaseMapper方法

```java
// 插入
int insert(T entity);

// 更新
int updateById(T entity);
int update(T entity, Wrapper<T> wrapper);

// 删除
int deleteById(Serializable id);
int deleteByMap(Map<String, Object> columnMap);
int delete(Wrapper<T> wrapper);

// 查询
T selectById(Serializable id);
List<T> selectBatchIds(Collection<? extends Serializable> idList);
T selectOne(Wrapper<T> wrapper);
Integer selectCount(Wrapper<T> wrapper);
List<T> selectList(Wrapper<T> wrapper);
```

---

## 五、Entity层规范

### 5.1 Entity模板

```java
package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 模块实体
 * @author 开发者
 * @date 创建日期
 */
@Data
@TableName("table_name")
@ApiModel(value = "模块实体", description = "模块实体描述")
public class EntityName implements Serializable {

    private static final long serialVersionUID = 1L;

    @ApiModelProperty("主键ID")
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    @ApiModelProperty("名称")
    @TableField("name")
    private String name;

    @ApiModelProperty("创建时间")
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private Date createTime;

    @ApiModelProperty("更新时间")
    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @ApiModelProperty("是否删除")
    @TableLogic
    @TableField("is_deleted")
    private Integer isDeleted;
}
```

### 5.2 Entity规范要点

#### 5.2.1 常用注解

```java
@TableName("table_name")     // 表名
@TableId                     // 主键
@TableField("column_name")   // 字段映射
@TableLogic                  // 逻辑删除
@Version                     // 乐观锁
```

#### 5.2.2 主键策略

```java
@TableId(type = IdType.AUTO)     // 自增
@TableId(type = IdType.ASSIGN_ID) // 雪花算法
@TableId(type = IdType.ASSIGN_UUID) // UUID
```

#### 5.2.3 字段填充

```java
@TableField(fill = FieldFill.INSERT)        // 插入时填充
@TableField(fill = FieldFill.INSERT_UPDATE) // 插入和更新时填充
@TableField(fill = FieldFill.UPDATE)        // 更新时填充
```

---

## 六、DTO层规范

### 6.1 DTO模板

```java
package com.example.medical.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.Serializable;

/**
 * 模块DTO
 * @author 开发者
 * @date 创建日期
 */
@Data
@ApiModel(value = "模块DTO", description = "数据传输对象")
public class ModuleDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @ApiModelProperty(value = "名称", required = true)
    @NotBlank(message = "名称不能为空")
    private String name;

    @ApiModelProperty(value = "数量", required = true)
    @NotNull(message = "数量不能为空")
    private Integer quantity;

    @ApiModelProperty("备注")
    private String remark;
}
```

### 6.2 参数校验注解

```java
@NotNull      // 不能为null
@NotBlank     // 不能为空字符串
@NotEmpty     // 集合不能为空
@Min(value)   // 最小值
@Max(value)   // 最大值
@Size(min, max) // 长度范围
@Pattern(regexp) // 正则匹配
@Email        // 邮箱格式
```

---

## 七、统一响应格式

### 7.1 Result类

```java
package com.example.medical.common;

import lombok.Data;

import java.io.Serializable;

/**
 * 统一响应结果
 */
@Data
public class Result<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer code;
    private String message;
    private T data;

    public static <T> Result<T> success() {
        Result<T> result = new Result<>();
        result.setCode(200);
        result.setMessage("操作成功");
        return result;
    }

    public static <T> Result<T> success(T data) {
        Result<T> result = new Result<>();
        result.setCode(200);
        result.setMessage("操作成功");
        result.setData(data);
        return result;
    }

    public static <T> Result<T> success(String message, T data) {
        Result<T> result = new Result<>();
        result.setCode(200);
        result.setMessage(message);
        result.setData(data);
        return result;
    }

    public static <T> Result<T> error(String message) {
        Result<T> result = new Result<>();
        result.setCode(500);
        result.setMessage(message);
        return result;
    }

    public static <T> Result<T> error(Integer code, String message) {
        Result<T> result = new Result<>();
        result.setCode(code);
        result.setMessage(message);
        return result;
    }
}
```

### 7.2 响应码定义

```java
package com.example.medical.common;

/**
 * 响应码定义
 */
public enum ResponseCode {
    SUCCESS(200, "操作成功"),
    ERROR(500, "操作失败"),
    NOT_FOUND(404, "资源不存在"),
    UNAUTHORIZED(401, "未授权"),
    FORBIDDEN(403, "禁止访问");

    private final Integer code;
    private final String message;

    ResponseCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }

    public Integer getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
```

---

## 八、Swagger文档规范

### 8.1 Controller文档

```java
@Api(tags = "模块管理")
public class ModuleController {

    @ApiOperation(value = "创建资源", notes = "创建新的资源记录")
    @PostMapping("/create")
    public Result<?> create(@RequestBody Entity entity) { }

    @ApiOperation(value = "查询详情", notes = "根据ID查询资源详情")
    @GetMapping("/{id}")
    public Result<?> getById(@ApiParam("资源ID") @PathVariable Long id) { }
}
```

### 8.2 Entity文档

```java
@ApiModel(value = "用户实体", description = "用户信息")
public class User {

    @ApiModelProperty("用户ID")
    private Long id;

    @ApiModelProperty(value = "用户名", required = true)
    private String username;
}
```

---

## 九、JWT认证规范

### 9.1 JwtUtil工具类

```java
package com.example.medical.common;

import io.jsonwebtoken.*;
import java.util.Date;

/**
 * JWT工具类
 */
public class JwtUtil {

    private static final String SECRET = "your-secret-key";
    private static final long EXPIRATION = 7 * 24 * 60 * 60 * 1000; // 7天

    public static String generateToken(Long userId, String username) {
        return Jwts.builder()
                .setSubject(username)
                .claim("userId", userId)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION))
                .signWith(SignatureAlgorithm.HS512, SECRET)
                .compact();
    }

    public static Claims parseToken(String token) {
        return Jwts.parser()
                .setSigningKey(SECRET)
                .parseClaimsJws(token)
                .getBody();
    }

    public static boolean validateToken(String token) {
        try {
            parseToken(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
```

### 9.2 认证拦截器

```java
@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String token = request.getHeader("Authorization");
        if (token == null || !JwtUtil.validateToken(token)) {
            response.setStatus(401);
            return false;
        }
        return true;
    }
}
```

---

## 十、最佳实践

### 10.1 异常处理

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        return Result.error("系统异常: " + e.getMessage());
    }

    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException e) {
        return Result.error(e.getMessage());
    }
}
```

### 10.2 日志记录

```java
@Slf4j
@RestController
public class ModuleController {

    @PostMapping("/create")
    public Result<?> create(@RequestBody Entity entity) {
        log.info("创建资源: {}", entity);
        // 业务逻辑
        log.info("资源创建成功: id={}", entity.getId());
        return Result.success(entity);
    }
}
```

### 10.3 分页查询

```java
@GetMapping("/list")
public Result<?> list(
    @RequestParam(defaultValue = "1") Integer current,
    @RequestParam(defaultValue = "10") Integer size,
    @RequestParam(required = false) String keyword
) {
    Page<Entity> page = new Page<>(current, size);
    LambdaQueryWrapper<Entity> wrapper = new LambdaQueryWrapper<>();

    if (keyword != null) {
        wrapper.like(Entity::getName, keyword);
    }

    wrapper.orderByDesc(Entity::getCreateTime);

    Page<Entity> result = moduleService.page(page, wrapper);
    return Result.success(result);
}
```

---

**最后更新**: 2026-05-06
**适用版本**: Spring Boot 2.x, Java 17+, MyBatis-Plus 3.x
