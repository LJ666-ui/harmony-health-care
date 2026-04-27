import { RecommendedHospitalModel } from '../model/RecommendedHospitalModel'
import { HospitalServiceMock } from '../service/HospitalServiceMock'
import { HospitalService } from '../service/HospitalService'

export class RecommendedHospitalManager {
  private hospitalService: HospitalService = new HospitalServiceMock()

  async getRecommendedHospitals(): Promise<RecommendedHospitalModel[]> {
    let recommendedHospitalsData = await this.hospitalService.getRecommendedHospitals()
    let recommendedHospitals: RecommendedHospitalModel[] = []

    let sortedHospitals = recommendedHospitalsData.hospitals.sort((a, b) => a.distance - b.distance)

    for (let hospital of sortedHospitals) {
      let recommendedHospital = new RecommendedHospitalModel()
      recommendedHospital.id = hospital.id
      recommendedHospital.name = hospital.name
      recommendedHospital.distance = hospital.distance
      recommendedHospital.address = hospital.address
      recommendedHospital.level = hospital.level
      recommendedHospitals.push(recommendedHospital)
    }
    return recommendedHospitals
  }
}
