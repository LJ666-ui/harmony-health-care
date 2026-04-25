

export enum RiskLevel {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL'
}

export class RiskItem {
  key: string = '';
  label: string = '';
  value: number = 0;
  level: RiskLevel = RiskLevel.LOW;
  color: string = '';
  description: string = '';

  constructor(key?: string, label?: string, value?: number, level?: RiskLevel, color?: string, description?: string) {
    if (key !== undefined) {
      this.key = key;
    }
    if (label !== undefined) {
      this.label = label;
    }
    if (value !== undefined) {
      this.value = value;
    }
    if (level !== undefined) {
      this.level = level;
    }
    if (color !== undefined) {
      this.color = color;
    }
    if (description !== undefined) {
      this.description = description;
    }
  }
}

export class RiskRisksMap {
  hypertension: RiskItem = new RiskItem();
  diabetes: RiskItem = new RiskItem();
  fall: RiskItem = new RiskItem();
  frailty: RiskItem = new RiskItem();
  sarcopenia: RiskItem = new RiskItem();

  constructor(htn?: RiskItem, dia?: RiskItem, fl?: RiskItem, frl?: RiskItem, sarc?: RiskItem) {
    if (htn) this.hypertension = htn;
    if (dia) this.diabetes = dia;
    if (fl) this.fall = fl;
    if (frl) this.frailty = frl;
    if (sarc) this.sarcopenia = sarc;
  }
}

export class RiskAssessmentResult {
  assessmentId: string = '';
  timestamp: string = '';
  risks: RiskRisksMap = new RiskRisksMap();
  overallScore: number = 0;
  overallLevel: RiskLevel = RiskLevel.LOW;
  suggestions: string[] = [];
  modelVersion: string = '';
  processingTimeMs: number = 0;

  constructor(assessmentId?: string, timestamp?: string, risks?: RiskRisksMap,
              overallScore?: number, overallLevel?: RiskLevel, suggestions?: string[],
              modelVersion?: string, processingTimeMs?: number) {
    if (assessmentId) this.assessmentId = assessmentId;
    if (timestamp) this.timestamp = timestamp;
    if (risks) this.risks = risks;
    if (overallScore !== undefined) this.overallScore = overallScore;
    if (overallLevel) this.overallLevel = overallLevel;
    if (suggestions) this.suggestions = suggestions;
    if (modelVersion) this.modelVersion = modelVersion;
    if (processingTimeMs !== undefined) this.processingTimeMs = processingTimeMs;
  }
}

export class RadarDataItem {
  label: string = '';
  value: number = 0;
  color: string = '';

  constructor(label?: string, value?: number, color?: string) {
    if (label !== undefined) {
      this.label = label;
    }
    if (value !== undefined) {
      this.value = value;
    }
    if (color !== undefined) {
      this.color = color;
    }
  }
}

export class RadarChartProps {
  data: RadarDataItem[] = [];
  size: number = 200;
  showValue: boolean = true;
  animated: boolean = true;

  constructor(data?: RadarDataItem[], size?: number, showValue?: boolean, animated?: boolean) {
    if (data !== undefined) {
      this.data = data;
    }
    if (size !== undefined) {
      this.size = size;
    }
    if (showValue !== undefined) {
      this.showValue = showValue;
    }
    if (animated !== undefined) {
      this.animated = animated;
    }
  }
}

export class HealthInputData {
  age: number = 0;
  gender: string = '';
  height: number = 0;
  weight: number = 0;
  bmi: number = 0;
  systolic: number = 0;
  diastolic: number = 0;
  fastingGlucose: number = 0;
  postprandialGlucose: number = 0;
  heartRate: number = 0;
  sleepDuration: number = 0;
  exerciseFrequency: number = 0;
  smoking: boolean = false;
  drinking: boolean = false;
  medicalHistory: string[] = [];

  constructor(age?: number, gender?: string, height?: number, weight?: number, bmi?: number,
              systolic?: number, diastolic?: number, fastingGlucose?: number,
              postprandialGlucose?: number, heartRate?: number, sleepDuration?: number,
              exerciseFrequency?: number, smoking?: boolean, drinking?: boolean,
              medicalHistory?: string[]) {
    if (age !== undefined) {
      this.age = age;
    }
    if (gender !== undefined) {
      this.gender = gender;
    }
    if (height !== undefined) {
      this.height = height;
    }
    if (weight !== undefined) {
      this.weight = weight;
    }
    if (bmi !== undefined) {
      this.bmi = bmi;
    }
    if (systolic !== undefined) {
      this.systolic = systolic;
    }
    if (diastolic !== undefined) {
      this.diastolic = diastolic;
    }
    if (fastingGlucose !== undefined) {
      this.fastingGlucose = fastingGlucose;
    }
    if (postprandialGlucose !== undefined) {
      this.postprandialGlucose = postprandialGlucose;
    }
    if (heartRate !== undefined) {
      this.heartRate = heartRate;
    }
    if (sleepDuration !== undefined) {
      this.sleepDuration = sleepDuration;
    }
    if (exerciseFrequency !== undefined) {
      this.exerciseFrequency = exerciseFrequency;
    }
    if (smoking !== undefined) {
      this.smoking = smoking;
    }
    if (drinking !== undefined) {
      this.drinking = drinking;
    }
    if (medicalHistory !== undefined) {
      this.medicalHistory = medicalHistory;
    }
  }
}

export function getRiskLevel(value: number): RiskLevel {
  if (value >= 0.8) {
    return RiskLevel.CRITICAL;
  }
  if (value >= 0.6) {
    return RiskLevel.HIGH;
  }
  if (value >= 0.3) {
    return RiskLevel.MEDIUM;
  }
  return RiskLevel.LOW;
}

export function getRiskColor(level: RiskLevel): string {
  switch (level) {
    case RiskLevel.LOW:
      return '#52C41A';
    case RiskLevel.MEDIUM:
      return '#FAAD14';
    case RiskLevel.HIGH:
      return '#FF4D4F';
    case RiskLevel.CRITICAL:
      return '#CF1322';
    default:
      return '#52C41A';
  }
}

export function getRiskLabel(level: RiskLevel): string {
  switch (level) {
    case RiskLevel.LOW:
      return '低风险';
    case RiskLevel.MEDIUM:
      return '中风险';
    case RiskLevel.HIGH:
      return '高风险';
    case RiskLevel.CRITICAL:
      return '极高风险';
    default:
      return '低风险';
  }
}
