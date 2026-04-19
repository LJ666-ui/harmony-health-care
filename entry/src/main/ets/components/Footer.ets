import { router } from '@kit.ArkUI';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

interface TabItem {
  icon: string;
  label: string;
  pageUrl: string;
}

const TAB_ITEMS: TabItem[] = [
  { icon: '🏠', label: '首页', pageUrl: 'pages/HomePage' },
  { icon: '🏥', label: '就医', pageUrl: 'pages/MedicalPage' },
  { icon: '🧘', label: '康复', pageUrl: 'pages/RehabPage' },
  { icon: '📚', label: '科普', pageUrl: 'pages/SciencePage' },
  { icon: '👤', label: '我的', pageUrl: 'pages/Profile' }
];

@Component
export struct Footer {
  @Prop activeIndex: number = 0;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  build() {
    Row({ space: 0 }) {
      ForEach(TAB_ITEMS, (item: TabItem, index: number) => {
        Column({ space: this.isElderMode ? 6 : 4 }) {
          Text(item.icon)
            .fontSize(this.isElderMode ? 32 : 24)
            .fontColor(this.activeIndex === index ? AccessibilityConfig.getThemeColor() : AccessibilityConfig.getTextHint());

          Text(item.label)
            .fontSize(this.isElderMode ? 16 : 12)
            .fontWeight(this.activeIndex === index ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.activeIndex === index ? AccessibilityConfig.getThemeColor() : AccessibilityConfig.getTextHint());
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .accessibilityText('' + item.label + (this.activeIndex === index ? '，当前页面' : ''))
        .onClick(() => {
          router.pushUrl({ url: item.pageUrl });
        });
      }, (item: TabItem, index: number) => 'tab_' + index);
    }
    .width('100%')
    .height(this.isElderMode ? 75 : 60)
    .backgroundColor('#FFFFFF')
    .padding({
      left: this.isElderMode ? AccessibilityConfig.getSpacingMD() : AccessibilityConfig.getSpacingSM(),
      right: this.isElderMode ? AccessibilityConfig.getSpacingMD() : AccessibilityConfig.getSpacingSM()
    })
    .justifyContent(FlexAlign.SpaceAround)
    .shadow({
      radius: 8,
      color: '#00000010',
      offsetX: 0,
      offsetY: -2
    });
  }
}