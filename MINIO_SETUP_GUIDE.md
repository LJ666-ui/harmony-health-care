# MinIO服务配置指南

## 问题描述
```
❌ MinIO初始化失败，文件存储功能将不可用: Failed to connect to localhost/0:0:0:0:0:0:0:1:9000
```

**影响范围**: 仅影响医学影像上传功能（ImageUploadService）
**其他功能**: ✅ 不受影响（停车、智慧病房、医疗服务等全部正常）

---

## 快速解决方案（推荐）

### 方案1：使用Docker启动MinIO（最简单）

#### 前置要求
- 已安装Docker Desktop（Windows/Mac）或Docker Engine（Linux）
- Docker版本 >= 20.10

#### 启动步骤

1. **打开命令行终端，进入项目根目录**
```bash
cd e:\harmony-health-care
```

2. **启动MinIO服务**
```bash
docker-compose up -d minio
```

3. **验证MinIO是否启动成功**
```bash
# 查看容器状态
docker-compose ps

# 应该看到：
# Name              Command               State           Ports
# -------------------------------------------------------------------------
# medical-minio   "/usr/bin/docker-ent ..."   Up      0.0.0.0:9000->9000/tcp, 0.0.0.0:9001->9001/tcp

# 检查健康状态
curl http://localhost:9000/minio/health/live
# 返回: {"status":"OK"} 表示成功
```

4. **访问MinIO控制台（可选）**
- 打开浏览器访问：http://localhost:9001
- 用户名：`minioadmin`
- 密码：`minioadmin`
- 可以在这里管理文件和Bucket

5. **重启后端应用**
```bash
# 停止当前运行的后端应用
# 然后重新启动
mvn spring-boot:run
# 或者在IDE中重新运行Application.java
```

6. **验证日志输出**
```
✅ MinIO初始化成功！文件存储功能已就绪
```

---

### 方案2：手动安装MinIO（不使用Docker）

#### Windows系统

1. **下载MinIO**
   - 访问：https://min.io/download#/windows
   - 下载 `minio.exe`

2. **配置环境变量**
   ```powershell
   # 设置MinIO用户名和密码（在PowerShell中执行）
   $env:MINIO_ROOT_USER="minioadmin"
   $env:MINIO_ROOT_PASSWORD="minioadmin"
   ```

3. **启动MinIO服务**
   ```powershell
   # 创建数据存储目录
   mkdir C:\minio-data
   
   # 启动MinIO（指定数据目录和控制台端口）
   .\minio.exe server C:\minio-data --console-address ":9001"
   ```

4. **验证启动**
   - 浏览器访问：http://localhost:9000/minio/health/live
   - 控制台访问：http://localhost:9001

---

### 方案3：临时禁用文件存储功能（开发测试用）

如果暂时不需要医学影像上传功能，可以忽略此错误：

#### 当前行为
- ✅ 应用可以正常启动
- ✅ 所有其他功能正常运行
- ⚠️ 医学影像上传功能不可用
- ❌ 调用影像上传接口时会报错

#### 如何避免错误提示干扰

修改 `application-dev.yml`，添加配置注释：

```yaml
# MinIO对象存储配置（用于医学影像存储）
# 注意：如果未启动MinIO服务，应用仍可正常运行，但影像上传功能将不可用
minio:
  endpoint: http://localhost:9000        # MinIO服务地址
  access-key: minioadmin                 # 访问密钥
  secret-key: minioadmin                 # 安全密钥
  bucket-name: medical-images            # 存储桶名称
  preview-url-expiry: 3600               # 预览URL有效期(秒)
```

---

## 配置说明

### 当前MinIO配置（application-dev.yml）

```yaml
minio:
  endpoint: http://localhost:9000       # MinIO API端口
  access-key: minioadmin                # Root User
  secret-key: minioadmin                # Root Password
  bucket-name: medical-images           # 自动创建的Bucket名称
  preview-url-expiry: 3600              # 预览链接1小时有效
```

### 端口说明
| 端口 | 用途 | 说明 |
|------|------|------|
| **9000** | MinIO API | 应用程序连接的端口 |
| **9001** | MinIO Console | Web管理界面（可选） |

### 数据存储位置
- **Docker方式**: Docker Volume (`minio_data`)
- **手动安装**: 自定义目录（如 `C:\minio-data`）

---

## 故障排查

### 问题1：端口被占用
```bash
# 检查9000端口是否被占用
netstat -ano | findstr :9000

# 如果被占用，停止占用进程或修改端口
# 修改 docker-compose.yml 中的端口映射：
ports:
  - "9001:9000"  # 改为其他端口如9001
```

同时需要修改 `application-dev.yml`:
```yaml
minio:
  endpoint: http://localhost:9001  # 改为新端口
```

### 问题2：Docker权限问题（Linux/Mac）
```bash
# 添加当前用户到docker组
sudo usermod -aG docker $USER

# 重新登录或执行
newgrp docker
```

### 问题3：MinIO容器无法启动
```bash
# 查看容器日志
docker-compose logs minio

# 删除旧容器和数据卷，重新创建
docker-compose down -v
docker-compose up -d minio
```

### 问题4：连接超时
```bash
# 检查防火墙设置
# Windows: 控制面板 →系统和安全→Windows Defender 防火墙
# 允许入站规则：TCP端口 9000, 9001

# Linux:
sudo ufw allow 9000/tcp
sudo ufw allow 9001/tcp
```

---

## 生产环境部署建议

### 使用外部MinIO集群（推荐）
```yaml
# application-prod.yml
minio:
  endpoint: https://minio.yourdomain.com  # 使用域名
  access-key: ${MINIO_ACCESS_KEY}         # 从环境变量读取
  secret-key: ${MINIO_SECRET_KEY}         # 从环境变量读取
  bucket-name: medical-images-prod
  preview-url-expiry: 1800                # 生产环境缩短有效期
```

### 安全加固
1. ✅ 修改默认密码（不要使用minioadmin）
2. ✅ 启用HTTPS（生产环境必须）
3. ✅ 设置Bucket策略（限制公开访问）
4. ✅ 定期备份数据卷
5. ✅ 启用访问日志审计

---

## 相关文件清单

| 文件 | 用途 | 说明 |
|------|------|------|
| [application-dev.yml](src/main/resources/application-dev.yml) | MinIO配置 | 连接地址、密钥等 |
| [FileStorageAdapter.java](src/main/java/com/example/medical/service/medicalimage/FileStorageAdapter.java) | 存储适配器 | 封装MinIO操作 |
| [ImageUploadService.java](src/main/java/com/example/medical/service/medicalimage/ImageUploadService.java) | 影像上传服务 | 调用FileStorageAdapter |
| [docker-compose.yml](docker-compose.yml) | Docker配置 | 一键启动MinIO |

---

## 常用命令速查

```bash
# 启动MinIO
docker-compose up -d minio

# 停止MinIO
docker-compose stop minio

# 重启MinIO
docker-compose restart minio

# 查看日志
docker-compose logs -f minio

# 进入MinIO容器
docker exec -it medical-minio sh

# 删除所有数据（慎用！）
docker-compose down -v
```

---

## 技术支持

如果遇到问题，请检查：
1. ✅ Docker是否正在运行
2. ✅ 端口9000/9001未被占用
3. ✅ 防火墙已放行相关端口
4. ✅ application-dev.yml配置正确
5. ✅ 后端应用已重启

**最后更新时间**: 2026-05-11
