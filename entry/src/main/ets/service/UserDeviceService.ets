export interface UserDeviceService {
  getUserDeviceStatus(): Promise<UserDeviceStatus>
}

export interface UserDeviceStatus {
  hasMultipleDevices: boolean,  // 是否已绑定多设备
  deviceCount: number,          // 设备数量
  updateTime: number
}
