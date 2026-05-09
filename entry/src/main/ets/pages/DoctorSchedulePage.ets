import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';

interface DoctorSchedule {
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

@Entry
@Component
struct DoctorSchedulePage {
  @State schedules: DoctorSchedule[] = [];
  @State loading: boolean = false;
  @State showCreateDialog: boolean = false;
  @State selectedDate: Date = new Date();
  @State selectedPeriod: number = 0;

  aboutToAppear() {
    this.loadSchedules();
  }

  async loadSchedules() {
    this.loading = true;
    try {
      const response = await http.createHttp().request(
        'http://localhost:8080/api/doctor/schedule/doctor/1',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        const result: Record<string, Object> = JSON.parse(response.result as string) as Record<string, Object>;
        this.schedules = (result.data as DoctorSchedule[]) || [];
      }
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.loading = false;
    }
  }

  async deleteSchedule(id: number) {
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/doctor/schedule/${id}`,
        {
          method: http.RequestMethod.DELETE,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        this.loadSchedules();
      }
    } catch (error) {
      console.error('删除失败:', error);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('医生排班管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Button('添加排班')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#007DFF')
          .onClick(() => {
            this.showCreateDialog = true;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 排班列表
      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#007DFF')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.schedules.length === 0) {
        Column() {
          Text('暂无排班')
            .fontSize(16)
            .fontColor('#999999')
          
          Button('添加第一个排班')
            .fontSize(14)
            .margin({ top: 16 })
            .onClick(() => {
              this.showCreateDialog = true;
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.schedules, (item: DoctorSchedule) => {
            ListItem() {
              Column() {
                Row() {
                  Text(this.formatDate(item.scheduleDate))
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                  
                  Blank()
                  
                  Text(this.getPeriodText(item.schedulePeriod))
                    .fontSize(12)
                    .fontColor('#007DFF')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor('#E3F2FD')
                    .borderRadius(4)
                }
                .width('100%')
                .margin({ bottom: 8 })

                Row() {
                  Text(`最大预约数: ${item.maxCount}`)
                    .fontSize(12)
                    .fontColor('#666666')
                  
                  Blank()
                  
                  Text(`已预约: ${item.currentCount}`)
                    .fontSize(12)
                    .fontColor(item.currentCount >= item.maxCount ? '#FF3B30' : '#34C759')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Row() {
                  Text(`状态: ${item.status === 1 ? '正常' : '禁用'}`)
                    .fontSize(12)
                    .fontColor('#999999')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Row() {
                  Button('编辑')
                    .fontSize(14)
                    .fontColor('#007DFF')
                    .backgroundColor('#E3F2FD')
                    .onClick(() => {
                      // 编辑排班
                    })

                  Blank()

                  Button('删除')
                    .fontSize(14)
                    .fontColor('#FF3B30')
                    .backgroundColor('#FFE5E5')
                    .onClick(() => {
                      this.deleteSchedule(item.id);
                    })
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .margin({ bottom: 12 })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet($$this.showCreateDialog, this.CreateScheduleSheet(), {
      height: 400,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  CreateScheduleSheet() {
    Column() {
      Text('添加排班')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      // 表单内容
      Column() {
        TextInput({ placeholder: '排班日期 (yyyy-MM-dd)' })
          .width('100%')
          .margin({ bottom: 16 })

        Row() {
          Text('时段:')
            .fontSize(14)
            .fontColor('#333333')
          
          Radio({ value: '上午', group: 'period' })
            .checked(this.selectedPeriod === 0)
            .onChange((isChecked: boolean) => {
              if (isChecked) this.selectedPeriod = 0;
            })
          
          Radio({ value: '下午', group: 'period' })
            .checked(this.selectedPeriod === 1)
            .onChange((isChecked: boolean) => {
              if (isChecked) this.selectedPeriod = 1;
            })
          
          Radio({ value: '晚上', group: 'period' })
            .checked(this.selectedPeriod === 2)
            .onChange((isChecked: boolean) => {
              if (isChecked) this.selectedPeriod = 2;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })

        TextInput({ placeholder: '最大预约数' })
          .width('100%')
          .margin({ bottom: 16 })
          .type(InputType.Number)

        Row() {
          Button('取消')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .onClick(() => {
              this.showCreateDialog = false;
            })

          Blank()

          Button('创建')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#007DFF')
            .onClick(() => {
              // 创建排班
              this.showCreateDialog = false;
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .padding(20)
  }

  private formatDate(dateStr: string): string {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  }

  private getPeriodText(period: number): string {
    switch (period) {
      case 0:
        return '上午';
      case 1:
        return '下午';
      case 2:
        return '晚上';
      default:
        return '未知';
    }
  }
}
