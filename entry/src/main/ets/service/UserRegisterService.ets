export interface UserRegisterService {
  getUserRegisterTime(): Promise<UserRegisterTime>
}

export interface UserRegisterTime {
  registerTime: number  // 注册时间戳
}
