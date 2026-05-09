# 家属功能数据修复完整指南

## 📋 问题概述

### 核心问题
家属功能无法查看病例信息，原因是：
1. **数据关联错误**：家属关联的是医生（user_type=1），而不是患者（user_type=0）
2. **缺少病例数据**：医生没有病例记录，查询返回空
3. **user_type定义混乱**：设计文档与实际使用不一致

### 数据证据
```
user表：
- ID 1-20: user_type=1 (医生)
- ID 21-100: user_type=0 (患者)

family_member表：
- family_id=1,2,3 关联 user_id=1 (医生王建国)
- family_id=4,5 关联 user_id=2 (医生李淑琴)

问题：家属是"医生的家属"，而不是"患者的家属"
```

---

## 🚀 快速修复步骤

### 步骤1：备份数据库（重要！）
```bash
# 导出当前数据库
mysqldump -u root -p123456 medical_health > backup_before_fix_$(date +%Y%m%d).sql
```

### 步骤2：诊断问题
```bash
# 连接MySQL
mysql -u root -p123456

# 切换数据库
USE medical_health;

# 执行诊断脚本
source e:/HMOS6.0/Github/harmony-health-care/fix-family-data-association.sql
```

**预期输出**：
- 显示user_type分布
- 显示家属关联的用户类型（应该是"❌ 错误：关联医生"）
- 显示可用的患者列表

### 步骤3：修正数据关联
根据诊断结果，执行以下UPDATE语句：

```sql
-- 方案A：将家属关联到患者21（马建国，64岁）
UPDATE family_member 
SET user_id = 21, 
    update_time = NOW() 
WHERE id IN (1, 2, 3);

-- 方案B：将家属关联到患者22（任桂英，36岁）
UPDATE family_member 
SET user_id = 22, 
    update_time = NOW() 
WHERE id IN (4, 5);

-- 验证修正结果
SELECT 
    fm.id AS family_id,
    fm.name AS family_name,
    fm.user_id AS related_user_id,
    u.username AS related_username,
    u.user_type AS related_user_type,
    CASE u.user_type 
        WHEN 0 THEN '✅ 正确：关联患者'
        ELSE '❌ 错误'
    END AS status
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;
```

### 步骤4：插入测试病例数据
```bash
# 执行病例数据插入脚本
source e:/HMOS6.0/Github/harmony-health-care/insert-test-medical-records.sql
```

取消注释并执行INSERT语句，为患者添加病例数据：

```sql
-- 为患者21添加病例
INSERT INTO medical_record (
    user_id, hospital_id, doctor_id, 
    diagnosis, treatment, record_time, 
    is_desensitized, is_deleted, create_time, update_time
) VALUES 
(21, 1, 1, '高血压病3级（极高危）', 
 '降压药物治疗：氨氯地平5mg qd + 缬沙坦80mg qd\n低盐低脂饮食\n定期监测血压', 
 '2026-05-01 10:00:00', 0, 0, NOW(), NOW()),
 
(21, 1, 2, '2型糖尿病', 
 '口服降糖药：二甲双胍0.5g tid\n饮食控制\n定期监测血糖', 
 '2026-04-15 14:30:00', 0, 0, NOW(), NOW());

-- 为患者22添加病例
INSERT INTO medical_record (
    user_id, hospital_id, doctor_id, 
    diagnosis, treatment, record_time, 
    is_desensitized, is_deleted, create_time, update_time
) VALUES 
(22, 1, 4, '慢性浅表性胃炎', 
 '抑酸治疗：奥美拉唑20mg qd\n胃黏膜保护：铝碳酸镁1g tid', 
 '2026-04-28 11:00:00', 0, 0, NOW(), NOW());
```

### 步骤5：验证修复结果
```sql
-- 验证家属能否查看病例
SELECT 
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    u.username AS 关联患者,
    COUNT(mr.id) AS 可查看病例数,
    CASE 
        WHEN COUNT(mr.id) > 0 THEN '✅ 修复成功'
        ELSE '❌ 仍需修复'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
WHERE fm.is_deleted = 0
GROUP BY fm.id, fm.name, fm.relation, u.username;
```

### 步骤6：重启服务并测试
```bash
# 重启后端服务
# 如果使用IDE，重启Spring Boot应用
# 如果使用命令行
cd e:/HMOS6.0/Github/harmony-health-care
mvn spring-boot:run

# 或者如果已经打包
java -jar target/medical-0.0.1-SNAPSHOT.jar
```

