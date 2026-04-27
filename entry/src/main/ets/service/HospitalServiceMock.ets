import { HospitalService, RecommendedHospitals } from './HospitalService'

export class HospitalServiceMock implements HospitalService {
  async getRecommendedHospitals(): Promise<RecommendedHospitals> {
    let recommendedHospitals: RecommendedHospitals = {
      hospitals: [
        {
          id: 'hospital_1',
          name: 'XX医院',
          distance: 1.2,
          address: 'XX路XX号',
          level: '三甲'
        },
        {
          id: 'hospital_2',
          name: 'YY医院',
          distance: 2.5,
          address: 'YY路YY号',
          level: '三乙'
        },
        {
          id: 'hospital_3',
          name: 'ZZ医院',
          distance: 3.0,
          address: 'ZZ路ZZ号',
          level: '二甲'
        }
      ],
      updateTime: Date.now()
    }
    return recommendedHospitals
  }
}
