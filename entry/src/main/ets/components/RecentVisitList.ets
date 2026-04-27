@Preview
@Entry
@Component
export struct RecentVisitList {
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
      Text("最近访问")
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
    }
    .width("100%")
  }
}
