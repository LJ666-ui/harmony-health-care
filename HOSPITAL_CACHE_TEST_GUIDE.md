# 医院缓存功能测试指南

## 一、测试准备

### 1. 确认文件已创建
```bash
# 运行验证脚本
bash verify-hospital-cache.sh
```

**预期结果**：
```
✅ HospitalCacheManager.ets 已创建
✅ HospitalPage.ets 已集成缓存功能
```

### 2. 启动后端服务
```bash
# 确保后端服务运行
mysql -uroot -p123456 -e "SELECT 1;"
# 如果连接成功，说明MySQL服务正常

# 启动Spring Boot后端（如果未启动）
cd E:/harmony-health-care
mvn spring-boot:run
```

---

## 二、测试步骤

### 测试1：首次加载（缓存初始化）

#### 步骤：
1. **清除旧缓存**（如果存在）
   ```typescript
   // 在应用初始化时或开发工具中执行
   import hospitalCacheManager from '../utils/HospitalCacheManager';
   await hospitalCacheManager.clearCache();
   console.log('缓存已清除');
   ```

2. **打开医院列表页面**
   - 启动HarmonyOS应用
   - 导航到"就医" → "医院列表"

3. **观察控制台日志**
   - 打开DevEco Studio的HiLog窗口
   - 查找标签：`HospitalPage` 和 `HospitalCacheManager`

#### 预期结果：
```
[HospitalPage] 缓存无效，从服务器获取数据
[HospitalPage] 请求医院列表...
[HospitalPage] 接收到数据，数量：381
[HospitalCacheManager] Saved 381 hospitals to cache
[HospitalPage] 已保存到缓存，数量：381
```

#### 验证：
- ✅ 页面显示381家医院
- ✅ 控制台显示"从服务器获取数据"
- ✅ 控制台显示"已保存到缓存"

---

### 测试2：缓存命中（快速加载）

#### 步骤：
1. **关闭医院列表页面**
   - 返回上一页或退出应用

2. **重新打开医院列表页面**
   - 再次进入"就医" → "医院列表"

3. **观察控制台日志**

#### 预期结果：
```
[HospitalPage] 使用缓存数据，数量：381
```

#### 验证：
- ✅ 页面快速显示（< 100ms）
- ✅ 控制台显示"使用缓存数据"
- ✅ **无网络请求日志**（重要！）
- ✅ 加载速度明显比首次快

---

### 测试3：分类筛选缓存

#### 步骤：
1. **点击"三级甲等"分类**
   - 观察页面更新
   - 观察控制台日志

2. **点击"综合医院"分类**
   - 观察页面更新

3. **再次点击"三级甲等"**
   - 这次应该使用缓存

#### 预期结果：
```
首次点击"三级甲等"：
[HospitalPage] 使用缓存数据，数量：116

首次点击"综合医院"：
[HospitalPage] 使用缓存数据，数量：121

再次点击"三级甲等"：
[HospitalPage] 使用缓存数据，数量：116
```

#### 验证：
- ✅ "三级甲等"显示116家医院
- ✅ "综合医院"显示121家医院
- ✅ 所有操作都使用缓存，无网络请求

---

### 测试4：离线访问测试

#### 步骤：
1. **断开网络连接**
   - 关闭WiFi或移动数据
   - 或者在应用设置中禁用网络权限

2. **打开医院列表页面**
   - 尝试访问医院列表

3. **测试分类筛选**
   - 点击不同分类
   - 观察是否能正常显示

#### 预期结果：
```
[HospitalPage] 使用缓存数据，数量：381
离线模式下仍能正常显示医院列表
```

#### 验证：
- ✅ 离线状态下仍能显示医院列表
- ✅ 所有分类筛选正常工作
- ✅ 无错误提示
- ✅ 功能完全可用

---

### 测试5：缓存有效性测试

#### 步骤：
1. **检查缓存是否有效**
   ```typescript
   const isValid = await hospitalCacheManager.isCacheValid();
   console.log('缓存是否有效：', isValid);
   // 预期：true（24小时内）
   ```

2. **模拟缓存过期**
   ```typescript
   // 手动设置缓存时间为25小时前
   const sql = `UPDATE local_hospital_cache SET cached_time = ${Date.now() - 25 * 60 * 60 * 1000}`;
   await rdbHelper.executeSql(sql);
   
   // 再次检查
   const isValid = await hospitalCacheManager.isCacheValid();
   console.log('缓存是否有效：', isValid);
   // 预期：false（已过期）
   ```

