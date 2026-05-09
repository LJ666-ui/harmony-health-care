# 医院数据前端缓存实现方案

## 一、需求说明

在前端操作时，将医院数据缓存到前端SQLite数据库`harmony_medical.db`中，实现：
1. **离线访问**：无网络时也能查看医院列表
2. **快速响应**：优先从缓存读取，提升加载速度
3. **数据同步**：缓存失效时自动从服务器更新

---

## 二、数据库设计

### 表名：`local_hospital_cache`

### 表结构

| 字段名 | 类型 | 说明 | 索引 |
|--------|------|------|------|
| id | INTEGER | 医院ID（主键） | PRIMARY KEY |
| name | TEXT | 医院名称 | ✓ |
| address | TEXT | 医院地址 | - |
| phone | TEXT | 联系电话 | - |
| level | TEXT | 医院等级/分类 | ✓ |
| department | TEXT | 科室/部门 | - |
| description | TEXT | 医院描述 | - |
| longitude | REAL | 经度 | - |
| latitude | REAL | 纬度 | - |
| cached_time | INTEGER | 缓存时间戳 | - |
| data_source | TEXT | 数据来源（server/local） | - |

### 索引设计

```sql
CREATE INDEX idx_hospital_level ON local_hospital_cache(level);
CREATE INDEX idx_hospital_name ON local_hospital_cache(name);
```

---

## 三、核心代码实现

### 1. HospitalCacheManager.ets

**位置**：`entry/src/main/ets/utils/HospitalCacheManager.ets`

**核心功能**：

#### (1) 初始化缓存表
```typescript
public async init(): Promise<void> {
  const createTableSql = `
    CREATE TABLE IF NOT EXISTS local_hospital_cache (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      address TEXT,
      phone TEXT,
      level TEXT,
      department TEXT,
      description TEXT,
      longitude REAL,
      latitude REAL,
      cached_time INTEGER NOT NULL,
      data_source TEXT DEFAULT 'server'
    )
  `;
  await rdbHelper.executeSql(createTableSql);
}
```

#### (2) 保存医院到缓存
```typescript
public async saveHospitals(hospitals: HospitalCacheItem[]): Promise<void> {
  rdbHelper.beginTransaction();
  
  for (const hospital of hospitals) {
    await rdbHelper.insertOrUpdate(TABLE_NAME, values, 'id', hospital.id);
  }
  
  rdbHelper.commit();
}
```

#### (3) 按等级查询医院
```typescript
public async getHospitalsByLevel(level: string): Promise<HospitalCacheItem[]> {
  const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
  
  if (level && level !== '全部') {
    predicates.equalTo('level', level);
  }
  
  return await rdbHelper.queryByPredicates(predicates);
}
```

#### (4) 检查缓存有效性
```typescript
public async isCacheValid(maxAgeMs: number = 24 * 60 * 60 * 1000): Promise<boolean> {
  const sql = `SELECT MAX(cached_time) as latest_time FROM ${TABLE_NAME}`;
  const latestTime = await query(sql);
  const now = Date.now();
  return (now - latestTime) < maxAgeMs;  // 默认24小时有效
}
```

#### (5) 获取缓存统计
```typescript
public async getCacheStats(): Promise<{ total: number; byLevel: Record<string, number> }> {
  const sql = `SELECT level, COUNT(*) as count FROM ${TABLE_NAME} GROUP BY level`;
  return await query(sql);
}
```

---

### 2. HospitalPage.ets 修改

**缓存加载逻辑**：

```typescript
async loadHospitalList(filterLevel?: string): Promise<void> {
  try {
    // 1. 先尝试从缓存读取
    const cachedHospitals = await hospitalCacheManager.getHospitalsByLevel(filterLevel || '全部');
    const isCacheValid = await hospitalCacheManager.isCacheValid();
    
    // 2. 缓存有效则直接使用
    if (cachedHospitals.length > 0 && isCacheValid) {
      console.log('使用缓存数据，数量：', cachedHospitals.length);
      this.hospitals = cachedHospitals;
      return;
    }
    
    // 3. 缓存无效则从服务器获取
    console.log('缓存无效，从服务器获取数据');
    const response = await HttpUtil.request(...);
    
    // 4. 保存到缓存
    if (response.success && response.data) {
      this.hospitals = hospitalList;
      await hospitalCacheManager.saveHospitals(cacheItems);
      console.log('已保存到缓存，数量：', cacheItems.length);
    }
  } catch (error) {
    // 错误处理
  }
}
```

---

## 四、工作流程

### 首次加载流程

```
用户打开医院列表页面
        ↓
检查缓存是否存在
        ↓
   缓存为空
        ↓
从服务器请求数据
        ↓
显示医院列表
        ↓
保存到本地缓存
```

### 再次加载流程

