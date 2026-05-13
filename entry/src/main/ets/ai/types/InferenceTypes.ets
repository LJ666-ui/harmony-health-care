import { ModelType, BackendType } from './ModelTypes';
import { EngineType, InferencePriority, InferenceScene } from './EngineTypes';

export class InferenceInput {
  age: number = 0;
  bmi: number = 0;
  systolic: number = 0;
  diastolic: number = 0;
  fastingGlucose: number = 0;
  totalCholesterol: number = 0;
  width: number = 0;
  height: number = 0;
  format: string = '';
  uri: string = '';
  options: object | null = null;
  symptoms: object | null = null;
}

export interface InferenceRequest {
  requestId: string;
  scene: InferenceScene;
  modelType: ModelType;
  input: InferenceInput;
  priority: InferencePriority;
  preferredEngine?: EngineType;
  preferredBackend?: BackendType;
  enableCache?: boolean;
  timeout?: number;
  timestamp: number;
}

export class InferenceOutput {
  probabilities: number[] = [];
  fallback: boolean = false;
  input: InferenceInput = new InferenceInput();
}

export interface HealthDataInput {
  age: number;
  bmi: number;
  systolic: number;
  diastolic: number;
  fastingGlucose: number;
  totalCholesterol: number;
}

export interface InferenceResultData {
  probabilities: number[];
}

export interface TCMSymptoms {
  energy: number;
  coldHands: number;
  dryMouth: number;
  sleep: number;
}

export interface TCMConstitutionResult {
  mainType: string;
  scores: TCMScores;
}

export interface TCMScores {
  peaceful: number;
  qiDeficiency: number;
  yangDeficiency: number;
  yinDeficiency: number;
  phlegmDampness: number;
  dampHeat: number;
  bloodStasis: number;
  qiStagnation: number;
  specialConstitution: number;
}

export interface ImageProcessResult {
  width: number;
  height: number;
  processed: boolean;
  operation: string;
  engine: string;
}

export interface TCMSymptomsInput {
  symptoms?: TCMSymptoms;
}

export interface ImageSizeInput {
  width?: number;
  height?: number;
}

export interface InferenceResult {
  requestId: string;
  success: boolean;
  output: InferenceOutput;
  engine: EngineType;
  backend: BackendType;
  modelVersion: string;
  latency: number;
  cached: boolean;
  timestamp: number;
  error?: InferenceError;
}

export interface InferenceError {
  code: string;
  message: string;
  details?: string;
  recoverable: boolean;
}

export interface InferenceMetrics {
  requestId: string;
  scene: InferenceScene;
  engine: EngineType;
  backend: BackendType;
  inputSize: number;
  outputSize: number;
  preprocessingTime: number;
  inferenceTime: number;
  postprocessingTime: number;
  totalTime: number;
  cached: boolean;
  timestamp: number;
}

export interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
}

export interface ValidationError {
  field: string;
  message: string;
  value?: string | number | boolean;
}

export class InferenceRequestBuilder {
  private request: Partial<InferenceRequest> = {};

  setRequestId(id: string): InferenceRequestBuilder {
    this.request.requestId = id;
    return this;
  }

  setScene(scene: InferenceScene): InferenceRequestBuilder {
    this.request.scene = scene;
    return this;
  }

  setModelType(type: ModelType): InferenceRequestBuilder {
    this.request.modelType = type;
    return this;
  }

  setInput(input: InferenceInput): InferenceRequestBuilder {
    this.request.input = input;
    return this;
  }

  setPriority(priority: InferencePriority): InferenceRequestBuilder {
    this.request.priority = priority;
    return this;
  }

  setPreferredEngine(engine: EngineType): InferenceRequestBuilder {
    this.request.preferredEngine = engine;
    return this;
  }

  setEnableCache(enable: boolean): InferenceRequestBuilder {
    this.request.enableCache = enable;
    return this;
  }

  build(): InferenceRequest {
    return {
      requestId: this.request.requestId || this.generateId(),
      scene: this.request.scene!,
      modelType: this.request.modelType!,
      input: this.request.input || new InferenceInput(),
      priority: this.request.priority || InferencePriority.NORMAL,
      preferredEngine: this.request.preferredEngine,
      enableCache: this.request.enableCache ?? true,
      timestamp: Date.now()
    };
  }

  private generateId(): string {
    return 'INF-' + Date.now().toString(36) + '-' + Math.random().toString(36).substring(2, 8);
  }
}
