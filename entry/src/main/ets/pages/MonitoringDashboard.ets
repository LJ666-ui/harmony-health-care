/**
 * 监控仪表盘页面 - 简化版
 * 使用Mock数据,符合ArkTS规范
 */

import router from '@ohos.router';

@Entry
@Component
struct MonitoringDashboard {
  @State isMonitoring: boolean = false;

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('❤️ 实时健康监控')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Toggle({ type: ToggleType.Switch, isOn: this.isMonitoring })
          .onChange((isOn: boolean) => {
            this.isMonitoring = isOn;
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // 生命体征卡片区域
          this.buildVitalSignsSection()
          
          // 最新预警区域
          this.buildAlertsSection()
          
          // 操作按钮区域
          this.buildActionsSection()
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建生命体征区域
   */
  @Builder buildVitalSignsSection() {
    Column() {
      Text('生命体征快照')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ bottom: 12 })

      // 第一行: 血压、血糖
      Row() {
        Column() {
          this.buildVitalCard('💓', '血压', '135/85', 'mmHg', '#FAAD14', '注意')
        }
        Column() {
          this.buildVitalCard('🩸', '血糖', '6.2', 'mmol/L', '#52C41A', '正常')
        }.margin({ left: 12 })
      }
      .width('100%')

      // 第二行: 心率、体温
      Row() {
        Column() {
          this.buildVitalCard('❤️', '心率', '78', 'bpm', '#52C41A', '正常')
        }.margin({ top: 12 })
        Column() {
          this.buildVitalCard('🌡️', '体温', '36.5', '°C', '#52C41A', '正常')
        }.margin({ left: 12, top: 12 })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  /**
   * 构建生命体征卡片
   */
  @Builder buildVitalCard(
    icon: string,
    label: string,
    value: string,
    unit: string,
    statusColor: string,
    statusText: string
  ) {
    Column() {
      Row() {
        Text(icon).fontSize(24)
        Text(label).fontSize(14).fontColor('#666666').margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 12 })

      Text(value)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(statusColor)

      Text(unit)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 4 })

      Row() {
        Circle().width(8).height(8).fill(statusColor)
        Text(statusText)
          .fontSize(12)
          .fontColor(statusColor)
          .margin({ left: 4 })
      }
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  /**
   * 构建预警区域
   */
  @Builder buildAlertsSection() {
    Column() {
      Row() {
        Text('最新预警')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Blank()
        
        Button('查看全部')
          .fontSize(14)
          .height(28)
          .type(ButtonType.Normal)
          .backgroundColor('#FFFFFF')
          .fontColor('#1677FF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AlertHistoryPage' });
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 预警卡片
      Column() {
        this.buildAlertCard('🚨', '血压警告', '血压偏高: 145/92mmHg', '2小时前', '#FF4D4F')
      }
      Column() {
        this.buildAlertCard('⚠️', '血糖注意', '血糖轻度偏离: 6.8mmol/L', '5小时前', '#FAAD14')
      }.margin({ top: 8 })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  /**
   * 构建预警卡片
   */
  @Builder buildAlertCard(
    icon: string,
    title: string,
    desc: string,
    time: string,
    color: string
  ) {
    Row() {
      Text(icon).fontSize(24)
      
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Text(desc)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 4 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      
      Text(time)
        .fontSize(12)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(16)
    .borderRadius(12)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: color })
  }

  /**
   * 构建操作按钮区域
   */
  @Builder buildActionsSection() {
    Column() {
      Button('➕ 手动录入数据')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#1677FF')
        .onClick(() => {
          this.showAddDataDialog();
        })

      Row() {
        Button('预警历史')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .backgroundColor('#FFFFFF')
          .fontColor('#666666')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AlertHistoryPage' });
          })

        Button('提醒设置')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .backgroundColor('#FFFFFF')
          .fontColor('#666666')
          .margin({ left: 12 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/ReminderSettingsPage' });
          })

        Button('紧急联系人')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .backgroundColor('#FFFFFF')
          .fontColor('#666666')
          .margin({ left: 12 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/EmergencyContactsPage' });
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
  }

  /**
   * 显示添加数据对话框
   */
  private showAddDataDialog(): void {
    AlertDialog.show({
      title: '手动录入数据',
      message: '请选择要录入的数据类型',
      buttons: [
        { value: '血压', action: () => {} },
        { value: '血糖', action: () => {} },
        { value: '心率', action: () => {} },
        { value: '取消', action: () => {} }
      ]
    });
  }
}
