import { ImageAnalysisService, AnalysisResult } from '../medical/ImageAnalysisService';
import { medicalImageMock } from '../mock/medicalImageMock';
import { monitoringMock } from '../mock/monitoringMock';

@Entry
@Component
struct TestPage {
  @State testResults: string[] = [];
  @State isRunning: boolean = false;

  aboutToAppear(): void {
    console.log('[TestPage] 测试页面加载');
  }

  build() {
    Column() {
      Text('🧪 系统功能测试')
        .fontSize(24)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Button('开始运行测试')
        .width('80%')
        .height(48)
        .fontSize(16)
        .margin({ top: 30 })
        .onClick(() => this.runAllTests())

      if (this.isRunning) {
        LoadingProgress()
          .width(60)
          .height(60)
          .color('#1677FF')
          .margin({ top: 20 })
      }

      List() {
        ForEach(this.testResults, (result: string) => {
          ListItem() {
            Text(result)
              .fontSize(14)
              .fontColor('#333333')
              .lineHeight(20)
              .width('100%')
          }
          .padding(10)
        })
      }
      .width('90%')
      .layoutWeight(1)
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  async runAllTests(): Promise<void> {
    this.testResults = [];
    this.isRunning = true;

    this.addLog('═══════════════════════════');
    this.addLog('🚀 开始系统功能测试');
    this.addLog('═══════════════════════════');
    this.addLog('');

    try {
      await this.testImageAnalysisService();
      await this.testMedicalImageMock();
      await this.testMonitoringMock();
      
      this.addLog('');
      this.addLog('═══════════════════════════');
      this.addLog('✅ 所有测试完成！');
      this.addLog('═══════════════════════════');
    } catch (error) {
      this.addLog('');
      this.addLog('❌ 测试失败：' + (error instanceof Error ? error.message : String(error)));
    }

    this.isRunning = false;
  }

  private addLog(message: string): void {
    console.log(`[Test] ${message}`);
    this.testResults.push(message);
  }

  private async testImageAnalysisService(): Promise<void> {
    this.addLog('');
    this.addLog('📦 测试1: ImageAnalysisService（影像分析服务）');
    this.addLog('─────────────────────────────');

    const service = ImageAnalysisService.getInstance();
    
    this.addLog(`✓ 单例模式创建成功`);

    const sampleImages = service.getSampleImagesList();
    this.addLog(`✓ 获取示例图片列表: ${sampleImages.length}张`);
    
    for (let i = 0; i < sampleImages.length; i++) {
      this.addLog(`  - ${sampleImages[i].displayName} (${sampleImages[i].name})`);
    }

    const status = service.getModelStatus();
    this.addLog(`✓ 模型状态: 模式=${status.mode}, 版本=${status.version}`);

    for (let i = 0; i < sampleImages.length; i++) {
      this.addLog(`\n  📷 测试示例${i + 1}: ${sampleImages[i].name}`);
      
      try {
        const imageSource = service.loadSampleImage(i);
        
        if (imageSource) {
          this.addLog(`  ✓ 图片加载成功`);
          
          const result = await service.analyzeImage(imageSource);
          
          if (result) {
            this.addLog(`  ✓ AI分析完成 (${result.analysisTimeMs}ms)`);
            this.addLog(`  - 影像类型: ${result.imageType}`);
            this.addLog(`  - 病灶数量: ${result.findings.length}处`);
            this.addLog(`  - 紧急程度: ${result.urgencyLevel}`);
            
            if (result.findings.length > 0) {
              result.findings.forEach((finding, idx) => {
                this.addLog(`  - 病灶${idx + 1}: ${finding.label} (${(finding.confidence * 100).toFixed(0)}%) [${finding.severity}]`);
              });
            }
            
            this.addLog(`  - 建议数量: ${result.recommendations.length}条`);
          }
        }
      } catch (error) {
        this.addLog(`  ❌ 分析失败: ${error instanceof Error ? error.message : String(error)}`);
      }
    }

    this.addLog('\n✅ ImageAnalysisService测试通过\n');
  }

  private async testMedicalImageMock(): Promise<void> {
    this.addLog('📊 测试2: medicalImageMock（影像分析Mock数据）');
    this.addLog('─────────────────────────────');

    const sampleNames = [
      'chest_xray_normal.jpg',
      'chest_xray_pneumonia.jpg',
      'ct_lung_nodule.jpg',
      'skin_lesion_melanoma.jpg',
      'retina_diabetic.jpg'
    ];

    for (const name of sampleNames) {
      this.addLog(`\n  📄 Mock数据: ${name}`);
      
      try {
        const result = medicalImageMock.getMockAnalysisResult(name);
        
        this.addLog(`  ✓ 获取成功`);
        this.addLog(`  - 类型: ${result.imageType}`);
        this.addLog(`  - 病灶数: ${result.findings.length}`);
        this.addLog(`  - 紧急度: ${result.urgencyLevel}`);
        this.addLog(`  - 建议数: ${result.recommendations.length}`);
        this.addLog(`  - 诊断长度: ${result.overallDiagnosis.length}字符`);
      } catch (error) {
        this.addLog(`  ❌ 失败: ${error instanceof Error ? error.message : String(error)}`);
      }
    }

    this.addLog('\n✅ medicalImageMock测试通过\n');
  }

  private async testMonitoringMock(): Promise<void> {
    this.addLog('💓 测试3: monitoringMock（监控系统Mock数据）');
    this.addLog('─────────────────────────────');

    try {
      const normalVitals = monitoringMock.getNormalVitalSigns();
      this.addLog(`\n  ✅ 正常生命体征:`);
      this.addLog(`  - 血压: ${normalVitals.bloodPressure?.systolic}/${normalVitals.bloodPressure?.diastolic}`);
      this.addLog(`  - 血糖: ${normalVitals.bloodSugar?.value}`);
      this.addLog(`  - 心率: ${normalVitals.heartRate?.value}`);

      const dangerVitals = monitoringMock.getDangerVitalSigns();
      this.addLog(`\n  ⚠️ 危险生命体征:`);
      this.addLog(`  - 血压: ${dangerVitals.bloodPressure?.systolic}/${dangerVitals.bloodPressure?.diastolic}`);
      this.addLog(`  - 血糖: ${dangerVitals.bloodSugar?.value}`);
      this.addLog(`  - 心率: ${dangerVitals.heartRate?.value}`);

      const alerts = monitoringMock.getSampleAlerts();
      this.addLog(`\n  🚨 预警数据: ${alerts.length}条`);
      alerts.forEach((alert, idx) => {
        this.addLog(`  - 预警${idx + 1}: ${alert.title} [${alert.severity}]`);
      });

      const reminders = monitoringMock.getUpcomingReminders();
      this.addLog(`\n  ⏰ 提醒数据: ${reminders.length}条`);
      reminders.slice(0, 3).forEach((reminder, idx) => {
        this.addLog(`  - 提醒${idx + 1}: ${reminder.title}`);
      });

      const templates = monitoringMock.getReminderTemplates();
      this.addLog(`\n  📋 提醒模板: ${templates.length}个`);

      this.addLog('\n✅ monitoringMock测试通过\n');
    } catch (error) {
      this.addLog(`\n❌ 监控Mock测试失败: ${error instanceof Error ? error.message : String(error)}\n`);
    }
  }
}
