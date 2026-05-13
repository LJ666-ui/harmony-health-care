import { PersistedUserInfo } from '../utils/SettingsUtil';

export interface MockUser {
  userId: number;
  username: string;
  password: string;
  userType: number;
  realName?: string;
  phone?: string;
  avatar?: string;
}

export const mockUsers: MockUser[] = [
  {
    userId: 1,
    username: '13245679876',
    password: '123456',
    userType: 0,
    realName: '测试用户',
    phone: '13245679876',
    avatar: ''
  },
  {
    userId: 2,
    username: '13948999643',
    password: '123456',
    userType: 0,
    realName: '测试用户',
    phone: '13948999643',
    avatar: ''
  },
  {
    userId: 2,
    username: '13800138000',
    password: '123456',
    userType: 0,
    realName: '张三',
    phone: '13800138000',
    avatar: ''
  },
  {
    userId: 1001,
    username: '13900000001',
    password: '123456',
    userType: 1,
    realName: '李医生',
    phone: '13900000001',
    avatar: ''
  },
  {
    userId: 1002,
    username: '13900000002',
    password: '123456',
    userType: 1,
    realName: '王医生',
    phone: '13900000002',
    avatar: ''
  }
];

export function findMockUser(username: string, password: string): MockUser | null {
  for (let i = 0; i < mockUsers.length; i++) {
    const user = mockUsers[i];
    if (user.username === username && user.password === password) {
      return user;
    }
  }
  return null;
}

export function createMockToken(userId: number): string {
  const timestamp = Date.now();
  return `mock_token_${userId}_${timestamp}`;
}

export function createMockUserInfo(user: MockUser): PersistedUserInfo {
  return {
    userId: user.userId,
    username: user.username,
    userType: user.userType,
    avatar: user.avatar || '',
    age: 25,
    gender: 'male'
  };
}
