import { HealthInputData } from '../models/AIModels';

export class HealthFeatureExtractor {

  static extractFeatures(data: HealthInputData): number[] {
    const features: number[] = [];
    features.push(HealthFeatureExtractor.normalize(data.age, 0, 100));
    features.push(HealthFeatureExtractor.normalizeBmi(data.bmi));
    features.push(HealthFeatureExtractor.normalize(data.systolic, 60, 220));
    features.push(HealthFeatureExtractor.normalize(data.diastolic, 40, 140));
    features.push(HealthFeatureExtractor.normalize(data.fastingGlucose, 2, 25));
    features.push(HealthFeatureExtractor.normalize(data.heartRate, 40, 150));
    features.push(HealthFeatureExtractor.calculateSleepScore(data.sleepDuration));
    features.push(HealthFeatureExtractor.calculateExerciseScore(data.exerciseFrequency));
    features.push(HealthFeatureExtractor.calculateFallRiskScore(data));
    features.push(HealthFeatureExtractor.calculateFrailtyIndicator(data));
    return features;
  }

  static extractTimeSeriesFeatures(history: HealthInputData[]): number[] | null {
    if (history.length < 2) {
      return null;
    }
    const latest: HealthInputData = history[history.length - 1];
    const earliest: HealthInputData = history[0];
    const timeSpan: number = Math.max(history.length - 1, 1);
    const features: number[] = [];
    features.push((latest.systolic - earliest.systolic) / timeSpan);
    features.push((latest.diastolic - earliest.diastolic) / timeSpan);
    features.push((latest.fastingGlucose - earliest.fastingGlucose) / timeSpan);
    features.push((latest.weight - earliest.weight) / timeSpan);
    features.push(HealthFeatureExtractor.calculateVolatility(history));
    return features;
  }

  static normalize(value: number, min: number, max: number): number {
    if (max <= min) {
      return 0;
    }
    return Math.max(0, Math.min(1, (value - min) / (max - min)));
  }

  static normalizeBmi(bmi: number): number {
    if (bmi < 18.5) {
      return HealthFeatureExtractor.normalize(bmi, 10, 18.5) * 0.3;
    }
    if (bmi <= 24) {
      return 0.3 + (bmi - 18.5) / (24 - 18.5) * 0.4;
    }
    if (bmi <= 28) {
      return 0.7 + (bmi - 24) / (28 - 24) * 0.15;
    }
    return Math.min(1, 0.85 + (bmi - 28) / (40 - 28) * 0.15);
  }

  static calculateSleepScore(sleepDuration: number): number {
    if (sleepDuration >= 7 && sleepDuration <= 9) {
      return 0.1;
    }
    if (sleepDuration >= 6 && sleepDuration < 7) {
      return 0.4;
    }
    if (sleepDuration > 9 && sleepDuration <= 10) {
      return 0.5;
    }
    if (sleepDuration >= 5 && sleepDuration < 6) {
      return 0.7;
    }
    return 0.9;
  }

  static calculateExerciseScore(frequency: number): number {
    if (frequency >= 7) {
      return 0.1;
    }
    if (frequency >= 5) {
      return 0.3;
    }
    if (frequency >= 3) {
      return 0.5;
    }
    if (frequency >= 1) {
      return 0.7;
    }
    return 0.95;
  }

  static calculateFallRiskScore(data: HealthInputData): number {
    let score: number = 0;
    if (data.age >= 80) {
      score += 0.4;
    } else if (data.age >= 65) {
      score += 0.25;
    } else if (data.age >= 50) {
      score += 0.1;
    }
    if (data.medicalHistory.indexOf('骨质疏松') >= 0) {
      score += 0.25;
    }
    if (data.medicalHistory.indexOf('帕金森') >= 0) {
      score += 0.2;
    }
    if (data.exerciseFrequency < 2) {
      score += 0.15;
    }
    return Math.min(1, score);
  }

  static calculateFrailtyIndicator(data: HealthInputData): number {
    let count: number = 0;
    if (data.age >= 65) {
      count++;
    }
    if (data.bmi < 18.5 || data.bmi > 28) {
      count++;
    }
    if (data.exerciseFrequency < 2) {
      count++;
    }
    if (data.sleepDuration < 6 || data.sleepDuration > 9) {
      count++;
    }
    if (data.medicalHistory.length >= 3) {
      count++;
    }
    return Math.min(1, count / 5);
  }

  private static calculateVolatility(history: HealthInputData[]): number {
    if (history.length < 3) {
      return 0;
    }
    let sum: number = 0;
    let count: number = 0;
    for (let i: number = 1; i < history.length; i++) {
      const diff: number = Math.abs(history[i].systolic - history[i - 1].systolic);
      sum += diff;
      count++;
    }
    const avgChange: number = count > 0 ? sum / count : 0;
    return HealthFeatureExtractor.normalize(avgChange, 0, 30);
  }
}
