export interface LocationService {
  getUserLocation(): Promise<UserLocation>
}

export interface UserLocation {
  latitude: number,    // 纬度
  longitude: number,   // 经度
  accuracy: number     // 精度（米）
}
