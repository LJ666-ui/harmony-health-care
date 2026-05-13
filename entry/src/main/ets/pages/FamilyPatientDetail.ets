import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface PatientInfo {
  id: number;
  username: string;
  realName?: string;
  phone?: string;
  email?: string;
  age?: number;
  gender?: number;
  idCard?: string;
  address?: string;
  emergencyContact?: string;
  emergencyPhone?: string;
  medicalHistory?: string;
  allergyHistory?: string;
  familyHistory?: string;
}

interface HealthCondition {
  id: number;
  userId: number;
  height?: number;
  weight?: number;
  bloodType?: string;
  chronicDisease?: string;
  currentMedication?: string;
  lifestyle?: string;
  updateTime?: string;
}

interface BodyCondition {
  id: number;
  userId: number;
  bloodPressure?: string;
  bloodSugar?: string;
  heartRate?: number;
  bodyTemperature?: number;
  bmi?: number;
  vision?: string;
  hearing?: string;
  recordTime?: string;
}

@Entry
@Component
struct FamilyPatientDetail {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State patientInfo: PatientInfo | null = null;
  @State healthCondition: HealthCondition | null = null;
  @State bodyCondition: BodyCondition | null = null;
  @State relatedUserId: number = 0;

  async aboutToAppear(): Promise<void> {
    // 从路由参数或AppStorage获取患者ID
    const params = router.getParams() as Record<string, Object>;
    if (params && params['userId']) {
      this.relatedUserId = params['userId'] as number;
    } else {
      const familyInfo: Object | undefined = AppStorage.get('familyInfo');
      if (familyInfo) {
        const info: Record<string, Object> = familyInfo as Record<string, Object>;
        this.relatedUserId = info['userId'] as number || 0;
      }
    }

    if (this.relatedUserId === 0) {
      ToastUtil.showError('未找到关联患者信息');
      this.isLoading = false;
      return;
    }

    await this.loadPatientData();
  }

  private async loadPatientData(): Promise<void> {
    this.isLoading = true;
    try {
      // 使用正确的API格式：/user/info?id=xxx（不是 /user/xxx）
      const [patientRes] = await Promise.all([
        HttpUtil.get<PatientInfo>('/user/info', { 'id': this.relatedUserId.toString() })
      ]);

      // 处理患者基本信息
      if (patientRes.success && patientRes.data) {
        this.patientInfo = patientRes.data;
        console.log('[FamilyPatientDetail] 患者信息加载成功:', JSON.stringify(patientRes.data));
      } else {
        console.error('[FamilyPatientDetail] 加载患者信息失败:', patientRes.message);
      }

      // 注意：健康情况和身体情况接口可能不存在，暂时跳过避免报错
      // 如果需要这些数据，需要在后端添加对应接口

    } catch (error) {
      console.error('[FamilyPatientDetail] 加载患者信息失败:', error);
      ToastUtil.showError('加载患者信息失败');
    } finally {
      this.isLoading = false;
    }
  }

  private getGenderText(gender?: number): string {
    if (gender === 1) return '男';
    if (gender === 2) return '女';
    return '未设置';
  }

  private getBloodTypeText(bloodType?: string): string {
    if (!bloodType) return '未设置';
    const typeMap: Record<string, string> = {
      'A': 'A型',
      'B': 'B型',
      'AB': 'AB型',
      'O': 'O型',
      'A_TYPE': 'A型',
      'B_TYPE': 'B型',
      'AB_TYPE': 'AB型',
      'O_TYPE': 'O型'
    };
    return typeMap[bloodType] || bloodType;
  }

