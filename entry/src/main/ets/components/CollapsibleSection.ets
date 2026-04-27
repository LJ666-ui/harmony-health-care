@Preview
@Entry
@Component
export struct CollapsibleSection {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      this.ColumnElements()
    }
    .height('100%')
    .width('100%')
  }

  @Builder ColumnElements() {
    Column() {
      Text("更多服务")
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
    }
    .width("100%")
  }
}
