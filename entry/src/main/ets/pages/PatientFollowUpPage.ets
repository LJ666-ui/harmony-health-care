import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

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
  createdAt?: string;
}

@Entry
@Component
struct PatientFollowUpPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;
  @State isLoading: boolean = true;
  @State followUps: FollowUpItem[] = [];
  @State upcomingCount: number = 0;

  aboutToAppear(): void {
    if (this.currentUserId === 0) {
      const userIdStr: string | undefined = AppStorage.get('userId') as string | undefined;
      if (userIdStr) {
        this.currentUserId = parseInt(userIdStr, 10);
      }
    }
    if (this.currentUserId === 0) {
      ToastUtil.showError('请先登录');
      return;
    }
    this.loadFollowUps();
  }

  private async loadFollowUps(): Promise<void> {
    this.isLoading = true;
    try {
      console.info('正在加载复诊通知，当前用户ID:', this.currentUserId.toString());

      const response: BaseResponse<FollowUpItem[]> = await HttpUtil.get<FollowUpItem[]>('/medical/follow-up/list', {
        'userId': this.currentUserId
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
          notes: item.notes || '',
          createdAt: item.createdAt || ''
        }));

        this.upcomingCount = this.followUps.filter((item: FollowUpItem): boolean => item.status === 'UPCOMING').length;

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

  private getDaysUntil(dateStr: string): string {
    if (!dateStr) return '';
    const today: Date = new Date();
    const targetDate: Date = new Date(dateStr.replace(/-/g, '/'));
    const diffTime: number = targetDate.getTime() - today.getTime();
    const diffDays: number = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    if (diffDays < 0) {
      return `已过期 ${Math.abs(diffDays)} 天`;
    } else if (diffDays === 0) {
      return '今天';
    } else if (diffDays === 1) {
      return '明天';
    } else {
      return `${diffDays} 天后`;
    }
  }

  private isOverdue(item: FollowUpItem): boolean {
    if (!item.followUpDate || item.status !== 'UPCOMING') return false;
    const today: Date = new Date();
    const targetDate: Date = new Date(item.followUpDate.replace(/-/g, '/'));
    return targetDate < today;
  }

  build() {
    Column() {
      Header({ title: '复诊通知', showBack: true })

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
          Text('医生会为您安排复诊时间')
            .fontSize(14)
            .fontColor('#BBBBBB')
          Text('届时您将在此收到通知')
            .fontSize(14)
            .fontColor('#BBBBBB')
            .margin({ top: 4 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          Row() {
            Text(`共 ${this.followUps.length} 条通知`)
              .fontSize(14)
              .fontColor('#666666')

            Blank()

            if (this.upcomingCount > 0) {
              Text(`${this.upcomingCount} 条待处理`)
                .fontSize(13)
                .fontColor('#FFFFFF')
                .backgroundColor('#E74C3C')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(12)
            }
          }
          .width('95%')
          .padding({ top: 8, bottom: 8 })
        }
        .width('100%')

        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.followUps, (item: FollowUpItem) => {
              Column() {
                Row() {
                  Column({ space: 6 }) {
                    Text(this.getTypeIcon(item.type))
                      .fontSize(32)

                    if (item.status === 'UPCOMING') {
                      Text(this.getDaysUntil(item.followUpDate || ''))
                        .fontSize(11)
                        .fontColor(this.isOverdue(item) ? '#E74C3C' : '#27AE60')
                        .fontWeight(FontWeight.Bold)
                    }
                  }

                  Blank()

                  Column() {
                    Row() {
                      Text(item.title)
                        .fontSize(this.isElderMode ? 17 : 15)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333')

                      Blank()

                      Text(this.getStatusText(item.status))
                        .fontSize(11)
                        .fontColor('#FFFFFF')
                        .backgroundColor(this.getStatusColor(item.status))
                        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                        .borderRadius(10)
                    }
                    .width('100%')

                    Row({ space: 8 }) {
                      Text(this.getTypeText(item.type))
                        .fontSize(11)
                        .fontColor('#1677FF')
                        .backgroundColor('#E8F4FD')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(4)

                      if (item.doctorName) {
                        Text(`👨‍⚕️ ${item.doctorName}`)
                          .fontSize(11)
                          .fontColor('#666666')
                      }
                    }
                    .width('100%')
                    .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                }
                .width('100%')

                Divider().color('#E0E0E0').margin({ top: 12, bottom: 12 })

                Column({ space: 8 }) {
                  Row() {
                    Text('📅 时间:')
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(70)
                    Text(`${item.followUpDate || '-'} ${item.followUpTime || ''}`)
                      .fontSize(13)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')

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
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width('100%')
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)

                if (item.status === 'UPCOMING') {
                  Row({ space: 12 }) {
                    Button('确认收到')
                      .height(34)
                      .fontSize(13)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#27AE60')
                      .borderRadius(8)
                      .layoutWeight(1)
                      .onClick(() => {
                        ToastUtil.showInfo('已确认收到复诊通知');
                      })

                    Button('添加日历')
                      .height(34)
                      .fontSize(13)
                      .fontColor('#1677FF')
                      .backgroundColor('#E8F4FD')
                      .borderRadius(8)
                      .layoutWeight(1)
                      .onClick(() => {
                        ToastUtil.showInfo('已添加到日历提醒');
                      })
                  }
                  .width('100%')
                  .margin({ top: 12 })
                }
              }
              .width('95%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
              .border({
                width: this.isOverdue(item) ? 2 : 0,
                color: '#E74C3C'
              })
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
