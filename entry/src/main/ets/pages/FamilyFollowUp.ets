import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

interface FollowUpItem {
  id: number;
  type: string;
  title: string;
  hospitalName?: string;
  department?: string;
  doctorName?: string;
  followUpDate?: string;
  followUpTime?: string;
  status: 'UPCOMING' | 'COMPLETED' | 'CANCELLED' | 'OVERDUE';
  notes?: string;
}

@Entry
@Component
struct FamilyFollowUp {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State followUps: FollowUpItem[] = [];
  @State relatedUserId: number = 0;
  @State aiFollowUpAdvice: string = '';
  @State aiRehabilitationPlan: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    const familyInfo: Object | undefined = AppStorage.get('familyInfo');
    if (familyInfo) {
      const info: Record<string, Object> = familyInfo as Record<string, Object>;
      this.relatedUserId = info['userId'] as number || 0;
    }

    if (this.relatedUserId === 0) {
      ToastUtil.showError('未找到关联患者信息');
      return;
    }
    this.loadFollowUps();
  }

  private async loadFollowUps(): Promise<void> {
    this.isLoading = true;
    try {
      console.info('正在加载复诊信息，userId:', this.relatedUserId.toString());
      
      const response: BaseResponse<FollowUpItem[]> = await HttpUtil.get<FollowUpItem[]>('/medical/follow-up/list', {
        'userId': this.relatedUserId
      } as Record<string, number>);

      if (response.success && response.data) {
        console.info('成功获取到', response.data.length.toString(), '条复诊记录');
        this.followUps = response.data.map((item: FollowUpItem): FollowUpItem => ({
          id: item.id,
          type: item.type || 'FOLLOW_UP',
          title: item.title || '定期复查',
          hospitalName: item.hospitalName || '',
          department: item.department || '',
          doctorName: item.doctorName || '',
          followUpDate: item.followUpDate || '',
          followUpTime: item.followUpTime || '',
          status: item.status || 'UPCOMING',
          notes: item.notes || ''
        }));
        
        if (this.followUps.length === 0) {
          ToastUtil.showInfo('暂无复诊安排');
        }
      } else {
        console.error('获取复诊失败:', response.message);
        ToastUtil.showError(response.message || '获取复诊失败');
        this.followUps = [];
      }
    } catch (error) {
      console.error('加载复诊异常:', error);
      ToastUtil.showError('加载复诊失败，请检查网络连接');
      this.followUps = [];
    } finally {
      this.isLoading = false;
    }
  }

  private getStatusText(status: string): string {
    const map: Record<string, string> = {
      'UPCOMING': '待就诊',
      'COMPLETED': '已完成',
      'CANCELLED': '已取消',
      'OVERDUE': '已过期'
    };
    return map[status] || status;
  }

  private getStatusColor(status: string): string {
    const map: Record<string, string> = {
      'UPCOMING': '#F39C12',
      'COMPLETED': '#27AE60',
      'CANCELLED': '#95A5A6',
      'OVERDUE': '#E74C3C'
    };
    return map[status] || '#95A5A6';
  }

  private getTypeText(type: string): string {
    const map: Record<string, string> = {
      'FOLLOW_UP': '复诊',
      'CHECKUP': '检查',
      'EXAM': '体检',
      'SURGERY': '手术'
    };
    return map[type] || type;
  }

  private getTypeIcon(type: string): string {
    const map: Record<string, string> = {
      'FOLLOW_UP': '🏥',
      'CHECKUP': '🔬',
      'EXAM': '📋',
      'SURGERY': '⚕️'
    };
    return map[type] || '📅';
  }

  async getFollowUpAdvice(): Promise<void> {
    const upcomingFollowUps = this.followUps.filter(f => f.status === 'UPCOMING');
    if (upcomingFollowUps.length === 0) return;
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `即将到来的复诊：${upcomingFollowUps.map(f => `${f.title} - ${f.followUpDate}`).join('、')}，请给出随访准备建议`
        }
      });
      this.aiFollowUpAdvice = response.output.content as string;
    } catch (error) {
      console.error('[FamilyFollowUp] AI随访建议失败:', error);
      this.aiFollowUpAdvice = '';
    }
  }

  async generateRehabilitationPlan(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: '基于复诊记录生成康复训练计划'
        }
      });
      this.aiRehabilitationPlan = response.output.content as string;
    } catch (error) {
      console.error('[FamilyFollowUp] AI康复计划失败:', error);
      this.aiRehabilitationPlan = '';
    }
  }

  build() {
    Column() {
      Header({ title: '复诊安排', showBack: true })

      if (this.isLoading) {
        Loading()
      } else if (this.followUps.length === 0) {
        Column() {
          Text('🔔')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('暂无复诊安排')
            .fontSize(18)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text('患者当前没有待处理的复诊或检查')
            .fontSize(14)
            .fontColor('#BBBBBB')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            Text(`共 ${this.followUps.length} 条复诊安排`)
              .fontSize(14)
              .fontColor('#666666')
              .width('95%')
              .margin({ top: 8 })

            ForEach(this.followUps, (item: FollowUpItem) => {
              Column() {
                Row() {
                  Row() {
                    Text(this.getTypeIcon(item.type))
                      .fontSize(28)

                    Column({ space: 4 }) {
                      Text(item.title)
                        .fontSize(this.isElderMode ? 17 : 15)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333')

                      Row({ space: 8 }) {
                        Text(this.getTypeText(item.type))
                          .fontSize(12)
                          .fontColor('#FFFFFF')
                          .backgroundColor('#3498DB')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .borderRadius(4)

                        Text(this.getStatusText(item.status))
                          .fontSize(12)
                          .fontColor('#FFFFFF')
                          .backgroundColor(this.getStatusColor(item.status))
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .borderRadius(4)
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                  }

                  Blank()

                  Column({ space: 4 }) {
                    Text(item.followUpDate || '-')
                      .fontSize(this.isElderMode ? 18 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#F39C12')

                    if (item.followUpTime) {
                      Text(item.followUpTime)
                        .fontSize(13)
                        .fontColor('#666666')
                    }
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')

                Divider().color('#E0E0E0').margin({ top: 12, bottom: 12 })

                Column({ space: 8 }) {
                  if (item.hospitalName) {
                    Row() {
                      Text('🏥 医院:')
                        .fontSize(13)
                        .fontColor('#666666')
                        .width(70)
                      Text(item.hospitalName)
                        .fontSize(13)
                        .fontColor('#333333')
                        .layoutWeight(1)
                    }
                    .width('100%')
                  }

                  if (item.department) {
                    Row() {
                      Text('🔬 科室:')
                        .fontSize(13)
                        .fontColor('#666666')
                        .width(70)
                      Text(item.department)
                        .fontSize(13)
                        .fontColor('#333333')
                    }
                    .width('100%')
                  }

                  if (item.doctorName) {
                    Row() {
                      Text('👨‍⚕️ 医生:')
                        .fontSize(13)
                        .fontColor('#666666')
                        .width(70)
                      Text(item.doctorName)
                        .fontSize(13)
                        .fontColor('#333333')
                    }
                    .width('100%')
                  }

                  if (item.notes) {
                    Row() {
                      Text('📝 备注:')
                        .fontSize(13)
                        .fontColor('#666666')
                        .width(70)
                      Text(item.notes)
                        .fontSize(13)
                        .fontColor('#E74C3C')
                        .layoutWeight(1)
                    }
                    .width('100%')
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)

                if (item.status === 'UPCOMING') {
                  Button('设置提醒 >')
                    .width('100%')
                    .height(36)
                    .fontSize(14)
                    .fontColor('#F39C12')
                    .backgroundColor('#FEF9E7')
                    .borderRadius(8)
                    .margin({ top: 12 })
                    .onClick(() => {
                      ToastUtil.showInfo('已设置复诊提醒：' + item.title);
                    })
                }
              }
              .width('95%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
            })
          }
          .width('100%')
          .padding({ bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
