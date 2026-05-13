import { AccessibilityConfig } from '../utils/AccessibilityConfig';

export interface SearchBarProps {
  placeholder?: string;
  onSearch?: (text: string) => void;
  onVoiceInput?: () => void;
}

@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索健康知识、药材、食材...';
  onSearch?: (text: string) => void;
  onVoiceInput?: () => void;
  @State searchText: string = '';
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  build() {
    Row({ space: 10 }) {
      Row({ space: 8 }) {
        Text('🔍')
          .fontSize(18)

        TextInput({
          placeholder: this.placeholder,
          text: this.searchText
        })
          .fontSize(this.isElderMode ? 16 : 14)
          .layoutWeight(1)
          .height(40)
          .padding({ left: 8, right: 8 })
          .backgroundColor('transparent')
          .onChange((value: string) => {
            this.searchText = value;
          })
          .onSubmit(() => {
            if (this.searchText.trim()) {
              if (this.onSearch) {
                this.onSearch(this.searchText.trim());
              }
            }
          })

        if (this.searchText.length > 0) {
          Text('✕')
            .fontSize(16)
            .fontColor('#999999')
            .onClick(() => {
              this.searchText = '';
            })
        }
      }
      .layoutWeight(1)
      .height(48)
      .padding({ left: 16, right: 12 })
      .backgroundColor('#F5F7FA')
      .borderRadius(24)

      Text('🎤')
        .fontSize(22)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .backgroundColor('#1677FF')
        .borderRadius(20)
        .onClick(() => {
          if (this.onVoiceInput) {
            this.onVoiceInput();
          }
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }
}