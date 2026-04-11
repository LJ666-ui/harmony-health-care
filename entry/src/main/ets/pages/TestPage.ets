@Entry
@Component
struct TestPage {
  build() {
    Column() {
      Text('测试页面')
        .fontSize(30)
        .fontWeight('bold')
        .fontColor('#333333')

      Text('如果你能看到这个文字，说明 Preview 正常工作！')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ top: 20 })

      Button('点击测试')
        .fontSize(18)
        .margin({ top: 30 })
        .onClick(() => {
          console.log('按钮点击成功！');
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
