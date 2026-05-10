import { ImageType, ProcessStep, StepStatus, DiagnosisResult, Lesion } from '../types/medicalimage/MedicalImageTypes';

export class DiagnosisState {
  imageFile: string | null = null;
  imageType: ImageType | null = null;
  imageId: string | null = null;
  previewUrl: string | null = null;
  diagnosisResult: DiagnosisResult | null = null;
  uploadState: 'idle' | 'uploading' | 'success' | 'error' = 'idle';
  analysisState: 'idle' | 'analyzing' | 'success' | 'error' = 'idle';
  currentStep: ProcessStep = ProcessStep.UPLOAD;
  errorMessage: string | null = null;

  updateImageFile(imageFile: string): void {
    this.imageFile = imageFile;
  }

  updateImageType(imageType: ImageType): void {
    this.imageType = imageType;
  }

  updateImageId(imageId: string): void {
    this.imageId = imageId;
  }

  updatePreviewUrl(previewUrl: string): void {
    this.previewUrl = previewUrl;
  }

  updateDiagnosisResult(result: DiagnosisResult): void {
    this.diagnosisResult = result;
  }

  updateUploadState(state: 'idle' | 'uploading' | 'success' | 'error'): void {
    this.uploadState = state;
  }

  updateAnalysisState(state: 'idle' | 'analyzing' | 'success' | 'error'): void {
    this.analysisState = state;
  }

  updateCurrentStep(step: ProcessStep): void {
    this.currentStep = step;
  }

  updateErrorMessage(message: string | null): void {
    this.errorMessage = message;
  }

  canStartAnalysis(): boolean {
    return this.imageId !== null && 
           this.imageType !== null && 
           this.uploadState === 'success';
  }

  reset(): void {
    this.imageFile = null;
    this.imageType = null;
    this.imageId = null;
    this.previewUrl = null;
    this.diagnosisResult = null;
    this.uploadState = 'idle';
    this.analysisState = 'idle';
    this.currentStep = ProcessStep.UPLOAD;
    this.errorMessage = null;
  }
}

export class ProcessState {
  steps: Map<ProcessStep, StepStatus> = new Map();

  constructor() {
    this.steps.set(ProcessStep.UPLOAD, StepStatus.PENDING);
    this.steps.set(ProcessStep.AI_ANALYSIS, StepStatus.PENDING);
    this.steps.set(ProcessStep.VIEW_RESULT, StepStatus.PENDING);
    this.steps.set(ProcessStep.LESION_DETAIL, StepStatus.PENDING);
  }

  getStepStatus(step: ProcessStep): StepStatus {
    return this.steps.get(step) || StepStatus.PENDING;
  }

  setStepStatus(step: ProcessStep, status: StepStatus): void {
    this.steps.set(step, status);
  }

  completeStep(step: ProcessStep): void {
    this.steps.set(step, StepStatus.COMPLETED);
  }

  moveToStep(step: ProcessStep): boolean {
    if (this.canMoveToStep(step)) {
      this.steps.set(step, StepStatus.IN_PROGRESS);
      return true;
    }
    return false;
  }

  canMoveToStep(targetStep: ProcessStep): boolean {
    const stepOrder = [
      ProcessStep.UPLOAD,
      ProcessStep.AI_ANALYSIS,
      ProcessStep.VIEW_RESULT,
      ProcessStep.LESION_DETAIL
    ];

    const targetIndex = stepOrder.indexOf(targetStep);
    if (targetIndex === 0) {
      return true;
    }

    const previousStep = stepOrder[targetIndex - 1];
    return this.steps.get(previousStep) === StepStatus.COMPLETED;
  }

  getCurrentStep(): ProcessStep | null {
    for (const [step, status] of this.steps) {
      if (status === StepStatus.IN_PROGRESS) {
        return step;
      }
    }
    return null;
  }
}
