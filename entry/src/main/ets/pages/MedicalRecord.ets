import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { Input } from '../components/Input';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

interface MedicalRecordItem {
  id: string;
  date: string;
  hospital: string;
  diagnosis: string;
  doctor: string;
  patientName: string;
  patientGender: string;
  patientAge: string;
  treatmentPlan: string;
  medicationAdvice: string;
  doctorSignature: string;
}

interface FilterState {
  hospital: string;
  diagnosis: string;
}

@Entry
@Component
struct MedicalRecord {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State records: MedicalRecordItem[] = [];
  @State filteredRecords: MedicalRecordItem[] = [];
  @State @Watch('handleFilter') hospitalFilter: string = '';
  @State @Watch('handleFilter') diagnosisFilter: string = '';
  @State showDetail: boolean = false;
  @State selectedRecord: MedicalRecordItem | null = null;
  @State showShareDialog: boolean = false;

  aboutToAppear(): void {
    this.loadMedicalRecords();
  }

  loadMedicalRecords(): void {
    this.isLoading = true;
    this.hasError = false;

    setTimeout(() => {
      try {
        // 模拟数据，实际项目中应该从API获取
        this.records = [
          {
            id: '1',
            date: '2024-03-15',
            hospital: '协和医院',
            diagnosis: '高血压 I 级',
            doctor: '王医生',
            patientName: '张三',
            patientGender: '男',
            patientAge: '35岁',
            treatmentPlan: '1. 注意休息，避免过度劳累\n2. 低盐饮食，控制血压\n3. 定期测量血压，记录数据',
            medicationAdvice: '1. 阿司匹林 100mg，每日一次\n2. 降压药 5mg，每日两次',
            doctorSignature: '王医生'
          },
          {
            id: '2',
            date: '2024-02-20',
            hospital: '同济医院',
            diagnosis: '糖尿病 II 型',
            doctor: '李医生',
            patientName: '张三',
            patientGender: '男',
            patientAge: '35岁',
            treatmentPlan: '1. 控制饮食，减少糖分摄入\n2. 适量运动\n3. 定期监测血糖',
            medicationAdvice: '1. 二甲双胍 500mg，每日两次\n2. 胰岛素，睡前注射',
            doctorSignature: '李医生'
          },
          {
            id: '3',
            date: '2024-01-10',
            hospital: '协和医院',
            diagnosis: '慢性咽炎',
            doctor: '张医生',
            patientName: '张三',
            patientGender: '男',
            patientAge: '35岁',
            treatmentPlan: '1. 多喝水，保持喉部湿润\n2. 避免辛辣刺激食物\n3. 少说话，让喉部休息',
            medicationAdvice: '1. 润喉糖，按需使用\n2. 抗生素，每日三次',
            doctorSignature: '张医生'
          }
        ];

        // 按时间倒序排序
        this.records.sort((a, b) => {
          return new Date(b.date).getTime() - new Date(a.date).getTime();
        });

        this.filteredRecords = [...this.records];
        this.isLoading = false;
      } catch (error) {
        console.error('加载病历数据失败:', error);
        this.isLoading = false;
        this.hasError = true;
      }
    }, 1500);
  }

  handleFilter(): void {
    this.filteredRecords = this.records.filter(record => {
      const matchHospital = !this.hospitalFilter || record.hospital.includes(this.hospitalFilter);
      const matchDiagnosis = !this.diagnosisFilter || record.diagnosis.includes(this.diagnosisFilter);
      return matchHospital && matchDiagnosis;
    });
  }

  handleRecordClick(record: MedicalRecordItem): void {
    this.selectedRecord = record;
    this.showDetail = true;
  }

  handleShare(record: MedicalRecordItem): void {
    this.selectedRecord = record;
    this.showShareDialog = true;
  }

  handleExport(type: string): void {
    console.log(`导出${type}`, this.selectedRecord);
    // 实际项目中应该实现导出功能
    this.showShareDialog = false;
  }

