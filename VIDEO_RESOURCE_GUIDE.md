# 📹 康复训练视频资源管理指南

## 📍 **当前状态说明**

### ✅ 功能已实现
- 视频播放页面：`RehabCourseVideoPage.ets`
- 视频播放器组件：完整可用（播放/暂停/进度条）
- 页面跳转功能：正常工作

### ⚠️ 当前使用的视频
**这些是公开测试视频，不是真正的康复训练内容！**

| 课程 | 当前视频 | 实际内容 | 状态 |
|------|---------|---------|------|
| 颈椎康复训练 | mov_bbb.mp4 | 一只大耳朵兔子动画 | ❌ 占位符 |
| 膝关节强化训练 | movie.mp4 | 彩色蝴蝶飞舞 | ❌ 占位符 |
| 腰椎康复训练 | sintel.mp4 | 3D电影预告片 | ❌ 占位符 |
| 其他课程 | 同上 | 测试素材 | ❌ 占位符 |

**来源：**
- W3Schools 公开测试视频
- W3C 开源媒体库
- 仅用于开发阶段验证功能

---

## 🎯 **您需要做的：准备真实视频资源**

### 方案一：本地视频资源（推荐开发/演示用）

#### **步骤1：准备视频文件**

**视频要求：**
```
格式：MP4 (H.264编码)
分辨率：720p 或 1080p
时长：根据课程时长（10-35分钟）
大小：建议每个视频 < 100MB
帧率：30fps
```

**命名规范：**
```
rehab_course_1_neck.mp4      // 颈椎康复训练
rehab_course_2_knee.mp4      // 膝关节强化训练
rehab_course_3_lumbar.mp4    // 腰椎间盘突出康复
rehab_course_4_shoulder.mp4  // 肩周炎功能恢复
rehab_course_5_balance.mp4   // 平衡能力训练
rehab_course_6_parkinson.mp4 // 帕金森病康复操
rehab_course_7_breathing.mp4 // 呼吸系统康复
rehab_course_8_stroke.mp4    // 中风后遗症肢体康复
```

#### **步骤2：放置到项目目录**

```
d:/harmony-health-care/
└── entry/
    └── src/
        └── main/
            └── resources/
                └── rawfile/                    ← 本地资源目录
                    └── videos/                  ← 新建视频文件夹
                        ├── rehab_course_1_neck.mp4
                        ├── rehab_course_2_knee.mp4
                        ├── rehab_course_3_lumbar.mp4
                        ├── rehab_course_4_shoulder.mp4
                        ├── rehab_course_5_balance.mp4
                        ├── rehab_course_6_parkinson.mp4
                        ├── rehab_course_7_breathing.mp4
                        └── rehab_course_8_stroke.mp4
```

**操作方法：**
1. 在 `entry/src/main/resources/rawfile/` 下新建 `videos` 文件夹
2. 将您的视频文件复制到该文件夹
3. 视频会自动打包到APP中

#### **步骤3：修改代码使用本地视频**

**修改文件：** `RehabListPage.ets`

```typescript
@State courses: RehabCourse[] = [
  {
    id: '1',
    title: '颈椎康复训练',
    duration: '15分钟',
    difficulty: '初级',
    targetGroup: '上班族、低头族',
    description: '缓解颈椎僵硬，改善颈部活动度，预防颈椎病',
    icon: '🧘',
    completedCount: 0,
    totalCount: 12,
    videoUrl: 'rawfile://videos/rehab_course_1_neck.mp4'  // ✅ 本地路径
  },
  {
    id: '2',
    title: '膝关节强化训练',
    duration: '20分钟',
    difficulty: '中级',
    targetGroup: '中老年人、关节炎患者',
    description: '增强膝关节稳定性，减轻关节疼痛，提升行走能力',
    icon: '🦵',
    completedCount: 3,
    totalCount: 15,
    videoUrl: 'rawfile://videos/rehab_course_2_knee.mp4'  // ✅ 本地路径
  },
  // ... 其他课程类似
];
```

**本地视频路径格式：**
```
'rawfile://videos/文件名.mp4'
```

---

### 方案二：远程服务器视频（推荐生产环境）

#### **步骤1：准备视频服务器**

