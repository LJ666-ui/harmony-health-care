# 医院系统数据修复 - 编码任务文档

**版本**: v1.0
**创建日期**: 2025-01-15
**最后更新**: 2025-01-15
**作者**: System
**状态**: 草稿

## 任务概览

| 任务类别 | 任务数量 | 状态 |
|---------|---------|------|
| 数据字典建设 | 1 | 待开始 |
| 数据模型定义 | 2 | 待开始 |
| 医院筛选修复 | 1 | 待开始 |
| 护士列表修复 | 1 | 待开始 |
| 家属中心优化 | 1 | 待开始 |
| **总计** | **6** | **待开始** |

## 任务依赖图

```
┌─────────────────────────────────────────────────────────┐
│                    任务依赖关系                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Task-1: 数据字典建设                                    │
│       ↓                                                 │
│  Task-2: 医院模型定义  ──────→  Task-4: 医院筛选修复      │
│       ↓                                                 │
│  Task-3: 护士模型定义  ──────→  Task-5: 护士列表修复      │
│                                                         │
│  Task-6: 家属中心优化 (独立任务)                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 详细任务列表

### Task-1: 建立医院等级数据字典

**优先级**: P0
**预估工时**: 0.5小时
**依赖**: 无
**关联需求**: FR-007

#### 任务描述
创建数据字典文件，定义医院等级的前后端映射关系，提供数据转换工具函数。

#### 输入
- spec.md中的医院等级映射表
- design.md中的数据字典接口设计

#### 输出
- `entry/src/main/ets/constants/DataDictionary.ets` - 数据字典文件

#### 验收标准
- 定义HOSPITAL_LEVEL_MAP映射表，包含8个医院等级的映射
- 定义HOSPITAL_LEVEL_REVERSE_MAP反向映射表
- 定义HOSPITAL_LEVELS数组，包含所有前端显示值
- 提供convertLevelToDbValue函数，实现前端到后端的转换
- 提供convertLevelToDisplayValue函数，实现后端到前端的转换
- 所有函数使用JSDoc注释说明参数和返回值
- 代码符合ArkTS规范，不使用any类型

#### 代码生成提示
```arkts
请生成以下文件：entry/src/main/ets/constants/DataDictionary.ets

文件要求：
1. 定义IDataDictionary接口，包含三个属性：
   - HOSPITAL_LEVEL_MAP: Record<string, string> - 前端显示值到后端存储值的映射
   - HOSPITAL_LEVEL_REVERSE_MAP: Record<string, string> - 后端存储值到前端显示值的映射
   - HOSPITAL_LEVELS: string[] - 所有医院等级列表（前端显示值）

2. 定义DataDictionary常量，实现IDataDictionary接口，包含以下映射关系：
   - '全部' -> ''
   - '三级甲等' -> '三级甲等医院'
   - '综合医院' -> '综合医院'
   - '社区医院' -> '社区医院'
   - '专科医院' -> '专科医院'
   - '卫生院' -> '卫生院'
   - '保健机构' -> '保健机构'
   - '诊所' -> '诊所'

3. 导出convertLevelToDbValue函数：
   参数：displayLevel: string - 前端显示值
   返回：string - 后端存储值
   功能：将前端显示的医院等级转换为后端存储值

4. 导出convertLevelToDisplayValue函数：
   参数：dbLevel: string - 后端存储值
   返回：string - 前端显示值
   功能：将后端存储的医院等级转换为前端显示值

5. 所有函数使用JSDoc注释，说明参数类型和返回值类型

6. 代码风格符合ArkTS规范，使用严格类型定义
```

---

### Task-2: 定义医院数据模型

**优先级**: P0
**预估工时**: 0.5小时
**依赖**: Task-1
**关联需求**: FR-001, FR-002

#### 任务描述
创建医院数据模型文件，定义Hospital接口和HospitalPageData接口。

#### 输入
- spec.md中的医院数据模型定义
- design.md中的接口设计

#### 输出
- `entry/src/main/ets/models/Hospital.ets` - 医院模型文件

#### 验收标准
- 定义Hospital接口，包含id、name、address、phone、level、department、description字段
- 定义HospitalPageData接口，包含records字段（Hospital数组）
- level字段注释说明数据库存储值为完整字符串（如"三级甲等医院"）
- 所有字段使用明确的类型定义（number、string等）
- 代码符合ArkTS规范，导出接口供其他模块使用

#### 代码生成提示
```arkts
请生成以下文件：entry/src/main/ets/models/Hospital.ets

文件要求：
1. 定义Hospital接口，包含以下字段：
   - id: number - 医院ID
   - name: string - 医院名称
   - address: string - 医院地址
   - phone: string - 医院电话
   - level: string - 医院等级（数据库存储值，如"三级甲等医院"、"综合医院"等）
   - department: string - 医院科室
   - description: string - 医院描述

