export class PermissionInfo {
  role: string = '';
  permissions: string[] = [];
  routes: string[] = [];

  constructor() {}
}

export const PERMISSION_CONFIG: Record<string, PermissionInfo> = {
  'user': {
    role: 'user',
    permissions: ['view_profile', 'edit_profile', 'view_family', 'manage_family', 'view_health',
                  'chat_with_doctor', 'view_family_chat'],
    routes: ['HomePage', 'Profile', 'FamilyPage', 'HealthPage', 'DoctorChatPage']
  },
  'doctor': {
    role: 'doctor',
    permissions: ['view_profile', 'edit_profile', 'view_family', 'manage_family', 'view_health',
                  'view_patients', 'manage_appointments', 'view_medical_records',
                  'chat_with_patient', 'chat_with_family', 'view_family_chat'],
    routes: ['HomePage', 'Profile', 'FamilyPage', 'HealthPage', 'PatientPage', 'AppointmentPage',
             'DoctorChatPage', 'DoctorFamilyChatPage']
  },
  'admin': {
    role: 'admin',
    permissions: ['admin_login', 'view_dashboard', 'view_users', 'manage_users',
                  'view_all_family', 'manage_all_family'],
    routes: ['AdminLogin', 'AdminDashboard', 'AdminUsers', 'AdminFamily']
  },
  'superAdmin': {
    role: 'superAdmin',
    permissions: ['admin_login', 'view_dashboard', 'view_users', 'manage_users',
                  'view_all_family', 'manage_all_family', 'view_admins', 'manage_admins'],
    routes: ['AdminLogin', 'AdminDashboard', 'AdminUsers', 'AdminFamily', 'AdminManage']
  }
};

export class PermissionInfoHelper {
  static hasPermission(role: string, permission: string): boolean {
    const config: PermissionInfo | undefined = PERMISSION_CONFIG[role];
    if (!config) {
      return false;
    }
    return config.permissions.includes(permission);
  }

  static hasRoute(role: string, route: string): boolean {
    const config: PermissionInfo | undefined = PERMISSION_CONFIG[role];
    if (!config) {
      return false;
    }
    return config.routes.includes(route);
  }

  static getPermissions(role: string): string[] {
    const config: PermissionInfo | undefined = PERMISSION_CONFIG[role];
    return config ? config.permissions : [];
  }

  static getRoutes(role: string): string[] {
    const config: PermissionInfo | undefined = PERMISSION_CONFIG[role];
    return config ? config.routes : [];
  }
}

export const PAGE_PERMISSIONS: Record<string, string[]> = {
  'HomePage': ['user', 'doctor'],
  'Profile': ['user', 'doctor'],
  'FamilyPage': ['user', 'doctor'],
  'HealthPage': ['user', 'doctor'],
  'PatientPage': ['doctor'],
  'AppointmentPage': ['doctor'],
  'DoctorChatPage': ['user', 'doctor'],
  'DoctorFamilyChatPage': ['doctor'],
  'AdminLogin': ['guest', 'user', 'doctor', 'admin', 'superAdmin'],
  'AdminDashboard': ['admin', 'superAdmin'],
  'AdminUsers': ['admin', 'superAdmin'],
  'AdminFamily': ['admin', 'superAdmin'],
  'AdminManage': ['superAdmin']
};
