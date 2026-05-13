# API接口文档

## 文档信息

| 属性 | 值 |
|------|-----|
| 文档名称 | 星云医疗助手API接口文档 |
| 文档版本 | v2.0 |
| 更新日期 | 2026-05-10 |
| 基硎URL | http://localhost:8080 |

---

## 目录

1. [医生排班管理接口](#医生排班管理接口)
2. [处方模板管理接口](#处方模板管理接口)
3. [病历模板管理接口](#病历模板管理接口)
4. [会诊管理接口](#会诊管理接口)
5. [数据访问审批接口](#数据访问审批接口)
6. [敏感操作确认接口](#敏感操作确认接口)
7. [异常登录检测接口](#异常登录检测接口)

---

## 医生排班管理接口

### 1. 创建排班

**接口地址**：`POST /api/doctor/schedule`

**接口说明**：医生创建新的排班

**请求参数**：
```json
{
  "doctorId": 1,
  "scheduleDate": "2026-05-15",
  "schedulePeriod": 0,
  "maxCount": 20,
  "status": 1
}
```

**参数说明**：
- `doctorId`：医生ID（必填）
- `scheduleDate`：排班日期（必填）
- `schedulePeriod`：时段（0-上午，1-下午，2-晚上，必填）
- `maxCount`：最大预约数（必填）
- `status`：状态（1-正常，0-禁用）

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "doctorId": 1,
    "scheduleDate": "2026-05-15",
    "schedulePeriod": 0,
    "maxCount": 20,
    "currentCount": 0,
    "status": 1,
    "createTime": "2026-05-10 10:00:00"
  }
}
```

---

### 2. 获取医生排班列表

**接口地址**：`GET /api/doctor/schedule/doctor/{doctorId}`

**接口说明**：获取指定医生的所有排班

**路径参数**：
- `doctorId`：医生ID

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "doctorId": 1,
      "scheduleDate": "2026-05-15",
      "schedulePeriod": 0,
      "maxCount": 20,
      "currentCount": 5,
      "status": 1
    }
  ]
}
```

---

### 3. 更新排班

**接口地址**：`PUT /api/doctor/schedule/{scheduleId}`

**接口说明**：更新排班信息

**路径参数**：
- `scheduleId`：排班ID

**请求参数**：
```json
{
  "maxCount": 25,
  "status": 1
}
```

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "maxCount": 25,
    "status": 1
  }
}
```

---

### 4. 删除排班

**接口地址**：`DELETE /api/doctor/schedule/{scheduleId}`

**接口说明**：删除指定排班

**路径参数**：
- `scheduleId`：排班ID

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": true
}
```

---

## 处方模板管理接口

### 1. 创建处方模板

**接口地址**：`POST /api/doctor/prescription-template`

**接口说明**：医生创建处方模板

**请求参数**：
```json
{
  "doctorId": 1,
  "templateName": "感冒处方模板",
  "medicines": "[{\"name\":\"感冒灵\",\"dosage\":\"1片\",\"frequency\":\"3次/日\"}]",
  "notes": "饭后服用",
  "isPublic": 0
}
```

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "doctorId": 1,
    "templateName": "感冒处方模板",
    "usageCount": 0,
    "isPublic": 0
  }
}
```

---

### 2. 获取医生的处方模板列表

**接口地址**：`GET /api/doctor/{doctorId}/prescription-templates`

**接口说明**：获取医生的处方模板列表

**路径参数**：
- `doctorId`：医生ID

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "templateName": "感冒处方模板",
      "usageCount": 5,
      "isPublic": 0
    }
  ]
}
```

---

## 会诊管理接口

### 1. 发起会诊

**接口地址**：`POST /api/doctor/consultation`

**接口说明**：医生发起多学科会诊

**请求参数**：
```json
{
  "initiatorId": 1,
  "patientId": 1,
  "title": "疑难病例会诊",
  "description": "需要多科室会诊",
  "scheduledTime": "2026-05-15 14:00:00",
  "doctorIds": [2, 3, 4],
  "departmentIds": [1, 2]
}
```

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "initiatorId": 1,
    "patientId": 1,
    "title": "疑难病例会诊",
    "status": "pending",
    "scheduledTime": "2026-05-15 14:00:00"
  }
}
```

---

### 2. 开始会诊

**接口地址**：`PUT /api/doctor/consultation/{consultationId}/start`

**接口说明**：开始会诊

**路径参数**：
- `consultationId`：会诊ID

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "status": "in_progress",
    "startedTime": "2026-05-15 14:00:00"
  }
}
```