  build() {
    Column() {
      Header({ title: '患者详情', showBack: true })

      if (this.isLoading) {
        Loading()
      } else if (!this.patientInfo) {
        Column() {
          Text('👤')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('未找到患者信息')
            .fontSize(18)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 患者基本信息卡片
            this.buildBasicInfoCard()

            // 身体情况卡片
            this.buildBodyConditionCard()

            // 健康情况卡片
            this.buildHealthConditionCard()

            // 快捷操作按钮
            this.buildQuickActions()
          }
          .width('95%')
          .padding({ top: 16, bottom: 32 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 基本信息卡片
  @Builder
  buildBasicInfoCard() {
    Column() {
      Row() {
        Image($r('app.media.startIcon'))
          .width(60)
          .height(60)
          .borderRadius(30)
          .margin({ right: 16 })

        Column() {
          Text(this.patientInfo?.realName || this.patientInfo?.username || '患者')
            .fontSize(this.isElderMode ? 22 : 20)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)

          Text(`ID: ${this.patientInfo?.id || 0}`)
            .fontSize(12)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(16)

      Divider().color('#E0E0E0')

      Column({ space: 12 }) {
        this.InfoRow('📱 手机号', this.patientInfo?.phone || '未设置')
        this.InfoRow('📧 邮箱', this.patientInfo?.email || '未设置')
        this.InfoRow('🎂 年龄', this.patientInfo?.age ? `${this.patientInfo.age}岁` : '未设置')
        this.InfoRow('👤 性别', this.getGenderText(this.patientInfo?.gender))
        this.InfoRow('🆔 身份证', this.patientInfo?.idCard || '未设置')
        this.InfoRow('📍 地址', this.patientInfo?.address || '未设置')
        this.InfoRow('📞 紧急联系人', this.patientInfo?.emergencyContact || '未设置')
        this.InfoRow('📱 紧急联系电话', this.patientInfo?.emergencyPhone || '未设置')
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
  }

  // 身体情况卡片
  @Builder
  buildBodyConditionCard() {
    Column() {
      Row() {
        Text('💪 身体情况')
          .fontSize(this.isElderMode ? 18 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.TEXT_PRIMARY)

        Blank()

        if (this.bodyCondition?.recordTime) {
          Text(`更新于 ${this.bodyCondition.recordTime.substring(0, 10)}`)
            .fontSize(12)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
        }
      }
      .width('100%')
      .padding(16)

      Divider().color('#E0E0E0')

      if (this.bodyCondition) {
        Column({ space: 12 }) {
          Row() {
            this.BodyItem('📏 身高', this.healthCondition?.height ? `${this.healthCondition.height} cm` : '未设置')
            this.BodyItem('⚖️ 体重', this.healthCondition?.weight ? `${this.healthCondition.weight} kg` : '未设置')
          }
          Row() {
            this.BodyItem('💓 血压', this.bodyCondition.bloodPressure || '未设置')
            this.BodyItem('🍬 血糖', this.bodyCondition.bloodSugar || '未设置')
          }
          Row() {
            this.BodyItem('❤️ 心率', this.bodyCondition.heartRate ? `${this.bodyCondition.heartRate} bpm` : '未设置')
            this.BodyItem('🌡️ 体温', this.bodyCondition.bodyTemperature ? `${this.bodyCondition.bodyTemperature} ℃` : '未设置')
          }
          Row() {
            this.BodyItem('📊 BMI', this.bodyCondition.bmi ? `${this.bodyCondition.bmi}` : '未设置')
            this.BodyItem('🩸 血型', this.getBloodTypeText(this.healthCondition?.bloodType))
          }
          Row() {
            this.BodyItem('👁️ 视力', this.bodyCondition.vision || '未设置')
            this.BodyItem('👂 听力', this.bodyCondition.hearing || '未设置')
          }
        }
        .width('100%')
        .padding(16)
      } else {
        Column() {
          Text('暂无身体情况数据')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16, bottom: 16 })
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
    .margin({ top: 16 })
  }

  // 健康情况卡片
  @Builder
  buildHealthConditionCard() {
    Column() {
      Row() {
        Text('🏥 健康情况')
          .fontSize(this.isElderMode ? 18 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.TEXT_PRIMARY)

        Blank()

        if (this.healthCondition?.updateTime) {
          Text(`更新于 ${this.healthCondition.updateTime.substring(0, 10)}`)
            .fontSize(12)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
        }
      }
      .width('100%')
      .padding(16)

      Divider().color('#E0E0E0')

      if (this.healthCondition) {
        Column({ space: 12 }) {
          if (this.healthCondition.chronicDisease) {
            this.HealthItem('💊 慢性疾病', this.healthCondition.chronicDisease)
          }
          if (this.healthCondition.currentMedication) {
            this.HealthItem('💉 当前用药', this.healthCondition.currentMedication)
          }
          if (this.healthCondition.lifestyle) {
            this.HealthItem('🏃 生活习惯', this.healthCondition.lifestyle)
          }
          if (this.patientInfo?.medicalHistory) {
            this.HealthItem('📋 病史', this.patientInfo.medicalHistory)
          }
          if (this.patientInfo?.allergyHistory) {
            this.HealthItem('⚠️ 过敏史', this.patientInfo.allergyHistory)
          }
          if (this.patientInfo?.familyHistory) {
            this.HealthItem('👨‍👩‍👧 家族病史', this.patientInfo.familyHistory)
          }
        }
        .width('100%')
        .padding(16)
      } else {
        Column() {
          Text('暂无健康情况数据')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16, bottom: 16 })
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
    .margin({ top: 16 })
  }

  // 快捷操作
  @Builder
  buildQuickActions() {
    Column() {
      Text('快捷操作')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: 12 })

      Row({ space: 12 }) {
        Button('📋 健康记录')
          .layoutWeight(1)
          .height(50)
          .fontSize(14)
          .backgroundColor('#3498DB')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/FamilyHealthRecords' });
          })

        Button('🏥 就诊记录')
          .layoutWeight(1)
          .height(50)
          .fontSize(14)
          .backgroundColor('#27AE60')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/FamilyMedicalRecords' });
          })
      }
      .width('100%')

      Row({ space: 12 }) {
        Button('💊 用药管理')
          .layoutWeight(1)
          .height(50)
          .fontSize(14)
          .backgroundColor('#E67E22')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/FamilyMedication' });
          })

        Button('💬 在线咨询')
          .layoutWeight(1)
          .height(50)
          .fontSize(14)
          .backgroundColor('#9B59B6')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/FamilyChatListPage' });
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
    .margin({ top: 16 })
  }

  // 信息行组件
  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width(100)

      Text(value)
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .layoutWeight(1)
    }
    .width('100%')
  }

  // 身体指标项
  @Builder
  BodyItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor(GlobalTheme.TEXT_SECONDARY)

      Text(value)
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#3498DB')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding(8)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
  }

  // 健康信息项
  @Builder
  HealthItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 4 })

      Text(value)
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%')
        .lineHeight(20)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
  }
}
