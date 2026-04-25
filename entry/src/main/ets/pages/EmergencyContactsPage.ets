/**
 * 紧急联系人页面 - 简化版
 */

import router from '@ohos.router';

@Entry
@Component
struct EmergencyContactsPage {
  @State contacts: string[] = ['contact1', 'contact2', 'contact3'];

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
        
        Text('紧急联系人')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('添加')
          .fontSize(14)
          .height(32)
          .type(ButtonType.Normal)
          .backgroundColor(this.contacts.length >= 3 ? '#E0E0E0' : '#1677FF')
          .fontColor(this.contacts.length >= 3 ? '#999999' : '#FFFFFF')
          .enabled(this.contacts.length < 3)
          .onClick(() => {
            this.showAddDialog();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 提示信息
      Row() {
        Text('ℹ️ 最多可设置3个紧急联系人,按优先级排序')
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFF7E6')

      // 联系人列表
      Scroll() {
        Column() {
          this.buildContactCard('张三(儿子)', '13800138001', '子女', 1)
          this.buildContactCard('李四(女儿)', '13800138002', '子女', 2)
          this.buildContactCard('王五(配偶)', '13800138003', '配偶', 3)
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

  @Builder buildContactCard(
    name: string,
    phone: string,
    relationship: string,
    priority: number
  ) {
    Row() {
      // 优先级标识
      Column() {
        Text(`${priority}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor(priority === 1 ? '#FF4D4F' : priority === 2 ? '#FAAD14' : '#1890FF')
      .justifyContent(FlexAlign.Center)

      // 联系人信息
      Column() {
        Text(name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Row() {
          Text('📱')
            .fontSize(14)
          
          Text(phone)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 4 })
        }
        .margin({ top: 4 })
        
        Text(relationship)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      // 操作按钮
      Row() {
        Button('拨打')
          .fontSize(12)
          .height(28)
          .type(ButtonType.Normal)
          .backgroundColor('#E6F7FF')
          .fontColor('#1677FF')
          .onClick(() => {
            AlertDialog.show({
              title: '拨打电话',
              message: `确定要拨打 ${name} 的电话吗?\n${phone}`,
              buttons: [
                { value: '取消', action: () => {} },
                { value: '拨打', action: () => {} }
              ]
            });
          })
        
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
              message: '确定要删除这个紧急联系人吗?',
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
      title: '添加紧急联系人',
      message: '请在下方输入联系人信息',
      buttons: [
        { value: '确定', action: () => {} }
      ]
    });
  }
}