**选项A：使用对象存储服务（推荐）**
```
├─ 阿里云 OSS
├─ 腾讯云 COS
├─ 华为云 OBS
└─ AWS S3

优势：
✅ 无限存储空间
✅ CDN加速分发
✅ 自动压缩转码
✅ 按量付费，成本低
```

**选项B：自建服务器**
```
├─ Nginx 静态文件服务器
├─ Tomcat/Jetty 应用服务器
└─ 云服务器（ECS/CVM）

配置示例（Nginx）：
location /videos/ {
    alias /data/rehab_videos/;
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

#### **步骤2：上传视频到服务器**

**目录结构：**
```
服务器：
/var/www/videos/rehab/
├── course_1_neck.mp4
├── course_2_knee.mp4
├── course_3_lumbar.mp4
└── ...

访问地址：
https://your-domain.com/videos/rehab/course_1_neck.mp4
```

**批量上传脚本（Linux）：**
```bash
#!/bin/bash
# upload_videos.sh

SERVER_USER="user"
SERVER_IP="192.168.1.100"
REMOTE_DIR="/var/www/rehab_videos/"
LOCAL_DIR="./rehab_videos/"

scp -r $LOCAL_DIR* $SERVER_USER@$SERVER_IP:$REMOTE_DIR

echo "视频上传完成！"
```

#### **步骤3：后端API管理视频URL**

**数据库表设计：**
```sql
CREATE TABLE rehab_courses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    duration VARCHAR(20),
    difficulty VARCHAR(20),
    target_group VARCHAR(100),
    icon VARCHAR(10),
    video_url VARCHAR(500),        -- 视频URL字段
    cover_image VARCHAR(500),     -- 封面图URL
    created_at DATETIME,
    updated_at DATETIME
);
```

**后端接口示例：**

**获取课程列表（含视频URL）：**
```java
// RehabController.java

@GetMapping("/list")
public Result<List<RehabCourseVO>> getCourseList() {
    List<RehabCourse> courses = rehabService.list();
    
    return Result.success(courses.stream().map(course -> {
        RehabCourseVO vo = new RehabCourseVO();
        vo.setId(course.getId());
        vo.setTitle(course.getTitle());
        vo.setDescription(course.getDescription());
        vo.setDuration(course.getDuration());
        vo.setDifficulty(course.getDifficulty());
        
        // ✅ 关键：返回完整的视频URL
        String videoUrl = course.getVideoUrl();
        if (videoUrl != null && !videoUrl.startsWith("http")) {
            // 如果是相对路径，拼接完整URL
            videoUrl = SERVER_BASE_URL + "/videos/" + videoUrl;
        }
        vo.setVideoUrl(videoUrl);
        
        return vo;
    }).collect(Collectors.toList()));
}
```

**返回数据示例：**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "颈椎康复训练",
      "videoUrl": "https://api.yourapp.com/videos/course_1_neck.mp4",
      "duration": "15分钟",
      "difficulty": "初级"
    }
  ]
}
```

#### **步骤4：前端动态加载视频**

**修改 RehabListPage.ets：**
```typescript
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

@Entry
@Component
struct RehabListPage {
  @State courses: RehabCourse[] = [];
  
  aboutToAppear(): void {
    this.loadCourses();  // ✅ 从后端加载
  }
  
  async loadCourses(): Promise<void> {
    try {
      const response: BaseResponse<RehabCourse[]> = await HttpUtil.get<RehabCourse[]>(
        '/api/rehab/courses/list'
      );
      
      if (response.success && response.data) {
        this.courses = response.data;
      }
    } catch (error) {
      console.error('加载课程失败:', error);
      ToastUtil.showError('加载失败');
    }
  }
}
```

---

## 🎬 **如何获取专业的康复训练视频？**

### 选项1：自己录制（成本最低）

**设备需求：**
```
必备：
□ 手机或相机（1080p以上）
□ 三脚架
□ 良好照明环境
□ 安静的录制场所

推荐：
□ 专业摄像机
□ 补光灯
□ 麦克风（收音）
□ 绿幕背景（后期处理）
```

