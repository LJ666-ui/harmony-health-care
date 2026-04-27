@Preview
@Entry
@Component
export struct RecommendList {
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
      Text("今日推荐")
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
    }
    .width("100%")
  }
}
