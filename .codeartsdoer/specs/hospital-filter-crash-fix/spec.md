# 医院筛选崩溃修复 - 需求规格文档

**版本**: v1.0
**创建日期**: 2025-01-08
**最后更新**: 2025-01-08
**作者**: CodeArts Agent
**状态**: 草稿

## 1. 概述

### 1.1 功能简介
修复HarmonyOS健康医疗应用中"医院列表"页面点击分类筛选标签（如"三级甲等"、"综合医院"等）时应用崩溃的问题，通过增强错误处理机制确保应用稳定运行。

### 1.2 业务背景
用户在使用医院列表筛选功能时，应用因数据库查询异常而崩溃退出，严重影响用户体验。经代码分析发现，`HospitalCacheManager.getHospitalsByLevel`方法在调用`RdbHelper.queryByPredicates`时，如果数据库未正确初始化或查询条件有问题，会导致未捕获的异常。

### 1.3 范围定义
**包含范围**:
- 增强`HospitalCacheManager.getHospitalsByLevel`方法的错误处理
- 优化错误日志记录，包含详细的错误上下文信息
- 确保查询失败时返回空数组而非抛出异常
- 验证修复后筛选功能正常工作

**排除范围**:
- 修改数据库初始化流程（`EntryAbility.ets`）
- 修改`RdbHelper`类的核心逻辑
- 修改`HospitalPage.ets`的UI交互逻辑

## 2. 用户故事

### US-001: 医院筛选功能稳定运行
**作为** 健康医疗应用用户
**我想要** 点击医院分类筛选标签时应用不崩溃
**以便于** 正常浏览筛选后的医院列表

**验收标准**:
- Given 应用已启动并进入医院列表页面
- When 用户点击任意分类筛选标签（如"三级甲等"、"综合医院"）
- Then 应用正常显示筛选结果或空列表，不会崩溃退出

### US-002: 错误信息可追溯
**作为** 开发人员
**我想要** 查看详细的错误日志
**以便于** 快速定位问题根源

**验收标准**:
- Given 医院筛选查询发生异常
- When 系统捕获异常并记录日志
- Then 日志包含错误类型、错误消息、查询参数等关键信息

## 3. 功能需求

### 3.1 错误处理增强

#### FR-001: 数据库查询异常捕获
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When the `HospitalCacheManager.getHospitalsByLevel` method executes a database query, the system shall catch all exceptions including `BusinessError` and other runtime errors.

**验收标准**:
- Given the `getHospitalsByLevel` method is called with any level parameter
- When the database query throws any exception
- Then the exception is caught and logged, and an empty array is returned

**依赖**: 无

#### FR-002: 增强错误日志记录
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When an exception occurs during hospital query, the system shall log detailed error information including error type, error message, and query parameters.

**验收标准**:
- Given a database query exception is caught
- When the error is logged
- Then the log contains: error type, error message, query level parameter, and stack trace if available

**依赖**: FR-001

#### FR-003: 空结果集安全处理
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When the database query returns an empty result set, the system shall safely close the result set and return an empty array.

**验收标准**:
- Given the query executes successfully but returns no matching hospitals
- When the result set is processed
- Then the result set is properly closed and an empty array is returned

**依赖**: FR-001

### 3.2 日志记录优化

#### FR-004: 查询参数日志记录
**优先级**: P2
**类型**: 功能需求

**需求描述**:
When the `getHospitalsByLevel` method is called, the system shall log the query parameters for debugging purposes.

**验收标准**:
- Given the `getHospitalsByLevel` method is invoked
- When the method starts execution
- Then the log includes the level parameter value

**依赖**: 无

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 查询响应时间
**指标**: 正常情况下查询响应时间 < 500ms
**测试方法**: 使用性能分析工具测量`getHospitalsByLevel`方法执行时间

#### NFR-002: 错误处理开销
**指标**: 异常捕获和日志记录开销 < 10ms
**测试方法**: 模拟异常场景测量try-catch块执行时间

### 4.2 可用性需求

#### NFR-003: 崩溃率
**指标**: 医院筛选功能崩溃率 = 0%
**测试方法**: 执行100次筛选操作，验证无崩溃发生

### 4.3 可维护性需求

#### NFR-004: 日志可读性
**指标**: 错误日志包含足够的上下文信息用于问题定位
**测试方法**: 人工审查日志输出，确认包含关键字段

## 5. 数据需求

### 5.1 数据模型
本功能不涉及新的数据模型，复用现有的`HospitalCacheItem`接口：
```arkts
export interface HospitalCacheItem {
  id: number;
  name: string;
  address: string;
  phone: string;
  level: string;
  department: string;
  description: string;
  longitude: number;
  latitude: number;
  cached_time: number;
  data_source: string;
}
```

### 5.2 数据存储
使用现有的SQLite数据库表`local_hospital_cache`，无需修改表结构。

### 5.3 数据安全
- 错误日志不记录敏感信息（如医院电话、地址等详细数据）
- 仅记录查询参数和错误类型信息

## 6. 接口需求

### 6.1 用户界面
本功能不涉及UI修改，保持现有界面不变。

### 6.2 系统接口
修改的方法签名保持不变：
```arkts
public async getHospitalsByLevel(level: string): Promise<HospitalCacheItem[]>
```

## 7. 约束条件

### 7.1 技术约束
- 必须使用HarmonyOS ArkTS语言
- 必须兼容现有的`@ohos.data.relationalStore` API
- 必须使用`@kit.PerformanceAnalysisKit`的`hilog`进行日志记录

### 7.2 业务约束
- 修复方案不能改变现有业务逻辑
- 必须保持向后兼容性

### 7.3 时间约束
- 预计开发时间：2小时
- 预计测试时间：1小时

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 数据库查询异常捕获 | 捕获所有异常并返回空数组 | P0 | 待验证 |
| FR-002 | 增强错误日志记录 | 日志包含错误类型、消息、参数 | P1 | 待验证 |
| FR-003 | 空结果集安全处理 | 安全关闭结果集并返回空数组 | P1 | 待验证 |
| FR-004 | 查询参数日志记录 | 记录查询level参数 | P2 | 待验证 |
| NFR-001 | 查询响应时间 | < 500ms | - | 待验证 |
| NFR-002 | 错误处理开销 | < 10ms | - | 待验证 |
| NFR-003 | 崩溃率 | 0% | - | 待验证 |

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| RdbStore | 关系型数据库存储对象 |
| RdbPredicates | 关系型数据库谓词，用于构建查询条件 |
| ResultSet | 查询结果集 |
| BusinessError | HarmonyOS API抛出的业务错误类型 |

## 10. 附录

### 10.1 参考资料
- HarmonyOS关系型数据库文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/data-rdb-guidelines-V5
- 项目代码路径：`entry/src/main/ets/utils/HospitalCacheManager.ets`

### 10.2 变更历史
| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|---------|
| v1.0 | 2025-01-08 | CodeArts Agent | 初始版本 |