**录制要点：**
```
1. 拍摄角度：
   - 正面示范动作
   - 侧面展示细节
   - 多角度切换

2. 讲解内容：
   - 动作名称和目的
   - 详细步骤分解
   - 常见错误纠正
   - 呼吸配合要领

3. 时长控制：
   - 单个动作 3-5分钟
   - 完整课程 15-35分钟
   - 包含热身和放松环节

4. 后期制作：
   - 添加字幕（重要！）
   - 标注重点提示
   - 配合背景音乐（轻柔）
   - 片头片尾设计
```

### 选项2：购买版权视频（省时）

**推荐平台：**
```
国内平台：
├─ 淘宝/拼多多（搜索"康复训练视频"）
├─ 素材网站（摄图网、包图网）
└─ 医疗健康类知识付费平台

国际平台：
├─ Shutterstock
├─ Getty Images
├─ Pond5
└─ VideoHive
```

**注意事项：**
```
✅ 确认商业使用权
✅ 检查是否可修改
✅ 了解授权范围（永久/限时）
✅ 保留购买凭证
```

### 选项3：与医疗机构合作（最专业）

**合作方式：**
```
方案A：医院合作
├─ 联系当地康复科
├─ 请专业治疗师录制
└─ 支付劳务费或分成

方案B：高校合作
├─ 联系体育学院/医学院
├─ 学生实习项目
└─ 学术资源共享

方案C：在线教育平台
├─ 购买现成课程
├─ 获得授权使用
└─ 内容质量有保证
```

---

## 📊 **视频资源管理最佳实践**

### 存储策略对比

| 方案 | 适用场景 | 成本 | 维护难度 |
|------|---------|------|---------|
| **本地rawfile** | 开发/离线演示 | 免费 | 低（需更新APP） |
| **自建服务器** | 小规模应用 | 中等 | 中等 |
| **云存储OSS** | 生产环境推荐 | 低（按量） | 低 |
| **CDN加速** | 大流量应用 | 中等 | 低 |

### 推荐的生产架构

```
用户请求视频
    ↓
前端调用 API
    ↓
后端查询数据库（video_url 字段）
    ↓
返回视频地址（带签名/Token）
    ↓
客户端从 CDN/OSS 加载视频
    ↓
边下边播（支持HLS/DASH）
```

**技术栈建议：**
```
存储：阿里云 OSS / 华为云 OBS
加速：阿里云 CDN / CloudFront
转码：FFmpeg / 阿里云媒体处理
格式：HLS (.m3u8) + MP4（兼容性）
加密：DRM / Token鉴权（防盗链）
```

---

## 🔧 **快速开始指南（立即可用）**

### 最简方案：先用测试视频验证功能

**如果您暂时没有真实视频，可以：**

1️⃣ **继续使用当前测试视频**（功能已正常）
   - 验证所有交互逻辑
   - 测试UI布局和样式
   - 准备其他功能模块

2️⃣ **下载免费示例视频替换**
   
   推荐来源：
   - [Pexels Videos](https://www.pexels.com/videos/) （免费商用）
   - [Coverr](https://coverr.co/) （免费视频）
   - [Mixkit](https://mixkit.co/free-stock-video/) （高质量免费）
   
   搜索关键词：`yoga` `exercise` `stretching` `fitness`

3️⃣ **逐步替换为专业内容**
   - 先录制1-2个核心课程
   - 收集用户反馈
   - 迭代优化质量

---

## 💡 **下一步行动建议**

### 立即执行（今天）：
- [ ] ✅ 确认视频播放功能正常（已完成）
- [ ] 决定视频来源方式（自制/购买/合作）
- [ ] 准备至少1个测试视频文件

### 短期计划（本周）：
- [ ] 录制或获取3-5个核心课程视频
- [ ] 选择部署方案（本地/云端）
- [ ] 配置视频存储和访问

### 中期规划（本月）：
- [ ] 完成8个课程的全部视频
- [ ] 上线后端视频管理接口
- [ ] 实现视频缓存和离线观看

---

## 📞 **需要帮助？**

如果您需要：
- 具体的视频录制指导
- 服务器部署协助
- 后端接口完整代码
- 视频转码和优化方案

请随时告诉我，我可以提供详细的实现方案！

---

**总结：当前使用的是占位符测试视频，您需要准备真实的康复训练视频内容。可以选择本地嵌入、服务器托管或云存储等多种方式。** 🎥
