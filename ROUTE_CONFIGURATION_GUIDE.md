# 路由配置指南

## 新增页面路由配置

### 一、医生端路由

在医生端路由配置文件中添加以下路由：

```typescript
// 医生排班管理
import DoctorSchedulePage from './pages/DoctorSchedulePage';
import PrescriptionTemplatePage from './pages/PrescriptionTemplatePage';
import MedicalRecordTemplatePage from './pages/MedicalRecordTemplatePage';
import ConsultationManagementPage from './pages/ConsultationManagementPage';

// 路由配置
const doctorRoutes = [
  {
    path: 'pages/DoctorSchedulePage',
    component: DoctorSchedulePage
  },
  {
    path: 'pages/PrescriptionTemplatePage',
    component: PrescriptionTemplatePage
  },
  {
    path: 'pages/MedicalRecordTemplatePage',
    component: MedicalRecordTemplatePage
  },
  {
    path: 'pages/ConsultationManagementPage',
    component: ConsultationManagementPage
  }
];
```

### 二、管理员端路由

在管理员端路由配置文件中添加以下路由：

```typescript
// 安全管理
import DataAccessApprovalPage from './pages/DataAccessApprovalPage';
import AbnormalLoginPage from './pages/AbnormalLoginPage';
import SensitiveOperationPage from './pages/SensitiveOperationPage';

// 路由配置
const adminRoutes = [
  {
    path: 'pages/DataAccessApprovalPage',
    component: DataAccessApprovalPage
  },
  {
    path: 'pages/AbnormalLoginPage',
    component: AbnormalLoginPage
  },
  {
    path: 'pages/SensitiveOperationPage',
    component: SensitiveOperationPage
  }
];
```

---

## 页面跳转示例

### 医生端页面跳转

```typescript
import { router } from '@kit.ArkUI';

// 跳转到医生排班管理页面
router.pushUrl({
  url: 'pages/DoctorSchedulePage'
});

// 跳到处方模板管理页面
router.pushUrl({
  url: 'pages/PrescriptionTemplatePage'
});

// 跳到病历模板管理页面
router.pushUrl({
  url: 'pages/MedicalRecordTemplatePage'
});

// 跳到会诊管理页面
router.pushUrl({
  url: 'pages/ConsultationManagementPage'
});
```

### 管理员端页面跳转

```typescript
import { router } from '@kit.ArkUI';

// 跳到数据访问审批页面
router.pushUrl({
  url: 'pages/DataAccessApprovalPage'
});

// 跳到异常登录检测页面
router.pushUrl({
  url: 'pages/AbnormalLoginPage'
});

// 跳到敏感操作确认页面
router.pushUrl({
  url: 'pages/SensitiveOperationPage'
});
```

---

## 导航菜单配置

### 医生端导航菜单

在医生端主页或导航栏中添加以下菜单项：

```typescript
const doctorMenuItems = [
  {
    title: '排班管理',
    icon: $r('app.media.ic_schedule'),
    page: 'pages/DoctorSchedulePage'
  },
  {
    title: '处方模板',
    icon: $r('app.media.ic_prescription'),
    page: 'pages/PrescriptionTemplatePage'
  },
  {
    title: '病历模板',
    icon: $r('app.media.ic_medical_record'),
    page: 'pages/MedicalRecordTemplatePage'
  },
  {
    title: '会诊管理',
    icon: $r('app.media.ic_consultation'),
    page: 'pages/ConsultationManagementPage'
  }
];
```

### 管理员端导航菜单

在管理员端主页或导航栏中添加以下菜单项：

```typescript
const adminMenuItems = [
  {
    title: '数据访问审批',
    icon: $r('app.media.ic_data_access'),
    page: 'pages/DataAccessApprovalPage'
  },
  {
    title: '异常登录检测',
    icon: $r('app.media.ic_abnormal_login'),
    page: 'pages/AbnormalLoginPage'
  },
  {
    title: '敏感操作确认',
    icon: $r('app.media.ic_sensitive_operation'),
    page: 'pages/SensitiveOperationPage'
  }
];
```

---

## 完整路由配置示例

### entry/src/main/ets/route/Routes.ets

```typescript
import { Router } from '@kit.ArkUI';

// 医生端页面
import DoctorSchedulePage from '../pages/DoctorSchedulePage';
import PrescriptionTemplatePage from '../pages/PrescriptionTemplatePage';
import MedicalRecordTemplatePage from '../pages/MedicalRecordTemplatePage';
import ConsultationManagementPage from '../pages/ConsultationManagementPage';

// 管理员端页面
import DataAccessApprovalPage from '../pages/DataAccessApprovalPage';
import AbnormalLoginPage from '../pages/AbnormalLoginPage';
import SensitiveOperationPage from '../pages/SensitiveOperationPage';

export class Routes {
  // 医生端路由
  static readonly DOCTOR_ROUTES = [
    { path: 'pages/DoctorSchedulePage', component: DoctorSchedulePage },
    { path: 'pages/PrescriptionTemplatePage', component: PrescriptionTemplatePage },
    { path: 'pages/MedicalRecordTemplatePage', component: MedicalRecordTemplatePage },
    { path: 'pages/ConsultationManagementPage', component: ConsultationManagementPage }
  ];

  // 管理员端路由
  static readonly ADMIN_ROUTES = [
    { path: 'pages/DataAccessApprovalPage', component: DataAccessApprovalPage },
    { path: 'pages/AbnormalLoginPage', component: AbnormalLoginPage },
    { path: 'pages/SensitiveOperationPage', component: SensitiveOperationPage }
  ];

  // 获取所有路由
  static getAllRoutes() {
    return [
      ...this.DOCTOR_ROUTES,
      ...this.ADMIN_ROUTES
    ];
  }
}
```

---

## 注意事项

1. **路由路径**：确保路由路径与页面文件路径一致
2. **页面导入**：确保正确导入所有页面组件
3. **权限控制**：根据用户角色控制页面访问权限
4. **参数传递**：使用router.pushUrl传递参数时，确保参数格式正确
5. **返回处理**：使用router.back()返回上一页

---

## 测试路由配置

### 测试步骤

1. 编译项目：`hvigorw assembleHap`
2. 安装应用：`hdc install entry-default-signed.hap`
3. 测试页面跳转：
   - 从医生端主页跳转到各个新页面
   - 从管理员端主页跳转到各个新页面
4. 验证功能：
   - 页面加载正常
   - 数据显示正确
   - 操作功能正常

---

## 完成标志

- [x] 医生端路由配置完成
- [x] 管理员端路由配置完成
- [x] 页面跳转功能正常
- [x] 导航菜单配置完成
