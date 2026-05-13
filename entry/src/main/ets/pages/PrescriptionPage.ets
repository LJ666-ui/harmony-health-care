import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { ConsultationService, Prescription } from '../services/ConsultationService';
import { ToastUtil } from '../common/utils/ToastUtil';
import { getMockPrescriptionById } from '../mock/prescriptionMock';

interface PrescriptionItem {
  name: string;
  dosage: string;
  quantity: string;
  unit: string;
}

interface RouterParams {
  prescriptionId: number;
}

@Entry
@Component
struct PrescriptionPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State prescription: Prescription | null = null;
  @State isLoading: boolean = true;
  @State prescriptionItems: PrescriptionItem[] = [];
  
  private consultationService: ConsultationService = ConsultationService.getInstance();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    
    const params = router.getParams() as RouterParams;
    if (params && params.prescriptionId) {
      this.loadPrescription(params.prescriptionId);
    } else {
      ToastUtil.showError('处方ID缺失');
      router.back();
    }
  }

  async loadPrescription(prescriptionId: number): Promise<void> {
    this.isLoading = true;
    try {
      const data = await this.consultationService.getPrescription(prescriptionId);
      if (data) {
        this.prescription = data;
        this.parsePrescriptionContent(data.prescriptionContent);
      } else {
        console.log('[PrescriptionPage] API返回空数据，使用Mock数据');
        const mockData = getMockPrescriptionById(prescriptionId);
        if (mockData) {
          this.prescription = mockData;
          this.parsePrescriptionContent(mockData.prescriptionContent);
        } else {
          ToastUtil.showError('处方不存在');
        }
      }
    } catch (error) {
      console.error('[PrescriptionPage] 加载处方异常，使用Mock数据:', error);
      const mockData = getMockPrescriptionById(prescriptionId);
      if (mockData) {
        this.prescription = mockData;
        this.parsePrescriptionContent(mockData.prescriptionContent);
      } else {
        ToastUtil.showError('加载处方失败');
      }
    } finally {
      this.isLoading = false;
    }
  }

  parsePrescriptionContent(content: string): void {
    try {
      this.prescriptionItems = JSON.parse(content);
    } catch (error) {
      console.error('[PrescriptionPage] 解析处方内容失败:', error);
      this.prescriptionItems = [];
    }
  }

  private getTitleFontSize(): number {
    return this.isElderMode ? 18 : 16;
  }

  private getBodyFontSize(): number {
    return this.isElderMode ? 14 : 12;
  }

  build() {
    Column() {
      Header({ title: '处方详情', showBack: true });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#3498DB')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.prescription) {
        Scroll() {
          Column({ space: 15 }) {
            this.buildBasicInfo();
            this.buildDiagnosis();
            this.buildPrescriptionItems();
            this.buildUsageInstruction();
            this.buildValidityInfo();
          }
          .width('100%')
          .padding(15);
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto);
      } else {
        Column() {
          Text('📋')
            .fontSize(60)
          Text('处方信息加载失败')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 10 })
          Text('请返回重试')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 5 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      }
    }
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder buildBasicInfo(): void {
    Column({ space: 10 }) {
      Text('处方信息')
        .fontSize(this.getTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%');

      Row() {
        Text('处方编号：')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666');
        Text(this.prescription!.prescriptionNo)
          .fontSize(this.getBodyFontSize())
          .fontColor('#333')
          .layoutWeight(1);
      }
      .width('100%');

      Row() {
        Text('开具时间：')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666');
        Text(this.prescription!.createTime)
          .fontSize(this.getBodyFontSize())
          .fontColor('#333')
          .layoutWeight(1);
      }
      .width('100%');

      Row() {
        Text('处方状态：')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666');
        Text(this.getStatusText(this.prescription!.status))
          .fontSize(this.getBodyFontSize())
          .fontColor(this.getStatusColor(this.prescription!.status))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1);
      }
      .width('100%');
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  @Builder buildDiagnosis(): void {
    Column({ space: 10 }) {
      Text('诊断结果')
        .fontSize(this.getTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%');

      Text(this.prescription!.diagnosis || '暂无诊断信息')
        .fontSize(this.getBodyFontSize())
        .fontColor('#333')
        .width('100%')
        .lineHeight(20);
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  @Builder buildPrescriptionItems(): void {
    Column({ space: 10 }) {
      Text('处方药品')
        .fontSize(this.getTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%');

      if (this.prescriptionItems.length > 0) {
        ForEach(this.prescriptionItems, (item: PrescriptionItem, index: number) => {
          Row() {
            Column() {
              Text(`${index + 1}. ${item.name}`)
                .fontSize(this.getBodyFontSize())
                .fontColor('#333')
                .fontWeight(FontWeight.Medium)
                .width('100%');

              Row() {
                Text(`剂量：${item.dosage}`)
                  .fontSize(this.isElderMode ? 12 : 10)
                  .fontColor('#666');

                Text(`  数量：${item.quantity}${item.unit}`)
                  .fontSize(this.isElderMode ? 12 : 10)
                  .fontColor('#666');
              }
              .width('100%')
              .margin({ top: 4 });
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1);
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 });
        });
      } else {
        Text('暂无药品信息')
          .fontSize(this.getBodyFontSize())
          .fontColor('#999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 });
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  @Builder buildUsageInstruction(): void {
    Column({ space: 10 }) {
      Text('用法说明')
        .fontSize(this.getTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%');

      Text(this.prescription!.usageInstruction || '请遵医嘱用药')
        .fontSize(this.getBodyFontSize())
        .fontColor('#333')
        .width('100%')
        .lineHeight(20);
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  @Builder buildValidityInfo(): void {
    Column({ space: 10 }) {
      Row() {
        Text('有效期：')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666');
        Text(`${this.prescription!.validDays}天`)
          .fontSize(this.getBodyFontSize())
          .fontColor('#E74C3C')
          .fontWeight(FontWeight.Bold);
      }
      .width('100%');

      if (this.prescription!.status === 'expired') {
        Row() {
          Text('⚠️ 处方已过期，请重新就诊开具处方')
            .fontSize(this.getBodyFontSize())
            .fontColor('#E74C3C');
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#FFF3E0')
        .borderRadius(6);
      } else if (this.prescription!.status === 'active') {
        Row() {
          Text('✓ 处方有效，可凭此处方购药')
            .fontSize(this.getBodyFontSize())
            .fontColor('#27AE60');
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#E8F5E9')
        .borderRadius(6);
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'active':
        return '有效';
      case 'expired':
        return '已过期';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'active':
        return '#27AE60';
      case 'expired':
        return '#E74C3C';
      case 'cancelled':
        return '#999';
      default:
        return '#666';
    }
  }
}
