@Preview
@Entry
@Component
export struct HospitalCard {
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
      Text("推荐医院")
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
    }
    .width("100%")
  }
}
