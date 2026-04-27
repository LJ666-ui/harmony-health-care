import { HealthScoreModel } from '../model/HealthScoreModel'
import { HealthMetricModel } from '../model/HealthMetricModel'
import { HealthDataServiceMock } from '../service/HealthDataServiceMock'
import { HealthDataService } from '../service/HealthDataService'

export class HealthDataManager {
  private healthDataService: HealthDataService = new HealthDataServiceMock()
  private lastRefreshTime: number = 0
  private refreshInterval: number = 5 * 60 * 1000  // 5分钟

  async getHealthScore(): Promise<HealthScoreModel> {
    let healthMetric = await this.healthDataService.getHealthData()
    let healthScore = new HealthScoreModel()

    let stepsRate = 0
    let heartRateRate = 0
    let bloodPressureRate = 0

    if (healthMetric.steps !== undefined) {
      stepsRate = Math.min(healthMetric.steps / 10000, 1) * 40
    }
    if (healthMetric.heartRate !== undefined) {
      if (healthMetric.heartRate >= 60 && healthMetric.heartRate <= 100) {
        heartRateRate = 30
      } else {
        heartRateRate = 10
      }
    }
    if (healthMetric.systolic !== undefined && healthMetric.diastolic !== undefined) {
      if (healthMetric.systolic >= 90 && healthMetric.systolic <= 120 && healthMetric.diastolic >= 60 && healthMetric.diastolic <= 80) {
        bloodPressureRate = 30
      } else {
        bloodPressureRate = 10
      }
    }

    healthScore.score = Math.floor(stepsRate + heartRateRate + bloodPressureRate)

    let now = Date.now()
    healthScore.updateTime = now

    healthScore.trend = Math.floor(Math.random() * 10) - 5  // 模拟-5到+5之间的随机数

    return healthScore
  }

  async getHealthMetric(): Promise<HealthMetricModel> {
    let healthMetric = await this.healthDataService.getHealthData()
    return healthMetric
  }

  async refreshHealthData(): Promise<boolean> {
    let now = Date.now()
    if (now - this.lastRefreshTime < this.refreshInterval) {
      return false
    }

    try {
      await this.healthDataService.getHealthData()
      this.lastRefreshTime = now
      return true
    } catch (e) {
      console.error('Failed to refresh health data', e)
      return false
    }
  }
}
