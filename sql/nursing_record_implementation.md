# 护理记录功能实现说明

## 一、数据库表结构

**表名：** `nursing_record`

**建表脚本：** `sql/create_nursing_record_table.sql`

### 字段说明

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | bigint | 主键自增 |
| patient_id | bigint | 患者ID，关联user表 |
| nurse_id | bigint | 护士ID，关联nurse表 |
| record_type | tinyint | 记录类型：1-生命体征监测 2-用药护理 3-伤口护理 4-日常护理 5-术后护理 6-康复护理 |
| record_content | text | 护理记录内容 |
| remark | varchar(500) | 备注 |
| vital_signs | json | 生命体征数据JSON |
| care_time | datetime | 护理时间 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |
| is_deleted | tinyint | 逻辑删除标记 |

---

## 二、后端API接口

### 接口列表

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/nursing-record` | 创建护理记录 |
| GET | `/api/nursing-record/{id}` | 根据ID获取记录 |
| GET | `/api/nursing-record/patient/{patientId}` | 获取患者的护理记录 |
| GET | `/api/nursing-record/nurse/{nurseId}` | 获取护士的护理记录 |
| GET | `/api/nursing-record/list` | 分页查询护理记录 |
| PUT | `/api/nursing-record/{id}` | 更新护理记录 |
| DELETE | `/api/nursing-record/{id}` | 删除护理记录 |

### 创建护理记录示例

**请求：**
```json
POST /api/nursing-record
Content-Type: application/json
Authorization: Bearer {token}

{
    "patientId": 21,
    "recordType": 1,
    "recordContent": "今日生命体征监测：体温36.8℃，脉搏78次/分，血压120/80mmHg",
    "remark": "患者状态良好",
    "vitalSigns": "{\"temperature\": 36.8, \"pulse\": 78, \"bloodPressure\": \"120/80\"}"
}
```

**响应：**
```json
{
    "code": 200,
    "message": "success",
    "data": {
        "id": 1,
        "patientId": 21,
        "nurseId": 1,
        "recordType": 1,
        "recordContent": "今日生命体征监测：体温36.8℃，脉搏78次/分，血压120/80mmHg",
        "remark": "患者状态良好",
        "vitalSigns": "{\"temperature\": 36.8, \"pulse\": 78, \"bloodPressure\": \"120/80\"}",
        "careTime": "2026-05-12T10:30:00",
        "createTime": "2026-05-12T10:30:00",
        "updateTime": "2026-05-12T10:30:00",
        "isDeleted": 0
    }
}
```

---

## 三、实现文件清单

### 1. SQL脚本
- `sql/create_nursing_record_table.sql` - 建表及示例数据

### 2. Java实体类
- `entity/NursingRecord.java` - 护理记录实体类

### 3. Mapper接口
- `mapper/NursingRecordMapper.java` - MyBatis-Plus Mapper

### 4. Service层
- `service/NursingRecordService.java` - 服务接口
- `service/impl/NursingRecordServiceImpl.java` - 服务实现

### 5. Controller层
- `controller/NursingRecordController.java` - REST API控制器

---

## 四、部署步骤

1. **执行数据库脚本**
```sql
source E:/harmony-health-care/sql/create_nursing_record_table.sql
```

2. **重启后端服务**
```bash
mvn spring-boot:run
```

3. **测试API接口**
- 使用Postman或Swagger测试接口
- 访问 `http://localhost:8080/swagger-ui.html` 查看API文档

---

## 五、护理记录类型说明

| 值 | 类型名称 | 说明 |
|----|----------|------|
| 1 | 生命体征监测 | 体温、血压、心率、呼吸等监测 |
| 2 | 用药护理 | 药物给予、用药观察 |
| 3 | 伤口护理 | 伤口换药、愈合观察 |
| 4 | 日常护理 | 生活护理、口腔护理等 |
| 5 | 术后护理 | 术后观察、切口护理 |
| 6 | 康复护理 | 康复训练、功能锻炼 |
