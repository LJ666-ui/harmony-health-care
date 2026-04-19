@Component
export struct CategoryTabs {
  @Prop categories: string[] = [];
  @State currentIndex: number = 0;
  onTabChange?: (index: number, category: string) => void;

  build() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.categories, (category: string, index: number) => {
          Column({ space: 4 }) {
            Text(category)
              .fontSize(14)
              .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.currentIndex === index ? '#1677FF' : '#666666');

            if (this.currentIndex === index) {
              Row()
                .width(20)
                .height(3)
                .backgroundColor('#1677FF')
                .borderRadius(2);
            } else {
              Row()
                .width(20)
                .height(0);
            }
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.currentIndex === index ? '#E6F7FF' : 'transparent')
          .borderRadius(20)
          .onClick(() => {
            this.currentIndex = index;
            if (this.onTabChange) {
              this.onTabChange(index, category);
            }
          });
        }, (category: string, index: number) => '' + category + '_' + index);
      }
      .height('100%');
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .padding({ left: 12, right: 12 })
    .height(48)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({ radius: 2, color: '#00000008', offsetX: 0, offsetY: 1 });
  }
}
