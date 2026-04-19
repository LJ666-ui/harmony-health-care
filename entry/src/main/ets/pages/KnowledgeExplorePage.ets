import { Footer } from '../components/Footer';
import { Header } from '../components/Header';
import { GraphCanvas } from '../components/GraphCanvas';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { GlobalTheme } from '../global';

interface ExploreResult {
  centerId: number;
  depth: number;
  nodeCount: number;
  edgeCount: number;
  nodes: object[];
  edges: object[];
  keywords: string[];
  interpretation: string;
}

interface ExploreParams {
  query: string;
  depth: number;
}

@Entry
@Component
struct KnowledgeExplorePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State interpretation: string = '';
  @State keywords: string[] = [];
  @State graphCanvasKey: number = 0;
  @State exploreCenterId: number = 1;
  @State exploreDepth: number = 2;

  handleExplore(): void {
    if (!this.inputText.trim()) {
      return;
    }
    this.isLoading = true;
    this.interpretation = '';

    const params: ExploreParams = { query: this.inputText.trim(), depth: 2 };

    HttpUtil.post<ExploreResult>(ApiConstants.KNOWLEDGE_EXPLORE, params)
      .then((response: BaseResponse<ExploreResult>) => {
        this.isLoading = false;
        if (response.success && response.data) {
          const data: ExploreResult = response.data;
          this.keywords = data.keywords || [];
          this.interpretation = data.interpretation || '';
          if (data.centerId) {
            this.exploreCenterId = data.centerId;
          }
          this.exploreDepth = data.depth || 2;
          this.graphCanvasKey++;
        } else {
          this.interpretation = response.message || '探索失败，请重试';
        }
      })
      .catch((error: Error) => {
        this.isLoading = false;
        this.interpretation = error.message || '网络请求失败';
      });
  }

  build(): void {
    Column() {
      Header({
        title: 'AI 知识探索',
        showBack: true
      });

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          TextInput({ placeholder: '输入问题，如：高血压怎么治？' })
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => {
              this.inputText = value;
            })
            .onSubmit(() => this.handleExplore());

          Button('发送')
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(20)
            .onClick(() => this.handleExplore());
        }
        .width('100%')
        .padding({ left: 12, right: 12 });

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color(GlobalTheme.THEME_COLOR);
            Text('正在分析...')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .margin({ top: 8 });
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);
        } else {
          GraphCanvas()
            .width('100%')
            .height(400);

          if (this.keywords.length > 0) {
            Row({ space: 6 }) {
              Text('关键词:')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
              ForEach(this.keywords, (keyword: string) => {
                Text(keyword)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor('#1677FF')
                  .backgroundColor('#E6F4FF')
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .borderRadius(10);
              }, (keyword: string, index: number) => '' + keyword + '-' + index);
            }
            .width('100%')
            .padding({ left: 12, right: 12 });
          }

          if (this.interpretation) {
            Column() {
              Text('AI 解读')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight('bold')
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .margin({ bottom: 6 });
              Text(this.interpretation)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY)
                .lineHeight(22);
            }
            .width('100%')
            .padding(12)
            .backgroundColor(GlobalTheme.CARD_BG)
            .borderRadius(GlobalTheme.RADIUS_MD)
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
            .margin({ left: 12, right: 12 });
          }
        }
      }
      .width('88%')
      .layoutWeight(1);

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
