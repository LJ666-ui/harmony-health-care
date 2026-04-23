import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface MedicineDetail {
  id: number;
  name: string;
  indication: string;
  usageDesc: string;
  taboo: string;
  source: string;
}

@Entry
@Component
struct MedicationDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State medicine: MedicineDetail | null = null;
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    this.loadMedicineDetail();
  }

  async loadMedicineDetail(): Promise<void> {
    this.isLoading = true;
    try {
      const params = router.getParams() as Record<string, number>;
      if (params && params.medicineId) {
        const medicineId = params.medicineId;
        const url = ApiConstants.MEDICINE_DETAIL + medicineId;
        const response: BaseResponse<MedicineDetail> = await HttpUtil.get<MedicineDetail>(url);
        if (response.success && response.data) {
          this.medicine = response.data;
        } else {
          console.error('获取药品详情失败:', response.message);
        }
      } else {
        console.error('未接收到药品ID参数');
      }
    } catch (error) {
      console.error('加载药品详情失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#E6F4FF')
          .borderRadius(20)
          .onClick(() => {
            router.back();
          })
        Text('药品详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('').width(40)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#999999');
        }
        .width('100%')
        .height(400)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else if (!this.medicine) {
        Column() {
          Text('💊')
            .fontSize(48)
            .margin({ bottom: 16 });
          Text('药品不存在或加载失败')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#999999');
        }
        .width('100%')
        .height(400)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        Scroll() {
          Column() {
            Column() {
              Text('💊')
                .fontSize(80)
                .margin({ bottom: 16 });
              Text(this.medicine.name)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 });
              Row() {
                Text(this.medicine.source || '未知来源')
                  .fontSize(12)
                  .fontColor('#1677FF')
                  .backgroundColor('#E6F4FF')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(4);
              }
            }
            .width('100%')
            .padding({ top: 24, bottom: 24 })
            .backgroundColor('#FFFFFF')
            .alignItems(HorizontalAlign.Center);

            Column() {
              Text('适应症')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.medicine.indication || '暂无信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start);
            }
            .width('85%')
            .margin({ top: 16, bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            Column() {
              Text('用法用量')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.medicine.usageDesc || '暂无信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start);
            }
            .width('85%')
            .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            Column() {
              Text('注意事项（禁忌）')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.medicine.taboo || '暂无信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start);
            }
            .width('85%')
            .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            Column() {
              Text('数据来源')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.medicine.source || '暂无信息')
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start);
            }
            .width('85%')
            .margin({ bottom: 100, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });
          }
          .width('100%')
          .padding({ top: 0 });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
