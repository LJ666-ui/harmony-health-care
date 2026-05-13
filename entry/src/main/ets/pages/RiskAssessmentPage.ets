import { router } from '@kit.ArkUI';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { RiskAssessmentEngine } from '../ai/RiskAssessmentEngine';
import { HealthInputData, RiskAssessmentResult, RadarDataItem, getRiskColor, getRiskLabel, RiskLevel } from '../models/AIModels';
import { RadarChart } from '../components/RadarChart';
import { getRadarDataFromResult } from '../mock/riskAssessmentMock';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

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

  constructor(age?: string, gender?: string, height?: string, weight?: string, bmi?: number,
    systolic?: string, diastolic?: string, fastingGlucose?: string, postprandialGlucose?: string,
    smoking?: string, drinking?: string, exercise?: string, medicalHistory?: string[]) {
    if (age !== undefined) this.age = age;
    if (gender !== undefined) this.gender = gender;
    if (height !== undefined) this.height = height;
    if (weight !== undefined) this.weight = weight;
    if (bmi !== undefined) this.bmi = bmi;
    if (systolic !== undefined) this.systolic = systolic;
    if (diastolic !== undefined) this.diastolic = diastolic;
    if (fastingGlucose !== undefined) this.fastingGlucose = fastingGlucose;
    if (postprandialGlucose !== undefined) this.postprandialGlucose = postprandialGlucose;
    if (smoking !== undefined) this.smoking = smoking;
    if (drinking !== undefined) this.drinking = drinking;
    if (exercise !== undefined) this.exercise = exercise;
    if (medicalHistory !== undefined) this.medicalHistory = medicalHistory;
  }
}

class HealthRecord {
  type: string = '';
  value: string = '';

  constructor(type?: string, value?: string) {
    if (type !== undefined) this.type = type;
    if (value !== undefined) this.value = value;
  }
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
  @State assessmentData: AssessmentData = new AssessmentData();
  @State errorMessage: string = '';
  @State aiSuggestion: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  private createStepArray(): number[] {
    const arr: number[] = [];
    for (let i = 0; i < this.totalSteps; i++) {
      arr.push(i);
    }
    return arr;
  }

