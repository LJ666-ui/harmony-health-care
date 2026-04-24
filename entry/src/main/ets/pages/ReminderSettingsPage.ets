/**
 * 提醒设置页面 - 简化版
 */

import router from '@ohos.router';

@Entry
@Component
struct ReminderSettingsPage {
  @State reminders: string[] = ['reminder1', 'reminder2', 'reminder3'];

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('← 返回')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor('#1677FF')
          .onClick(() => {
            router.back();
          })
        
        Text('提醒设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('添加')
          .fontSize(14)
          .height(32)
          .type(ButtonType.Normal)
          .backgroundColor('#1677FF')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.showAddDialog();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 提醒列表
      Scroll() {
        Column() {
          this.buildReminderCard('💊', '服用降压药', '记得服用氨氯地平5mg', '08:00', '每天', true)
          this.buildReminderCard('📊', '测量血压', '早晚各测量一次血压', '07:30', '每天', true)
          this.buildReminderCard('🏥', '复查提醒', '下周三到医院复查', '09:00', '单次', false)
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

  @Builder buildReminderCard(
    icon: string,
    title: string,
    content: string,
    time: string,
    repeat: string,
    enabled: boolean
  ) {
    Row() {
      Text(icon).fontSize(32)
      
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Text(content)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Row() {
          Text(time)
            .fontSize(12)
            .fontColor('#999999')
          
          Text(repeat)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      
      Row() {
        Toggle({ type: ToggleType.Switch, isOn: enabled })
          .onChange((isOn: boolean) => {})
        
        Button('编辑')
          .fontSize(12)
          .height(28)
          .type(ButtonType.Normal)
          .backgroundColor('#F0F0F0')
          .fontColor('#666666')
          .margin({ left: 8 })
          .onClick(() => {})
        
        Button('删除')
          .fontSize(12)
          .height(28)
          .type(ButtonType.Normal)
          .backgroundColor('#FFF1F0')
          .fontColor('#FF4D4F')
          .margin({ left: 8 })
          .onClick(() => {
            AlertDialog.show({
              title: '确认删除',
              message: '确定要删除这个提醒吗?',
              buttons: [
                { value: '取消', action: () => {} },
                { value: '删除', action: () => {} }
              ]
            });
          })
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(12)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: '#0A000000', offsetX: 0, offsetY: 1 })
    .margin({ bottom: 12 })
  }

  private showAddDialog(): void {
    AlertDialog.show({
      title: '添加提醒',
      message: '请选择提醒类型',
      buttons: [
        { value: '💊 用药提醒', action: () => {} },
        { value: '📊 测量提醒', action: () => {} },
        { value: '🏥 复查提醒', action: () => {} },
        { value: '取消', action: () => {} }
      ]
    });
  }
}
