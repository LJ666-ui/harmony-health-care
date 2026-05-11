# 前端数据加载问题排查指南

## 问题现象
患者列表页面显示"暂无患者信息"

## 已完成的修复

### 1. 后端API已正常
```bash
curl http://localhost:8080/user/list
```
返回88+条用户数据，包含3个测试患者（张三、李四、王五）

### 2. 前端配置已修改
- **ApiConstants.ets**: 环境从 `DEV_EMULATOR` 改为 `DEV`
- **BASE_URL**: 从 `http://10.0.2.2:8080` 改为 `http://localhost:8080`

### 3. 添加详细调试日志
PatientApiService.ets 中添加了以下日志：
- Request URL
- BASE_URL
- Token状态
- Request Params
- Response Code
- Response Result
- Data Count

## 排查步骤

### 第一步：检查前端控制台日志
打开DevEco Studio的HiLog窗口，搜索以下关键词：
```
PatientApiService
PatientListViewModel
PatientListPage
```

### 第二步：验证网络请求
查看日志中是否包含：
- `Request URL: http://localhost:8080/user/list`
- `Response Code: 200`
- `Response Data Count: 88`

### 第三步：检查数据过滤
查看日志中是否包含：
- `Total Users: 88`
- `Filtered Patients: 3`（或其他数量）

## 可能的问题原因

### 1. 网络请求失败
**症状**: Response Code 不是 200
**解决**: 
- 检查BASE_URL是否正确
- 确认后端服务正在运行
- 检查防火墙设置

### 2. 数据解析失败
**症状**: Response Code 200，但 Data Count 为 0
**解决**:
- 检查后端返回的JSON格式
- 确认success字段为true
- 查看是否有异常日志

### 3. 用户类型过滤问题
**症状**: Total Users > 0，但 Filtered Patients = 0
**解决**:
- 检查user_type字段是否正确（患者应为0）
- 查看过滤逻辑日志

### 4. ViewModel状态问题
**症状**: 有数据但页面显示空状态
**解决**:
- 检查loadingState是否为SUCCESS
- 确认filteredPatients数组不为空
- 查看UI渲染逻辑

## 测试账号信息

### 护士账号
- 手机号: 13800138001
- 密码: 123456
- 姓名: 于护士
- 工号: N20230001

### 测试患者
- 张三 (ID: 111, 手机: 13800138002, 年龄: 45)
- 李四 (ID: 112, 手机: 13800138003, 年龄: 38)
- 王五 (ID: 113, 手机: 13800138004, 年龄: 52)

## 快速验证命令

### 后端API测试
```bash
# 测试用户列表
curl -s http://localhost:8080/user/list | python -m json.tool | head -50

# 测试患者数量
curl -s http://localhost:8080/user/list | grep -o '"userType":0' | wc -l
```

### 数据库验证
```sql
-- 查看患者数量
SELECT COUNT(*) FROM user WHERE user_type = 0 AND is_deleted = 0;

-- 查看测试患者
SELECT id, username, phone, real_name, age, user_type 
FROM user 
WHERE user_type = 0 AND real_name IS NOT NULL 
LIMIT 10;
```

## 下一步行动
1. 重新编译前端项目
2. 清除应用缓存数据
3. 重新登录护士账号
4. 查看HiLog日志输出
5. 进入患者列表页面
6. 观察日志中的数据加载过程