3. **打开医院列表页面**
   - 观察是否会重新请求数据

#### 预期结果：
```
缓存过期后打开页面：
[HospitalPage] 缓存无效，从服务器获取数据
[HospitalPage] 已保存到缓存，数量：381
```

#### 验证：
- ✅ 缓存过期后自动从服务器更新
- ✅ 更新后缓存重新变为有效

---

### 测试6：查看SQLite数据库

#### 步骤：
1. **找到数据库文件**
   ```
   位置：应用沙箱路径/databases/local.db
   或：项目根目录/sqlite/harmony_medical.db
   ```

2. **使用SQLite工具打开**
   - 推荐工具：SQLiteStudio、DB Browser for SQLite
   - 打开数据库文件

3. **查看缓存表**
   ```sql
   -- 查看表结构
   .schema local_hospital_cache
   
   -- 查看数据数量
   SELECT COUNT(*) FROM local_hospital_cache;
   -- 预期：381
   
   -- 查看分类统计
   SELECT level, COUNT(*) as count 
   FROM local_hospital_cache 
   GROUP BY level;
   
   -- 查看前10条数据
   SELECT id, name, level, cached_time 
   FROM local_hospital_cache 
   LIMIT 10;
   
   -- 查看缓存时间
   SELECT MIN(cached_time) as earliest, 
          MAX(cached_time) as latest,
          COUNT(*) as total
   FROM local_hospital_cache;
   ```

#### 预期结果：
```sql
-- 数据数量
COUNT(*)
--------
381

-- 分类统计
level         count
-----------   -----
三级甲等       116
综合医院       121
社区医院       87
专科医院       25
卫生院         5
保健机构       18
诊所           9
```

#### 验证：
- ✅ 表已创建
- ✅ 数据已保存
- ✅ 分类统计正确
- ✅ 缓存时间合理

---

## 三、自动化测试脚本

### 创建测试脚本
```typescript
// entry/src/main/ets/tests/HospitalCacheTest.ets

import hospitalCacheManager from '../utils/HospitalCacheManager';

export async function testHospitalCache(): Promise<void> {
  console.log('=== 开始医院缓存测试 ===');
  
  // 测试1：初始化
  console.log('\n测试1：初始化缓存表');
  await hospitalCacheManager.init();
  console.log('✅ 初始化成功');
  
  // 测试2：清除缓存
  console.log('\n测试2：清除缓存');
  await hospitalCacheManager.clearCache();
  const statsAfterClear = await hospitalCacheManager.getCacheStats();
  console.log('缓存数量：', statsAfterClear.total);
  console.log(statsAfterClear.total === 0 ? '✅ 清除成功' : '❌ 清除失败');
  
  // 测试3：保存数据
  console.log('\n测试3：保存医院数据');
  const testHospitals = [
    {
      id: 1,
      name: '测试医院1',
      address: '测试地址1',
      phone: '12345678',
      level: '三级甲等',
      department: '综合医院',
      description: '测试描述',
      longitude: 116.397,
      latitude: 39.909,
      cached_time: Date.now(),
      data_source: 'server'
    }
  ];
  await hospitalCacheManager.saveHospitals(testHospitals);
  console.log('✅ 保存成功');
  
  // 测试4：查询数据
  console.log('\n测试4：查询医院数据');
  const hospitals = await hospitalCacheManager.getHospitalsByLevel('三级甲等');
  console.log('查询结果数量：', hospitals.length);
  console.log(hospitals.length === 1 ? '✅ 查询成功' : '❌ 查询失败');
  
  // 测试5：按ID查询
  console.log('\n测试5：按ID查询');
  const hospital = await hospitalCacheManager.getHospitalById(1);
  console.log('查询结果：', hospital?.name);
  console.log(hospital?.name === '测试医院1' ? '✅ 按ID查询成功' : '❌ 按ID查询失败');
  
  // 测试6：缓存统计
  console.log('\n测试6：缓存统计');
  const stats = await hospitalCacheManager.getCacheStats();
  console.log('缓存总数：', stats.total);
  console.log('分类统计：', JSON.stringify(stats.byLevel));
  console.log('✅ 统计功能正常');
  
  // 测试7：缓存有效性
  console.log('\n测试7：缓存有效性检查');
  const isValid = await hospitalCacheManager.isCacheValid();
  console.log('缓存是否有效：', isValid);
  console.log(isValid ? '✅ 缓存有效' : '⚠️ 缓存已过期');
  
  console.log('\n=== 测试完成 ===');
}
```

