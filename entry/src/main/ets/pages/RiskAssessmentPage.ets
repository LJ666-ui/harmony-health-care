import { router } from '@kit.ArkUI';

interface AssessmentData {
  age: string;
  gender: string;
  height: string;
  weight: string;
  bmi: number;
  systolic: string;
  diastolic: string;
  fastingGlucose: string;
  postprandialGlucose: string;
  smoking: string;
  drinking: string;
  exercise: string;
  medicalHistory: string[];
}

// 定义健康记录类型
interface HealthRecord {
  type: string;
  value: string;
}

@Entry
@Component
struct RiskAssessmentPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentStep: number = 1;
  @State totalSteps: number = 5;
  @State isSubmitting: boolean = false;
  @State lastAssessment: string = '2026-04-10';
  @State lastResult: string = '低风险';
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
  @State errorMessage: string = '';

  private createStepArray(): number[] {
    const arr: number[] = [];
    for (let i = 0; i < this.totalSteps; i++) {
      arr.push(i);
    }
    return arr;
  }

  aboutToAppear() {
    // 接收从健康记录页面传递过来的数据
    const params = router.getParams();
    if (params) {
      // 简化处理，直接检查参数
      const record = params as HealthRecord;
      if (record.type && record.value) {
        if (record.type === '血压') {
          const parts = record.value.split('/');
          if (parts.length === 2) {
            this.assessmentData.systolic = parts[0];
            this.assessmentData.diastolic = parts[1];
          }
        } else if (record.type === '血糖') {
          this.assessmentData.fastingGlucose = record.value;
        }
      }
    }
  }

  calculateBMI() {
    const height = parseFloat(this.assessmentData.height);
    const weight = parseFloat(this.assessmentData.weight);
    if (height > 0 && weight > 0) {
      const heightInMeters = height / 100;
      this.assessmentData.bmi = parseFloat((weight / (heightInMeters * heightInMeters)).toFixed(1));
    }
  }

  private validateCurrentStep(): boolean {
    this.errorMessage = '';
    const data: AssessmentData = this.assessmentData;
    if (this.currentStep === 2) {
      if (!data.age || data.age.trim() === '') { this.errorMessage = '请输入年龄'; return false; }
      if (parseFloat(data.age) < 1 || parseFloat(data.age) > 150) { this.errorMessage = '请输入有效年龄(1-150)'; return false; }
      if (!data.height || data.height.trim() === '') { this.errorMessage = '请输入身高'; return false; }
      if (parseFloat(data.height) < 50 || parseFloat(data.height) > 250) { this.errorMessage = '请输入有效身高(50-250cm)'; return false; }
      if (!data.weight || data.weight.trim() === '') { this.errorMessage = '请输入体重'; return false; }
      if (parseFloat(data.weight) < 10 || parseFloat(data.weight) > 300) { this.errorMessage = '请输入有效体重(10-300kg)'; return false; }
    }
    if (this.currentStep === 3) {
      if (!data.systolic || data.systolic.trim() === '') { this.errorMessage = '请输入收缩压'; return false; }
      if (!data.diastolic || data.diastolic.trim() === '') { this.errorMessage = '请输入舒张压'; return false; }
      if (parseFloat(data.systolic) < 60 || parseFloat(data.systolic) > 280) { this.errorMessage = '请输入有效收缩压(60-280)'; return false; }
      if (parseFloat(data.diastolic) < 40 || parseFloat(data.diastolic) > 180) { this.errorMessage = '请输入有效舒张压(40-180)'; return false; }
    }
    if (this.currentStep === 4) {
      if (!data.fastingGlucose || data.fastingGlucose.trim() === '') { this.errorMessage = '请输入空腹血糖'; return false; }
      if (parseFloat(data.fastingGlucose) < 1 || parseFloat(data.fastingGlucose) > 30) { this.errorMessage = '请输入有效空腹血糖(1-30mmol/L)'; return false; }
    }
    return true;
  }

  nextStep() {
    if (this.currentStep >= 2 && !this.validateCurrentStep()) {
      return;
    }
    if (this.currentStep < this.totalSteps) {
      if (this.currentStep === 1) {
        this.calculateBMI();
      }
      this.currentStep++;
    } else {
      this.submitAssessment();
    }
  }

  prevStep() {
    if (this.currentStep > 1) {
      this.currentStep--;
    }
  }

  submitAssessment() {
    this.errorMessage = '';
    const data: AssessmentData = this.assessmentData;
    if (!data.age || data.age.trim() === '') { this.errorMessage = '请完成年龄填写'; return; }
    if (!data.height || data.height.trim() === '') { this.errorMessage = '请完成身高填写'; return; }
    if (!data.weight || data.weight.trim() === '') { this.errorMessage = '请完成体重填写'; return; }
    if (data.bmi <= 0) { this.calculateBMI(); }
    if (!data.systolic || data.systolic.trim() === '') { this.errorMessage = '请完成血压数据填写'; return; }
    if (!data.diastolic || data.diastolic.trim() === '') { this.errorMessage = '请完成血压数据填写'; return; }
    if (!data.fastingGlucose || data.fastingGlucose.trim() === '') { this.errorMessage = '请完成血糖数据填写'; return; }

    const submitData: AssessmentData = {
      age: data.age.trim(),
      gender: data.gender,
      height: data.height.trim(),
      weight: data.weight.trim(),
      bmi: data.bmi > 0 ? data.bmi : 0,
      systolic: data.systolic.trim(),
      diastolic: data.diastolic.trim(),
      fastingGlucose: data.fastingGlucose.trim(),
      postprandialGlucose: data.postprandialGlucose.trim() || '',
      smoking: data.smoking,
      drinking: data.drinking,
      exercise: data.exercise,
      medicalHistory: data.medicalHistory
    };

    this.isSubmitting = true;
    setTimeout(() => {
      this.isSubmitting = false;
      router.push({
        url: 'pages/RiskResultPage',
        params: { assessmentData: submitData }
      });
    }, 3000);
  }

  toggleMedicalHistory(condition: string) {
    const index = this.assessmentData.medicalHistory.indexOf(condition);
    if (index > -1) {
      this.assessmentData.medicalHistory.splice(index, 1);
    } else {
      this.assessmentData.medicalHistory.push(condition);
    }
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
        Text('健康风险评估')
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
      .shadow({
        radius: 4,
        color: '#00000010',
        offsetX: 0,
        offsetY: 2
      });

      // 顶部引导区
      if (this.currentStep === 1) {
        Column() {
          Text('温馨提示')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 24, bottom: 12 });
          Text('请如实填写以下信息，我们将为您提供个性化的健康风险评估报告')
            .fontSize(14)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
            .width('85%')
            .margin({ bottom: 24 });
          if (this.lastAssessment) {
            Text('上次评估：' + this.lastAssessment + ' (' + this.lastResult + ')')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ bottom: 24 });
          }
          Button('开始评估')
            .width('85%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(24)
            .onClick(() => {
              this.currentStep++;
            });
        }
        .width('100%')
        .padding({ bottom: 48 });
      }

      if (this.currentStep > 1) {
        // 进度条
        Column() {
          Row() {
            ForEach(this.createStepArray(), (_: number, index: number) => {
              Column() {
                Stack() {
                  Circle()
                    .width(24)
                    .height(24)
                    .fill((index + 1) <= this.currentStep ? '#1677FF' : '#E5E5E5');
                  Text((index + 1).toString())
                    .fontSize(12)
                    .fontColor((index + 1) <= this.currentStep ? '#FFFFFF' : '#999999');
                }

                Text((index + 1) <= this.currentStep ? '已完成' : '未开始')
                  .fontSize(10)
                  .fontColor((index + 1) <= this.currentStep ? '#1677FF' : '#999999')
                  .margin({ top: 4 });
              }
              .flexGrow(1);

              if ((index + 1) < this.totalSteps) {
                Line()
                  .width('100%')
                  .height(2)
                  .stroke((index + 1) < this.currentStep ? '#1677FF' : '#E5E5E5');
              }
            });
          }
          .width('85%')
          .margin({ top: 24, bottom: 32 });

          // 评估表单
          Scroll() {
            Column() {
              if (this.errorMessage) {
                Row() {
                  Text('⚠️ ' + this.errorMessage)
                    .fontSize(14)
                    .fontColor('#FF4D4F');
                }
                .width('100%')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor('#FFF1F0')
                .borderRadius(8)
                .margin({ bottom: 16 });
              }

              // 第一步：基本信息
              if (this.currentStep === 2) {
                Text('基本信息')
                  .fontSize(20)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 24 });

                Column() {
                  Text('年龄')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  TextInput({
                    placeholder: '请输入年龄'
                  })
                    .width('100%')
                    .height(48)
                    .padding(12)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)
                    .onChange((value) => {
                      this.assessmentData.age = value;
                    });
                }
                .margin({ bottom: 20 });

                Column() {
                  Text('性别')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  Row() {
                    Column() {
                      Text('男')
                        .fontSize(14)
                        .fontColor(this.assessmentData.gender === '男' ? '#1677FF' : '#666666');
                    }
                    .width('50%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.gender === '男' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .onClick(() => {
                      this.assessmentData.gender = '男';
                    });

                    Column() {
                      Text('女')
                        .fontSize(14)
                        .fontColor(this.assessmentData.gender === '女' ? '#1677FF' : '#666666');
                    }
                    .width('50%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.gender === '女' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.assessmentData.gender = '女';
                    });
                  }
                }
                .margin({ bottom: 20 });

                Column() {
                  Text('身高 (cm)')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  TextInput({
                    placeholder: '请输入身高'
                  })
                    .width('100%')
                    .height(48)
                    .padding(12)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)
                    .onChange((value) => {
                      this.assessmentData.height = value;
                      this.calculateBMI();
                    });
                }
                .margin({ bottom: 20 });

                Column() {
                  Text('体重 (kg)')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  Row() {
                    TextInput({
                      placeholder: '请输入体重'
                    })
                      .width('80%')
                      .height(48)
                      .padding(12)
                      .backgroundColor('#F5F5F5')
                      .borderRadius(8)
                      .onChange((value) => {
                        this.assessmentData.weight = value;
                        this.calculateBMI();
                      });
                    Text('BMI: ' + (this.assessmentData.bmi || '--'))
                      .height(48)
                      .padding({ left: 12, right: 12 })
                      .backgroundColor('#F5F5F5')
                      .borderRadius(8)
                      .fontSize(14)
                      .fontColor('#666666');
                  }
                }
                .margin({ bottom: 20 });
              }

              // 第二步：血压数据
              if (this.currentStep === 3) {
                Text('血压数据')
                  .fontSize(20)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 24 });

                Column() {
                  Text('收缩压 (mmHg)')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  TextInput({
                    placeholder: '请输入收缩压'
                  })
                    .width('100%')
                    .height(48)
                    .padding(12)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)
                    .onChange((value) => {
                      this.assessmentData.systolic = value;
                    });
                }
                .margin({ bottom: 20 });

                Column() {
                  Text('舒张压 (mmHg)')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  TextInput({
                    placeholder: '请输入舒张压'
                  })
                    .width('100%')
                    .height(48)
                    .padding(12)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)
                    .onChange((value) => {
                      this.assessmentData.diastolic = value;
                    });
                }
                .margin({ bottom: 20 });
              }

              // 第三步：血糖数据
              if (this.currentStep === 4) {
                Text('血糖数据')
                  .fontSize(20)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 24 });

                Column() {
                  Text('空腹血糖 (mmol/L)')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  TextInput({
                    placeholder: '请输入空腹血糖'
                  })
                    .width('100%')
                    .height(48)
                    .padding(12)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)
                    .onChange((value) => {
                      this.assessmentData.fastingGlucose = value;
                    });
                }
                .margin({ bottom: 20 });

                Column() {
                  Text('餐后血糖 (mmol/L)')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  TextInput({
                    placeholder: '请输入餐后血糖'
                  })
                    .width('100%')
                    .height(48)
                    .padding(12)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)
                    .onChange((value) => {
                      this.assessmentData.postprandialGlucose = value;
                    });
                }
                .margin({ bottom: 20 });
              }

              // 第四步：生活习惯
              if (this.currentStep === 5) {
                Text('生活习惯')
                  .fontSize(20)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 24 });

                Column() {
                  Text('吸烟情况')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  Row() {
                    Column() {
                      Text('是')
                        .fontSize(14)
                        .fontColor(this.assessmentData.smoking === '是' ? '#1677FF' : '#666666');
                    }
                    .width('33%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.smoking === '是' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .onClick(() => {
                      this.assessmentData.smoking = '是';
                    });

                    Column() {
                      Text('否')
                        .fontSize(14)
                        .fontColor(this.assessmentData.smoking === '否' ? '#1677FF' : '#666666');
                    }
                    .width('33%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.smoking === '否' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.assessmentData.smoking = '否';
                    });

                    Column() {
                      Text('已戒烟')
                        .fontSize(14)
                        .fontColor(this.assessmentData.smoking === '已戒烟' ? '#1677FF' : '#666666');
                    }
                    .width('33%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.smoking === '已戒烟' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.assessmentData.smoking = '已戒烟';
                    });
                  }
                }
                .margin({ bottom: 20 });

                Column() {
                  Text('饮酒情况')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  Row() {
                    Column() {
                      Text('是')
                        .fontSize(14)
                        .fontColor(this.assessmentData.drinking === '是' ? '#1677FF' : '#666666');
                    }
                    .width('33%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.drinking === '是' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .onClick(() => {
                      this.assessmentData.drinking = '是';
                    });

                    Column() {
                      Text('否')
                        .fontSize(14)
                        .fontColor(this.assessmentData.drinking === '否' ? '#1677FF' : '#666666');
                    }
                    .width('33%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.drinking === '否' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.assessmentData.drinking = '否';
                    });

                    Column() {
                      Text('偶尔')
                        .fontSize(14)
                        .fontColor(this.assessmentData.drinking === '偶尔' ? '#1677FF' : '#666666');
                    }
                    .width('33%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.drinking === '偶尔' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.assessmentData.drinking = '偶尔';
                    });
                  }
                }
                .margin({ bottom: 20 });

                Column() {
                  Text('运动频率')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 });
                  Row() {
                    Column() {
                      Text('每周1-2次')
                        .fontSize(12)
                        .fontColor(this.assessmentData.exercise === '每周1-2次' ? '#1677FF' : '#666666');
                    }
                    .width('33%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.exercise === '每周1-2次' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .onClick(() => {
                      this.assessmentData.exercise = '每周1-2次';
                    });

                    Column() {
                      Text('每周3-4次')
                        .fontSize(12)
                        .fontColor(this.assessmentData.exercise === '每周3-4次' ? '#1677FF' : '#666666');
                    }
                    .width('33%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.exercise === '每周3-4次' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.assessmentData.exercise = '每周3-4次';
                    });

                    Column() {
                      Text('每周5次以上')
                        .fontSize(12)
                        .fontColor(this.assessmentData.exercise === '每周5次以上' ? '#1677FF' : '#666666');
                    }
                    .width('33%')
                    .height(48)
                    .padding(12)
                    .backgroundColor(this.assessmentData.exercise === '每周5次以上' ? '#E8F0FF' : '#F5F5F5')
                    .borderRadius(8)
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.assessmentData.exercise = '每周5次以上';
                    });
                  }
                }
                .margin({ bottom: 20 });
              }

              // 第五步：既往病史
              if (this.currentStep === 6) {
                Text('既往病史')
                  .fontSize(20)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 24 });

                Text('请选择您曾患有的疾病（可多选）')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 16 });

                Grid() {
                  ForEach(['高血压', '糖尿病', '冠心病', '脑卒中', '慢性肾病', '骨质疏松', '癌症', '其他'],
                    (condition: string) => {
                      GridItem() {
                        Column() {
                          Text(condition)
                            .fontSize(14)
                            .fontColor(this.assessmentData.medicalHistory.includes(condition) ? '#1677FF' : '#666666');
                        }
                        .width('100%')
                        .height(48)
                        .padding(12)
                        .backgroundColor(this.assessmentData.medicalHistory.includes(condition) ? '#E8F0FF' : '#F5F5F5')
                        .borderRadius(8)
                        .onClick(() => {
                          this.toggleMedicalHistory(condition);
                        });
                      }
                    });
                }
                .columnsTemplate('1fr 1fr')
                .columnsGap(12)
                .rowsGap(12)
                .margin({ bottom: 20 });
              }
            }
            .width('85%')
            .padding({ bottom: 100 });
          }
          .height(0)
          .layoutWeight(1);

          // 底部按钮
          Row() {
            if (this.currentStep > 2) {
              Button('上一步')
                .width('48%')
                .height(48)
                .fontSize(16)
                .fontColor('#1677FF')
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .border({ width: 1, color: '#1677FF' })
                .onClick(() => {
                  this.prevStep();
                });
            } else {
              Blank()
                .width('48%');
            }
            Button(this.currentStep < this.totalSteps + 1 ? '下一步' : '提交评估')
              .width('48%')
              .height(48)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(24)
              .onClick(() => {
                this.nextStep();
              });
          }
          .width('85%')
          .padding({ bottom: 32 });
        }
      }

      // 评估中状态
      if (this.isSubmitting) {
        Stack() {
          Column() {
            Text('正在分析您的健康数据...')
              .fontSize(18)
              .fontColor('#333333')
              .margin({ bottom: 24 });
            Progress({
              value: 0,
              total: 100
            })
              .width('80%')
              .height(8)
              .color('#1677FF')
              .backgroundColor('#E5E5E5')
              .borderRadius(4);
          }
          .width('80%')
          .height(120)
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16);
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)');
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}