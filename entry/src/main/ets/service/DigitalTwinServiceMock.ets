import { DigitalTwinService, DigitalTwinReleaseTime } from './DigitalTwinService'

export class DigitalTwinServiceMock implements DigitalTwinService {
  async getDigitalTwinReleaseTime(): Promise<DigitalTwinReleaseTime> {
    let digitalTwinReleaseTime: DigitalTwinReleaseTime = {
      releaseTime: Date.now() - 10 * 24 * 60 * 60 * 1000  // 10天前
    }
    return digitalTwinReleaseTime
  }
}
