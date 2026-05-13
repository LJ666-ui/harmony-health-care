import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

interface Prescription {
  id: number;
  patientId: number;
  patientName?: string;
  doctorId?: number;
  doctorName?: string;
  diagnosis?: string;
  medications?: string;
  notes?: string;
  status?: string;
  createdAt?: string;
  validUntil?: string;
}

interface Medication {
  medicineName: string;
  specification?: string;
  dosage?: string;
  frequency?: string;
  quantity?: number;
  unit?: string;
}

@Entry
@Component
struct FamilyPrescription {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State prescriptions: Prescription[] = [];
  @State selectedPrescription: Prescription | null = null;
  @State relatedUserId: number = 0;
  @State aiMedicationGuidance: string = '';
  @State aiDrugInteractionCheck: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    const familyInfo: Object | undefined = AppStorage.get('familyInfo');
    if (familyInfo) {
      const info: Record<string, Object> = familyInfo as Record<string, Object>;
      this.relatedUserId = info['userId'] as number || 0;
    }

    if (this.relatedUserId === 0) {
      ToastUtil.showError('未找到关联患者信息');
      this.isLoading = false;
      return;
    }
    this.loadPrescriptions();
  }

  private async loadPrescriptions(): Promise<void> {
    this.isLoading = true;
    try {
      console.info('正在加载患者处方，userId:', this.relatedUserId.toString());

      const response: BaseResponse<Prescription[]> = await HttpUtil.get<Prescription[]>(
        `/medical/prescriptions/patient/${this.relatedUserId}`
      );

      if (response.success && response.data) {
        console.info('成功获取到', response.data.length.toString(), '条处方记录');
        this.prescriptions = response.data;

        if (this.prescriptions.length === 0) {
          ToastUtil.showInfo('暂无处方记录');
        }
      } else {
        console.error('获取处方失败:', response.message);
        ToastUtil.showError(response.message || '获取处方失败');
        this.prescriptions = [];
      }
    } catch (error) {
      console.error('加载处方异常:', error);
      ToastUtil.showError('加载处方失败，请检查网络连接');
      this.prescriptions = [];
    } finally {
      this.isLoading = false;
    }
  }

  private parseMedications(medicationsStr?: string): Medication[] {
    if (!medicationsStr) return [];
    try {
      return JSON.parse(medicationsStr) as Medication[];
    } catch (e) {
      return [];
    }
  }

  private formatDate(dateStr?: string): string {
    if (!dateStr) return '-';
    try {
      return dateStr.substring(0, 10);
    } catch (e) {
      return '-';
    }
  }

  private getStatusText(status?: string): string {
    const statusMap: Record<string, string> = {
      'ACTIVE': '有效',
      'COMPLETED': '已完成',
      'CANCELLED': '已取消'
    };
    return statusMap[status || ''] || status || '未知';
  }

  private getStatusColor(status?: string): string {
    const colorMap: Record<string, string> = {
      'ACTIVE': '#27AE60',
      'COMPLETED': '#3498DB',
      'CANCELLED': '#95A5A6'
    };
    return colorMap[status || ''] || '#95A5A6';
  }

  async getMedicationGuidance(): Promise<void> {
    if (!this.selectedPrescription) return;
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `处方信息：${this.selectedPrescription.medications}，诊断：${this.selectedPrescription.diagnosis}，请给出用药指导`
        }
      });
      this.aiMedicationGuidance = response.output.content as string;
    } catch (error) {
      console.error('[FamilyPrescription] AI用药指导失败:', error);
      this.aiMedicationGuidance = '';
    }
  }

  async checkDrugInteraction(): Promise<void> {
    if (!this.selectedPrescription) return;
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `药物列表：${this.selectedPrescription.medications}，请检查药物相互作用和注意事项`
        }
      });
      this.aiDrugInteractionCheck = response.output.content as string;
    } catch (error) {
      console.error('[FamilyPrescription] AI药物相互作用检查失败:', error);
      this.aiDrugInteractionCheck = '';
    }
  }

  build() {
    Column() {
      Header({ title: '处方记录', showBack: true })

      if (this.isLoading) {
        Loading()
      } else if (this.selectedPrescription !== null) {
        // 处方详情页
        this.buildPrescriptionDetail()
      } else if (this.prescriptions.length === 0) {
        // 空状态
        Column() {
          Text('💊')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('暂无处方记录')
            .fontSize(18)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text('患者当前没有处方')
            .fontSize(14)
            .fontColor('#BBBBBB')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 处方列表
        List({ space: 12 }) {
          ForEach(this.prescriptions, (prescription: Prescription) => {
            ListItem() {
              Column() {
                // 头部信息
                Row() {
                  Text(`处方 #${prescription.id}`)
                    .fontSize(this.isElderMode ? 18 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1677FF')

                  Blank()

                  Text(this.getStatusText(prescription.status))
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .backgroundColor(this.getStatusColor(prescription.status))
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(4)
                }
                .width('100%')

                Divider().color('#E0E0E0').margin({ top: 8, bottom: 8 })

                // 基本信息
                Column({ space: 8 }) {
                  Row() {
                    Text('📅 开具日期:')
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(80)
                    Text(this.formatDate(prescription.createdAt))
                      .fontSize(13)
                      .fontColor('#333333')
                  }
                  .width('100%')

                  Row() {
                    Text('👨‍⚕️ 开方医生:')
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(80)
                    Text(prescription.doctorName || '未知')
                      .fontSize(13)
                      .fontColor('#333333')
                  }
                  .width('100%')

                  Row() {
                    Text('🏥 诊断:')
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(80)
                    Text(prescription.diagnosis || '待诊断')
                      .fontSize(13)
                      .fontColor('#333333')
                      .layoutWeight(1)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')

                  // 药品数量
                  Row() {
                    Text('💊 药品数量:')
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(80)
                    Text(`${this.parseMedications(prescription.medications).length} 种`)
                      .fontSize(13)
                      .fontColor('#E74C3C')
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)

                // 查看详情按钮
                Button('查看详情 >')
                  .width('100%')
                  .height(36)
                  .fontSize(14)
                  .fontColor('#1677FF')
                  .backgroundColor('#E8F4FD')
                  .borderRadius(8)
                  .margin({ top: 12 })
                  .onClick(() => {
                    this.selectedPrescription = prescription;
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
            }
          })
        }
        .width('95%')
        .layoutWeight(1)
        .padding({ top: 12, bottom: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 处方详情
  @Builder
  buildPrescriptionDetail() {
    Scroll() {
      Column({ space: 16 }) {
        // 返回按钮
        Row() {
          Button('< 返回列表')
            .height(36)
            .fontSize(14)
            .fontColor('#1677FF')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.selectedPrescription = null;
            })
        }
        .width('100%')

        // 基本信息
        Column() {
          Text('基本信息')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .margin({ bottom: 12 })

          Column({ space: 8 }) {
            this.DetailRow('处方ID', `${this.selectedPrescription?.id || 0}`)
            this.DetailRow('患者姓名', this.selectedPrescription?.patientName || '未知')
            this.DetailRow('开方医生', this.selectedPrescription?.doctorName || '未知')
            this.DetailRow('开具日期', this.formatDate(this.selectedPrescription?.createdAt))
            this.DetailRow('有效期至', this.formatDate(this.selectedPrescription?.validUntil))
            this.DetailRow('状态', this.getStatusText(this.selectedPrescription?.status))
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        // 诊断信息
        Column() {
          Text('诊断信息')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .margin({ bottom: 12 })

          Text(this.selectedPrescription?.diagnosis || '无诊断信息')
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .lineHeight(22)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        // 药品清单
        Column() {
          Text('💊 药品清单')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .margin({ bottom: 12 })

          Column({ space: 12 }) {
            ForEach(this.parseMedications(this.selectedPrescription?.medications), (med: Medication, index: number) => {
              Column() {
                Text(`药品 ${index + 1}: ${med.medicineName}`)
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1677FF')
                  .width('100%')

                Column({ space: 6 }) {
                  if (med.specification) {
                    Row() {
                      Text('规格:')
                        .fontSize(13)
                        .fontColor('#666666')
                        .width(60)
                      Text(med.specification)
                        .fontSize(13)
                        .fontColor('#333333')
                    }
                    .width('100%')
                  }

                  Row() {
                    Text('用法用量:')
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(60)
                    Text(`${med.dosage || ''} ${med.frequency || ''}`)
                      .fontSize(13)
                      .fontColor('#333333')
                  }
                  .width('100%')

                  Row() {
                    Text('数量:')
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(60)
                    Text(`${med.quantity || 0} ${med.unit || '盒'}`)
                      .fontSize(13)
                      .fontColor('#333333')
                  }
                  .width('100%')
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F8F9FA')
              .borderRadius(8)
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        // 备注
        if (this.selectedPrescription?.notes) {
          Column() {
            Text('备注说明')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .width('100%')
              .margin({ bottom: 12 })

            Text(this.selectedPrescription.notes)
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .width('100%')
              .lineHeight(22)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFBE6')
          .borderRadius(12)
          .border({ width: 1, color: '#FFE58F' })
        }
      }
      .width('95%')
      .padding({ top: 16, bottom: 32 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder
  DetailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(80)

      Text(value)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
  }
}