**测试步骤**：
1. 使用家属账户登录（如果已启用登录功能）
2. 或者使用患者账户登录，查看家属管理页面
3. 进入"家属中心" -> "医疗记录"
4. 确认能看到病例信息

---

## 📊 user_type字段统一方案

### 当前问题
设计文档定义：`0-普通用户，1-医生`
实际使用情况：需要验证

### 推荐标准定义
```sql
user_type定义：
0 - 普通用户/家属（可以查看关联患者的健康信息）
1 - 患者（拥有自己的健康记录和病例信息）
2 - 医生（可以查看和管理患者的医疗信息）
3 - 护士（协助医生管理患者护理信息）
4 - 管理员（系统管理权限）
```

### 修复方案
如果需要重新定义user_type，执行：

```bash
source e:/HMOS6.0/Github/harmony-health-care/fix-user-type-definition.sql
```

**注意**：执行前务必备份数据库！

---

## 🔧 常见问题排查

### Q1: 执行脚本时提示"Table doesn't exist"
**原因**：数据库未创建或表结构不完整
**解决**：
```bash
# 导入完整数据库
mysql -u root -p123456 < e:/HMOS6.0/Github/harmony-health-care/medical_health6.sql
```

### Q2: 家属仍然看不到病例
**排查步骤**：
```sql
-- 1. 检查family_member关联是否正确
SELECT * FROM family_member WHERE is_deleted = 0;

-- 2. 检查medical_record是否有数据
SELECT COUNT(*) FROM medical_record WHERE is_deleted = 0;

-- 3. 检查关联的患者是否有病例
SELECT 
    u.id, u.username, 
    COUNT(mr.id) AS case_count
FROM user u
LEFT JOIN medical_record mr ON u.id = mr.user_id
WHERE u.user_type = 0 AND u.is_deleted = 0
GROUP BY u.id, u.username;
```

### Q3: 前端显示"暂无病历记录"
**可能原因**：
1. 后端API返回空数据
2. 前端获取的userId不正确
3. Token验证失败

**排查方法**：
1. 打开浏览器开发者工具
2. 查看Network面板
3. 找到`/medical/record/my`请求
4. 检查请求参数和响应数据

---

## 📝 需要同步修改的代码

### 1. 更新设计文档
**文件**：`init-database.sql`
```sql
-- 修改user表定义
`user_type` tinyint DEFAULT 0 COMMENT '用户类型：0-普通用户/家属，1-患者，2-医生，3-护士，4-管理员'
```

### 2. 更新实体类
**文件**：`src/main/java/com/example/medical/entity/User.java`
```java
// 添加用户类型枚举
public enum UserType {
    FAMILY(0, "普通用户/家属"),
    PATIENT(1, "患者"),
    DOCTOR(2, "医生"),
    NURSE(3, "护士"),
    ADMIN(4, "管理员");
    
    private final int code;
    private final String desc;
    
    UserType(int code, String desc) {
        this.code = code;
        this.desc = desc;
    }
    
    public int getCode() { return code; }
    public String getDesc() { return desc; }
}
```

### 3. 检查前端代码
**文件**：`entry/src/main/ets/pages/FamilyMedicalRecords.ets`
- 确认`relatedUserId`获取正确
- 确认API调用参数正确

---

## ✅ 修复完成检查清单

- [ ] 已备份数据库
- [ ] 已执行诊断脚本
- [ ] 已修正family_member关联
- [ ] 已插入测试病例数据
- [ ] 已验证家属能查看病例
- [ ] 已重启后端服务
- [ ] 已测试前端功能
- [ ] 已更新设计文档（可选）
- [ ] 已更新代码注释（可选）

---

## 📞 技术支持

如果遇到问题，请提供以下信息：
1. 执行的SQL语句和错误信息
2. 数据库表结构和数据截图
3. 后端日志（特别是错误日志）
4. 前端控制台日志

---

**修复脚本位置**：
- `fix-family-data-association.sql` - 数据关联修复
- `fix-user-type-definition.sql` - user_type统一方案
- `insert-test-medical-records.sql` - 测试病例数据插入

**生成时间**：2026-05-11
**作者**：CodeArts Agent
