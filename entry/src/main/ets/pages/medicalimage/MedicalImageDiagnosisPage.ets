import { ImageType, ProcessStep, StepStatus } from '../types/medicalimage/MedicalImageTypes';
import { IMAGE_TYPE_LABELS, PROCESS_STEP_LABELS, SEVERITY_COLORS, SEVERITY_LABELS } from '../types/medicalimage/MedicalImageConstants';
import diagnosisService from '../services/medicalimage/DiagnosisService';
import { DiagnosisState, ProcessState } from '../services/medicalimage/DiagnosisState';
import router from '@ohos.router';

interface MedicalImageRouterParams {
  mode?: string;
  imageUrl?: string;
}

@Entry
@Component
struct MedicalImageDiagnosisPage {
  @State diagnosisState: DiagnosisState = new DiagnosisState();
  @State processState: ProcessState = new ProcessState();
  @State isAnalyzing: boolean = false;
  @State selectedImageType: string = '';
  @State isSampleMode: boolean = false;

  aboutToAppear() {
    console.info('MedicalImageDiagnosisPage aboutToAppear');
    this.parseRouteParams();
  }
  
  parseRouteParams() {
    try {
      const params = router.getParams() as MedicalImageRouterParams;
      if (params && params.mode === 'sample') {
        this.isSampleMode = true;
        
        if (params.imageUrl) {
          this.diagnosisState.updatePreviewUrl(params.imageUrl);
          this.diagnosisState.updateUploadState('success');
        }
        
        if (params.imageType) {
          this.selectedImageType = params.imageType;
          this.diagnosisState.updateImageType(params.imageType);
        }
        
        if (params.imageId) {
          this.diagnosisState.updateImageId(params.imageId);
        }
        
        console.info('[MedicalImageDiagnosisPage] 示例图片模式已激活');
      }
    } catch (error) {
      console.error('[MedicalImageDiagnosisPage] 解析路由参数失败:', error);
    }
  }

  aboutToDisappear() {
    diagnosisService.destroy();
  }