  getDesensitizedName(name: string): string {
    if (name.length <= 1) return name;
    return name.charAt(0) + '*'.repeat(name.length - 1);
  }

  build() {
    Column() {
      Header({ title: '病历管理', showBack: true });

      if (this.isLoading) {
        Loading();
      } else if (this.hasError) {
        EmptyState({
          icon: '❌',
          title: '加载失败',
          description: '病历数据加载出现问题，请重试',
          buttonText: '重新加载',
          onAdd: () => this.loadMedicalRecords()
        });
      } else {
        // 筛选栏
        Column() {
          Text('筛选条件')
            .fontSize(AccessibilityConfig.getFontSizeSubtitle())
            .fontWeight('bold')
            .fontColor(AccessibilityConfig.getTextPrimary())
            .margin({ bottom: AccessibilityConfig.getSpacingMD() });

          Row({ space: AccessibilityConfig.getSpacingMD() }) {
            Column({ space: AccessibilityConfig.getSpacingSM() }) {
              Text('医院')
                .fontSize(AccessibilityConfig.getFontSizeSmall())
                .fontColor(AccessibilityConfig.getTextSecondary());
              Input({
                placeholder: '请输入医院名称',
                inputType: 'text',
                text: $hospitalFilter
              })
            }
            .layoutWeight(1);

            Column({ space: AccessibilityConfig.getSpacingSM() }) {
              Text('诊断')
                .fontSize(AccessibilityConfig.getFontSizeSmall())
                .fontColor(AccessibilityConfig.getTextSecondary());
              Input({
                placeholder: '请输入诊断名称',
                inputType: 'text',
                text: $diagnosisFilter
              })
            }
            .layoutWeight(1);
          }
        }
        .width('100%')
        .padding(AccessibilityConfig.getSpacingMD())
        .backgroundColor(AccessibilityConfig.getCardBgColor())
        .borderRadius(8)
        .margin({ bottom: AccessibilityConfig.getSpacingMD() });

        // 病历列表
        if (this.filteredRecords.length === 0) {
          EmptyState({
            icon: '📋',
            title: '暂无病历',
            description: '没有找到符合条件的病历记录',
            buttonText: '清除筛选',
            onAdd: () => {
              this.hospitalFilter = '';
              this.diagnosisFilter = '';
              this.filteredRecords = [...this.records];
            }
          });
        } else {
          List() {
            ForEach(this.filteredRecords, (record: MedicalRecordItem) => {
              ListItem() {
                Column() {
                  Row({ space: AccessibilityConfig.getSpacingMD() }) {
                    Column() {
                      Text(record.date)
                        .fontSize(AccessibilityConfig.getFontSizeBody())
                        .fontWeight('bold')
                        .fontColor(AccessibilityConfig.getTextPrimary());
                    }
                    .width(80);

                    Column({ space: AccessibilityConfig.getSpacingXS() }) {
                      Row() {
                        Text('医院:')
                          .fontSize(AccessibilityConfig.getFontSizeSmall())
                          .fontColor(AccessibilityConfig.getTextSecondary())
                          .width(40);
                        Text(record.hospital)
                          .fontSize(AccessibilityConfig.getFontSizeSmall())
                          .fontColor(AccessibilityConfig.getTextPrimary())
                          .flexGrow(1);
                      }
                      Row() {
                        Text('诊断:')
                          .fontSize(AccessibilityConfig.getFontSizeSmall())
                          .fontColor(AccessibilityConfig.getTextSecondary())
                          .width(40);
                        Text(record.diagnosis)
                          .fontSize(AccessibilityConfig.getFontSizeSmall())
                          .fontColor(AccessibilityConfig.getTextPrimary())
                          .flexGrow(1);
                      }
                      Row() {
                        Text('医生:')
                          .fontSize(AccessibilityConfig.getFontSizeSmall())
                          .fontColor(AccessibilityConfig.getTextSecondary())
                          .width(40);
                        Text(record.doctor)
                          .fontSize(AccessibilityConfig.getFontSizeSmall())
                          .fontColor(AccessibilityConfig.getTextPrimary())
                          .flexGrow(1);
                      }
                    }
                    .flexGrow(1);

                    Column() {
                      Text('>')
                        .fontSize(AccessibilityConfig.getFontSizeBody())
                        .fontColor(AccessibilityConfig.getTextSecondary());
                    }
                  }
                }
                .width('100%')
                .padding(AccessibilityConfig.getSpacingMD())
                .backgroundColor(AccessibilityConfig.getCardBgColor())
                .borderRadius(8)
                .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
                .onClick(() => this.handleRecordClick(record));
              }
              .padding({ bottom: AccessibilityConfig.getSpacingMD() });
            }, (record: MedicalRecordItem) => record.id);
          }
          .width('100%')
          .height(0)
          .layoutWeight(1)
          .scrollBar(BarState.Off);
        }
      }

      // 病历详情弹窗
      if (this.showDetail && this.selectedRecord) {
        Column() {
          Row() {
            Text('病历详情')
              .fontSize(AccessibilityConfig.getFontSizeSubtitle())
              .fontWeight('bold')
              .fontColor(AccessibilityConfig.getTextPrimary());
            Text('✕')
              .fontSize(AccessibilityConfig.getFontSizeBody())
              .fontColor(AccessibilityConfig.getTextSecondary())
              .onClick(() => this.showDetail = false);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: AccessibilityConfig.getSpacingMD() });

          Scroll() {
            Column({ space: AccessibilityConfig.getSpacingMD() }) {
              // 患者信息卡片
              Column() {
                Text('患者信息')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontWeight('bold')
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .margin({ bottom: AccessibilityConfig.getSpacingSM() });

                Row() {
                  Text('姓名:')
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextSecondary())
                    .width(80);
                  Text(this.getDesensitizedName(this.selectedRecord.patientName))
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextPrimary())
                    .flexGrow(1);
                }

                Row() {
                  Text('性别:')
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextSecondary())
                    .width(80);
                  Text(this.selectedRecord.patientGender)
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextPrimary())
                    .flexGrow(1);
                }

                Row() {
                  Text('年龄:')
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextSecondary())
                    .width(80);
                  Text(this.selectedRecord.patientAge)
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextPrimary())
                    .flexGrow(1);
                }

