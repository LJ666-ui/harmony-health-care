# 数据库修复指南 - 浏览历史功能

## 🚨 问题说明

### 根本原因
`local_browse_history` 表结构定义与实际代码使用**不匹配**，导致：
1. BrowseTracker 无法正确插入浏览记录
2. BrowseHistoryPage 无法查询到数据
3. SQLiteStudio 显示 `no such column` 错误

### 已修复内容
✅ **DatabaseConstants.ets** - 表结构已修正为正确的字段名

---

## 🔧 解决方案（选择一种）

### 方案A：删除旧数据库文件（推荐⭐）

#### 步骤1：关闭模拟器/应用
确保应用完全退出，避免文件被占用

#### 步骤2：删除旧数据库文件
```
文件路径：D:\harmony_medical.db
操作：直接删除该文件
```

或者使用命令行：
```bash
# Windows PowerShell
Remove-Item "D:\harmony_medical.db" -Force

# 或 CMD
del /F "D:\harmony_medical.db"
```

#### 步骤3：重新编译运行应用
```bash
# DevEco Studio
Ctrl + F9    # 重新编译
Shift + F10  # 运行到模拟器
```

应用启动后会自动创建新的、正确的表结构 ✅

---

### 方案B：在SQLiteStudio中手动修复表结构

#### 步骤1：打开SQLiteStudio
连接到 `D:\harmony_medical.db`

#### 步骤2：删除旧表
在SQL编辑器中执行：
```sql
DROP TABLE IF EXISTS local_browse_history;
```

#### 步骤3：创建新表（使用正确的结构）
```sql
CREATE TABLE IF NOT EXISTS local_browse_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  browse_type TEXT NOT NULL,
  target_id INTEGER NOT NULL,
  target_title TEXT,
  source_page TEXT,
  create_time INTEGER NOT NULL,
  browse_duration INTEGER
);
```

#### 步骤4：验证表结构
```sql
-- 查看表结构
PRAGMA table_info(local_browse_history);

-- 预期输出：
-- 0|id|INTEGER|0||1
-- 1|browse_type|TEXT|1||0
-- 2|target_id|INTEGER|1||0
-- 3|target_title|TEXT|0||0
-- 4|source_page|TEXT|0||0
-- 5|create_time|INTEGER|1||0
-- 6|browse_duration|INTEGER|0||0
```

#### 步骤5：重新编译运行应用
```bash
# DevEco Studio
Ctrl + F9    # 编译
Shift + F10  # 运行
```

---

## ✅ 修复后的表结构对比

### ❌ 旧的错误结构
```sql
CREATE TABLE local_browse_history (
  id INTEGER PRIMARY KEY,
  target_id TEXT,           -- 字段类型和用途不对
  target_type TEXT,         -- ❌ 应该是 browse_type
  target_title TEXT,
  target_image TEXT,        -- ❌ 不需要这列
  browse_time INTEGER       -- ❌ 应该是 create_time
)
```

### ✅ 新的正确结构
```sql
CREATE TABLE local_browse_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  browse_type TEXT NOT NULL,     -- 类型标识：ARTICLE/HERBAL/FOOD等
  target_id INTEGER NOT NULL,   -- 目标ID（文章ID）
  target_title TEXT,            -- 标题
  source_page TEXT,             -- 来源页面
  create_time INTEGER NOT NULL, -- 浏览时间戳
  browse_duration INTEGER       -- 浏览时长（毫秒）
)
```

---

## 🧪 功能测试步骤

### 1️⃣ 生成测试数据

进入 **我的 → 浏览历史** 页面，点击绿色 **"测试数据"** 按钮

应该看到插入5条模拟记录：
- 高血压的预防与日常管理指南（1小时前）
- 糖尿病患者饮食注意事项大全（2小时前）
- 冬季养生保健知识（1天前）
- 心血管疾病的早期症状识别（2天前）
- 如何科学补充维生素和矿物质（3天前）

### 2️⃣ 验证数据存储

