import { UserRegisterService, UserRegisterTime } from './UserRegisterService'

export class UserRegisterServiceMock implements UserRegisterService {
  async getUserRegisterTime(): Promise<UserRegisterTime> {
    let userRegisterTime: UserRegisterTime = {
      registerTime: Date.now() - 3 * 24 * 60 * 60 * 1000  // 3天前注册
    }
    return userRegisterTime
  }
}
