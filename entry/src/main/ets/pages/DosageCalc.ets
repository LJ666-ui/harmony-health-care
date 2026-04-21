import { router } from '@kit.ArkUI';
import { ToastUtil } from '../common/utils/ToastUtil';

type DosageForm = 'decoction' | 'pill' | 'powder';

interface DosageResult {
  adultDose: number;
  childDose: number;
  unit: string;
  warnings: string[];
}

@Entry
@Component
struct DosageCalc {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State age: string = '';
  @State weight: string = '';
  @State selectedForm: DosageForm = 'decoction';
  @State dosageResult: DosageResult | null = null;
  @State showResult: boolean = false;
  @State isSpecialPopulation: boolean = false;
  @State populationType: string = '';

  private static readonly BASE_ADULT_DOSE: Record<DosageForm, number> = {
    'decoction': 10,
    'pill': 6,
    'powder': 3
  };

  private static readonly DOSE_UNIT: Record<DosageForm, string> = {
    'decoction': '克',
    'pill': '克',
    'powder': '克'
  };

  aboutToAppear(): void {
    this.checkSpecialPopulation();
  }

  checkSpecialPopulation(): void {
    if (this.age && parseInt(this.age) > 0) {
      const ageNum: number = parseInt(this.age);
      if (ageNum < 12) {
        this.isSpecialPopulation = true;
        this.populationType = '儿童';
      } else if (ageNum >= 65) {
        this.isSpecialPopulation = true;
        this.populationType = '老年人';
      }
    } else {
      this.isSpecialPopulation = false;
      this.populationType = '';
    }
  }

  calculateDosage(): void {
    if (!this.age || !this.weight) {
      ToastUtil.showInfo('请输入年龄和体重');
      return;
    }

    const ageNum: number = parseInt(this.age);
    const weightNum: number = parseFloat(this.weight);

    if (isNaN(ageNum) || isNaN(weightNum) || ageNum <= 0 || weightNum <= 0) {
      ToastUtil.showInfo('请输入有效的年龄和体重');
      return;
    }

    if (ageNum > 120 || weightNum > 300) {
      ToastUtil.showInfo('请输入合理的数值范围');
      return;
    }

    const baseDose: number = DosageCalc.BASE_ADULT_DOSE[this.selectedForm];
    const warnings: string[] = [];

    let adultDose: number = baseDose;
    let childDose: number = 0;

    if (this.selectedForm === 'decoction') {
      adultDose = Math.round(weightNum * 0.2);
      if (adultDose < 5) adultDose = 5;
      if (adultDose > 30) adultDose = 30;

      if (ageNum < 1) {
        childDose = Math.round(adultDose * 0.25);
        warnings.push('婴幼儿用药需严格遵医嘱，建议减量至成人剂量的1/4');
      } else if (ageNum < 6) {
        childDose = Math.round(adultDose * 0.33);
        warnings.push('儿童用药需谨慎，建议减量至成人剂量的1/3');
      } else if (ageNum < 12) {
        childDose = Math.round(adultDose * 0.5);
        warnings.push('儿童用药建议减量至成人剂量的1/2');
      } else {
        childDose = adultDose;
      }
    } else if (this.selectedForm === 'pill') {
      adultDose = Math.round(weightNum * 0.12);
      if (adultDose < 3) adultDose = 3;
      if (adultDose > 15) adultDose = 15;

      if (ageNum < 12) {
        childDose = Math.round(adultDose * 0.5);
        warnings.push('儿童服用丸剂应减半，并注意吞咽安全');
      } else {
        childDose = adultDose;
      }
    } else {
      adultDose = Math.round(weightNum * 0.06);
      if (adultDose < 1) adultDose = 1;
      if (adultDose > 9) adultDose = 9;

      if (ageNum < 12) {
        childDose = Math.round(adultDose * 0.5);
        warnings.push('散剂口感较刺激，儿童使用需谨慎');
      } else {
        childDose = adultDose;
      }
    }

    if (weightNum < 40 && ageNum >= 18) {
      warnings.push('体重偏轻者可适当减少剂量');
    }

    if (weightNum > 80) {
      warnings.push('体重较重者不宜超过最大推荐剂量');
    }

    if (ageNum >= 65) {
      warnings.push('老年人肝肾功能减退，建议从低剂量开始');
    }

    this.dosageResult = {
      adultDose: adultDose,
      childDose: childDose,
      unit: DosageCalc.DOSE_UNIT[this.selectedForm],
      warnings: warnings
    };
    this.showResult = true;
  }

  getFormLabel(form: DosageForm): string {
    switch (form) {
      case 'decoction':
        return '汤剂';
      case 'pill':
        return '丸剂';
      case 'powder':
        return '散剂';
      default:
        return '';
    }
  }