在SQLiteStudio中查询：
```sql
SELECT * FROM local_browse_history ORDER BY create_time DESC;
```

预期结果：能看到刚才插入的5条记录

### 3️⃣ 测试点击跳转

点击任意一条文章记录，验证：
- ✅ 能正常跳转到 ScienceDetailPage
- ✅ 文章详情能正确加载
- ✅ 不再显示"加载失败"

### 4️⃣ 测试真实浏览记录

1. 进入 **发现** Tab
2. 点击任意 **科普文章**
3. 浏览几秒钟后返回
4. 再次进入 **浏览历史**
5. 应该能看到刚才浏览的文章自动记录

---

## 📋 数据字段说明

| 字段名 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| `id` | INTEGER | 主键自增 | 1, 2, 3... |
| `browse_type` | TEXT | 内容类型 | 'ARTICLE', 'HERBAL', 'FOOD' |
| `target_id` | INTEGER | 目标ID | 123 (文章ID) |
| `target_title` | TEXT | 标题 | '高血压预防指南' |
| `source_page` | TEXT | 来源页面 | 'ScienceDetailPage' |
| `create_time` | INTEGER | 时间戳(ms) | 1705276800000 |
| `browse_duration` | INTEGER | 浏览时长(ms) | 60000 (60秒) |

---

## 💡 常见问题排查

### Q1: 删除数据库后还是不行？
**A**: 确保：
- 完全关闭了模拟器/应用
- 删除的是正确路径的文件：`D:\harmony_medical.db`
- 重新编译并运行应用

### Q2: 插入测试数据失败？
**A**: 检查控制台日志：
- DevEco Studio 底部 Log 窗口
- 搜索关键词：`BrowseHistory`、`RdbHelper`、`error`
- 常见原因：数据库未初始化、权限不足

### Q3: 点击文章后还是"加载失败"？
**A**: 可能原因：
1. 后端服务未启动（端口8080）
2. 文章ID不存在或已被删除
3. 网络连接问题

检查后端是否正常运行：
```bash
# 浏览器访问
http://localhost:8080/test-health-food
# 应该返回："项目运行成功！健康食材接口正常！"
```

### Q4: SQLiteStudio报错 "no such column: next_retry_time"？
**A**: 这是 `sync_queue` 表的问题，不影响浏览历史功能。可以忽略，或在SQL编辑器单独处理：
```sql
-- 查看sync_queue表的实际结构
PRAGMA table_info(sync_queue);

-- 如果确实缺少该列，可以添加
ALTER TABLE sync_queue ADD COLUMN next_retry_time INTEGER;
```

---

## 🎯 完整功能验证清单

完成数据库修复后，请逐一测试：

### 基础功能
- [ ] **进入浏览历史页面**：我的 → 浏览历史
- [ ] **显示空状态提示**：首次打开显示友好提示
- [ ] **插入测试数据成功**：点击"测试数据"按钮无报错
- [ ] **数据显示正确**：看到5条分组记录
- [ ] **时间格式友好**：今天/昨天/具体日期
- [ ] **筛选功能正常**：切换"科普文章"/"全部记录"

### 跳转功能
- [ ] **点击文章跳转**：能打开ScienceDetailPage
- [ ] **参数传递正确**：不再显示"加载失败"
- [ ] **文章内容加载**：显示完整文章详情
- [ ] **返回后保留记录**：历史列表仍然存在

### 数据持久化
- [ ] **数据保存到本地**：SQLiteStudio能查到记录
- [ ] **重启应用后保留**：关闭重开后数据还在
- [ ] **清空功能正常**：可以删除所有记录

---

## 📞 技术支持

如果以上步骤都无法解决问题，请提供：

1. **控制台完整日志**（DevEco Studio Log窗口）
2. **具体错误信息**（截图或文字）
3. **操作步骤描述**（你做了什么操作）

---

**最后更新时间**：2026-01-15  
**适用版本**：HarmonyOS Next / ArkTS
