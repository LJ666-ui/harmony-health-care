import { UserDeviceService, UserDeviceStatus } from './UserDeviceService'

export class UserDeviceServiceMock implements UserDeviceService {
  async getUserDeviceStatus(): Promise<UserDeviceStatus> {
    let userDeviceStatus: UserDeviceStatus = {
      hasMultipleDevices: true,
      deviceCount: 2,
      updateTime: Date.now()
    }
    return userDeviceStatus
  }
}
