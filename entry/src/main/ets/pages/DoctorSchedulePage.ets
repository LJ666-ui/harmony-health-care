import { router } from '@kit.ArkUI';
import { HttpUtil, RequestOptions } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import promptAction from '@ohos.promptAction';

interface ScheduleItem {
  id: number;
  doctorId: number;
  scheduleDate: string;
  schedulePeriod: number;
  maxCount: number;
  currentCount: number;
  status: number;
  createTime: string;
  updateTime: string;
}

interface ScheduleData {
  doctorId: number;
  scheduleDate: string;
  schedulePeriod: number;
  maxCount: number;
}

@Entry
@Component
struct DoctorSchedulePage {
  @StorageLink('userId') currentUserId: number = 0;
  @State schedules: ScheduleItem[] = [];
  @State isLoading: boolean = false;
  @State showCreateDialog: boolean = false;

  private newScheduleDate: string = '';
  private newSchedulePeriod: number = 1;
  private newMaxCount: number = 20;

  aboutToAppear(): void {
    this.loadSchedules();
  }

  private loadSchedules(): void {
    this.isLoading = true;
    
    const requestOptions: RequestOptions = {} as RequestOptions;
    const params: Record<string, Object> = {} as Record<string, Object>;
    
    HttpUtil.get<Record<string, Object>>(`${ApiConstants.SCHEDULE_LIST}?doctorId=${this.currentUserId}`, params, requestOptions)
      .then((response: object) => {
        const res = response as Record<string, Object>;
        if (res['code'] === 200 && res['data']) {
          this.schedules = (res['data'] as ScheduleItem[]) || [];
        } else {
          promptAction.showToast({ message: '获取排班数据失败' });
        }
      })
      .catch((error: Error) => {
        console.error('[DoctorSchedulePage] 加载失败:', error.message);
        promptAction.showToast({ message: '网络错误：' + error.message });
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  private deleteSchedule(id: number): void {
    promptAction.showDialog({
      title: '确认删除',
      message: '确定要删除这条排班记录吗？',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '删除', color: '#FF3B30' }
      ]
    }, (err, result) => {
      if (!err && result && result.index === 1) {
        const requestOptions: RequestOptions = {} as RequestOptions;
        
        HttpUtil.delete<void>(`${ApiConstants.SCHEDULE_LIST}/${id}`, requestOptions)
          .then(() => {
            promptAction.showToast({ message: '删除成功' });
            this.loadSchedules();
          })
          .catch((error: Error) => {
            promptAction.showToast({ message: '删除失败：' + error.message });
          });
      }
    });
  }

  build() {
    Column() {
      Row() {
        Text('我的排班')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333');

        Blank();

        Button('添加排班')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            this.showCreateDialog = true;
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF');

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.schedules.length === 0) {
        Column() {
          Text('📅')
            .fontSize(56)
            .margin({ bottom: 16 });
          Text('暂无排班记录')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 8 });
          Text('点击上方按钮添加您的排班信息')
            .fontSize(13)
            .fontColor('#999999');
          
          Button('添加第一个排班')
            .fontSize(14)
            .fontColor('#1677FF')
            .backgroundColor('#E6F4FF')
            .borderRadius(20)
            .margin({ top: 24 })
            .onClick(() => {
              this.showCreateDialog = true;
            });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.schedules, (item: ScheduleItem, index: number) => {
              this.buildScheduleCard(item);
            }, (item: ScheduleItem) => item.id.toString());
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 40 });
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .bindSheet($$this.showCreateDialog, this.buildCreateScheduleSheet(), {
      height: 450,
      backgroundColor: Color.White,
      dragBar: true
    });
  }

  @Builder
  buildScheduleCard(item: ScheduleItem) {
    Column() {
      Row() {
        Column() {
          Text(this.formatDate(item.scheduleDate))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');
          
          Text(this.formatDateTime(item.createTime))
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 });
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Text(this.getPeriodText(item.schedulePeriod))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1677FF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#E6F4FF')
          .borderRadius(12);
      }
      .width('100%')
      .margin({ bottom: 12 });

      Row({ space: 24 }) {
        this.buildStatItem('最大号源', item.maxCount.toString(), '#666666');
        this.buildStatItem('已预约', item.currentCount.toString(), 
          item.currentCount >= item.maxCount ? '#FF3B30' : '#52C41A');
        this.buildStatItem('剩余', Math.max(0, item.maxCount - item.currentCount).toString(), '#1677FF');
      }
      .width('100%')
      .margin({ bottom: 12 });

      Row() {
        Text(item.status === 1 ? '✅ 正常' : '❌ 已停诊')
          .fontSize(13)
          .fontColor(item.status === 1 ? '#52C41A' : '#FF3B30');

        Blank();

        Button('编辑')
          .fontSize(13)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(16)
          .height(32)
          .onClick(() => {
            promptAction.showToast({ message: '编辑功能开发中' });
          });

        Button('删除')
          .fontSize(13)
          .fontColor('#FF3B30')
          .backgroundColor('#FFF1F0')
          .borderRadius(16)
          .height(32)
          .margin({ left: 12 })
          .onClick(() => {
            this.deleteSchedule(item.id);
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildStatItem(label: string, value: string, color: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color);
      
      Text(label)
        .fontSize(12)
        .fontColor('#999999');
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  buildCreateScheduleSheet() {
    Column({ space: 20 }) {
      Text('添加排班')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333');

      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text('排班日期')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%');

          TextInput({ placeholder: '请选择日期（格式：2024-01-15）', text: this.newScheduleDate })
            .width('100%')
            .height(44)
            .fontSize(14)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.newScheduleDate = value;
            });
        }

        Column({ space: 8 }) {
          Text('时间段')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%');

          Row({ space: 12 }) {
            this.buildPeriodOption(1, '上午');
            this.buildPeriodOption(2, '下午');
            this.buildPeriodOption(3, '晚上');
          }
          .width('100%');
        }

        Column({ space: 8 }) {
          Text('最大号源数')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%');

          TextInput({ placeholder: '请输入最大预约数', text: this.newMaxCount.toString() })
            .width('100%')
            .height(44)
            .fontSize(14)
            .type(InputType.Number)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.newMaxCount = parseInt(value) || 0;
            });
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20 });

      Row({ space: 12 }) {
        Button('取消')
          .fontSize(15)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .layoutWeight(1)
          .height(44)
          .borderRadius(8)
          .onClick(() => {
            this.showCreateDialog = false;
          });

        Button('确认添加')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .layoutWeight(1)
          .height(44)
          .borderRadius(8)
          .onClick(() => {
            this.createSchedule();
          });
      }
      .width('100%')
      .padding({ left: 20, right: 20 });
    }
    .width('100%')
    .padding({ top: 24, bottom: 24 });
  }

  @Builder
  buildPeriodOption(period: number, label: string) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor(this.newSchedulePeriod === period ? '#FFFFFF' : '#666666');
    }
    .width('calc(33.33% - 8px)')
    .height(40)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.newSchedulePeriod === period ? '#1677FF' : '#F5F5F5')
    .borderRadius(8)
    .onClick(() => {
      this.newSchedulePeriod = period;
    });
  }

  private createSchedule(): void {
    if (!this.newScheduleDate || !this.validateDateFormat(this.newScheduleDate)) {
      promptAction.showToast({ message: '请输入正确的日期格式（YYYY-MM-DD）' });
      return;
    }

    if (this.newMaxCount <= 0) {
      promptAction.showToast({ message: '请输入有效的号源数' });
      return;
    }

    const requestOptions: RequestOptions = {} as RequestOptions;

    const scheduleData: ScheduleData = {
      doctorId: this.currentUserId,
      scheduleDate: this.newScheduleDate,
      schedulePeriod: this.newSchedulePeriod,
      maxCount: this.newMaxCount
    };

    HttpUtil.post<ScheduleData>(ApiConstants.SCHEDULE_ADD, scheduleData, requestOptions)
      .then((response: object) => {
        const res = response as Record<string, Object>;
        if (res['code'] === 200) {
          promptAction.showToast({ message: '添加成功' });
          this.showCreateDialog = false;
          this.loadSchemas();
          this.resetForm();
        } else {
          promptAction.showToast({ message: (res['message'] as string) || '添加失败' });
        }
      })
      .catch((error: Error) => {
        promptAction.showToast({ message: '网络错误：' + error.message });
      });
  }

  private loadSchemas(): void {
    this.loadSchedules();
  }

  private resetForm(): void {
    this.newScheduleDate = '';
    this.newSchedulePeriod = 1;
    this.newMaxCount = 20;
  }

  private validateDateFormat(dateStr: string): boolean {
    const regex = /^\d{4}-\d{2}-\d{2}$/;
    return regex.test(dateStr);
  }

  private formatDate(dateStr: string): string {
    if (!dateStr) return '';
    
    try {
      const date = new Date(dateStr);
      if (isNaN(date.getTime())) return dateStr;
      
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      
      return `${year}年${month}月${day}日`;
    } catch (e) {
      return dateStr;
    }
  }

  private formatDateTime(dateTimeStr: string): string {
    if (!dateTimeStr) return '';
    
    try {
      const date = new Date(dateTimeStr);
      if (isNaN(date.getTime())) return dateTimeStr;
      
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');
      
      return `${month}-${day} ${hours}:${minutes}`;
    } catch (e) {
      return dateTimeStr;
    }
  }

  private getPeriodText(period: number): string {
    switch (period) {
      case 1:
        return '上午';
      case 2:
        return '下午';
      case 3:
        return '晚上';
      default:
        return '未知';
    }
  }
}
