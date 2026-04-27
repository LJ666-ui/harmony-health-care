@Preview
@Entry
@Component
export struct ServiceGrid {
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
      Text("快捷功能")
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
    }
    .width("100%")
  }
}
