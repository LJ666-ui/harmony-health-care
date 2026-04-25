import { router } from '@kit.ArkUI';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface RiskRecord {
  id: number;
  userId: number;
  assessTime: string;
  createTime: string;
  hypertensionRisk: number;
  diabetesRisk: number;
  fallRisk: number;
  frailtyRisk: number;
  sarcopeniaRisk: number;
  totalRisk: number;
  assessResult: string;
}

interface PageData {
  records: RiskRecord[];
  total: number;
  pages: number;
  current: number;
}

interface ListParams {
  page: string;
  size: string;
}

@Entry
@Component
struct RiskHistoryPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State historyItems: RiskRecord[] = [];
  @State isLoading: boolean = true;
  @State showDeleteDialog: boolean = false;
  @State deleteTargetId: number = -1;

  aboutToAppear(): void {
    this.fetchHistory();
  }

  fetchHistory(): void {
    this.isLoading = true;
    const userId: number = AppStorage.get<number>('userId') || 1;
    const params: ListParams = { page: '1', size: '50' };
    HttpUtil.get<PageData>(ApiConstants.RISK_LIST + userId, params)
      .then((response: BaseResponse<PageData>) => {
        if (response.success && response.data) {
          const pageData: PageData = response.data;
          if (pageData.records && Array.isArray(pageData.records)) {
            this.historyItems = pageData.records;
          }
        }
        this.isLoading = false;
      })
      .catch(() => {
        this.isLoading = false;
      });
  }

  deleteRecord(id: number): void {
    this.deleteTargetId = id;
    this.showDeleteDialog = true;
  }

  confirmDelete(): void {
    HttpUtil.delete<RiskRecord>(ApiConstants.RISK_DELETE + this.deleteTargetId)
      .then((response: BaseResponse<RiskRecord>) => {
        if (response.success) {
          const newList: RiskRecord[] = [];
          for (let i: number = 0; i < this.historyItems.length; i++) {
            if (this.historyItems[i].id !== this.deleteTargetId) {
              newList.push(this.historyItems[i]);
            }
          }
          this.historyItems = newList;
        }
        this.showDeleteDialog = false;
        this.deleteTargetId = -1;
      })
      .catch(() => {
        this.showDeleteDialog = false;
        this.deleteTargetId = -1;
      });
  }

  getLevelInfo(totalRisk: number): string[] {
    if (totalRisk >= 80) { return ['低风险', '#52C41A', '#F6FFED']; }
    if (totalRisk >= 60) { return ['中风险', '#FAAD14', '#FFFBE6']; }
    return ['高风险', '#FF4D4F', '#FFF1F0'];
  }

  getRiskLabel(risk: number): string {
    if (risk >= 80) { return '低'; }
    if (risk >= 60) { return '中'; }
    return '高';
  }

  getRiskColor(risk: number): string {
    if (risk >= 80) { return '#52C41A'; }
    if (risk >= 60) { return '#FAAD14'; }
    return '#FF4D4F';
  }

  formatDate(dateStr: string): string {
    if (!dateStr) { return '--'; }
    return dateStr.substring(0, 10);
  }

  build() {
    Column() {
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => { router.back(); });
        Text('评估历史')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center);
        Blank()
          .width(60);
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 });

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#1677FF');
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else if (this.historyItems.length === 0) {
        Column() {
          Text('📋').fontSize(48);
          Text('暂无评估记录')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 12 });
          Text('完成风险评估后将在此显示')
            .fontSize(13)
            .fontColor('#CCCCCC')
            .margin({ top: 8 });
          Button('开始评估')
            .margin({ top: 20 })
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(20)
            .onClick(() => { router.push({ url: 'pages/RiskAssessmentPage' }); });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.historyItems, (item: RiskRecord, index: number) => {
              Column() {
                Row() {
                  Column({ space: 4 }) {
                    Text(this.formatDate(item.assessTime || item.createTime))
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333');
                    Text('综合评分: ' + item.totalRisk)
                      .fontSize(12)
                      .fontColor('#999999');
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1);

                  Text(this.getLevelInfo(item.totalRisk)[0])
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getLevelInfo(item.totalRisk)[1])
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .backgroundColor(this.getLevelInfo(item.totalRisk)[2])
                    .borderRadius(10);

                  Text('🗑')
                    .fontSize(16)
                    .fontColor('#CCCCCC')
                    .margin({ left: 8 })
                    .padding(4)
                    .onClick(() => { this.deleteRecord(item.id); });
                }
                .width('100%')
                .margin({ bottom: 10 });

                Row({ space: 6 }) {
                  Row() {
                    Text('高血压')
                      .fontSize(10)
                      .fontColor(this.getRiskColor(item.hypertensionRisk))
                      .fontWeight(FontWeight.Medium);
                    Text(this.getRiskLabel(item.hypertensionRisk))
                      .fontSize(9)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.getRiskColor(item.hypertensionRisk))
                      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                      .borderRadius(4)
                      .margin({ left: 4 });
                  }
                  .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8);

                  Row() {
                    Text('糖尿病')
                      .fontSize(10)
                      .fontColor(this.getRiskColor(item.diabetesRisk))
                      .fontWeight(FontWeight.Medium);
                    Text(this.getRiskLabel(item.diabetesRisk))
                      .fontSize(9)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.getRiskColor(item.diabetesRisk))
                      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                      .borderRadius(4)
                      .margin({ left: 4 });
                  }
                  .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8);

                  Row() {
                    Text('跌倒')
                      .fontSize(10)
                      .fontColor(this.getRiskColor(item.fallRisk))
                      .fontWeight(FontWeight.Medium);
                    Text(this.getRiskLabel(item.fallRisk))
                      .fontSize(9)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.getRiskColor(item.fallRisk))
                      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                      .borderRadius(4)
                      .margin({ left: 4 });
                  }
                  .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8);
                }
                .width('100%');

                if (item.assessResult) {
                  Text(item.assessResult)
                    .fontSize(12)
                    .fontColor('#666666')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                    .margin({ top: 8 })
                    .padding(8)
                    .backgroundColor('#FAFBFC')
                    .borderRadius(8);
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
            }, (item: RiskRecord) => 'risk-' + item.id);

            Button('开始新的评估')
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(22)
              .margin({ top: 8, bottom: 32 })
              .onClick(() => { router.push({ url: 'pages/RiskAssessmentPage' }); });
          }
          .width('90%')
          .padding({ top: 16, bottom: 16 });
        }
        .layoutWeight(1);
      }

      if (this.showDeleteDialog) {
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#00000044')
            .onClick(() => { this.showDeleteDialog = false; });

          Column({ space: 16 }) {
            Text('确认删除')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333');
            Text('确定要删除这条评估记录吗？此操作不可恢复。')
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center);
            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .height(40)
                .fontSize(14)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(20)
                .onClick(() => { this.showDeleteDialog = false; });
              Button('删除')
                .layoutWeight(1)
                .height(40)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF4D4F')
                .borderRadius(20)
                .onClick(() => { this.confirmDelete(); });
            }
            .width('100%');
          }
          .width('75%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Center);
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
