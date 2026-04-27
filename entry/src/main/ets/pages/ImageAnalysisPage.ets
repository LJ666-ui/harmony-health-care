/**
 * 医学影像分析主页面
 * 
 * 提供4步向导式分析流程:
 * 1. 上传/拍摄影像
 * 2. AI分析中
 * 3. 查看结果
 * 4. 病灶详情
 */

import { router } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import {
  ImagingType,
  RiskLevel,
  ImagingTypeLabels,
  RiskLevelLabels,
  RiskLevelColors,
  ImageAnalysisResult,
  Lesion,
  DISCLAIMER
} from '../models/ImagingModels';
import { getMockResult, delay } from '../mock/imagingMock';

@Entry
@Component
struct ImageAnalysisPage {
  /** 当前步骤(1-4) */
  @State currentStep: number = 1;
  
  /** 选中的影像类型 */
  @State selectedImagingType: ImagingType = ImagingType.CHEST_XRAY;
  
  /** 图像URI */
  @State imageUri: string = '';
  
  /** 分析结果 */
  @State analysisResult: ImageAnalysisResult | null = null;
  
  /** 分析进度 */
  @State progress: number = 0;
  
  /** 进度文本 */
  @State progressText: string = '';
  
  /** 是否正在分析 */
  @State isAnalyzing: boolean = false;
  
  /** 选中的病灶 */
  @State selectedLesion: Lesion | null = null;
  
  /** 是否显示病灶详情弹窗 */
  @State showLesionDetail: boolean = false;

