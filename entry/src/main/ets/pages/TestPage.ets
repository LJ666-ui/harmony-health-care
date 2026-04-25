/**
 * 测试页面 - 验证路由是否正常工作
 */

import { router } from '@kit.ArkUI';

@Entry
@Component
struct TestPage {
  @State message: string = '测试页面';

  aboutToAppear(): void {
    console.log('TestPage: aboutToAppear');
  }

  build() {
    Column() {
      Text(this.message)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Text('路由测试成功！')
        .fontSize(16)
        .fontColor('#4CAF50')

      Button('返回首页')
        .margin({ top: 20 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
