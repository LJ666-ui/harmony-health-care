import { ModelType } from './types/ModelTypes';
import { EngineType } from './types/EngineTypes';
import { InferenceResult, InferenceOutput, HealthDataInput, InferenceResultData, TCMSymptoms, TCMConstitutionResult, ImageProcessResult, TCMSymptomsInput, ImageSizeInput, TCMScores } from './types/InferenceTypes';

export class FallbackEngine {
  private static instance: FallbackEngine;

  private constructor() {}

  static getInstance(): FallbackEngine {
    if (!FallbackEngine.instance) {
      FallbackEngine.instance = new FallbackEngine();
    }
    return FallbackEngine.instance;
  }

  assessHealthRisk(data: HealthDataInput): InferenceOutput {
    const hypertension = this.calculateHypertensionRisk(data);
    const diabetes = this.calculateDiabetesRisk(data);
    const fall = this.calculateFallRisk(data);
    const frailty = this.calculateFrailtyRisk(data);
    const sarcopenia = this.calculateSarcopeniaRisk(data);

    const output = new InferenceOutput();
    output.probabilities = [hypertension, diabetes, fall, frailty, sarcopenia];
    return output;
  }

  identifyTCMConstitution(data: TCMSymptomsInput): TCMConstitutionResult {
    const scores: TCMScores = {
      peaceful: 0,
      qiDeficiency: 0,
      yangDeficiency: 0,
      yinDeficiency: 0,
      phlegmDampness: 0,
      dampHeat: 0,
      bloodStasis: 0,
      qiStagnation: 0,
      specialConstitution: 0
    };

    const symptoms = data.symptoms;
    if (symptoms) {
      if (symptoms.energy < 3) {
        scores.qiDeficiency += 0.3;
      }
      if (symptoms.coldHands > 3) {
        scores.yangDeficiency += 0.25;
      }
      if (symptoms.dryMouth > 3) {
        scores.yinDeficiency += 0.25;
      }
      if (symptoms.sleep < 3) {
        scores.qiStagnation += 0.2;
      }
    }

    const scoreValues: number[] = [
      scores.peaceful,
      scores.qiDeficiency,
      scores.yangDeficiency,
      scores.yinDeficiency,
      scores.phlegmDampness,
      scores.dampHeat,
      scores.bloodStasis,
      scores.qiStagnation,
      scores.specialConstitution
    ];
    scores.peaceful = Math.max(0, 1 - Math.max(...scoreValues));

    const result: TCMConstitutionResult = {
      scores: scores,
      mainType: this.getMainConstitution(scores)
    };
    return result;
  }

  basicImageProcess(image: ImageSizeInput, operation: string): ImageProcessResult {
    console.info(`FallbackEngine: 执行基础图像处理 operation=${operation}`);
    const result: ImageProcessResult = {
      width: image.width || 0,
      height: image.height || 0,
      processed: true,
      operation: operation,
      engine: 'fallback'
    };
    return result;
  }

  private calculateHypertensionRisk(data: HealthDataInput): number {
    let risk = 0;
    if (data.systolic >= 180 || data.diastolic >= 110) {
      risk = 0.9;
    } else if (data.systolic >= 140 || data.diastolic >= 90) {
      risk = 0.7;
    } else if (data.systolic >= 120 || data.diastolic >= 80) {
      risk = 0.4;
    } else {
      risk = 0.15;
    }
    if (data.age >= 65) risk += 0.1;
    if (data.bmi >= 28) risk += 0.07;
    return Math.min(1, risk);
  }

  private calculateDiabetesRisk(data: HealthDataInput): number {
    let risk = 0;
    if (data.fastingGlucose >= 7.0) {
      risk = 0.85;
    } else if (data.fastingGlucose >= 6.1) {
      risk = 0.55;
    } else if (data.fastingGlucose >= 5.6) {
      risk = 0.35;
    } else {
      risk = 0.1;
    }
    if (data.bmi >= 28) risk += 0.1;
    if (data.age >= 45) risk += 0.08;
    return Math.min(1, risk);
  }

  private calculateFallRisk(data: HealthDataInput): number {
    let risk = 0;
    if (data.age >= 80) risk = 0.7;
    else if (data.age >= 70) risk = 0.5;
    else if (data.age >= 65) risk = 0.35;
    else risk = 0.1;
    return Math.min(1, risk);
  }

  private calculateFrailtyRisk(data: HealthDataInput): number {
    let risk = 0;
    if (data.age >= 80) risk += 0.25;
    else if (data.age >= 70) risk += 0.15;
    if (data.bmi < 18.5) risk += 0.2;
    return Math.min(1, risk);
  }

  private calculateSarcopeniaRisk(data: HealthDataInput): number {
    let risk = 0;
    if (data.age < 60) return 0.08;
    if (data.age >= 80) risk += 0.3;
    else if (data.age >= 70) risk += 0.2;
    else risk += 0.1;
    if (data.bmi < 18.5) risk += 0.25;
    return Math.min(1, risk);
  }

  private getMainConstitution(scores: TCMScores): string {
    const entries: [string, number][] = [
      ['peaceful', scores.peaceful],
      ['qiDeficiency', scores.qiDeficiency],
      ['yangDeficiency', scores.yangDeficiency],
      ['yinDeficiency', scores.yinDeficiency],
      ['phlegmDampness', scores.phlegmDampness],
      ['dampHeat', scores.dampHeat],
      ['bloodStasis', scores.bloodStasis],
      ['qiStagnation', scores.qiStagnation],
      ['specialConstitution', scores.specialConstitution]
    ];
    const sorted = entries.sort((a: [string, number], b: [string, number]): number => b[1] - a[1]);
    return sorted[0][0];
  }
}