```
用户打开医院列表页面
        ↓
检查缓存是否存在
        ↓
   缓存存在
        ↓
检查缓存是否有效（24小时内）
        ↓
   缓存有效
        ↓
从缓存读取数据（快速响应）
        ↓
显示医院列表
```

### 缓存失效流程

```
用户打开医院列表页面
        ↓
检查缓存是否存在
        ↓
   缓存存在
        ↓
检查缓存是否有效
        ↓
   缓存过期（超过24小时）
        ↓
从服务器请求数据
        ↓
更新缓存
        ↓
显示医院列表
```

---

## 五、功能特性

### 1. 离线访问 ✅
- 无网络时自动从缓存读取
- 保证基本功能可用

### 2. 快速响应 ✅
- 优先使用缓存数据
- 避免重复网络请求
- 提升用户体验

### 3. 自动更新 ✅
- 缓存24小时自动失效
- 失效后自动从服务器更新
- 保证数据时效性

### 4. 分类缓存 ✅
- 支持按医院等级分类缓存
- 查询时按level字段筛选
- 性能优化

### 5. 缓存管理 ✅
- 提供缓存统计功能
- 支持手动清除缓存
- 便于调试和维护

---

## 六、性能优化

### 1. 索引优化
```sql
CREATE INDEX idx_hospital_level ON local_hospital_cache(level);
CREATE INDEX idx_hospital_name ON local_hospital_cache(name);
```

### 2. 批量操作
```typescript
// 使用事务批量插入
rdbHelper.beginTransaction();
for (const hospital of hospitals) {
  await rdbHelper.insertOrUpdate(...);
}
rdbHelper.commit();
```

### 3. 缓存策略
- **缓存有效期**：24小时
- **更新策略**：懒更新（使用时检查）
- **淘汰策略**：手动清除或覆盖更新

---

## 七、使用示例

### 查看缓存统计

```typescript
const stats = await hospitalCacheManager.getCacheStats();
console.log('缓存总数：', stats.total);
console.log('各分类数量：', stats.byLevel);
// 输出：
// 缓存总数：381
// 各分类数量：{
//   "三级甲等": 116,
//   "综合医院": 121,
//   "社区医院": 87,
//   "专科医院": 25,
//   "卫生院": 5,
//   "保健机构": 18,
//   "诊所": 9
// }
```

### 清除缓存

```typescript
await hospitalCacheManager.clearCache();
console.log('缓存已清除');
```

### 检查缓存有效性

```typescript
const isValid = await hospitalCacheManager.isCacheValid();
if (isValid) {
  console.log('缓存有效，可以使用');
} else {
  console.log('缓存已过期，需要更新');
}
```

---

## 八、测试验证

### 1. 首次加载测试
```
1. 清除缓存
2. 打开医院列表页面
3. 观察网络请求（应有请求）
4. 查看缓存统计（应有数据）
```

### 2. 缓存命中测试
```
1. 再次打开医院列表页面
2. 观察网络请求（应无请求）
3. 查看控制台日志（应显示"使用缓存数据"）
4. 确认加载速度更快
```

### 3. 缓存失效测试
```
1. 修改缓存时间为过去时间
2. 打开医院列表页面
3. 观察网络请求（应有请求）
4. 确认缓存已更新
```

### 4. 离线测试
```
1. 断开网络
2. 打开医院列表页面
3. 确认仍能显示数据（从缓存读取）
4. 确认功能正常
```

---

## 九、文件清单

### 新增文件
- ✅ `entry/src/main/ets/utils/HospitalCacheManager.ets` - 医院缓存管理器

### 修改文件
- ✅ `entry/src/main/ets/pages/HospitalPage.ets` - 添加缓存功能

### 文档文件
- ✅ `HOSPITAL_CACHE_IMPLEMENTATION.md` - 本实现方案文档

---

## 十、对比总结

| 功能 | 实现前 | 实现后 |
|------|--------|--------|
| 数据来源 | 仅网络 | 缓存+网络 |
| 离线访问 | ❌ 不支持 | ✅ 支持 |
| 加载速度 | 慢（网络请求） | 快（缓存优先） |
| 流量消耗 | 高 | 低 |
| 用户体验 | 一般 | 优秀 |

---

## 十一、后续优化建议

1. **增量更新**：只更新变化的医院数据
2. **图片缓存**：医院图片也缓存到本地
3. **地理信息**：使用缓存的经纬度支持离线地图
4. **智能预加载**：根据用户行为预加载常用分类
5. **压缩存储**：对文本字段压缩存储节省空间

---

**实现完成时间**：2026-05-08  
**实现状态**：✅ 已完成  
**功能状态**：✅ 离线访问、快速响应、自动更新  
**数据库位置**：`sqlite/harmony_medical.db`
