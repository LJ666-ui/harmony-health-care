# 前端数据显示问题排查指南

## 已添加的调试日志

### PatientListPage.ets
```
=== PatientListPage - aboutToAppear START ===
PatientListPage - Initial loadingState: 0
PatientListPage - loadPatientList called
PatientListPage - updateState - patients count: XX
PatientListPage - updateState - filteredPatients count: XX
PatientListPage - updateState - loadingState: X
PatientListPage - After loadPatientList, loadingState: X
=== PatientListPage - aboutToAppear END ===
```

### PatientListViewModel.ets
```
=== PatientListViewModel - loadPatientList START ===
PatientListViewModel - pageNumber: 1
PatientListViewModel - pageSize: 20
PatientListViewModel - Loaded patients count: XX
PatientListViewModel - First patient: {...}
PatientListViewModel - filteredPatients count: XX
PatientListViewModel - State: SUCCESS/EMPTY
=== PatientListViewModel - loadPatientList END ===
```

### PatientApiService.ets
```
PatientApiService - Request URL: http://172.26.96.1:8080/user/list
PatientApiService - BASE_URL: http://172.26.96.1:8080
PatientApiService - Token: exists/empty
PatientApiService - Response Code: 200
PatientApiService - Response Data Count: 112
PatientApiService - Total Users: 112
User ID 111: userType=0, isPatient=true
PatientApiService - Filtered Patients: 88
```

## 排查步骤

### 1. 重新编译前端
```
DevEco Studio → Build → Clean Project
DevEco Studio → Build → Rebuild Project
```

### 2. 运行应用并查看日志
在DevEco Studio的HiLog窗口中：
- 搜索关键词：`PatientListPage`
- 查看完整的数据加载流程

### 3. 预期正常日志顺序
```
1. PatientListPage - aboutToAppear START
2. PatientListViewModel - loadPatientList START
3. PatientApiService - Request URL
4. PatientApiService - Response Code: 200
5. PatientApiService - Filtered Patients: 88
6. PatientListViewModel - Loaded patients count: 88
7. PatientListViewModel - State: SUCCESS
8. PatientListPage - updateState - loadingState: 2 (SUCCESS)
```

### 4. LoadingState枚举值
```
0 = IDLE (初始状态)
1 = LOADING (加载中)
2 = SUCCESS (成功)
3 = ERROR (错误)
4 = EMPTY (空数据)
```

## 可能的问题场景

### 场景1: 网络请求失败
**日志特征**：
- `Response Code: -1` 或 `Response Code: 404`
- `Failed to connect to server`

**原因**：网络不通或API地址错误

### 场景2: 数据解析失败
**日志特征**：
- `Response Code: 200`
- `Response Data Count: 0`
- `Total Users: 0`

**原因**：后端返回格式不匹配

### 场景3: 过滤后无数据
**日志特征**：
- `Total Users: 112`
- `Filtered Patients: 0`

**原因**：userType字段不匹配

### 场景4: 状态更新失败
**日志特征**：
- `Loaded patients count: 88`
- `loadingState: 4` (EMPTY)

**原因**：状态管理逻辑错误

## 后端API测试命令

### 测试API连通性
```bash
curl http://172.26.96.1:8080/user/list
```

### 统计患者数量
```bash
curl -s http://172.26.96.1:8080/user/list | \
  python -c "import sys,json; d=json.load(sys.stdin); \
  print('患者数:', len([u for u in d['data'] if u['userType']==0]))"
```

### 查看第一个患者
```bash
curl -s http://172.26.96.1:8080/user/list | \
  python -c "import sys,json; d=json.load(sys.stdin); \
  p=[u for u in d['data'] if u['userType']==0][0]; \
  print(json.dumps(p, ensure_ascii=False, indent=2))"
```

## 下一步操作

1. ✅ 已添加详细调试日志
2. ✅ 已修复字段命名问题
3. ✅ 已配置正确的API地址

**现在需要**：
- 重新编译前端项目
- 运行应用
- 查看HiLog日志输出
- 根据日志定位具体问题

如果看到完整的日志流程且`Filtered Patients: 88`，
说明数据加载成功，可能是UI渲染问题。

如果看到错误日志，请提供完整的日志内容。

