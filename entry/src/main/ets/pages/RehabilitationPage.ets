import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface TrainingPlan {
  id: number;
  name: string;
  type: string;
  progress: number;
  totalDays: number;
  completedDays: number;
  status: string;
  nextSession: string;
}

interface TrainingRecord {
  id: number;
  date: string;
  duration: number;
  type: string;
  completed: boolean;
}

@Entry
@Component
struct RehabilitationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State plans: TrainingPlan[] = [];
  @State records: TrainingRecord[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    
    try {
      await new Promise<void>(resolve => setTimeout(resolve, 500));
      
      this.plans = [
        { id: 1, name: '膝关节康复训练', type: '骨科康复', progress: 75, totalDays: 30, completedDays: 22, status: '进行中', nextSession: '今天 15:00' },
        { id: 2, name: '颈椎病康复训练', type: '脊柱康复', progress: 40, totalDays: 20, completedDays: 8, status: '进行中', nextSession: '明天 09:00' },
        { id: 3, name: '心肺功能训练', type: '心肺康复', progress: 100, totalDays: 15, completedDays: 15, status: '已完成', nextSession: '-' }
      ];
      
      this.records = [
        { id: 1, date: '2024-12-18', duration: 45, type: '膝关节康复训练', completed: true },
        { id: 2, date: '2024-12-17', duration: 30, type: '颈椎病康复训练', completed: true },
        { id: 3, date: '2024-12-16', duration: 60, type: '膝关节康复训练', completed: true },
        { id: 4, date: '2024-12-15', duration: 40, type: '心肺功能训练', completed: true },
        { id: 5, date: '2024-12-14', duration: 35, type: '颈椎病康复训练', completed: true }
      ];
    } catch (error) {
      console.error('[RehabilitationPage] 加载数据异常:', error);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  startTraining(plan: TrainingPlan): void {
    if (plan.status === '已完成') {
      ToastUtil.showInfo('该训练计划已完成');
      return;
    }
    router.pushUrl({ 
      url: 'pages/Rehab3DPage',
      params: { planId: plan.id }
    }).catch((error: Error) => {
      console.error('跳转训练页失败:', error.message);
      ToastUtil.showError('功能开发中');
    });
  }

  viewPlanDetail(plan: TrainingPlan): void {
    ToastUtil.showInfo('详情功能开发中');
  }

  build() {
    Column() {
      Header({ title: '康复训练', showBack: true });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#16A085')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 训练计划
            Text('训练计划')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('90%')
              .margin({ top: 15, bottom: 10 })

            ForEach(this.plans, (plan: TrainingPlan) => {
              Column() {
                Row() {
                  Text(plan.name)
                    .fontSize(this.isElderMode ? 18 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')
                    .layoutWeight(1)
                  
                  Text(plan.status)
                    .fontSize(12)
                    .fontColor('#fff')
                    .backgroundColor(plan.status === '已完成' ? '#2ECC71' : '#16A085')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(10)
                }
                .width('100%')

                Text('类型：' + plan.type)
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#666')
                  .margin({ top: 8 })
                  .width('100%')

                // 进度条
                Column() {
                  Row() {
                    Text('进度：' + plan.completedDays + '/' + plan.totalDays + '天')
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                      .layoutWeight(1)
                    
                    Text(plan.progress + '%')
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#16A085')
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')
                  .margin({ bottom: 5 })

                  Progress({ value: plan.progress, total: 100, type: ProgressType.Linear })
                    .width('100%')
                    .height(8)
                    .color('#16A085')
                }
                .width('100%')
                .margin({ top: 10 })

                Row() {
                  Text('下次训练：' + plan.nextSession)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#999')
                    .layoutWeight(1)

                  if (plan.status !== '已完成') {
                    Button('开始训练')
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontColor('#fff')
                      .backgroundColor('#16A085')
                      .borderRadius(20)
                      .height(36)
                      .padding({ left: 20, right: 20 })
                      .onClick(() => this.startTraining(plan))
                  }
                }
                .width('100%')
                .margin({ top: 10 })
              }
              .width('90%')
              .backgroundColor('#fff')
              .borderRadius(12)
              .padding(15)
              .shadow({ radius: 2, color: '#e0e0e0', offsetX: 0, offsetY: 1 })
              .margin({ bottom: 10 })
              .onClick(() => this.viewPlanDetail(plan))
            })

            // 训练记录
            Text('训练记录')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('90%')
              .margin({ top: 20, bottom: 10 })

            ForEach(this.records, (record: TrainingRecord, index: number) => {
              Row() {
                Column() {
                  // 时间线
                  Row() {
                    Circle()
                      .width(12)
                      .height(12)
                      .fill(record.completed ? '#16A085' : '#ccc')
                    
                    if (index < this.records.length - 1) {
                      Line()
                        .width(2)
                        .height(40)
                        .backgroundColor('#e0e0e0')
                        .position({ x: 5, y: 12 })
                    }
                  }
                }
                .width(20)
                .height(50)

                Column() {
                  Text(record.date)
                    .fontSize(this.isElderMode ? 16 : 14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')
                    .width('100%')

                  Row() {
                    Text(record.type)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#666')
                    
                    Text('时长：' + record.duration + '分钟')
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                      .margin({ left: 15 })
                  }
                  .width('100%')
                  .margin({ top: 5 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Text(record.completed ? '✓' : '○')
                  .fontSize(20)
                  .fontColor(record.completed ? '#16A085' : '#ccc')
              }
              .width('90%')
              .alignItems(VerticalAlign.Top)
              .margin({ bottom: 5 })
            })
          }
          .width('100%')
          .padding({ bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      Footer();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')
  }
}