  aboutToAppear() {
    const params = router.getParams();
    if (params) {
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

    const submitData: AssessmentData = new AssessmentData(
      data.age.trim(),
      data.gender,
      data.height.trim(),
      data.weight.trim(),
      data.bmi > 0 ? data.bmi : 0,
      data.systolic.trim(),
      data.diastolic.trim(),
      data.fastingGlucose.trim(),
      data.postprandialGlucose.trim() || '',
      data.smoking,
      data.drinking,
      data.exercise,
      data.medicalHistory
    );

    this.isSubmitting = true;
    const userId: number = AppStorage.get<number>('userId') || 1;

    const healthInput: HealthInputData = new HealthInputData(
      parseFloat(submitData.age) || 0,
      submitData.gender,
      parseFloat(submitData.height) || 0,
      parseFloat(submitData.weight) || 0,
      submitData.bmi > 0 ? submitData.bmi : 0,
      parseFloat(submitData.systolic) || 0,
      parseFloat(submitData.diastolic) || 0,
      parseFloat(submitData.fastingGlucose) || 0,
      parseFloat(submitData.postprandialGlucose) || 0,
      72,
      7,
      submitData.exercise === '每天' ? 7 : (submitData.exercise === '每周3-5次' ? 4 : 1),
      submitData.smoking === '是',
      submitData.drinking === '是',
      submitData.medicalHistory
    );

    const engine: RiskAssessmentEngine = RiskAssessmentEngine.getInstance();
    engine.assessRisk(healthInput).then((aiResult: RiskAssessmentResult) => {
      HttpUtil.post<Object>(ApiConstants.RISK_ASSESS + userId, submitData)
        .then((response: BaseResponse<Object>) => {
          this.isSubmitting = false;
          if (response.success) {
            router.pushUrl({
              url: 'pages/RiskResultPage',
              params: { assessmentData: submitData, aiResult: aiResult }
            });
          } else {
            router.pushUrl({
              url: 'pages/RiskResultPage',
              params: { assessmentData: submitData, aiResult: aiResult }
            });
          }
        })
        .catch(() => {
          this.isSubmitting = false;
          router.pushUrl({
            url: 'pages/RiskResultPage',
            params: { assessmentData: submitData, aiResult: aiResult }
          });
        });
    }).catch(() => {
      this.isSubmitting = false;
      router.pushUrl({
        url: 'pages/RiskResultPage',
        params: { assessmentData: submitData }
      });
    });
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

      if (this.currentStep === 1) {
        Scroll() {
          Column() {
            Row() {
              Column({ space: 8 }) {
                Text('健康概览')
                  .fontSize(16)
                  .fontWeight('bold')
                  .fontColor('#FFFFFF')
                  .alignSelf(ItemAlign.Start);
                Row({ space: 24 }) {
                  Column({ space: 4 }) {
                    Text(this.lastResult)
                      .fontSize(24)
                      .fontWeight('bold')
                      .fontColor('#FFFFFF');
                    Text('风险等级')
                      .fontSize(11)
                      .fontColor('#FFFFFF99');
                  }
                  Line().width(1).height(32).stroke('#FFFFFF33');
                  Column({ space: 4 }) {
                    Text(this.lastAssessment)
                      .fontSize(14)
                      .fontWeight('bold')
                      .fontColor('#FFFFFF');
                    Text('上次评估')
                      .fontSize(11)
                      .fontColor('#FFFFFF99');
                  }
                }.alignItems(VerticalAlign.Center);
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);
              Text('→')
                .fontSize(20)
                .fontColor('#FFFFFF')
                .margin({ right: 8 });
            }
            .width('90%')
            .height(100)
            .padding({ left: 20, right: 16 })
            .borderRadius(16)
            .linearGradient({
              angle: 135,
              colors: [['#1677FF', 0], ['#36CFC9', 1]]
            })
            .shadow({ radius: 12, color: '#1677FF22', offsetX: 0, offsetY: 6 })
            .margin({ top: 20, bottom: 20 })
            .onClick(() => {
              router.push({ url: 'pages/RiskHistoryPage' });
            });

            Column({ space: 10 }) {
              Row() {
                Text('💡')
                  .fontSize(18);
                Text('温馨提示')
                  .fontSize(16)
                  .fontWeight('bold')
                  .fontColor('#1677FF');
              }
              .alignItems(VerticalAlign.Center)
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 4 });
              Text('请如实填写以下信息，我们将为您提供个性化的健康风险评估报告')
                .fontSize(13)
                .fontColor('#666666')
                .textAlign(TextAlign.Center)
                .width('100%')
                .lineHeight(20);
            }
            .width('90%')
            .padding(16)
            .backgroundColor('#F0F7FF')
            .borderRadius(12)
            .margin({ bottom: 20 });

            Button('开始评估')
              .width('90%')
              .height(50)
              .fontSize(17)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(25)
              .shadow({ radius: 8, color: '#1677FF44', offsetX: 0, offsetY: 4 })
              .onClick(() => {
                this.currentStep++;
              });

            Row() {
              Column() {
                Text('📋')
                  .fontSize(28)
                  .margin({ bottom: 8 });
                Text('我的历史')
                  .fontSize(13)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 4 });
                Text('查看历史评估记录')
                  .fontSize(11)
                  .fontColor('#999999');
              }
              .flexGrow(1)
              .height(95)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(14)
              .shadow({ radius: 8, color: '#0000000A', offsetX: 0, offsetY: 3 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/RiskHistoryPage' });
              });

              Column() {
                Text('👨‍⚕️')
                  .fontSize(28)
                  .margin({ bottom: 8 });
                Text('医患对话')
                  .fontSize(13)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 4 });
                Text('与医生在线沟通')
                  .fontSize(11)
                  .fontColor('#999999');
              }
              .flexGrow(1)
              .height(95)
              .margin({ left: 12 })
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(14)
              .shadow({ radius: 8, color: '#0000000A', offsetX: 0, offsetY: 3 })
              .onClick(() => {
                router.push({ url: 'pages/DoctorListPage' });
              });
            }
            .width('90%')
            .margin({ top: 20, bottom: 16 });

            Row() {
              Column() {
                Text('📊')
                  .fontSize(24)
                  .margin({ bottom: 6 });
                Text('健康记录')
                  .fontSize(12)
                  .fontColor('#555555');
              }
              .flexGrow(1)
              .height(80)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.back();
              });

              Column() {
                Text('🤖')
                  .fontSize(24)
                  .margin({ bottom: 6 });
                Text('AI 咨询')
                  .fontSize(12)
                  .fontColor('#555555');
              }
              .flexGrow(1)
              .height(80)
              .margin({ left: 10 })
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.push({ url: 'pages/AiChatPage' });
              });

              Column() {
                Text('📈')
                  .fontSize(24)
                  .margin({ bottom: 6 });
                Text('趋势分析')
                  .fontSize(12)
                  .fontColor('#555555');
              }
              .flexGrow(1)
              .height(80)
              .margin({ left: 10 })
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.push({ url: 'pages/BrowseHistoryPage' });
              });

              Column() {
                Text('⚙️')
                  .fontSize(24)
                  .margin({ bottom: 6 });
                Text('设置')
                  .fontSize(12)
                  .fontColor('#555555');
              }
              .flexGrow(1)
              .height(80)
              .margin({ left: 10 })
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/Profile' });
              });
            }
            .width('90%')
            .margin({ top: 8, bottom: 16 });

            Column({ space: 12 }) {
              Row() {
                Text('🌟')
                  .fontSize(18);
                Text('每日健康小贴士')
                  .fontSize(15)
                  .fontWeight('bold')
                  .fontColor('#333333');
                Blank();
                Text('换一条')
                  .fontSize(12)
                  .fontColor('#1677FF')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor('#E8F0FF')
                  .borderRadius(12);
              }
              .alignItems(VerticalAlign.Center)
              .width('100%');

              Text('💧 每天至少饮用 2000ml 水，有助于促进新陈代谢和排出体内毒素。建议分多次少量饮用，避免一次性大量饮水。')
                .fontSize(13)
                .fontColor('#555555')
                .lineHeight(22)
                .textAlign(TextAlign.Start);
            }
            .width('90%')
            .padding(16)
            .backgroundColor('#FFFBEB')
            .borderRadius(14)
            .border({ width: 1, color: '#FFF3CD', style: BorderStyle.Solid })
            .margin({ bottom: 32 });
          }
          .width('100%')
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .layoutWeight(1);
      }

      if (this.currentStep > 1) {
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
            Button(this.currentStep < this.totalSteps ? '下一步' : '提交评估')
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