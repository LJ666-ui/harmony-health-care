import { UserInpatientService, UserInpatientStatus } from './UserInpatientService'

export class UserInpatientServiceMock implements UserInpatientService {
  async getUserInpatientStatus(): Promise<UserInpatientStatus> {
    let userInpatientStatus: UserInpatientStatus = {
      isInpatient: false,
      wardNumber: '',
      bedNumber: '',
      updateTime: Date.now()
    }
    return userInpatientStatus
  }
}