---

### 3. 结束会诊

**接口地址**：`PUT /api/doctor/consultation/{consultationId}/end`

**接口说明**：结束会诊

**路径参数**：
- `consultationId`：会诊ID

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "status": "completed",
    "endedTime": "2026-05-15 15:30:00"
  }
}
```

---

## 数据访问审批接口

### 1. 申请数据访问

**接口地址**：`POST /api/security/data-access-apply`

**接口说明**：申请访问敏感数据

**请求参数**：
```json
{
  "requesterId": 2,
  "requesterRole": "doctor",
  "approverId": 1,
  "dataType": "health_record",
  "dataId": 1,
  "reason": "需要查看患者病历",
  "duration": 24
}
```

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "requesterId": 2,
    "dataType": "health_record",
    "status": "pending",
    "duration": 24
  }
}
```

---

### 2. 审批数据访问

**接口地址**：`POST /api/security/data-access-approve`

**接口说明**：审批数据访问申请

**请求参数**：
```json
{
  "applicationId": 1,
  "approverId": 1,
  "approved": true,
  "comment": "同意访问"
}
```

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "status": "approved",
    "approvedAt": "2026-05-10 10:00:00",
    "expiresAt": "2026-05-11 10:00:00"
  }
}
```

---

## 敏感操作确认接口

### 1. 发起敏感操作

**接口地址**：`POST /api/security/sensitive-operation`

**接口说明**：发起敏感操作，生成确认码

**请求参数**：
```json
{
  "userId": 1,
  "operationType": "delete",
  "resourceType": "health_record",
  "resourceId": 1,
  "reason": "删除过期病历"
}
```

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "userId": 1,
    "operationType": "delete",
    "status": "pending_confirmation",
    "confirmationCode": "123456"
  }
}
```

---

### 2. 确认敏感操作

**接口地址**：`POST /api/security/sensitive-operation/{operationId}/confirm`

**接口说明**：确认敏感操作

**路径参数**：
- `operationId`：操作ID

**请求参数**：
```json
{
  "confirmationCode": "123456"
}
```

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "status": "confirmed",
    "confirmedAt": "2026-05-10 10:00:00"
  }
}
```

---

## 异常登录检测接口

### 1. 记录异常登录

**接口地址**：`POST /api/security/abnormal-login`

**接口说明**：记录异常登录

**请求参数**：
```json
{
  "userId": 1,
  "loginTime": "2026-05-10 03:00:00",
  "loginLocation": "北京市朝阳区",
  "deviceInfo": "iPhone 15",
  "ipAddress": "192.168.1.100",
  "abnormalReason": "abnormal_time",
  "riskLevel": "medium"
}
```

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "userId": 1,
    "abnormalReason": "abnormal_time",
    "riskLevel": "medium",
    "isHandled": 0
  }
}
```

---

### 2. 处理异常登录

**接口地址**：`PUT /api/security/abnormal-login/{loginId}/handle`

**接口说明**：处理异常登录

**路径参数**：
- `loginId`：登录记录ID

**请求参数**：
```json
{
  "handledBy": 1,
  "handleRemark": "确认是本人操作"
}
```

**返回示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "isHandled": 1,
    "handledAt": "2026-05-10 10:00:00",
    "handledBy": 1
  }
}
```

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 注意事项

1. 所有接口都需要在Header中携带Token
2. 日期格式：`yyyy-MM-dd HH:mm:ss`
3. 分页参数：`page`（页码，从1开始）、`pageSize`（每页数量）
4. 所有返回数据都包含`code`、`message`、`data`三个字段

---

## 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|---------|
| v2.0 | 2026-05-10 | 新增医生排班、异常登录、敏感操作等接口文档 |
| v1.0 | 2026-05-09 | 初始版本 |
