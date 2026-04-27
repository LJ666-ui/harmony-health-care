export interface HospitalService {
  getRecommendedHospitals(): Promise<RecommendedHospitals>
}

export interface RecommendedHospitals {
  hospitals: Array<{
    id: string,
    name: string,         // 医院名称
    distance: number,     // 距离（km）
    address: string,      // 医院地址
    level: string         // 医院等级
  }>,
  updateTime: number
}