  /**
   * 页面构建
   */
  build() {
    Column() {
      // 顶部导航栏
      this.buildHeader();
      
      // 步骤指示器
      this.buildStepIndicator();
      
      // 内容区域
      if (this.currentStep === 1) {
        this.buildUploadStep();
      } else if (this.currentStep === 2) {
        this.buildAnalyzingStep();
      } else if (this.currentStep === 3) {
        this.buildResultStep();
      } else if (this.currentStep === 4) {
        this.buildDetailStep();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建顶部导航栏
   */
  @Builder
  buildHeader() {
    Row() {
      // 返回按钮
      Button({ type: ButtonType.Circle }) {
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
      }
      .width(40)
      .height(40)
      .backgroundColor('#FFFFFF')
      .onClick(() => {
        if (this.currentStep > 1) {
          this.currentStep--;
        } else {
          router.back();
        }
      })

      // 标题
      Text('医学影像AI分析')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 占位
      Blank()
        .width(40)
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  /**
   * 构建步骤指示器
   */
  @Builder
  buildStepIndicator() {
    Row() {
      ForEach([1, 2, 3, 4], (step: number) => {
        Column() {
          // 步骤圆圈
          Circle()
            .width(32)
            .height(32)
            .fill(this.currentStep >= step ? '#4A90E2' : '#CCCCCC')
          
          // 步骤文本
          Text(this.getStepText(step))
            .fontSize(12)
            .fontColor(this.currentStep >= step ? '#4A90E2' : '#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        // 连接线
        if (step < 4) {
          Divider()
            .width(40)
            .height(2)
            .color(this.currentStep > step ? '#4A90E2' : '#CCCCCC')
        }
      })
    }
    .width('100%')
    .height(80)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .margin({ top: 8 })
  }

  /**
   * 获取步骤文本
   */
  private getStepText(step: number): string {
    const texts = ['上传影像', 'AI分析', '查看结果', '病灶详情'];
    return texts[step - 1];
  }

  /**
   * 构建上传步骤
   */
  @Builder
  buildUploadStep() {
    Column() {
      // 影像预览区域
      Column() {
        if (this.imageUri) {
          Image(this.imageUri)
            .width(280)
            .height(280)
            .objectFit(ImageFit.Contain)
            .borderRadius(8)
        } else {
          Column() {
            Text('📷')
              .fontSize(48)
            
            Text('点击上传医学影像')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ top: 16 })
            
            Text('支持: JPG/PNG/DICOM')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 8 })
          }
          .width(280)
          .height(280)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .border({ width: 2, style: BorderStyle.Dashed, color: '#CCCCCC' })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 32 })

      // 上传按钮
      Row() {
        Button('从相册选择')
          .width(140)
          .height(44)
          .fontSize(16)
          .backgroundColor('#4A90E2')
          .onClick(() => this.selectFromGallery())

        Button('拍照')
          .width(140)
          .height(44)
          .fontSize(16)
          .backgroundColor('#50C878')
          .onClick(() => this.takePhoto())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 24 })

      // 影像类型选择
      Column() {
        Text('或选择影像类型:')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 12 })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(Object.values(ImagingType), (type: ImagingType) => {
            Button(ImagingTypeLabels.getLabel(type))
              .height(36)
              .fontSize(14)
              .backgroundColor(this.selectedImagingType === type ? '#4A90E2' : '#FFFFFF')
              .fontColor(this.selectedImagingType === type ? '#FFFFFF' : '#333333')
              .border({ width: 1, color: '#CCCCCC' })
              .margin({ right: 8, bottom: 8 })
              .onClick(() => {
                this.selectedImagingType = type;
              })
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .margin({ top: 32 })

      // 开始分析按钮
      Button('开始分析')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(this.imageUri ? '#4A90E2' : '#CCCCCC')
        .enabled(!!this.imageUri)
        .margin({ top: 32 })
        .onClick(() => this.startAnalysis())
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }

  /**
   * 构建分析中步骤
   */
  @Builder
  buildAnalyzingStep() {
    Column() {
      // 进度条
      Column() {
        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('80%')
          .height(8)
          .color('#4A90E2')

        Text(`${this.progress}%`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 16 })

        Text(this.progressText)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 100 })

      // 提示信息
      Column() {
        Text('正在进行AI病灶检测...')
          .fontSize(16)
          .fontColor('#666666')

        Text('预计剩余时间: ' + Math.ceil((100 - this.progress) / 10) + '秒')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 8 })
      }
      .width('100%')
      .margin({ top: 32 })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建结果步骤
   */
  @Builder
  buildResultStep() {
    Scroll() {
      Column() {
        // 标注影像
        if (this.analysisResult) {
          Column() {
            Text('分析结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 16 })

            // 模拟标注影像
            Column() {
              Text('📷 标注影像')
                .fontSize(16)
                .fontColor('#666666')

              // 病灶列表
              ForEach(this.analysisResult.lesions, (lesion: Lesion, index: number) => {
                Row() {
                  Column() {
                    Row() {
                      Text(`${index + 1}. ${lesion.lesionType}`)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333')

                      Text(`${(lesion.confidence * 100).toFixed(0)}%`)
                        .fontSize(14)
                        .fontColor('#FFFFFF')
                        .backgroundColor(this.getConfidenceColor(lesion.confidence))
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                        .borderRadius(4)
                        .margin({ left: 8 })
                    }

                    Text(`位置: ${lesion.locationDescription}`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 4 })

                    Row() {
                      Text(`风险等级: `)
                        .fontSize(14)
                        .fontColor('#666666')

                      Text(RiskLevelLabels.getLabel(lesion.riskLevel))
                        .fontSize(14)
                        .fontColor(RiskLevelColors.getColor(lesion.riskLevel))
                        .fontWeight(FontWeight.Bold)
                    }
                    .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Button('详情')
                    .height(32)
                    .fontSize(14)
                    .backgroundColor('#4A90E2')
                    .onClick(() => {
                      this.selectedLesion = lesion;
                      this.showLesionDetail = true;
                    })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .margin({ top: 8 })
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F0F0F0')
            .borderRadius(8)
          }
          .width('100%')
          .padding(20)
        }

        // 总体评估
        if (this.analysisResult) {
          Column() {
            Text('总体评估')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 12 })

            Row() {
              Text(`检测到 ${this.analysisResult.lesions.length} 个病灶`)
                .fontSize(16)
                .fontColor('#666666')

              Text(RiskLevelLabels.getLabel(this.analysisResult.report.overallRiskLevel))
                .fontSize(16)
                .fontColor(RiskLevelColors.getColor(this.analysisResult.report.overallRiskLevel))
                .fontWeight(FontWeight.Bold)
                .margin({ left: 8 })
            }

            Text(this.analysisResult.report.overallAssessment)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 16 })
        }

        // 操作按钮
        Row() {
          Button('查看详细报告')
            .width('45%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#4A90E2')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/TestPage',
                params: { result: this.analysisResult }
              });
            })

          Button('重新分析')
            .width('45%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#FFFFFF')
            .fontColor('#4A90E2')
            .border({ width: 1, color: '#4A90E2' })
            .onClick(() => {
              this.currentStep = 1;
              this.analysisResult = null;
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 20, right: 20 })
        .margin({ top: 24 })

        // 免责声明
        Column() {
          Text('免责声明')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF0000')
            .margin({ bottom: 8 })

          Text(DISCLAIMER)
            .fontSize(12)
            .fontColor('#666666')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFF5F5')
        .borderRadius(8)
        .margin({ top: 24, left: 20, right: 20 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
  }

  /**
   * 构建详情步骤
   */
  @Builder
  buildDetailStep() {
    Column() {
      if (this.selectedLesion) {
        // 病灶详情
        Column() {
          Text('病灶详情')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 24 })

          // 病灶信息
          this.buildDetailItem('病灶类型', this.selectedLesion.lesionType);
          this.buildDetailItem('位置', this.selectedLesion.locationDescription);
          
          if (this.selectedLesion.size) {
            this.buildDetailItem(
              '大小',
              `${this.selectedLesion.size.widthMM.toFixed(1)}mm × ${this.selectedLesion.size.heightMM.toFixed(1)}mm`
            );
          }

          this.buildDetailItem('置信度', `${(this.selectedLesion.confidence * 100).toFixed(0)}%`);
          this.buildDetailItem('风险等级', RiskLevelLabels.getLabel(this.selectedLesion.riskLevel));
          this.buildDetailItem('初步诊断', this.selectedLesion.suggestedDiagnosis);

          // 建议
          Column() {
            Text('建议:')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 8 })

            ForEach(this.selectedLesion.recommendations, (rec: string) => {
              Row() {
                Text('•')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ right: 8 })

                Text(rec)
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ top: 4 })
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 16 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 20, left: 20, right: 20 })

        // 操作按钮
        Row() {
          Button('保存报告')
            .width('30%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#4A90E2')
            .onClick(() => {
              // TODO: 实现保存报告功能
            })

          Button('返回')
            .width('30%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#FFFFFF')
            .fontColor('#4A90E2')
            .border({ width: 1, color: '#4A90E2' })
            .onClick(() => {
              this.currentStep = 3;
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ top: 24 })
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建详情项
   */
  @Builder
  buildDetailItem(label: string, value: string) {
    Row() {
      Text(`${label}:`)
        .fontSize(16)
        .fontColor('#666666')
        .width(100)

      Text(value)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: 12 })
  }

  /**
   * 从相册选择图片
   */
  private async selectFromGallery() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select(photoSelectOptions);

      if (result.photoUris && result.photoUris.length > 0) {
        this.imageUri = result.photoUris[0];
      }
    } catch (error) {
      console.error('选择图片失败:', error);
    }
  }

  /**
   * 拍照
   */
  private async takePhoto() {
    try {
      // TODO: 实现拍照功能
      console.info('拍照功能待实现');
    } catch (error) {
      console.error('拍照失败:', error);
    }
  }

  /**
   * 开始分析
   */
  private async startAnalysis() {
    this.currentStep = 2;
    this.isAnalyzing = true;

    try {
      // 模拟分析过程 - 使用接口定义的数组
      interface ProgressStep {
        progress: number;
        text: string;
      }
      
      const steps: ProgressStep[] = [
        { progress: 10, text: '正在加载影像...' },
        { progress: 20, text: '正在识别影像类型...' },
        { progress: 40, text: '正在进行AI病灶检测...' },
        { progress: 70, text: '正在生成分析报告...' },
        { progress: 90, text: '正在保存分析记录...' },
        { progress: 100, text: '分析完成!' }
      ];

      for (const step of steps) {
        this.progress = step.progress;
        this.progressText = step.text;
        await delay(1000);
      }

      // 获取Mock结果
      this.analysisResult = getMockResult(this.selectedImagingType);

      // 进入结果步骤
      this.currentStep = 3;
    } catch (error) {
      console.error('分析失败:', error);
    } finally {
      this.isAnalyzing = false;
    }
  }

  /**
   * 获取置信度颜色
   */
  private getConfidenceColor(confidence: number): string {
    if (confidence >= 0.8) {
      return '#50C878'; // 绿色
    } else if (confidence >= 0.6) {
      return '#FFA500'; // 橙色
    } else {
      return '#CCCCCC'; // 灰色
    }
  }
}