2. 定义HospitalPageData接口，包含以下字段：
   - records: Hospital[] - 医院列表

3. 导出Hospital和HospitalPageData接口

4. level字段添加注释，说明数据库存储值为完整字符串

5. 代码风格符合ArkTS规范，使用严格类型定义
```

---

### Task-3: 定义护士数据模型

**优先级**: P0
**预估工时**: 0.5小时
**依赖**: Task-1
**关联需求**: FR-003, FR-004, FR-008

#### 任务描述
创建护士数据模型文件，定义Nurse接口，明确字段列表，确保不包含不存在的gender字段。

#### 输入
- spec.md中的护士数据模型定义
- design.md中的接口设计

#### 输出
- `entry/src/main/ets/models/Nurse.ets` - 护士模型文件

#### 验收标准
- 定义Nurse接口，包含id、userId、nurseNo、name、phone、department、title、workYears、avatar、status字段
- 不包含gender字段（数据库nurse表中不存在该字段）
- 所有字段使用明确的类型定义
- 代码符合ArkTS规范，导出接口供其他模块使用

#### 代码生成提示
```arkts
请生成以下文件：entry/src/main/ets/models/Nurse.ets

文件要求：
1. 定义Nurse接口，包含以下字段：
   - id: number - 护士ID
   - userId: number - 用户ID
   - nurseNo: string - 护士工号
   - name: string - 护士姓名
   - phone: string - 护士电话
   - department: string - 所属科室
   - title: string - 职称
   - workYears: number - 工作年限
   - avatar: string - 头像URL
   - status: number - 状态

2. 重要说明：此接口不包含gender字段，因为数据库nurse表中不存在该字段

3. 导出Nurse接口

4. 代码风格符合ArkTS规范，使用严格类型定义
```

---

### Task-4: 修复医院筛选功能

**优先级**: P0
**预估工时**: 1小时
**依赖**: Task-1, Task-2
**关联需求**: FR-001, FR-002

#### 任务描述
修改HospitalPage.ets文件，使用数据字典进行前后端数据转换，修复医院筛选功能。

#### 输入
- 现有HospitalPage.ets文件
- Task-1生成的DataDictionary.ets
- Task-2生成的Hospital.ets

#### 输出
- 修改后的`entry/src/main/ets/pages/HospitalPage.ets`

#### 验收标准
- 导入convertLevelToDbValue和convertLevelToDisplayValue函数
- 导入Hospital和HospitalPageData类型
- 在loadHospitalList方法中使用convertLevelToDbValue转换筛选参数
- 在缓存查询中使用convertLevelToDbValue转换level参数
- 保留原有的convertLevelToDbValue私有方法，或替换为导入的函数
- 筛选标签点击后，列表能正确显示对应等级的医院
- 代码添加注释说明数据转换逻辑

#### 代码生成提示
```arkts
请修改以下文件：entry/src/main/ets/pages/HospitalPage.ets

修改要求：
1. 在文件顶部导入语句中添加：
   import { convertLevelToDbValue, convertLevelToDisplayValue } from '../constants/DataDictionary';
   import type { Hospital, HospitalPageData } from '../models/Hospital';

2. 在loadHospitalList方法中：
   - 查询缓存时，使用this.convertLevelToDbValue(filterLevel || '全部')转换level参数
   - 发送HTTP请求时，使用this.convertLevelToDbValue(filterLevel)转换level参数

3. 保留原有的convertLevelToDbValue私有方法（或替换为导入的函数）

4. 添加注释说明数据转换逻辑：
   // 将前端显示的筛选标签转换为数据库中实际存储的值
   // 注意：数据库中使用 level 字段存储医院等级，值为完整字符串（如"三级甲等医院"）

5. 确保筛选功能正常工作：
   - 点击"三级甲等"筛选时，传递给后端的level参数为"三级甲等医院"
   - 点击"综合医院"筛选时，传递给后端的level参数为"综合医院"
   - 其他筛选标签同理

6. 代码风格符合ArkTS规范，保持与原有代码一致
```

---

### Task-5: 修复护士列表功能

**优先级**: P0
**预估工时**: 1小时
**依赖**: Task-3
**关联需求**: FR-003, FR-004

#### 任务描述
修改FamilyNurseListPage.ets文件，使用正确的Nurse数据模型，确保护士列表正常加载和显示。

#### 输入
- 现有FamilyNurseListPage.ets文件
- Task-3生成的Nurse.ets

#### 输出
- 修改后的`entry/src/main/ets/pages/FamilyNurseListPage.ets`

#### 验收标准
- 导入Nurse类型
- 修改nurses状态变量类型为Nurse[]
- 修改loadNurses方法返回类型为BaseResponse<Nurse[]>
- 确保不引用不存在的gender字段
- 护士列表能正常加载和显示
- 显示护士姓名、科室、职称、工作年限、头像等信息
- 列表项可点击进入聊天页面

#### 代码生成提示
```arkts
请修改以下文件：entry/src/main/ets/pages/FamilyNurseListPage.ets

