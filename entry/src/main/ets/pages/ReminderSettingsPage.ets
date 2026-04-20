import { Reminder, ReminderTemplate } from '../monitoring/ReminderScheduler';
import { ReminderScheduler } from '../monitoring/ReminderScheduler';
import { ReminderListItem } from '../components/ReminderListItem';

@Entry
@Component
struct ReminderSettingsPage {
  @State reminders: Reminder[] = [];
  @State templates: ReminderTemplate[] = [];
  @State isLoading: boolean = true;
  @State showAddDialog: boolean = false;
  @State showTemplatePicker: boolean = false;
  @State newReminderTitle: string = '';
  @State newReminderTime: string = '08:00';
  @State selectedTemplate: ReminderTemplate | null = null;
  @State soundEnabled: boolean = true;
  @State vibrationEnabled: boolean = true;

  private reminderService: ReminderScheduler = ReminderScheduler.getInstance();

  aboutToAppear(): void {
    console.log('[ReminderSettingsPage] 页面加载');
    this.loadData();
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '⏰ 提醒设置', 
        showBack: true 
      })

      if (this.isLoading) {
        this.buildLoadingView()
      } else {
        Scroll() {
          Column({ space: 16 }) {
            this.buildQuickAddSection()
            
            this.buildRemindersList()
            
            this.buildStatisticsCard()
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }

      if (this.showAddDialog) {
        this.buildAddReminderDialog()
      }

      if (this.showTemplatePicker) {
        this.buildTemplatePicker()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildLoadingView() {
    Column({ space: 20 }) {
      LoadingProgress()
        .width(60)
        .height(60)
        .color('#1677FF')
      
      Text('正在加载提醒设置...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildQuickAddSection() {
    Column({ space: 12 }) {
      Text('快速添加提醒')
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      Row({ space: 10 }) {
        Button('使用模板添加')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(22)
          .onClick(() => {
            this.showTemplatePicker = true;
          })

        Button('自定义提醒')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(22)
          .onClick(() => {
            this.showAddDialog = true;
            this.selectedTemplate = null;
            this.newReminderTitle = '';
          })
      }
      .width('100%')

      Row({ space: 8 }) {
        Text('通知设置：')
          .fontSize(14)
          .fontColor('#666666')

        Toggle({ type: ToggleType.Switch, isOn: this.soundEnabled })
          .onChange((isOn: boolean) => {
            this.soundEnabled = isOn;
            console.log(`[ReminderSettingsPage] 声音通知${isOn ? '开启' : '关闭'}`);
          })

        Text('声音')
          .fontSize(13)
          .fontColor(this.soundEnabled ? '#52C41A' : '#999999')

        Toggle({ type: ToggleType.Switch, isOn: this.vibrationEnabled })
          .onChange((isOn: boolean) => {
            this.vibrationEnabled = isOn;
            console.log(`[ReminderSettingsPage] 震动通知${isOn ? '开启' : '关闭'}`);
          })

        Text('震动')
          .fontSize(13)
          .fontColor(this.vibrationEnabled ? '#52C41A' : '#999999')

        Blank()
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
  }

  @Builder buildRemindersList() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('我的提醒列表')
          .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

        Text(`${this.reminders.length}`)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .width(20)
          .height(20)
          .borderRadius(10)
          .textAlign(TextAlign.Center)
          .backgroundColor('#1677FF')

        Blank()

        if (this.reminders.length > 0) {
          Button('清空全部')
            .height(30)
            .fontSize(12)
            .fontColor('#FF4D4F')
            .backgroundColor('#FFF2F0')
            .borderRadius(15)
            .onClick(() => this.clearAllReminders())
        }
      }
      .width('100%')

      if (this.reminders.length === 0) {
        this.buildEmptyReminders()
      } else {
        ForEach(this.reminders, (reminder: Object) => {
          const reminderItem = reminder as Reminder;
          
          ReminderListItem({
            reminder: reminderItem,
            onComplete: (reminderId: string) => this.handleComplete(reminderId),
            onSnooze: (reminderId: string, minutes: number) => this.handleSnooze(reminderId, minutes),
            onToggle: (reminderId: string, active: boolean) => this.handleToggle(reminderId, active)
          })
        })
      }
    }
    .width('100%')
  }

  @Builder buildEmptyReminders() {
    Column({ space: 16 }) {
      Text('📅')
        .fontSize(48)

      Text('暂无提醒')
        .fontSize(16)
        .fontColor('#666666')

      Text('点击上方按钮添加健康提醒')
        .fontSize(13)
        .fontColor('#BBBBBB')
    }
    .width('100%')
    .padding(32)
    .backgroundColor('#FAFAFA')
    .borderRadius(12)
  }

  @Builder buildStatisticsCard() {
    const stats = this.reminderService.getStatistics();
    
    Column({ space: 12 }) {
      Text('📊 提醒统计')
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      Row({ space: 8 }) {
        this.buildStatItem('总提醒数', String(stats.total), '#1677FF')
        this.buildStatItem('活跃中', String(stats.active), '#52C41A')
        this.buildStatItem('已完成', String(stats.completed), '#999999')
      }
      .width('100%')

      Row({ space: 8 }) {
        this.buildStatItem('完成率', `${stats.completionRate}%`, '#FAAD14')
        this.buildStatItem('逾期', String(stats.overdue), '#FF4D4F')
        this.buildStatItem('即将到来', String(stats.upcoming), '#722ED1')
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder buildStatItem(label: string, value: string, color: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(24)
        .fontColor(color)
        .fontWeight(FontWeight.Bold)

      Text(label)
        .fontSize(12)
        .fontColor('#999999')
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
  }

  @Builder buildAddReminderDialog() {
    Column() {
      Row() {
        Text(selectedTemplate ? `添加：${selectedTemplate.name}` : '自定义提醒')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('✕')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => this.showAddDialog = false)
      }
      .width('100%')
      .padding(16)

      Divider()
        .color('#EEEEEE')

      Column({ space: 16 }) {
        TextInput({ placeholder: '请输入提醒标题', text: this.newReminderTitle })
          .width('100%')
          .height(50)
          .fontSize(15)
          .onChange((value: string) => {
            this.newReminderTitle = value;
          })

        TextInput({ placeholder: '请输入时间（如08:00）', text: this.newReminderTime })
          .width('100%')
          .height(50)
          .fontSize(15)
          .type(InputType.Normal)
          .onChange((value: string) => {
            this.newReminderTime = value;
          })

        Text('重复模式')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')

        Select([
          { value: '仅一次' },
          { value: '每天' },
          { value: '每周' },
          { value: '每月' }
        ])
          .value('每天')
          .selected(1)
          .font({ size: 14 })
          .width('100%')

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(() => this.showAddDialog = false)

          Button('确认添加')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(22)
            .onClick(() => this.addNewReminder())
        }
        .width('100%')
      }
      .padding(16)
    }
    .width('90%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.2)',
      offsetX: 0,
      offsetY: 8
    })
  }

  @Builder buildTemplatePicker() {
    Column() {
      Row() {
        Text('选择模板')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('✕')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => this.showTemplatePicker = false)
      }
      .width('100%')
      .padding(16)

      Divider()
        .color('#EEEEEE')

      List({ space: 8 }) {
        ForEach(this.templates, (template: Object) => {
          const templateItem = template as ReminderTemplate;
          
          ListItem() {
            Row({ space: 12 }) {
              Text(templateItem.icon)
                .fontSize(28)

              Column({ space: 4 }) {
                Text(templateItem.name)
                  .fontSize(16)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)

                Text(templateItem.defaultDescription)
                  .fontSize(13)
                  .fontColor('#999999')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('选择')
                .fontSize(14)
                .fontColor('#1677FF')
                .fontWeight(FontWeight.Medium)
                .padding({ horizontal: 12, vertical: 6 })
                .backgroundColor('#E6F4FF')
                .borderRadius(15)
                .onClick(() => this.selectTemplate(templateItem))
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .onClick(() => this.selectTemplate(templateItem))
          }
        })
      }
      .layoutWeight(1)
      .padding(16)
    }
    .width('90%')
    .height('70%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.2)',
      offsetX: 0,
      offsetY: 8
    })
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;

    try {
      await new Promise(resolve => setTimeout(resolve, 300));

      try {
        const mockModule = await import('../mock/monitoringMock');
        
        if (mockModule && mockModule.monitoringMock) {
          this.reminders = mockModule.monitoringMock.getUpcomingReminders();
          this.templates = mockModule.monitoringMock.getReminderTemplates();
          
          console.log(`[ReminderSettingsPage] 加载了 ${this.reminders.length} 个提醒`);
        }
      } catch (error) {
        console.warn('[ReminderSettingsPage] Mock加载失败:', error instanceof Error ? error.message : String(error));
        
        this.reminders = [];
        this.templates = [];
      }

    } catch (error) {
      console.error('[ReminderSettingsPage] 加载失败:', error instanceof Error ? error.message : String(error));
      
      this.reminders = [];
      this.templates = [];
    } finally {
      this.isLoading = false;
    }
  }

  private selectTemplate(template: ReminderTemplate): void {
    this.selectedTemplate = template;
    this.showTemplatePicker = false;
    
    this.newReminderTitle = template.defaultTitle;
    this.showAddDialog = true;
    
    console.log(`[ReminderSettingsPage] 选择模板: ${template.name}`);
  }

  private addNewReminder(): void {
    if (!this.newReminderTitle.trim()) {
      AlertDialog.show({
        title: '提示',
        message: '请输入提醒标题',
        primaryText: '确定'
      });
      return;
    }

    const now = new Date();
    const [hours, minutes] = this.newReminderTime.split(':').map(Number);
    const scheduledDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hours || 8, minutes || 0);

    const reminder = this.reminderService.addReminder({
      title: this.newReminderTitle,
      description: this.selectedTemplate?.defaultDescription || '自定义提醒',
      type: this.selectedTemplate?.category || 'CUSTOM',
      scheduledTime: scheduledDate.toISOString(),
      repeatPattern: 'DAILY',
      isActive: true,
      isCompleted: false,
      priority: 'MEDIUM',
      soundEnabled: this.soundEnabled,
      vibrationEnabled: this.vibrationEnabled,
      advanceNoticeMinutes: 5
    });

    this.reminders.push(reminder);
    
    this.reminders.sort((a, b) => 
      new Date(a.scheduledTime).getTime() - new Date(b.scheduledTime).getTime()
    );

    this.showAddDialog = false;
    this.newReminderTitle = '';
    this.newReminderTime = '08:00';
    this.selectedTemplate = null;

    AlertDialog.show({
      title: '✅ 添加成功',
      message: `提醒"${reminder.title}"已创建`,
      primaryText: '确定'
    });
  }

  private handleComplete(reminderId: string): void {
    this.reminderService.completeReminder(reminderId);
    
    this.reminders = this.reminders.filter(r => r.id !== reminderId);
    
    console.log(`[ReminderSettingsPage] 完成提醒: ${reminderId}`);
  }

  private handleSnooze(reminderId: string, minutes: number): void {
    this.reminderService.snoozeReminder(reminderId, minutes);
    
    console.log(`[ReminderSettingsPage] 延迟提醒 ${minutes} 分钟: ${reminderId}`);
  }

  private handleToggle(reminderId: string, active: boolean): void {
    this.reminderService.toggleReminder(reminderId, active);
    
    const index = this.reminders.findIndex(r => r.id === reminderId);
    
    if (index > -1) {
      this.reminders[index].isActive = active;
    }
    
    console.log(`[ReminderSettingsPage] 切换提醒状态: ${reminderId} -> ${active}`);
  }

  private clearAllReminders(): void {
    AlertDialog.show({
      title: '⚠️ 确认清空',
      message: '确定要删除所有提醒吗？此操作不可恢复。',
      primaryText: '取消',
      secondaryText: '确认',
      onSecondaryClick: () => {
        this.reminderService.clearAllReminders();
        this.reminders = [];
        
        console.log('[ReminderSettingsPage] 已清空所有提醒');
      }
    });
  }
}

@Component
struct NavigationTitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;

  build() {
    Row() {
      if (this.showBack) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
      }

      Text(this.title)
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