                Row() {
                  Text('就诊日期:')
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextSecondary())
                    .width(80);
                  Text(this.selectedRecord.date)
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextPrimary())
                    .flexGrow(1);
                }

                Row() {
                  Text('医院:')
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextSecondary())
                    .width(80);
                  Text(this.selectedRecord.hospital)
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextPrimary())
                    .flexGrow(1);
                }

                Row() {
                  Text('医生:')
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextSecondary())
                    .width(80);
                  Text(this.selectedRecord.doctor)
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextPrimary())
                    .flexGrow(1);
                }
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

              // 诊断结果卡片
              Column() {
                Text('诊断结果')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontWeight('bold')
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .margin({ bottom: AccessibilityConfig.getSpacingSM() });

                Text(this.selectedRecord.diagnosis)
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextPrimary());
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

              // 治疗方案卡片
              Column() {
                Text('治疗方案')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontWeight('bold')
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .margin({ bottom: AccessibilityConfig.getSpacingSM() });

                Text(this.selectedRecord.treatmentPlan)
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .textAlign(TextAlign.Start);
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

              // 用药建议卡片
              Column() {
                Text('用药建议')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontWeight('bold')
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .margin({ bottom: AccessibilityConfig.getSpacingSM() });

                Text(this.selectedRecord.medicationAdvice)
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .textAlign(TextAlign.Start);
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

              // 医生签名卡片
              Column() {
                Text('医生签名')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontWeight('bold')
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .margin({ bottom: AccessibilityConfig.getSpacingSM() });

                Text(this.selectedRecord.doctorSignature)
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextPrimary());
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

              // 操作按钮
              Row({ space: AccessibilityConfig.getSpacingMD() }) {
                Button('分享')
                  .width('33%')
                  .height(AccessibilityConfig.getButtonHeight())
                  .fontSize(AccessibilityConfig.getFontSizeButton())
                  .fontWeight('medium')
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .backgroundColor(AccessibilityConfig.getActiveBgColor())
                  .borderRadius(8)
                  .onClick(() => this.handleShare(this.selectedRecord!));

                Button('风险评估')
                  .width('33%')
                  .height(AccessibilityConfig.getButtonHeight())
                  .fontSize(AccessibilityConfig.getFontSizeButton())
                  .fontWeight('medium')
                  .fontColor('#FFFFFF')
                  .backgroundColor(AccessibilityConfig.getThemeColor())
                  .borderRadius(8)
                  .onClick(() => {
                    router.push({
                      url: 'pages/RiskAssessmentPage',
                      params: {
                        record: this.selectedRecord
                      }
                    });
                  });

                Button('导出')
                  .width('33%')
                  .height(AccessibilityConfig.getButtonHeight())
                  .fontSize(AccessibilityConfig.getFontSizeButton())
                  .fontWeight('medium')
                  .fontColor('#FFFFFF')
                  .backgroundColor(AccessibilityConfig.getThemeColor())
                  .borderRadius(8)
                  .onClick(() => this.handleShare(this.selectedRecord!));
              }
              .width('100%')
            }
            .width('100%')
            .padding({ bottom: AccessibilityConfig.getSpacingLG() });
          }
          .height(0)
          .layoutWeight(1)
          .scrollBar(BarState.Off);
        }
        .width('100%')
        .height('100%')
        .padding(AccessibilityConfig.getSpacingLG())
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .position({ x: 0, y: 0 })
        .zIndex(1000);
      }

      // 分享导出弹窗
      if (this.showShareDialog) {
        Column() {
          Row() {
            Text('分享导出')
              .fontSize(AccessibilityConfig.getFontSizeSubtitle())
              .fontWeight('bold')
              .fontColor(AccessibilityConfig.getTextPrimary());
            Text('✕')
              .fontSize(AccessibilityConfig.getFontSizeBody())
              .fontColor(AccessibilityConfig.getTextSecondary())
              .onClick(() => this.showShareDialog = false);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: AccessibilityConfig.getSpacingMD() });

          Column({ space: AccessibilityConfig.getSpacingMD() }) {
            Button('导出为PDF')
              .width('100%')
              .height(AccessibilityConfig.getButtonHeight())
              .fontSize(AccessibilityConfig.getFontSizeButton())
              .fontWeight('medium')
              .fontColor(AccessibilityConfig.getTextPrimary())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
              .onClick(() => this.handleExport('PDF'));

            Button('导出为图片')
              .width('100%')
              .height(AccessibilityConfig.getButtonHeight())
              .fontSize(AccessibilityConfig.getFontSizeButton())
              .fontWeight('medium')
              .fontColor(AccessibilityConfig.getTextPrimary())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
              .onClick(() => this.handleExport('图片'));

            Button('取消')
              .width('100%')
              .height(AccessibilityConfig.getButtonHeight())
              .fontSize(AccessibilityConfig.getFontSizeButton())
              .fontWeight('medium')
              .fontColor(AccessibilityConfig.getTextSecondary())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
              .onClick(() => this.showShareDialog = false);
          }
          .width('100%');
        }
        .width('80%')
        .padding(AccessibilityConfig.getSpacingLG())
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .position({ x: '10%', y: '30%' })
        .zIndex(2000);
      }

      Footer({ activeIndex: 4 })
    }
    .width('100%')
    .height('100%')
    .padding({ top: AccessibilityConfig.getSpacingLG(), bottom: AccessibilityConfig.getSpacingLG() })
    .backgroundColor(AccessibilityConfig.getBgColor());
  }
}