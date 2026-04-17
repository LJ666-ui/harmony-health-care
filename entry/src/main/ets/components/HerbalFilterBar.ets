import { NATURE_TYPES, TASTE_TYPES, SORT_OPTIONS } from '../mock/herbalMock';

@Component
export struct HerbalFilterBar {
  @State showNatureFilter: boolean = false;
  @State showTasteFilter: boolean = false;
  @State selectedNature: string = '';
  @State selectedTaste: string = '';
  @State currentSort: number = 0;
  searchValue: string = '';

  onSearch?: (value: string) => void;
  onNatureChange?: (nature: string) => void;
  onTasteChange?: (taste: string) => void;
  onSortChange?: (sortIndex: number) => void;

  build() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        TextInput({ placeholder: '搜索药材名称、功效...', text: this.searchValue })
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .backgroundColor('#F5F5F5')
          .borderRadius(18)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.searchValue = value;
            if (this.onSearch) {
              this.onSearch(value);
            }
          });

        Button('搜索')
          .height(36)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(18)
          .onClick(() => {
            if (this.onSearch) {
              this.onSearch(this.searchValue);
            }
          });
      }
      .width('100%');

      Row({ space: 12 }) {
        this.buildFilterButton('药性', this.selectedNature || '全部', () => {
          this.showNatureFilter = !this.showNatureFilter;
          this.showTasteFilter = false;
        });

        this.buildFilterButton('味道', this.selectedTaste || '全部', () => {
          this.showTasteFilter = !this.showTasteFilter;
          this.showNatureFilter = false;
        });

        this.buildFilterButton(SORT_OPTIONS[this.currentSort], '', () => {
          this.currentSort = (this.currentSort + 1) % SORT_OPTIONS.length;
          if (this.onSortChange) {
            this.onSortChange(this.currentSort);
          }
        });
      }
      .width('100%');

      if (this.showNatureFilter) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(NATURE_TYPES, (nature: string) => {
            Text(nature)
              .fontSize(12)
              .fontColor(this.selectedNature === nature ? '#1677FF' : '#666666')
              .backgroundColor(this.selectedNature === nature ? '#E6F7FF' : '#F5F5F5')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .borderRadius(15)
              .margin(4)
              .onClick(() => {
                this.selectedNature = this.selectedNature === nature ? '' : nature;
                if (this.onNatureChange) {
                  this.onNatureChange(this.selectedNature);
                }
              });
          }, (nature: string) => nature);
        }
        .width('100%')
        .padding(8)
        .backgroundColor('#FAFAFA')
        .borderRadius(8);
      }

      if (this.showTasteFilter) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(TASTE_TYPES, (taste: string) => {
            Text(taste)
              .fontSize(12)
              .fontColor(this.selectedTaste === taste ? '#1677FF' : '#666666')
              .backgroundColor(this.selectedTaste === taste ? '#E6F7FF' : '#F5F5F5')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .borderRadius(15)
              .margin(4)
              .onClick(() => {
                this.selectedTaste = this.selectedTaste === taste ? '' : taste;
                if (this.onTasteChange) {
                  this.onTasteChange(this.selectedTaste);
                }
              });
          }, (taste: string) => taste);
        }
        .width('100%')
        .padding(8)
        .backgroundColor('#FAFAFA')
        .borderRadius(8);
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 });
  }

  @Builder
  buildFilterButton(label: string, value: string, onClick: () => void) {
    Row({ space: 4 }) {
      Text(label)
        .fontSize(13)
        .fontColor(value && value !== '全部' ? '#1677FF' : '#333333');

      if (value && value !== '全部') {
        Text(`(${value})`)
          .fontSize(11)
          .fontColor('#1677FF');
      }

      Text('▼')
        .fontSize(10)
        .fontColor('#999999');
    }
    .padding({ left: 12, right: 12, top: 7, bottom: 7 })
    .backgroundColor('#F5F5F5')
    .borderRadius(16)
    .onClick(onClick);
  }
}
