@Component
export struct EfficacyTag {
  @Prop efficacies: string[] = [];
  @Prop isCompact: boolean = false;

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.efficacies, (efficacy: string) => {
        Text(efficacy)
          .fontSize(this.isCompact ? 11 : 13)
          .fontColor('#1677FF')
          .backgroundColor('#E6F7FF')
          .padding(this.isCompact
            ? { left: 8, right: 8, top: 3, bottom: 3 }
            : { left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(16)
          .margin(4);
      }, (efficacy: string) => efficacy);
    }
    .width('100%');
  }
}
