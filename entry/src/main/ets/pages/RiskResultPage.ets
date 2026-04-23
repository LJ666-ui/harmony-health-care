import { router } from '@kit.ArkUI';

class AssessmentData {
  age: string = '';
  gender: string = '男';
  height: string = '';
  weight: string = '';
  bmi: number = 0;
  systolic: string = '';
  diastolic: string = '';
  fastingGlucose: string = '';
  postprandialGlucose: string = '';
  smoking: string = '否';
  drinking: string = '否';
  exercise: string = '每周1-2次';
  medicalHistory: string[] = [];
}

interface RiskLevel {
  level: string;
  color: string;
  icon: string;
  message: string;
}

interface RiskItem {
  id: string;
  name: string;
  level: string;
  levelColor: string;
  icon: string;
  description: string;
}

class PageParams {
  assessmentData: AssessmentData = new AssessmentData();
}

@Entry
@Component
struct RiskResultPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State riskLevel: RiskLevel = {
    level: '低风险',
    color: '#52C41A',
    icon: '🟢',
    message: '您的健康状况良好'
  };

  @State riskItems: RiskItem[] = [];

  @State aiSuggestions: string[] = [];
  @State hasValidData: boolean = false;
  @State assessmentData: AssessmentData = {
    age: '',
    gender: '男',
    height: '',
    weight: '',
    bmi: 0,
    systolic: '',
    diastolic: '',
    fastingGlucose: '',
    postprandialGlucose: '',
    smoking: '否',
    drinking: '否',
    exercise: '每周1-2次',
    medicalHistory: []
  };

  aboutToAppear(): void {
    const params = router.getParams() as PageParams;
    if (params && params.assessmentData) {
      const data: AssessmentData = params.assessmentData;
      if (data.age && data.age.trim() !== '') {
        this.assessmentData = data;
        this.hasValidData = true;
        this.calculateRisks();
        this.generateSuggestions();
      }
    }
  }

  getLevelBgColor(levelColor: string): string {
    if (levelColor === '#52C41A') {
      return '#F6FFED';
    }
    if (levelColor === '#FAAD14') {
      return '#FFFBE6';
    }
    return '#FFF1F0';
  }

  handleViewReport() {
    router.push({
      url: 'pages/RiskDetailPage',
      params: { assessmentData: this.assessmentData }
    });
  }

  handleShare() {
    router.push({ url: 'pages/DoctorListPage' });
  }

  handleReassess() {
    router.push({ url: 'pages/RiskAssessmentPage' });
  }

  handleRehabPlan() {
    console.log('制定康复计划');
  }

  private calculateRisks(): void {
    const data: AssessmentData = this.assessmentData;
    const items: RiskItem[] = [];
    let highRiskCount: number = 0;
    let midRiskCount: number = 0;

    const age: number = parseFloat(data.age) || 0;
    const systolic: number = parseFloat(data.systolic) || 0;
    const diastolic: number = parseFloat(data.diastolic) || 0;
    const fastingGlucose: number = parseFloat(data.fastingGlucose) || 0;
    const postprandialGlucose: number = parseFloat(data.postprandialGlucose) || 0;

    if (systolic > 0 && diastolic > 0) {
      if (systolic >= 140 || diastolic >= 90) {
        items.push({ id: '1', name: '高血压', level: '高风险', levelColor: '#FF4D4F', icon: '🩺', description: '血压偏高(' + systolic + '/' + diastolic + 'mmHg)，建议尽快就医检查' });
        highRiskCount++;
      } else if (systolic >= 120 || diastolic >= 80) {
        items.push({ id: '1', name: '高血压', level: '中风险', levelColor: '#FAAD14', icon: '🩺', description: '血压正常偏高(' + systolic + '/' + diastolic + 'mmHg)，建议定期监测' });
        midRiskCount++;
      } else {
        items.push({ id: '1', name: '高血压', level: '低风险', levelColor: '#52C41A', icon: '🩺', description: '血压正常(' + systolic + '/' + diastolic + 'mmHg)，请继续保持' });
      }
    } else {
      items.push({ id: '1', name: '高血压', level: '低风险', levelColor: '#52C41A', icon: '🩺', description: '血压数据正常' });
    }

    if (fastingGlucose > 0) {
      if (fastingGlucose >= 7.0) {
        items.push({ id: '2', name: '糖尿病', level: '高风险', levelColor: '#FF4D4F', icon: '💉', description: '空腹血糖偏高(' + fastingGlucose + 'mmol/L)，建议就医检查' });
        highRiskCount++;
      } else if (fastingGlucose >= 6.1) {
        items.push({ id: '2', name: '糖尿病', level: '中风险', levelColor: '#FAAD14', icon: '💉', description: '空腹血糖偏高(' + fastingGlucose + 'mmol/L)，需注意饮食控制' });
        midRiskCount++;
      } else {
        items.push({ id: '2', name: '糖尿病', level: '低风险', levelColor: '#52C41A', icon: '💉', description: '空腹血糖正常(' + fastingGlucose + 'mmol/L)' });
      }
    } else {
      items.push({ id: '2', name: '糖尿病', level: '低风险', levelColor: '#52C41A', icon: '💉', description: '血糖在正常范围内' });
    }

    if (age >= 65 || data.medicalHistory.includes('骨质疏松') || data.exercise === '每周1-2次' && data.smoking === '是') {
      items.push({ id: '3', name: '跌倒', level: '中风险', levelColor: '#FAAD14', icon: '🧓', description: age >= 65 ? '年龄较大，存在跌倒风险，建议加强平衡训练' : '存在跌倒风险因素，建议加强平衡训练' });
      midRiskCount++;
    } else {
      items.push({ id: '3', name: '跌倒', level: '低风险', levelColor: '#52C41A', icon: '🧓', description: '跌倒风险较低' });
    }

    if (data.bmi < 18.5 || data.bmi >= 27) {
      items.push({ id: '4', name: '衰弱', level: '中风险', levelColor: '#FAAD14', icon: '💪', description: 'BMI为' + data.bmi + '，需要注意营养和运动' });
      midRiskCount++;
    } else if (data.bmi <= 0) {
      items.push({ id: '4', name: '衰弱', level: '低风险', levelColor: '#52C41A', icon: '💪', description: '身体状况良好' });
    } else {
      items.push({ id: '4', name: '衰弱', level: '低风险', levelColor: '#52C41A', icon: '💪', description: 'BMI正常(' + data.bmi + ')，身体状况良好' });
    }

    if (data.bmi < 18.5 || data.exercise === '每周1-2次' && age >= 60) {
      items.push({ id: '5', name: '肌少症', level: '中风险', levelColor: '#FAAD14', icon: '🏋️', description: '建议增加蛋白质摄入和抗阻运动' });
      midRiskCount++;
    } else {
      items.push({ id: '5', name: '肌少症', level: '低风险', levelColor: '#52C41A', icon: '🏋️', description: '肌肉量正常' });
    }

    this.riskItems = items;

    if (highRiskCount > 0) {
      this.riskLevel = { level: '高风险', color: '#FF4D4F', icon: '🔴', message: '发现' + highRiskCount + '项高风险指标，建议尽早就医' };
    } else if (midRiskCount > 0) {
      this.riskLevel = { level: '中风险', color: '#FAAD14', icon: '🟡', message: '有' + midRiskCount + '项指标需要关注' };
    } else {
      this.riskLevel = { level: '低风险', color: '#52C41A', icon: '🟢', message: '您的健康状况良好' };
    }
  }

  private generateSuggestions(): void {
    const suggestions: string[] = [];
    const data: AssessmentData = this.assessmentData;
    const systolic: number = parseFloat(data.systolic) || 0;
    const diastolic: number = parseFloat(data.diastolic) || 0;
    const glucose: number = parseFloat(data.fastingGlucose) || 0;
    const bmi: number = data.bmi;

    if (systolic >= 140 || diastolic >= 90) {
      suggestions.push('您的血压偏高，建议减少盐分摄入，每日食盐不超过5g，定期监测血压');
    }
    if (glucose >= 6.1) {
      suggestions.push('您的血糖偏高，建议控制碳水化合物摄入，避免高糖食物');
    }
    if (bmi < 18.5) {
      suggestions.push('您的BMI偏低(' + bmi + ')，建议增加营养摄入，适当进行力量训练');
    } else if (bmi >= 27) {
      suggestions.push('您的BMI偏高(' + bmi + ')，建议控制饮食热量，增加有氧运动');
    }
    if (data.smoking === '是') {
      suggestions.push('吸烟会显著增加心血管疾病风险，建议戒烟或减少吸烟量');
    }
    if (data.drinking === '是') {
      suggestions.push('过量饮酒会影响健康，建议适量饮酒或戒酒');
    }
    if (data.exercise === '每周1-2次') {
      suggestions.push('运动频率偏低，建议逐步增加到每周至少150分钟中等强度运动');
    }

    suggestions.push('保持良好的作息习惯，保证每晚7-8小时充足睡眠');

    this.aiSuggestions = suggestions;
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.back();
          });
        Text('评估结果')
          .fontSize(18)
          .fontWeight('bold')
          .flexGrow(1)
          .textAlign(TextAlign.Center);
        Text('历史')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.push({ url: 'pages/RiskHistoryPage' });
          });
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 });

      Scroll() {
        if (this.hasValidData) {
          Column() {
            // 综合风险等级
            Column() {
              Text(this.riskLevel.icon)
                .fontSize(64)
                .margin({ bottom: 16 });
              Text(this.riskLevel.level)
                .fontSize(32)
                .fontWeight('bold')
                .fontColor(this.riskLevel.color)
                .margin({ bottom: 8 });
              Text(this.riskLevel.message)
                .fontSize(16)
                .fontColor('#666666');
            }
            .width('100%')
            .padding(32)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .alignItems(HorizontalAlign.Center)
            .margin({ top: 24, bottom: 24 });

            // 五项风险详情卡片
            Text('风险详情')
              .fontSize(20)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 16 });

            ForEach(this.riskItems, (item: RiskItem) => {
              Column() {
                Row() {
                  Text(item.icon)
                    .fontSize(32)
                    .margin({ right: 16 });
                  Column() {
                    Row() {
                      Text(item.name)
                        .fontSize(16)
                        .fontWeight('bold')
                        .fontColor('#333333')
                        .flexGrow(1);
                      Text(item.level)
                        .fontSize(14)
                        .fontWeight('bold')
                        .fontColor(item.levelColor)
                        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                        .backgroundColor(this.getLevelBgColor(item.levelColor))
                        .borderRadius(12);
                    }
                    Text(item.description)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 4 });
                  }
                  .flexGrow(1);
                }
                .width('100%');
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 12 });
            });

            // AI解读建议
            Column() {
              Row() {
                Text('🤖 AI解读建议')
                  .fontSize(18)
                  .fontWeight('bold')
                  .fontColor('#333333');
              }
              .width('100%')
              .margin({ bottom: 16 });

              ForEach(this.aiSuggestions, (suggestion: string, index: number) => {
                Row() {
                  Text((index + 1) + '.')
                    .fontSize(14)
                    .fontColor('#1677FF')
                    .fontWeight('bold')
                    .margin({ right: 8 });
                  Text(suggestion)
                    .fontSize(14)
                    .fontColor('#666666')
                    .flexGrow(1);
                }
                .width('100%')
                .margin({ bottom: 8 });
              });
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#F0F7FF')
            .borderRadius(16)
            .margin({ top: 24, bottom: 24 });

            // 操作按钮
            Column() {
              Row() {
                Button('查看详细报告')
                  .width('48%')
                  .height(48)
                  .fontSize(14)
                  .fontColor('#1677FF')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(24)
                  .border({ width: 1, color: '#1677FF' })
                  .onClick(() => {
                    this.handleViewReport();
                  });
                Button('分享给医生')
                  .width('48%')
                  .height(48)
                  .fontSize(14)
                  .fontColor('#1677FF')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(24)
                  .border({ width: 1, color: '#1677FF' })
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.handleShare();
                  });
              }
              .width('100%')
              .margin({ bottom: 12 });

              Row() {
                Button('重新评估')
                  .width('48%')
                  .height(48)
                  .fontSize(14)
                  .fontColor('#1677FF')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(24)
                  .border({ width: 1, color: '#1677FF' })
                  .onClick(() => {
                    this.handleReassess();
                  });
                Button('制定康复计划')
                  .width('48%')
                  .height(48)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#1677FF')
                  .borderRadius(24)
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.handleRehabPlan();
                  });
              }
              .width('100%');
            }
            .width('100%')
            .margin({ bottom: 48 });
          }
          .width('85%')
          .padding({ top: 24, bottom: 48 });
        } else {
          Column() {
            Text('📋')
              .fontSize(72)
              .margin({ bottom: 24 });
            Text('您还有未填数据')
              .fontSize(22)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 12 });
            Text('请完成健康评估后再查看结果')
              .fontSize(15)
              .fontColor('#999999')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 40 });
            Button('去评估')
              .width('60%')
              .height(48)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(24)
              .onClick(() => {
                router.push({ url: 'pages/RiskAssessmentPage' });
              });
          }
          .width('85%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        }
      }
      .height(0)
      .layoutWeight(1)

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