  build() {
    Column() {
      this.ProcessNavigator()
      this.ImageUploadArea()
      this.ImageTypeSelector()
      this.AnalysisTrigger()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  ProcessNavigator() {
    Row() {
      ForEach([
        { step: ProcessStep.UPLOAD, label: '1.上传影像' },
        { step: ProcessStep.AI_ANALYSIS, label: '2.AI分析' },
        { step: ProcessStep.VIEW_RESULT, label: '3.查看结果' },
        { step: ProcessStep.LESION_DETAIL, label: '4.病灶详情' }
      ], (item: { step: ProcessStep, label: string }) => {
        Row() {
          Circle()
            .width(24)
            .height(24)
            .fill(this.getStepColor(item.step))
          
          Text(item.label)
            .fontSize(12)
            .fontColor(this.getStepTextColor(item.step))
            .margin({ left: 4 })
        }
        .margin({ right: 16 })
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  ImageUploadArea() {
    Column() {
      if (this.diagnosisState.previewUrl) {
        Image(this.diagnosisState.previewUrl)
          .width(280)
          .height(200)
          .objectFit(ImageFit.Contain)
          .borderRadius(8)
      } else {
        Column() {
          Image($r('app.media.ic_camera'))
            .width(48)
            .height(48)
            .fillColor('#999999')
          
          Text('点击上传医学影像')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
          
          Text('支持格式: JPG / PNG / DICOM (≤20MB)')
            .fontSize(12)
            .fontColor('#CCCCCC')
            .margin({ top: 4 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .border({ width: 2, style: BorderStyle.Dashed, color: '#CCCCCC' })
        .borderRadius(8)
        .margin({ top: 16 })
        .onClick(() => {
          this.selectImageFromAlbum();
        })
      }

      Row() {
        Button('从相册选择')
          .type(ButtonType.Normal)
          .backgroundColor('#0066FF')
          .fontColor(Color.White)
          .onClick(() => this.selectImageFromAlbum())

        Button('拍照')
          .type(ButtonType.Normal)
          .backgroundColor('#00CC66')
          .fontColor(Color.White)
          .onClick(() => this.captureFromCamera())

        Button('使用示例图片')
          .type(ButtonType.Normal)
          .backgroundColor('#FF9900')
          .fontColor(Color.White)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/medicalimage/SampleGalleryPage'
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ top: 8 })
  }

  @Builder
  ImageTypeSelector() {
    Column() {
      Text('选择影像类型')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach([
          ImageType.CHEST_XRAY,
          ImageType.BONE_XRAY,
          ImageType.SKIN_PHOTO,
          ImageType.FUNDUS_PHOTO,
          ImageType.BREAST_ULTRASOUND,
          ImageType.OTHER
        ], (type: ImageType) => {
          Button(IMAGE_TYPE_LABELS[type])
            .type(ButtonType.Normal)
            .backgroundColor(this.selectedImageType === type ? '#0066FF' : '#E5E5E5')
            .fontColor(this.selectedImageType === type ? Color.White : '#333333')
            .onClick(() => {
              this.selectedImageType = type;
              this.diagnosisState.updateImageType(type);
            })
            .margin({ right: 8, bottom: 8 })
        })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ top: 8 })
  }

  @Builder
  AnalysisTrigger() {
    Column() {
      Button('开始分析')
        .type(ButtonType.Normal)
        .width('100%')
        .height(48)
        .backgroundColor(this.canStartAnalysis() ? '#0066FF' : '#CCCCCC')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .enabled(this.canStartAnalysis() && !this.isAnalyzing)
        .onClick(() => {
          this.startAnalysis();
        })

      if (this.isAnalyzing) {
        LoadingProgress()
          .width(24)
          .height(24)
          .margin({ top: 12 })
        
        Text('AI分析中...')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ top: 8 })
  }

  private getStepColor(step: ProcessStep): ResourceColor {
    const status = this.processState.getStepStatus(step);
    switch (status) {
      case StepStatus.COMPLETED:
        return '#00CC66';
      case StepStatus.IN_PROGRESS:
        return '#0066FF';
      default:
        return '#CCCCCC';
    }
  }

  private getStepTextColor(step: ProcessStep): ResourceColor {
    const status = this.processState.getStepStatus(step);
    switch (status) {
      case StepStatus.COMPLETED:
      case StepStatus.IN_PROGRESS:
        return '#333333';
      default:
        return '#999999';
    }
  }

  private canStartAnalysis(): boolean {
    return this.diagnosisState.imageId !== null && 
           this.diagnosisState.imageType !== null &&
           this.diagnosisState.uploadState === 'success';
  }

  private selectImageFromAlbum(): void {
    console.info('Select image from album');
  }

  private captureFromCamera(): void {
    console.info('Capture from camera');
  }

  private async startAnalysis(): Promise<void> {
    if (!this.diagnosisState.imageId || !this.diagnosisState.imageType) {
      return;
    }

    this.isAnalyzing = true;
    this.diagnosisState.updateAnalysisState('analyzing');
    this.processState.setStepStatus(ProcessStep.AI_ANALYSIS, StepStatus.IN_PROGRESS);

    try {
      const result = await diagnosisService.analyzeImage(
        this.diagnosisState.imageId,
        this.diagnosisState.imageType,
        1
      );

      console.info('Analysis result:', JSON.stringify(result));
      this.diagnosisState.updateAnalysisState('success');
      this.processState.completeStep(ProcessStep.AI_ANALYSIS);
    } catch (error) {
      console.error('Analysis failed:', error);
      this.diagnosisState.updateAnalysisState('error');
      this.diagnosisState.updateErrorMessage(error.message);
    } finally {
      this.isAnalyzing = false;
    }
  }
}