修改要求：
1. 在文件顶部导入语句中添加：
   import type { Nurse } from '../models/Nurse';

2. 修改nurses状态变量类型：
   @State nurses: Nurse[] = [];

3. 修改loadNurses方法：
   - 返回类型改为Promise<void>
   - response类型改为BaseResponse<Nurse[]>
   - 确保不引用不存在的gender字段

4. 修改handleNurseClick方法参数类型：
   private handleNurseClick(nurse: Nurse): void

5. 确保护士列表正常显示：
   - 显示护士头像、姓名、工号
   - 显示科室、职称、工作年限
   - 支持搜索护士姓名或工号
   - 列表项可点击进入聊天

6. 代码风格符合ArkTS规范，保持与原有代码一致
```

---

### Task-6: 优化家属中心数据加载

**优先级**: P0
**预估工时**: 1小时
**依赖**: 无
**关联需求**: FR-005, FR-006

#### 任务描述
优化FamilyHome.ets文件，确保家属信息和关联患者数据完整加载和显示。

#### 输入
- 现有FamilyHome.ets文件
- spec.md中的家属信息模型定义

#### 输出
- 修改后的`entry/src/main/ets/pages/FamilyHome.ets`

#### 验收标准
- 确保loadData方法正确加载家属信息
- 确保loadRelatedUserInfo方法正确加载关联患者信息
- 显示家属基本信息卡片（姓名、关系、联系方式、年龄、性别、健康状况）
- 显示关联患者信息卡片（患者姓名、ID、电话）
- "查看详情"按钮能正确跳转到患者健康记录页面
- 退出登录功能正常工作

#### 代码生成提示
```arkts
请修改以下文件：entry/src/main/ets/pages/FamilyHome.ets

修改要求：
1. 确保loadData方法正确加载家属信息：
   - 调用HttpUtil.get<FamilyInfo>('/family/info', options)获取家属信息
   - 将返回数据保存到this.familyInfo
   - 使用AppStorage.setOrCreate保存familyInfo到全局存储

2. 确保loadRelatedUserInfo方法正确加载关联患者信息：
   - 调用HttpUtil.get<RelatedUser>(`/user/${userId}`)获取用户信息
   - 将返回数据保存到this.relatedUser
   - 使用AppStorage.setOrCreate保存relatedUser到全局存储

3. 确保家属信息卡片完整显示：
   - 显示家属头像、姓名、关系
   - 显示手机号、年龄、性别
   - 显示健康状况（如果有）
   - 显示紧急联系人标识（如果是）

4. 确保关联患者信息卡片完整显示：
   - 显示患者头像、姓名
   - 显示患者ID、电话
   - "查看详情"按钮能正确跳转到FamilyHealthRecords页面

5. 确保退出登录功能正常：
   - 清除家属认证信息
   - 清除全局存储的familyToken、familyInfo、isFamilyLoggedIn
   - 跳转到登录页面

6. 代码风格符合ArkTS规范，保持与原有代码一致
```

---

## 测试验证计划

### 单元测试
- [ ] 测试convertLevelToDbValue函数，验证所有医院等级的转换
- [ ] 测试convertLevelToDisplayValue函数，验证反向转换

### 集成测试
- [ ] 测试医院筛选功能，验证各个筛选标签都能正确显示对应医院
- [ ] 测试护士列表加载，验证护士信息完整显示
- [ ] 测试家属中心数据加载，验证家属和患者信息完整显示

### UI测试
- [ ] 测试医院列表页面交互，验证筛选标签点击响应
- [ ] 测试护士列表页面交互，验证搜索和点击功能
- [ ] 测试家属中心页面交互，验证功能菜单跳转

---

## 注意事项

1. **类型安全**：所有代码必须使用ArkTS严格类型，禁止使用any类型
2. **代码注释**：关键逻辑必须添加注释说明
3. **向后兼容**：修改现有代码时保持向后兼容，不影响其他功能
4. **数据一致性**：确保前后端数据契约一致，避免再次出现不匹配问题
5. **测试验证**：每个任务完成后进行测试验证，确保功能正常

---

## 附录

### 相关文件路径
- 数据字典：`entry/src/main/ets/constants/DataDictionary.ets`
- 医院模型：`entry/src/main/ets/models/Hospital.ets`
- 护士模型：`entry/src/main/ets/models/Nurse.ets`
- 医院页面：`entry/src/main/ets/pages/HospitalPage.ets`
- 护士列表：`entry/src/main/ets/pages/FamilyNurseListPage.ets`
- 家属中心：`entry/src/main/ets/pages/FamilyHome.ets`

### 变更历史

| 版本 | 日期 | 变更内容 | 变更人 |
|-----|------|---------|--------|
| v1.0 | 2025-01-15 | 初始版本，完成编码任务文档 | System |
