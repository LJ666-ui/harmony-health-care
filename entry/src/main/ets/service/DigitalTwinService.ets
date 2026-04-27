export interface DigitalTwinService {
  getDigitalTwinReleaseTime(): Promise<DigitalTwinReleaseTime>
}

export interface DigitalTwinReleaseTime {
  releaseTime: number  // 功能发布时间戳
}