### 运行测试
```typescript
// 在页面中调用
import { testHospitalCache } from '../tests/HospitalCacheTest';

// 在aboutToAppear中执行
async aboutToAppear() {
  await testHospitalCache();
}
```

---

## 四、验证清单

### ✅ 功能验证

- [ ] 首次加载从服务器获取数据
- [ ] 首次加载数据保存到缓存
- [ ] 再次加载使用缓存数据
- [ ] 缓存加载速度明显更快
- [ ] 分类筛选功能正常
- [ ] 离线状态下可访问
- [ ] 缓存过期自动更新
- [ ] SQLite数据库有数据

### ✅ 性能验证

- [ ] 首次加载时间：2-3秒
- [ ] 缓存加载时间：< 100ms
- [ ] 内存占用合理
- [ ] 无内存泄漏

### ✅ 数据验证

- [ ] 缓存数据完整（381条）
- [ ] 分类统计正确
- [ ] 缓存时间合理
- [ ] 索引创建成功

---

## 五、故障排查

### 问题1：缓存未保存

**症状**：每次都从服务器获取数据

**排查**：
```typescript
// 检查RdbHelper是否初始化
import rdbHelper from '../utils/RdbHelper';
console.log('RdbStore:', rdbHelper.getRdb());

// 检查缓存管理器是否初始化
await hospitalCacheManager.init();
```

**解决**：确保在Ability初始化时调用`rdbHelper.init(context)`

---

### 问题2：缓存读取失败

**症状**：控制台显示"缓存无效"

**排查**：
```typescript
// 检查缓存是否存在
const stats = await hospitalCacheManager.getCacheStats();
console.log('缓存统计：', stats);

// 检查缓存有效性
const isValid = await hospitalCacheManager.isCacheValid();
console.log('缓存是否有效：', isValid);
```

**解决**：清除缓存重新加载

---

### 问题3：数据库文件找不到

**症状**：无法打开SQLite数据库

**排查**：
```bash
# 查找数据库文件
adb shell find /data -name "local.db"
adb shell find /data -name "harmony_medical.db"
```

**解决**：数据库在应用沙箱目录，需要root权限或使用DevEco Studio的工具导出

---

## 六、性能基准测试

### 创建性能测试脚本
```typescript
export async function performanceTest(): Promise<void> {
  console.log('=== 性能测试开始 ===');
  
  // 测试1：网络加载时间
  const start1 = Date.now();
  // 模拟网络请求
  await fetchFromServer();
  const time1 = Date.now() - start1;
  console.log('网络加载时间：', time1, 'ms');
  
  // 测试2：缓存加载时间
  const start2 = Date.now();
  await hospitalCacheManager.getHospitalsByLevel('全部');
  const time2 = Date.now() - start2;
  console.log('缓存加载时间：', time2, 'ms');
  
  // 性能提升
  const improvement = ((time1 - time2) / time1 * 100).toFixed(2);
  console.log('性能提升：', improvement, '%');
  
  console.log('=== 性能测试结束 ===');
}
```

---

## 七、测试报告模板

```markdown
# 医院缓存功能测试报告

## 测试环境
- 设备：
- 系统版本：
- 应用版本：
- 测试时间：

## 测试结果

### 功能测试
| 测试项 | 结果 | 备注 |
|--------|------|------|
| 首次加载 | ✅ 通过 | 从服务器获取381条数据 |
| 缓存保存 | ✅ 通过 | 成功保存到SQLite |
| 缓存读取 | ✅ 通过 | 使用缓存，加载< 100ms |
| 分类筛选 | ✅ 通过 | 所有分类正常 |
| 离线访问 | ✅ 通过 | 离线可访问 |

### 性能测试
| 指标 | 首次加载 | 缓存加载 | 提升 |
|------|----------|----------|------|
| 加载时间 | 2500ms | 80ms | 96.8% |
| 网络请求 | 1次 | 0次 | 100% |

### 结论
✅ 医院缓存功能实现完整，性能优秀，测试通过。
```

---

**测试完成时间**：2026-05-08  
**测试状态**：待执行  
**预期结果**：全部通过 ✅
