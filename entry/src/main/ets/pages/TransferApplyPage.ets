import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { Input } from '../components/Input';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

interface Hospital {
  id: string;
  name: string;
  distance: string;
  address: string;
  level: string;
}

interface TransferApplication {
  id: string;
  targetHospital: Hospital;
  reason: string;
  customReason: string;
  status: 'pending' | 'approved' | 'rejected';
  submitDate: string;
  reviewOpinion: string;
}

@Entry
@Component
struct TransferApplyPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentStep: number = 1;
  @State isLoading: boolean = false;
  @State hasError: boolean = false;
  @State hospitals: Hospital[] = [];
  @State filteredHospitals: Hospital[] = [];
  @State searchKeyword: string = '';
  @State selectedHospital: Hospital | null = null;
  @State selectedReason: string = '';
  @State customReason: string = '';
  @State applications: TransferApplication[] = [];
  @State showSuccessDialog: boolean = false;
  @State selectedApplication: TransferApplication | null = null;
  @State showStatusDialog: boolean = false;
  
  private reasons = ['病情需要', '医疗条件', '个人原因', '其他原因'];

  aboutToAppear(): void {
    this.loadHospitals();
    this.loadApplications();
  }

  loadHospitals(): void {
    this.isLoading = true;
    this.hasError = false;

    setTimeout(() => {
      try {
        // 模拟数据，实际项目中应该从API获取
        this.hospitals = [
          {
            id: '1',
            name: '协和医院',
            distance: '2.5km',
            address: '北京市东城区帅府园1号',
            level: '三级甲等'
          },
          {
            id: '2',
            name: '同济医院',
            distance: '3.8km',
            address: '上海市普陀区新村路399号',
            level: '三级甲等'
          },
          {
            id: '3',
            name: '人民医院',
            distance: '1.2km',
            address: '北京市西城区西直门南大街11号',
            level: '三级甲等'
          },
          {
            id: '4',
            name: '第一医院',
            distance: '5.6km',
            address: '上海市静安区乌鲁木齐中路12号',
            level: '三级甲等'
          },
          {
            id: '5',
            name: '中医院',
            distance: '4.3km',
            address: '北京市东城区东单帅府园1号',
            level: '三级甲等'
          }
        ];

        // 按距离排序
        this.hospitals.sort((a, b) => {
          const distanceA = parseFloat(a.distance.replace('km', ''));
          const distanceB = parseFloat(b.distance.replace('km', ''));
          return distanceA - distanceB;
        });

        this.filteredHospitals = [...this.hospitals];
        this.isLoading = false;
      } catch (error) {
        console.error('加载医院数据失败:', error);
        this.isLoading = false;
        this.hasError = true;
      }
    }, 1500);
  }

  loadApplications(): void {
    // 模拟数据，实际项目中应该从API获取
    this.applications = [
      {
        id: '1',
        targetHospital: {
          id: '1',
          name: '协和医院',
          distance: '2.5km',
          address: '北京市东城区帅府园1号',
          level: '三级甲等'
        },
        reason: '病情需要',
        customReason: '需要更专业的治疗',
        status: 'approved',
        submitDate: '2024-03-10',
        reviewOpinion: '同意转院，建议尽快办理手续'
      },
      {
        id: '2',
        targetHospital: {
          id: '2',
          name: '同济医院',
          distance: '3.8km',
          address: '上海市普陀区新村路399号',
          level: '三级甲等'
        },
        reason: '其他原因',
        customReason: '个人原因需要转院',
        status: 'pending',
        submitDate: '2024-03-15',
        reviewOpinion: ''
      },
      {
        id: '3',
        targetHospital: {
          id: '3',
          name: '人民医院',
          distance: '1.2km',
          address: '北京市西城区西直门南大街11号',
          level: '三级甲等'
        },
        reason: '医疗条件',
        customReason: '需要更好的医疗设备',
        status: 'rejected',
        submitDate: '2024-03-05',
        reviewOpinion: '当前医院可以提供相同的治疗方案，暂不同意转院'
      }
    ];
  }

  handleSearch(): void {
    this.filteredHospitals = this.hospitals.filter(hospital => {
      return hospital.name.includes(this.searchKeyword) || hospital.address.includes(this.searchKeyword);
    });
  }

  handleHospitalSelect(hospital: Hospital): void {
    this.selectedHospital = hospital;
    this.currentStep = 2;
  }

  handleReasonSelect(reason: string): void {
    this.selectedReason = reason;
  }

  handleSubmit(): void {
    this.isLoading = true;

    setTimeout(() => {
      try {
        if (!this.selectedHospital || !this.selectedReason) {
          throw new Error('请完成所有必填项');
        }

        const newApplication: TransferApplication = {
          id: Date.now().toString(),
          targetHospital: this.selectedHospital,
          reason: this.selectedReason,
          customReason: this.customReason,
          status: 'pending',
          submitDate: new Date().toISOString().split('T')[0],
          reviewOpinion: ''
        };

        this.applications.unshift(newApplication);
        this.showSuccessDialog = true;
        this.isLoading = false;
      } catch (error) {
        console.error('提交申请失败:', error);
        this.isLoading = false;
        this.hasError = true;
      }
    }, 1500);
  }

  handleApplicationClick(application: TransferApplication): void {
    this.selectedApplication = application;
    this.showStatusDialog = true;
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'pending':
        return AccessibilityConfig.getWarningColor();
      case 'approved':
        return AccessibilityConfig.getSuccessColor();
      case 'rejected':
        return AccessibilityConfig.getErrorColor();
      default:
        return AccessibilityConfig.getTextSecondary();
    }
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'pending':
        return '待审核';
      case 'approved':
        return '已同意';
      case 'rejected':
        return '已拒绝';
      default:
        return '未知状态';
    }
  }

  build() {
    Column() {
      Header({ title: '转院申请', showBack: true });

      if (this.isLoading) {
        Loading();
      } else if (this.hasError) {
        EmptyState({
          icon: '❌',
          title: '加载失败',
          description: '数据加载出现问题，请重试',
          buttonText: '重新加载',
          onAdd: () => this.loadHospitals()
        });
      } else {
        if (this.currentStep === 1) {
          // 第一步：选择目标医院
          Column({ space: AccessibilityConfig.getSpacingMD() }) {
            Text('选择目标医院')
              .fontSize(AccessibilityConfig.getFontSizeSubtitle())
              .fontWeight('bold')
              .fontColor(AccessibilityConfig.getTextPrimary());

            // 搜索框
            Input({
              placeholder: '搜索医院名称或地址',
              inputType: 'text',
              text: $searchKeyword,
              onChange: (value: string) => {
                this.searchKeyword = value;
                this.handleSearch();
              }
            })

            // 医院列表
            if (this.filteredHospitals.length === 0) {
              EmptyState({
                icon: '🏥',
                title: '暂无医院',
                description: '没有找到符合条件的医院',
                buttonText: '清除搜索',
                onAdd: () => {
                  this.searchKeyword = '';
                  this.filteredHospitals = [...this.hospitals];
                }
              });
            } else {
              List() {
                ForEach(this.filteredHospitals, (hospital: Hospital) => {
                  ListItem() {
                    Column() {
                      Row({ space: AccessibilityConfig.getSpacingMD() }) {
                        Column() {
                          Text(hospital.name)
                            .fontSize(AccessibilityConfig.getFontSizeBody())
                            .fontWeight('bold')
                            .fontColor(AccessibilityConfig.getTextPrimary());
                          Text(hospital.address)
                            .fontSize(AccessibilityConfig.getFontSizeSmall())
                            .fontColor(AccessibilityConfig.getTextSecondary());
                        }
                        .flexGrow(1);

                        Column({ space: AccessibilityConfig.getSpacingXS() }) {
                          Text(hospital.level)
                            .fontSize(AccessibilityConfig.getFontSizeTiny())
                            .fontColor(AccessibilityConfig.getTextSecondary());
                          Text(hospital.distance)
                            .fontSize(AccessibilityConfig.getFontSizeTiny())
                            .fontColor(AccessibilityConfig.getThemeColor());
                        }
                      }
                    }
                    .width('100%')
                    .padding(AccessibilityConfig.getSpacingMD())
                    .backgroundColor(AccessibilityConfig.getCardBgColor())
                    .borderRadius(8)
                    .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
                    .onClick(() => this.handleHospitalSelect(hospital));
                  }
                  .padding({ bottom: AccessibilityConfig.getSpacingMD() });
                }, (hospital: Hospital) => hospital.id);
              }
              .width('100%')
              .height(0)
              .layoutWeight(1)
              .scrollBar(BarState.Off);
            }
          }
        } else if (this.currentStep === 2) {
          // 第二步：填写原因
          Column({ space: AccessibilityConfig.getSpacingMD() }) {
            Text('填写转院原因')
              .fontSize(AccessibilityConfig.getFontSizeSubtitle())
              .fontWeight('bold')
              .fontColor(AccessibilityConfig.getTextPrimary());

            Text('选择原因')
              .fontSize(AccessibilityConfig.getFontSizeSmall())
              .fontColor(AccessibilityConfig.getTextSecondary());

            // 预设选项
            Column({ space: AccessibilityConfig.getSpacingSM() }) {
              ForEach(this.reasons, (reason: string) => {
                Row() {
                  Text(this.selectedReason === reason ? '✓' : '○')
                    .fontSize(AccessibilityConfig.getFontSizeBody())
                    .fontColor(this.selectedReason === reason ? AccessibilityConfig.getThemeColor() : AccessibilityConfig.getTextSecondary())
                    .width(30);
                  Text(reason)
                    .fontSize(AccessibilityConfig.getFontSizeBody())
                    .fontColor(AccessibilityConfig.getTextPrimary())
                    .flexGrow(1);
                }
                .width('100%')
                .padding(AccessibilityConfig.getSpacingMD())
                .backgroundColor(this.selectedReason === reason ? AccessibilityConfig.getActiveBgColor() : AccessibilityConfig.getCardBgColor())
                .borderRadius(8)
                .border({ width: 1, color: this.selectedReason === reason ? AccessibilityConfig.getThemeColor() : AccessibilityConfig.getBorderColor() })
                .onClick(() => this.handleReasonSelect(reason));
              });
            }

            Text('详细说明')
              .fontSize(AccessibilityConfig.getFontSizeSmall())
              .fontColor(AccessibilityConfig.getTextSecondary());

            TextInput({
              placeholder: '请详细说明转院原因'
            })
              .placeholderColor('#999999')
              .fontSize(14)
              .fontColor('#333333')
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .border({ width: 1, color: '#E5E6EB' })
              .width('100%')
              .height(120)
              .textAlign(TextAlign.Start)
              .onChange((value: string) => {
                this.customReason = value;
              });

            Text('上传材料（可选）')
              .fontSize(AccessibilityConfig.getFontSizeSmall())
              .fontColor(AccessibilityConfig.getTextSecondary());

            Button('选择文件')
              .width('100%')
              .height(AccessibilityConfig.getButtonHeight())
              .fontSize(AccessibilityConfig.getFontSizeButton())
              .fontWeight('medium')
              .fontColor(AccessibilityConfig.getTextPrimary())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
              .onClick(() => {
                console.log('选择文件');
              });

            // 按钮组
            Row({ space: AccessibilityConfig.getSpacingMD() }) {
              Button('上一步')
                .width('100%')
                .height(AccessibilityConfig.getButtonHeight())
                .fontSize(AccessibilityConfig.getFontSizeButton())
                .fontWeight('medium')
                .fontColor(AccessibilityConfig.getTextPrimary())
                .backgroundColor(AccessibilityConfig.getCardBgColor())
                .borderRadius(8)
                .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
                .onClick(() => this.currentStep = 1);

              Button('下一步')
                .width('100%')
                .height(AccessibilityConfig.getButtonHeight())
                .fontSize(AccessibilityConfig.getFontSizeButton())
                .fontWeight('medium')
                .fontColor('#FFFFFF')
                .backgroundColor(AccessibilityConfig.getThemeColor())
                .borderRadius(8)
                .onClick(() => this.currentStep = 3);
            }
          }
        } else if (this.currentStep === 3) {
          // 第三步：确认提交
          Column({ space: AccessibilityConfig.getSpacingMD() }) {
            Text('确认转院申请')
              .fontSize(AccessibilityConfig.getFontSizeSubtitle())
              .fontWeight('bold')
              .fontColor(AccessibilityConfig.getTextPrimary());

            // 汇总信息
            Column() {
              Text('申请信息')
                .fontSize(AccessibilityConfig.getFontSizeBody())
                .fontWeight('bold')
                .fontColor(AccessibilityConfig.getTextPrimary())
                .margin({ bottom: AccessibilityConfig.getSpacingSM() });

              Row() {
                Text('目标医院:')
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextSecondary())
                  .width(80);
                Text(this.selectedHospital?.name || '')
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .flexGrow(1);
              }

              Row() {
                Text('转院原因:')
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextSecondary())
                  .width(80);
                Text(this.selectedReason)
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .flexGrow(1);
              }

              if (this.customReason) {
                Row() {
                  Text('详细说明:')
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextSecondary())
                    .width(80);
                  Text(this.customReason)
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextPrimary())
                    .flexGrow(1)
                    .textAlign(TextAlign.Start);
                }
              }
            }
            .width('100%')
            .padding(AccessibilityConfig.getSpacingMD())
            .backgroundColor(AccessibilityConfig.getCardBgColor())
            .borderRadius(8)
            .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

            Text('请确认以上信息无误后提交申请')
              .fontSize(AccessibilityConfig.getFontSizeSmall())
              .fontColor(AccessibilityConfig.getTextSecondary());

            // 按钮组
            Row({ space: AccessibilityConfig.getSpacingMD() }) {
              Button('上一步')
                .width('100%')
                .height(AccessibilityConfig.getButtonHeight())
                .fontSize(AccessibilityConfig.getFontSizeButton())
                .fontWeight('medium')
                .fontColor(AccessibilityConfig.getTextPrimary())
                .backgroundColor(AccessibilityConfig.getCardBgColor())
                .borderRadius(8)
                .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
                .onClick(() => this.currentStep = 2);

              Button('提交申请')
                .width('100%')
                .height(AccessibilityConfig.getButtonHeight())
                .fontSize(AccessibilityConfig.getFontSizeButton())
                .fontWeight('medium')
                .fontColor('#FFFFFF')
                .backgroundColor(AccessibilityConfig.getThemeColor())
                .borderRadius(8)
                .onClick(() => this.handleSubmit());
            }
          }
        }

        // 申请状态追踪
        Column() {
          Text('申请状态追踪')
            .fontSize(AccessibilityConfig.getFontSizeSubtitle())
            .fontWeight('bold')
            .fontColor(AccessibilityConfig.getTextPrimary())
            .margin({ top: AccessibilityConfig.getSpacingLG(), bottom: AccessibilityConfig.getSpacingMD() });

          if (this.applications.length === 0) {
            EmptyState({
              icon: '📋',
              title: '暂无申请',
              description: '您还没有提交过转院申请',
              buttonText: '发起申请',
              onAdd: () => this.currentStep = 1
            });
          } else {
            List() {
              ForEach(this.applications, (application: TransferApplication) => {
                ListItem() {
                  Column() {
                    Row({ space: AccessibilityConfig.getSpacingMD() }) {
                      Column() {
                        Text(application.targetHospital.name)
                          .fontSize(AccessibilityConfig.getFontSizeBody())
                          .fontWeight('bold')
                          .fontColor(AccessibilityConfig.getTextPrimary());
                        Text(`提交日期: ${application.submitDate}`)
                          .fontSize(AccessibilityConfig.getFontSizeSmall())
                          .fontColor(AccessibilityConfig.getTextSecondary());
                      }
                      .flexGrow(1);

                      Column() {
                        Text(this.getStatusText(application.status))
                          .fontSize(AccessibilityConfig.getFontSizeSmall())
                          .fontWeight('bold')
                          .fontColor(this.getStatusColor(application.status));
                      }
                    }
                  }
                  .width('100%')
                  .padding(AccessibilityConfig.getSpacingMD())
                  .backgroundColor(AccessibilityConfig.getCardBgColor())
                  .borderRadius(8)
                  .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
                  .onClick(() => this.handleApplicationClick(application));
                }
                .padding({ bottom: AccessibilityConfig.getSpacingMD() });
              }, (application: TransferApplication) => application.id);
            }
            .width('100%')
            .height(0)
            .layoutWeight(1)
            .scrollBar(BarState.Off);
          }
        }
      }

      // 提交成功弹窗
      if (this.showSuccessDialog) {
        Column() {
          Text('🎉')
            .fontSize(48)
            .margin({ bottom: AccessibilityConfig.getSpacingMD() });

          Text('提交成功')
            .fontSize(AccessibilityConfig.getFontSizeSubtitle())
            .fontWeight('bold')
            .fontColor(AccessibilityConfig.getTextPrimary())
            .margin({ bottom: AccessibilityConfig.getSpacingSM() });

          Text('您的转院申请已提交，等待审核')
            .fontSize(AccessibilityConfig.getFontSizeSmall())
            .fontColor(AccessibilityConfig.getTextSecondary())
            .margin({ bottom: AccessibilityConfig.getSpacingMD() });

          Button('确定')
            .width('100%')
            .height(AccessibilityConfig.getButtonHeight())
            .fontSize(AccessibilityConfig.getFontSizeButton())
            .fontWeight('medium')
            .fontColor('#FFFFFF')
            .backgroundColor(AccessibilityConfig.getThemeColor())
            .borderRadius(8)
            .onClick(() => {
              this.showSuccessDialog = false;
              this.currentStep = 1;
              this.selectedHospital = null;
              this.selectedReason = '';
              this.customReason = '';
            });
        }
        .width('80%')
        .padding(AccessibilityConfig.getSpacingLG())
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .position({ x: '10%', y: '30%' })
        .zIndex(1000);
      }

      // 状态详情弹窗
      if (this.showStatusDialog && this.selectedApplication) {
        Column() {
          Row() {
            Text('申请详情')
              .fontSize(AccessibilityConfig.getFontSizeSubtitle())
              .fontWeight('bold')
              .fontColor(AccessibilityConfig.getTextPrimary());
            Text('✕')
              .fontSize(AccessibilityConfig.getFontSizeBody())
              .fontColor(AccessibilityConfig.getTextSecondary())
              .onClick(() => this.showStatusDialog = false);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: AccessibilityConfig.getSpacingMD() });

          Scroll() {
            Column({ space: AccessibilityConfig.getSpacingMD() }) {
              // 医院信息
              Column() {
                Text('目标医院')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontWeight('bold')
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .margin({ bottom: AccessibilityConfig.getSpacingSM() });

                Text(this.selectedApplication.targetHospital.name)
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextPrimary());
                Text(this.selectedApplication.targetHospital.address)
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextSecondary());
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

              // 申请信息
              Column() {
                Text('申请信息')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontWeight('bold')
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .margin({ bottom: AccessibilityConfig.getSpacingSM() });

                Text(`提交日期: ${this.selectedApplication.submitDate}`)
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextPrimary());
                Text(`转院原因: ${this.selectedApplication.reason}`)
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(AccessibilityConfig.getTextPrimary());
                if (this.selectedApplication.customReason) {
                  Text(`详细说明: ${this.selectedApplication.customReason}`)
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextPrimary());
                }
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

              // 审核状态
              Column() {
                Text('审核状态')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontWeight('bold')
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .margin({ bottom: AccessibilityConfig.getSpacingSM() });

                Text(this.getStatusText(this.selectedApplication.status))
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontWeight('bold')
                  .fontColor(this.getStatusColor(this.selectedApplication.status));

                if (this.selectedApplication.reviewOpinion) {
                  Text(`审核意见: ${this.selectedApplication.reviewOpinion}`)
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextPrimary())
                    .margin({ top: AccessibilityConfig.getSpacingSM() });
                }
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(8)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() });
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

      Footer({ activeIndex: 4 })
    }
    .width('100%')
    .height('100%')
    .padding({ top: AccessibilityConfig.getSpacingLG(), bottom: AccessibilityConfig.getSpacingLG() })
    .backgroundColor(AccessibilityConfig.getBgColor());
  }
}
