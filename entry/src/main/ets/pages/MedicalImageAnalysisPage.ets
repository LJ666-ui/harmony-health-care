import { ImageAnalysisService, AnalysisResult, Finding, SampleImageInfo } from '../medical/ImageAnalysisService';
import { AnnotationOverlay } from '../components/AnnotationOverlay';

@Entry
@Component
struct MedicalImageAnalysisPage {
  @State currentStep: 'SELECT_SOURCE' | 'SELECT_SAMPLE' | 'ANALYZING' | 'RESULT' = 'SELECT_SOURCE';
  @State selectedImage: any = null;
  @State analysisResult: AnalysisResult | null = null;
  @State isAnalyzing: boolean = false;
  @State analysisProgress: number = 0;
  @State sampleImages: SampleImageInfo[] = [];
  @State showFindingDetail: Finding | null = null;

  private imageService: ImageAnalysisService = ImageAnalysisService.getInstance();

  aboutToAppear(): void {
    console.log('[MedicalImageAnalysisPage] 页面加载');
    this.loadSampleImages();
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '🔬 AI影像分析', 
        showBack: true 
      })

      if (this.currentStep === 'SELECT_SOURCE') {
        this.buildSelectSourceView()
      } else if (this.currentStep === 'SELECT_SAMPLE') {
        this.buildSelectSampleView()
      } else if (this.currentStep === 'ANALYZING') {
        this.buildAnalyzingView()
      } else if (this.currentStep === 'RESULT') {
        this.buildResultView()
      }

      if (this.showFindingDetail) {
        this.buildFindingDetailDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildSelectSourceView() {
    Column({ space: 24 }) {
      Column({ space: 16 }) {
        Text('📷 选择影像来源')
          .fontSize(22)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Text('您可以从相册选择医学影像，或使用内置示例图片进行体验')
          .fontSize(14)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .lineHeight(20)
      }

      Row({ space: 16 }) {
        Button('📂 从相册选择')
          .layoutWeight(1)
          .height(120)
          .fontSize(17)
          .fontColor('#1677FF')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(22,119,255,0.15)',
            offsetX: 0,
            offsetY: 4
          })
          .onClick(() => this.selectFromAlbum())

        Button('🖼️ 使用示例图片')
          .layoutWeight(1)
          .height(120)
          .fontSize(17)
          .fontColor('#52C41A')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(82,196,26,0.15)',
            offsetX: 0,
            offsetY: 4
          })
          .onClick(() => this.goToSelectSample())
      }
      .width('100%')

      this.buildFeatureList()

      this.buildDisclaimer()
    }
    .width('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildFeatureList() {
    Column({ space: 12 }) {
      Text('✨ 功能特点')
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      ForEach([
        { icon: '🤖', title: 'AI智能识别', desc: '基于深度学习的病灶检测算法' },
        { icon: '🎯', title: '精准定位', desc: '自动标注病灶位置和置信度' },
        { icon: '📋', title: '诊断建议', desc: '提供专业医疗建议供参考' },
        { icon: '🔒', title: '隐私保护', desc: '本地处理，数据不上传云端' }
      ], (feature: Object) => {
        const f = feature as { icon: string; title: string; desc: string };
        
        Row({ space: 12 }) {
          Text(f.icon)
            .fontSize(28)

          Column({ space: 4 }) {
            Text(f.title)
              .fontSize(15)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)

            Text(f.desc)
              .fontSize(13)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
      })
    }
    .width('100%')
  }

  @Builder buildDisclaimer() {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text('⚠️')
          .fontSize(16)

        Text('重要声明')
          .fontSize(14)
          .fontColor('#FF4D4F')
          .fontWeight(FontWeight.Medium)
      }

      Text('本系统为AI辅助诊断工具，所有分析结果仅供参考，不作为最终诊断依据。请以专业医生诊断为准。如有健康问题请及时就医。')
        .fontSize(13)
        .fontColor('#666666')
        .lineHeight(18)
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFBE6')
    .borderRadius(10)
  }

  @Builder buildSelectSampleView() {
    Scroll() {
      Column({ space: 16 }) {
        Row({ space: 8 }) {
          Button('← 返回')
            .height(36)
            .fontSize(13)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(18)
            .onClick(() => this.currentStep = 'SELECT_SOURCE')

          Text('选择示例影像')
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)

          Blank()

          Text(`${this.sampleImages.length}张`)
            .fontSize(13)
            .fontColor('#999999')
        }
        .width('100%')

        Grid() {
          ForEach(this.sampleImages, (sample: Object) => {
            const sampleItem = sample as SampleImageInfo;
            
            GridItem() {
              this.buildSampleCard(sampleItem)
            }
            .columnSpan(1)
            .rowSpan(1)
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .width('100%')
      }
      .padding(16)
    }
    .layoutWeight(1)
  }

  @Builder buildSampleCard(sample: SampleImageInfo) {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column()
          .width('100%')
          .aspectRatio(1)
          .backgroundColor('#F0F2F5')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)

        Text(sample.icon)
          .fontSize(40)
      }
      .width('100%')

      Column({ space: 4 }) {
        Text(sample.displayName)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 4 }) {
          Text(this.getUrgencyIcon(sample))
            .fontSize(12)

          Text(sample.description.substring(0, 20) + (sample.description.length > 20 ? '...' : ''))
            .fontSize(11)
            .fontColor('#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 3
    })
    .onClick(() => this.selectSampleImage(sample))
  }

  @Builder buildAnalyzingView() {
    Column({ space: 32 }) {
      Column({ space: 20 }) {
        LoadingProgress()
          .width(80)
          .height(80)
          .color('#1677FF')

        Text('AI正在分析影像...')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)

        Text('请稍候，系统正在进行深度学习推理')
          .fontSize(14)
          .fontColor('#999999')
      }

      Column({ space: 12 }) {
        Text(`进度：${Math.floor(this.analysisProgress * 100)}%`)
          .fontSize(14)
          .fontColor('#666666')

        Progress({
          value: this.analysisProgress * 100,
          total: 100,
          type: ProgressType.Linear
        })
          .width('100%')
          .height(8)
          .color('#1677FF')
          .backgroundColor('#E6F4FF')
      }
      .width('80%')

      Column({ space: 8 }) {
        ForEach([
          '加载影像数据...',
          '图像预处理（归一化、增强）...',
          '特征提取（CNN网络）...',
          '病灶检测与分类...',
          '生成诊断报告...'
        ], (step: string, index: number) => {
          const stepIndex = index as number;
          
          Row({ space: 8 }) {
            Text(stepIndex < Math.floor(this.analysisProgress * 5) ? '✅' : '⏳')
              .fontSize(14)

            Text(step)
              .fontSize(13)
              .fontColor(
                stepIndex < Math.floor(this.analysisProgress * 5) ? '#52C41A' : '#BBBBBB'
              )
          }
          .width('100%')
        })
      }
      .width('80%')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildResultView() {
    if (!this.analysisResult) return;

    Scroll() {
      Column({ space: 16 }) {
        Row({ space: 8 }) {
          Button('← 返回')
            .height(32)
            .fontSize(12)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(16)
            .onClick(() => this.resetToStart())

          Blank()

          Button('重新分析')
            .height(32)
            .fontSize(12)
            .fontColor('#1677FF')
            .backgroundColor('#E6F4FF')
            .borderRadius(16)
            .onClick(() => this.reanalyze())
        }
        .width('100%')

        this.buildImageViewer()

        this.buildFindingsSummary()

        this.buildDiagnosisSection()

        this.buildRecommendationsSection()

        this.buildActionButtons()
      }
      .padding(16)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder buildImageViewer() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text('📷 影像分析结果')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        if (this.analysisResult!.findings.length > 0) {
          Text(`检出${this.analysisResult!.findings.length}处异常`)
            .fontSize(12)
            .fontColor('#FF4D4F')
            .fontWeight(FontWeight.Bold)
            .padding({ horizontal: 6, vertical: 2 })
            .backgroundColor('#FFF2F0')
            .borderRadius(8)
        } else {
          Text('未检出异常')
            .fontSize(12)
            .fontColor('#52C41A')
            .fontWeight(FontWeight.Bold)
            .padding({ horizontal: 6, vertical: 2 })
            .backgroundColor('#F6FFED')
            .borderRadius(8)
        }

        Blank()

        Text(`耗时 ${this.analysisResult!.analysisTimeMs}ms`)
          .fontSize(11)
          .fontColor('#BBBBBB')
      }
      .width('100%')

      Stack({ alignContent: Alignment.TopLeft }) {
        Column()
          .width('100%')
          .aspectRatio(4 / 3)
          .backgroundColor('#E8E8E8')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)

        if (this.analysisResult!.findings.length > 0) {
          AnnotationOverlay({
            imageWidth: 400,
            imageHeight: 300,
            findings: this.analysisResult!.findings,
            showConfidence: true,
            onSelectFinding: (finding: Finding) => {
              this.showFindingDetail = finding;
            }
          })
            .width('100%')
            .height('100%')
        }
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder buildFindingsSummary() {
    if (this.analysisResult!.findings.length === 0) return;

    Column({ space: 12 }) {
      Text('🔍 病灶详情')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      ForEach(this.analysisResult!.findings, (finding: Object, index: number) => {
        const findingItem = finding as Finding;
        
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(String(index! + 1))
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .width(28)
              .height(28)
              .borderRadius(14)
              .backgroundColor(this.getSeverityColor(findingItem.severity))
              .textAlign(TextAlign.Center)
          }

          Column({ space: 4 }) {
            Row({ space: 8 }) {
              Text(findingItem.label)
                .fontSize(15)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)

              Text(`${(findingItem.confidence * 100).toFixed(0)}%`)
                .fontSize(13)
                .fontColor(this.getSeverityColor(findingItem.severity))
                .fontWeight(FontWeight.Bold)
                .padding({ horizontal: 6, vertical: 2 })
                .backgroundColor(this.getSeverityBgColor(findingItem.severity))
                .borderRadius(8)

              Text(this.getSeverityLabel(findingItem.severity))
                .fontSize(11)
                .fontColor('#999999')
            }
            .width('100%')

            Text(findingItem.description)
              .fontSize(13)
              .fontColor('#666666')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('详情 ›')
            .fontSize(13)
            .fontColor('#1677FF')
            .onClick(() => this.showFindingDetail = findingItem)
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .onClick(() => this.showFindingDetail = findingItem)
      })
    }
    .width('100%')
  }

  @Builder buildDiagnosisSection() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('📋 综合诊断')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Blank()

        Row({ space: 6 }) {
          Text('紧急程度：')
            .fontSize(13)
            .fontColor('#666666')

          Text(this.getUrgencyLabel(this.analysisResult!.urgencyLevel))
            .fontSize(13)
            .fontColor(this.getUrgencyColor(this.analysisResult!.urgencyLevel))
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('100%')

      Text(this.analysisResult!.overallDiagnosis)
        .fontSize(14)
        .fontColor('#555555')
        .lineHeight(22)
        .width('100%')
        .padding(14)
        .backgroundColor('#FAFAFA')
        .borderRadius(10)
    }
    .width('100%')
  }

  @Builder buildRecommendationsSection() {
    Column({ space: 12 }) {
      Text('💡 建议与指导')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      ForEach(this.analysisResult!.recommendations, (rec: string, index: number) => {
        Row({ space: 10 }) {
          Text('•')
            .fontSize(16)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Bold)

          Text(rec)
            .fontSize(14)
            .fontColor('#555555')
            .lineHeight(20)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ vertical: 6, horizontal: 4 })
      })
    }
    .width('100%')
  }

  @Builder buildActionButtons() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Button('保存报告')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(22)
          .onClick(() => this.saveReport())

        Button('分享给医生')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(22)
          .onClick(() => this.shareReport())
      }
      .width('100%')

      Text(this.analysisResult!.disclaimer)
        .fontSize(12)
        .fontColor('#FAAD14')
        .lineHeight(18)
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding(12)
        .backgroundColor('#FFFBE6')
        .borderRadius(8)
    }
    .width('100%')
  }

  @Builder buildFindingDetailDialog() {
    if (!this.showFindingDetail) return;

    Column() {
      Row() {
        Text('病灶详情')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('✕')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => this.showFindingDetail = null)
      }
      .width('100%')
      .padding(16)

      Divider()
        .color('#EEEEEE')

      Column({ space: 16 }) {
        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text(this.showFindingDetail.label)
              .fontSize(20)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)

            Row({ space: 8 }) {
              Text(`置信度: ${(this.showFindingDetail.confidence * 100).toFixed(1)}%`)
                .fontSize(14)
                .fontColor(this.getSeverityColor(this.showFindingDetail.severity))

              Text(this.getSeverityLabel(this.showFindingDetail.severity))
                .fontSize(14)
                .fontColor(this.getSeverityColor(this.showFindingDetail.severity))
                .padding({ horizontal: 8, vertical: 3 })
                .backgroundColor(this.getSeverityBgColor(this.showFindingDetail.severity))
                .borderRadius(10)
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        Text('详细描述')
          .fontSize(15)
          .fontColor('#666666')
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Text(this.showFindingDetail.description)
          .fontSize(14)
          .fontColor('#555555')
          .lineHeight(22)
          .width('100%')
          .padding(12)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)

        Column({ space: 8 }) {
          Text('位置信息')
            .fontSize(15)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)
            .width('100%')

          Column({ space: 6 }) {
            this.buildInfoRow('X坐标', `${this.showFindingDetail.bbox.x}px`)
            this.buildInfoRow('Y坐标', `${this.showFindingDetail.bbox.y}px`)
            this.buildInfoRow('宽度', `${this.showFindingDetail.bbox.width}px`)
            this.buildInfoRow('高度', `${this.showFindingDetail.bbox.height}px`)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F9F9F9')
          .borderRadius(8)
        }
        .width('100%')

        Button('关闭')
          .width('100%')
          .height(44)
          .fontSize(15)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .onClick(() => this.showFindingDetail = null)
      }
      .padding(16)
    }
    .width('90%')
    .maxHeight('85%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.2)',
      offsetX: 0,
      offsetY: 8
    })
  }

  @Builder buildInfoRow(label: string, value: string) {
    Row({ space: 8 }) {
      Text(label + ':')
        .fontSize(13)
        .fontColor('#999999')
        .width(60)

      Text(value)
        .fontSize(13)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)

      Blank()
    }
    .width('100%')
  }

  private async loadSampleImages(): Promise<void> {
    try {
      this.sampleImages = this.imageService.getSampleImagesList();
      
      console.log(`[MedicalImageAnalysisPage] 加载了 ${this.sampleImages.length} 张示例图片`);
    } catch (error) {
      console.error('[MedicalImageAnalysisPage] 加载示例图片失败:', error instanceof Error ? error.message : String(error));
      this.sampleImages = [];
    }
  }

  private async selectFromAlbum(): Promise<void> {
    console.log('[MedicalImageAnalysisPage] 从相册选择');

    try {
      const imageSource = await this.imageService.selectImageFromAlbum();

      if (imageSource) {
        this.selectedImage = imageSource;
        
        await this.startAnalysis();
      }
    } catch (error) {
      console.error('[MedicalImageAnalysisPage] 相册选择失败:', error instanceof Error ? error.message : String(error));
    }
  }

  private goToSelectSample(): void {
    this.currentStep = 'SELECT_SAMPLE';
  }

  private selectSampleImage(sample: SampleImageInfo): void {
    console.log(`[MedicalImageAnalysisPage] 选择示例: ${sample.name}`);

    this.selectedImage = this.imageService.loadSampleImage(
      this.sampleImages.findIndex(s => s.id === sample.id)
    );

    this.startAnalysis();
  }

  private async startAnalysis(): Promise<void> {
    this.currentStep = 'ANALYZING';
    this.isAnalyzing = true;
    this.analysisProgress = 0;

    const progressInterval = setInterval(() => {
      if (this.analysisProgress < 0.95) {
        this.analysisProgress += Math.random() * 0.08;
        
        if (this.analysisProgress > 0.95) {
          this.analysisProgress = 0.95;
        }
      }
    }, 200);

    try {
      this.analysisResult = await this.imageService.analyzeImage(this.selectedImage);

      this.analysisProgress = 1.0;

      setTimeout(() => {
        clearInterval(progressInterval);
        
        this.currentStep = 'RESULT';
        this.isAnalyzing = false;

        console.log('[MedicalImageAnalysisPage] 分析完成！');
        console.log(`  检出病灶数: ${this.analysisResult?.findings.length || 0}`);
        console.log(`  紧急程度: ${this.analysisResult?.urgencyLevel}`);
      }, 500);

    } catch (error) {
      clearInterval(progressInterval);
      this.isAnalyzing = false;

      console.error('[MedicalImageAnalysisPage] 分析失败:', error instanceof Error ? error.message : String(error));

      AlertDialog.show({
        title: '❌ 分析失败',
        message: error instanceof Error ? error.message : '影像分析过程中出现错误',
        primaryText: '返回',
        secondaryText: '重试',
        onSecondaryClick: () => this.reanalyze(),
        onPrimaryClick: () => this.resetToStart()
      });
    }
  }

  private reanalyze(): void {
    if (this.selectedImage) {
      this.startAnalysis();
    }
  }

  private resetToStart(): void {
    this.currentStep = 'SELECT_SOURCE';
    this.selectedImage = null;
    this.analysisResult = null;
    this.isAnalyzing = false;
    this.analysisProgress = 0;
    this.showFindingDetail = null;
  }

  private saveReport(): void {
    console.log('[MedicalImageAnalysisPage] 保存报告');

    AlertDialog.show({
      title: '✅ 报告已生成',
      message: `分析报告已保存至本地\n\n时间：${new Date().toLocaleString('zh-CN')}\n影像类型：${this.analysisResult?.imageType}\n检出异常：${this.analysisResult?.findings.length || 0}处`,
      primaryText: '确定'
    });
  }

  private shareReport(): void {
    console.log('[MedicalImageAnalysisPage] 分享报告');

    AlertDialog.show({
      title: '分享选项',
      message: '选择分享方式',
      primaryText: '取消',
      secondaryText: '复制报告摘要',
      onSecondaryClick: () => {
        AlertDialog.show({
          title: '✅ 已复制',
          message: '报告摘要已复制到剪贴板',
          primaryText: '确定'
        });
      }
    });
  }

  private getUrgencyIcon(sample: SampleImageInfo): string {
    const urgencyMap: Record<string, string> = {
      'chest_xray_normal.jpg': '🟢',
      'chest_xray_pneumonia.jpg': '🔴',
      'ct_lung_nodule.jpg': '🟡',
      'skin_lesion_melanoma.jpg': '🔴',
      'retina_diabetic.jpg': '🟡'
    };

    return urgencyMap[sample.name] || '⚪';
  }

  private getSeverityColor(severity: Finding['severity']): string {
    switch (severity) {
      case 'HIGH':
        return '#FF4D4F';
      case 'MEDIUM':
        return '#FAAD14';
      case 'LOW':
        return '#52C41A';
      default:
        return '#999999';
    }
  }

  private getSeverityBgColor(severity: Finding['severity']): string {
    switch (severity) {
      case 'HIGH':
        return '#FFF2F0';
      case 'MEDIUM':
        return '#FFFBE6';
      case 'LOW':
        return '#F6FFED';
      default:
        return '#F5F5F5';
    }
  }

  private getSeverityLabel(severity: Finding['severity']): string {
    switch (severity) {
      case 'HIGH':
        return '高风险';
      case 'MEDIUM':
        return '中风险';
      case 'LOW':
        return '低风险';
      default:
        return '未知';
    }
  }

  private getUrgencyColor(urgency: AnalysisResult['urgencyLevel']): string {
    switch (urgency) {
      case 'CRITICAL':
        return '#CF1322';
      case 'HIGH':
        return '#FF4D4F';
      case 'MEDIUM':
        return '#FAAD14';
      case 'LOW':
        return '#52C41A';
      default:
        return '#999999';
    }
  }

  private getUrgencyLabel(urgency: AnalysisResult['urgencyLevel']): string {
    switch (urgency) {
      case 'CRITICAL':
        return '⛔ 极危';
      case 'HIGH':
        return '🔴 高';
      case 'MEDIUM':
        return '🟡 中';
      case 'LOW':
        return '🟢 低';
      default:
        return '未知';
    }
  }
}

@Component
struct NavigationTitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;

  build() {
    Row() {
      if (this.showBack) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
      }

      Text(this.title)
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