  getFormDesc(form: DosageForm): string {
    switch (form) {
      case 'decoction':
        return '水煎服用，吸收快，药效强';
      case 'pill':
        return '丸状制剂，便于储存携带';
      case 'powder':
        return '粉末冲服或外用，起效迅速';
      default:
        return '';
    }
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(20)
          .fontColor('#1677FF')
          .onClick(() => router.back());

        Text('用量计算器')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center);

      Scroll() {
        Column({ space: 20 }) {
          Text('根据年龄和体重计算中药用量')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%');

          Column({ space: 20 }) {
            Column({ space: 8 }) {
              Text('📅 年龄（岁）')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%');

              TextInput({ placeholder: '请输入年龄', text: this.age })
                .width('100%')
                .height(48)
                .fontSize(16)
                .backgroundColor('#F5F7FA')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.age = value;
                  this.checkSpecialPopulation();
                });
            }
            .width('100%');

            Column({ space: 8 }) {
              Text('⚖️ 体重（公斤）')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%');

              TextInput({ placeholder: '请输入体重', text: this.weight })
                .width('100%')
                .height(48)
                .fontSize(16)
                .backgroundColor('#F5F7FA')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.weight = value;
                });
            }
            .width('100%');

            Column({ space: 8 }) {
              Text('💊 选择剂型')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%');

              Row({ space: 12 }) {
                ForEach(['decoction', 'pill', 'powder'] as DosageForm[], (form: DosageForm) => {
                  Column({ space: 6 }) {
                    Text(this.getFormLabel(form))
                      .fontSize(15)
                      .fontColor(this.selectedForm === form ? '#FFFFFF' : '#666666')
                      .fontWeight(FontWeight.Medium);

                    Text(this.getFormDesc(form))
                      .fontSize(11)
                      .fontColor(this.selectedForm === form ? '#E6F4FF' : '#999999')
                      .maxLines(2);
                  }
                  .width('30%')
                  .height(72)
                  .padding(10)
                  .backgroundColor(this.selectedForm === form ? '#1677FF' : '#F5F7FA')
                  .borderRadius(10)
                  .border({
                    width: this.selectedForm === form ? 2 : 1,
                    color: this.selectedForm === form ? '#1677FF' : '#E0E0E0'
                  })
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .onClick(() => {
                    this.selectedForm = form;
                  });
                }, (form: DosageForm) => form);
              }
              .width('100%');
            }
            .width('100%');

            Button('计算剂量')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(24)
              .onClick(() => this.calculateDosage());
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 6, color: '#0000000A', offsetX: 0, offsetY: 2 });

          if (this.showResult && this.dosageResult) {
            Column({ space: 16 }) {
              Text('📊 计算结果')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%');

              Row({ space: 16 }) {
                Column({ space: 8 }) {
                  Text('成人剂量')
                    .fontSize(13)
                    .fontColor('#666666');

                  Text(this.dosageResult!.adultDose.toString() + ' ' + this.dosageResult!.unit)
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1677FF');
                }
                .layoutWeight(1)
                .height(100)
                .padding(16)
                .backgroundColor('#E6F4FF')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center);

                Column({ space: 8 }) {
                  Text('儿童剂量')
                    .fontSize(13)
                    .fontColor('#666666');

                  Text(this.dosageResult!.childDose.toString() + ' ' + this.dosageResult!.unit)
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#52C41A');
                }
                .layoutWeight(1)
                .height(100)
                .padding(16)
                .backgroundColor('#F6FFED')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center);
              }
              .width('100%');

              if (this.dosageResult.warnings.length > 0) {
                Column({ space: 10 }) {
                  Row() {
                    Text('⚠️ 注意事项')
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#FAAD14')
                      .layoutWeight(1);
                  }
                  .width('100%');

                  ForEach(this.dosageResult.warnings, (warning: string, index: number) => {
                    Row({ space: 8 }) {
                      Text((index + 1).toString() + '.')
                        .fontSize(13)
                        .fontColor('#FAAD14');

                      Text(warning)
                        .fontSize(13)
                        .fontColor('#666666')
                        .lineHeight(20)
                        .layoutWeight(1);
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top);
                  }, (warning: string, index: number) => index.toString());
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFBE6')
                .borderRadius(12)
                .border({ width: 1, color: '#FFE58F' });
              }

              Text('💡 以上剂量仅供参考，具体用药请遵医嘱')
                .fontSize(12)
                .fontColor('#999999')
                .width('100%')
                .textAlign(TextAlign.Center);
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 6, color: '#0000000A', offsetX: 0, offsetY: 2 });
          }

          Column({ space: 12 }) {
            Text('📋 剂量参考标准')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%');

            Text('• 汤剂：成人一般 5-30g/味，儿童按年龄递减\n• 丸剂：成人一般 3-15g/次，儿童减半\n• 散剂：成人一般 1-9g/次，儿童慎用\n• 老年人：建议从最低剂量开始，逐步调整\n• 孕妇：禁用或慎用毒性药材，必须遵医嘱')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(22)
              .width('100%');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(12);
        }
        .width('90%')
        .padding({ top: 20, bottom: 40 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
