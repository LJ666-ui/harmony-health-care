import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { ToastUtil } from '../common/utils/ToastUtil';

type DosageForm = 'decoction' | 'pill' | 'powder';

interface DosageResult {
  adultDose: number;
  childDose: number;
  unit: string;
  warnings: string[];
  populationType: string;
  reductionRatio: string;
}

interface FormInfo {
  label: string;
  desc: string;
  icon: string;
  baseDose: string;
  maxDose: string;
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
  @State isPregnant: boolean = false;
  private scroller: Scroller = new Scroller();

  private static readonly DOSE_UNIT: Record<DosageForm, string> = {
    'decoction': '克',
    'pill': '克',
    'powder': '克'
  };

  getFormInfo(form: DosageForm): FormInfo {
    switch (form) {
      case 'decoction':
        return {
          label: '汤剂',
          desc: '水煎服用，吸收快，药效强',
          icon: '🍵',
          baseDose: '5-30g',
          maxDose: '30g'
        };
      case 'pill':
        return {
          label: '丸剂',
          desc: '丸状制剂，便于储存携带',
          icon: '💊',
          baseDose: '3-15g',
          maxDose: '15g'
        };
      case 'powder':
        return {
          label: '散剂',
          desc: '粉末冲服或外用，起效迅速',
          icon: '🌫️',
          baseDose: '1-9g',
          maxDose: '9g'
        };
      default:
        return { label: '', desc: '', icon: '', baseDose: '', maxDose: '' };
    }
  }

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
      } else {
        this.isSpecialPopulation = false;
        this.populationType = '';
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

    const warnings: string[] = [];
    let adultDose: number = 0;
    let childDose: number = 0;
    let reductionRatio: string = '';

    switch (this.selectedForm) {
      case 'decoction':
        adultDose = Math.round(weightNum * 0.2);
        if (adultDose < 5) adultDose = 5;
        if (adultDose > 30) adultDose = 30;

        if (ageNum < 1) {
          childDose = Math.round(adultDose * 0.25);
          reductionRatio = '1/4';
          warnings.push('婴幼儿用药需严格遵医嘱，建议减量至成人剂量的1/4');
          warnings.push('婴幼儿肝肾功能尚未发育完全，需特别谨慎');
        } else if (ageNum < 6) {
          childDose = Math.round(adultDose * 0.33);
          reductionRatio = '1/3';
          warnings.push('儿童（1-6岁）用药需谨慎，建议减量至成人剂量的1/3');
        } else if (ageNum < 12) {
          childDose = Math.round(adultDose * 0.5);
          reductionRatio = '1/2';
          warnings.push('儿童（6-12岁）建议减量至成人剂量的1/2');
        } else if (ageNum >= 18) {
          childDose = adultDose;
          reductionRatio = '全量';

          if (weightNum < 40) {
            warnings.push('体重偏轻者可适当减少剂量，建议从低剂量开始');
          }
          if (weightNum > 80) {
            warnings.push('体重较重者不宜超过最大推荐剂量（30g）');
          }
        } else {
          childDose = Math.round(adultDose * 0.75);
          reductionRatio = '3/4';
          warnings.push('青少年（12-18岁）可使用成人剂量的3/4');
        }
        break;

      case 'pill':
        adultDose = Math.round(weightNum * 0.12);
        if (adultDose < 3) adultDose = 3;
        if (adultDose > 15) adultDose = 15;

        if (ageNum < 12) {
          childDose = Math.round(adultDose * 0.5);
          reductionRatio = '1/2';
          warnings.push('儿童服用丸剂应减半，并注意吞咽安全');
          warnings.push('丸剂体积较大，儿童服用需防噎呛风险');
        } else if (ageNum >= 18) {
          childDose = adultDose;
          reductionRatio = '全量';
        } else {
          childDose = Math.round(adultDose * 0.75);
          reductionRatio = '3/4';
        }
        break;

      case 'powder':
        adultDose = Math.round(weightNum * 0.06);
        if (adultDose < 1) adultDose = 1;
        if (adultDose > 9) adultDose = 9;

        if (ageNum < 12) {
          childDose = Math.round(adultDose * 0.5);
          reductionRatio = '1/2';
          warnings.push('散剂口感较刺激，儿童使用需谨慎');
          warnings.push('散剂建议冲服或调蜜后服用，减少刺激性');
        } else if (ageNum >= 18) {
          childDose = adultDose;
          reductionRatio = '全量';
        } else {
          childDose = Math.round(adultDose * 0.75);
          reductionRatio = '3/4';
        }
        break;
    }

    if (ageNum >= 65) {
      warnings.push('老年人肝肾功能减退，建议从最低剂量开始，逐步调整');
      warnings.push('老年人需注意药物相互作用，避免多种药物同服');
    }

    if (this.isPregnant) {
      warnings.push('⛔ 孕妇禁用或慎用毒性药材、活血化瘀药、峻下逐水药');
      warnings.push('孕妇用药必须严格遵医嘱，切勿自行用药');
    }

    this.dosageResult = {
      adultDose: adultDose,
      childDose: childDose,
      unit: DosageCalc.DOSE_UNIT[this.selectedForm],
      warnings: warnings,
      populationType: this.populationType,
      reductionRatio: reductionRatio
    };
    this.showResult = true;

    setTimeout(() => {
      this.scroller.scrollTo({ xOffset: 0, yOffset: 600, animation: { duration: 400 } });
    }, 150);
  }

  resetCalculator(): void {
    this.age = '';
    this.weight = '';
    this.selectedForm = 'decoction';
    this.dosageResult = null;
    this.showResult = false;
    this.isSpecialPopulation = false;
    this.populationType = '';
    this.isPregnant = false;
    ToastUtil.showSuccess('已重置');
  }

  build() {
    Column() {
      Header({ title: '用量计算器', showBack: true });

      Scroll(this.scroller) {
        Column({ space: 20 }) {
          Column({ space: 16 }) {
            Text('根据年龄和体重计算中药用量')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%');

            Text('💡 本工具提供标准剂量参考，具体用药请遵医嘱')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%');
          }
          .width('100%');

          Column({ space: 20 }) {
            Row({ space: 16 }) {
              Column({ space: 8 }) {
                Text('📅 年龄')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .width('100%');

                TextInput({ placeholder: '请输入年龄', text: this.age })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor('#F5F7FA')
                  .borderRadius(10)
                  .type(InputType.Number)
                  .onChange((value: string) => {
                    this.age = value;
                    this.checkSpecialPopulation();
                  });
              }
              .layoutWeight(1);

              Column({ space: 8 }) {
                Text('⚖️ 体重(kg)')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .width('100%');

                TextInput({ placeholder: '请输入体重', text: this.weight })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor('#F5F7FA')
                  .borderRadius(10)
                  .type(InputType.Number)
                  .onChange((value: string) => {
                    this.weight = value;
                  });
              }
              .layoutWeight(1);
            }
            .width('100%');

            if (this.isSpecialPopulation) {
              Row({ space: 8 }) {
                Text('🔔')
                  .fontSize(16);

                Text('检测到特殊人群：' + this.populationType)
                  .fontSize(13)
                  .fontColor('#FAAD14')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1);

                Text('将自动减量')
                  .fontSize(12)
                  .fontColor('#FAAD14')
                  .backgroundColor('#FFFBE6')
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .borderRadius(10);
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFFBE6')
              .borderRadius(10)
              .border({ width: 1, color: '#FFE58F', style: BorderStyle.Dashed });
            }

            Column({ space: 8 }) {
              Text('💊 选择剂型')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%');

              Row({ space: 12 }) {
                ForEach(['decoction', 'pill', 'powder'] as DosageForm[], (form: DosageForm) => {
                  Column({ space: 6 }) {
                    Text(this.getFormInfo(form).icon)
                      .fontSize(24);

                    Text(this.getFormInfo(form).label)
                      .fontSize(15)
                      .fontColor(this.selectedForm === form ? '#FFFFFF' : '#333333')
                      .fontWeight(FontWeight.Bold);

                    Text(this.getFormInfo(form).desc)
                      .fontSize(11)
                      .fontColor(this.selectedForm === form ? '#E6F4FF' : '#999999')
                      .maxLines(2)
                      .textAlign(TextAlign.Center);

                    Text('参考：' + this.getFormInfo(form).baseDose)
                      .fontSize(10)
                      .fontColor(this.selectedForm === form ? '#BAE7FF' : '#BBBBBB');
                  }
                  .width('31%')
                  .height(105)
                  .padding({ top: 12, bottom: 12 })
                  .backgroundColor(this.selectedForm === form ? '#1677FF' : '#F5F7FA')
                  .borderRadius(12)
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

            Row({ space: 12 }) {
              Button('📊 计算剂量')
                .layoutWeight(1)
                .height(48)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(24)
                .onClick(() => this.calculateDosage());

              Button('🔄 重置')
                .height(48)
                .fontSize(14)
                .fontColor('#666666')
                .backgroundColor('#F5F7FA')
                .borderRadius(24)
                .onClick(() => this.resetCalculator());
            }
            .width('100%');
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 6, color: '#0000000A', offsetX: 0, offsetY: 2 });

          if (this.showResult && this.dosageResult) {
            Column({ space: 16 }) {
              Row() {
                Text('📊 计算结果')
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .layoutWeight(1);

                if (this.dosageResult!.reductionRatio !== '全量') {
                  Text('减量比例：' + this.dosageResult!.reductionRatio)
                    .fontSize(12)
                    .fontColor('#FF4D4F')
                    .backgroundColor('#FFF2F0')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .borderRadius(12);
                }
              }
              .width('100%');

              Row({ space: 16 }) {
                Column({ space: 10 }) {
                  Row() {
                    Text('👤')
                      .fontSize(18);

                    Text('成人剂量')
                      .fontSize(13)
                      .fontColor('#666666')
                      .margin({ left: 4 });
                  }

                  Text(this.dosageResult!.adultDose.toString())
                    .fontSize(36)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1677FF');

                  Text(this.dosageResult!.unit)
                    .fontSize(14)
                    .fontColor('#1677FF');
                }
                .layoutWeight(1)
                .height(130)
                .padding(16)
                .backgroundColor('#E6F4FF')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .border({ width: 1.5, color: '#91D5FF', style: BorderStyle.Solid });

                Column({ space: 10 }) {
                  Row() {
                    Text('👶')
                      .fontSize(18);

                    Text(this.dosageResult!.populationType || '适用剂量')
                      .fontSize(13)
                      .fontColor('#666666')
                      .margin({ left: 4 });
                  }

                  Text(this.dosageResult!.childDose.toString())
                    .fontSize(36)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#52C41A');

                  Text(this.dosageResult!.unit)
                    .fontSize(14)
                    .fontColor('#52C41A');
                }
                .layoutWeight(1)
                .height(130)
                .padding(16)
                .backgroundColor('#F6FFED')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .border({ width: 1.5, color: '#B7EB8F', style: BorderStyle.Solid });
              }
              .width('100%');

              if (this.dosageResult.warnings.length > 0) {
                Column({ space: 12 }) {
                  Row() {
                    Text('⚠️ 注意事项')
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#FAAD14')
                      .layoutWeight(1);

                    Text(this.dosageResult.warnings.length + '条')
                      .fontSize(12)
                      .fontColor('#FAAD14')
                      .backgroundColor('#FFFBE6')
                      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                      .borderRadius(10);
                  }
                  .width('100%');

                  ForEach(this.dosageResult.warnings, (warning: string, index: number) => {
                    Row({ space: 10 }) {
                      Text((index + 1).toString())
                        .fontSize(13)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                        .width(22)
                        .height(22)
                        .backgroundColor('#FAAD14')
                        .borderRadius(11)
                        .textAlign(TextAlign.Center)
                        .textVerticalAlign(TextVerticalAlign.CENTER);

                      Text(warning)
                        .fontSize(13)
                        .fontColor('#666666')
                        .lineHeight(20)
                        .layoutWeight(1);
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top)
                    .padding({ top: 6, bottom: 6 });
                  }, (_warning: string, _index: number) => _index.toString());
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFBE6')
                .borderRadius(12)
                .border({ width: 1.5, color: '#FFE58F', style: BorderStyle.Dashed });
              }

              Column({ space: 10 }) {
                Text('📋 剂量参考标准（' + this.getFormInfo(this.selectedForm).label + '）')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .width('100%');

                Text('• 成人一般用量：' + this.getFormInfo(this.selectedForm).baseDose + '/味\n• 最大推荐剂量：' + this.getFormInfo(this.selectedForm).maxDose + '/味\n• 老年人：从最低剂量开始，逐步调整\n• 儿童：按年龄递减，详见上方注意事项\n• 孕妇：禁用或慎用毒性药材，必须遵医嘱')
                  .fontSize(13)
                  .fontColor('#666666')
                  .lineHeight(22)
                  .width('100%');
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FAFAFA')
              .borderRadius(10);

              Text('⚕️ 以上剂量仅供参考，具体用药请遵医嘱')
                .fontSize(12)
                .fontColor('#999999')
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(12)
                .backgroundColor('#F5F5F5')
                .borderRadius(8);
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 6, color: '#0000000A', offsetX: 0, offsetY: 2 });
          }

          Column({ space: 12 }) {
            Text('❓ 常见问题')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%');

            Column({ space: 12 }) {
              Text('Q：为什么不同剂型剂量不同？\nA：汤剂吸收快但损失多；丸剂作用缓和持久；散剂起效迅速但刺激性大。')

              Text('Q：儿童剂量如何计算更准确？\nA：常用方法：① 按年龄折算 ② 按体重计算 ③ Young公式。建议遵医嘱。')

              Text('Q：老年人用药需要注意什么？\nA：老年人代谢慢，应从小剂量开始，注意药物相互作用，定期监测肝肾功能。')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FAFAFA')
            .borderRadius(10)

            ForEach([
              { q: '为什么不同剂型剂量不同？', a: '汤剂吸收快但损失多；丸剂作用缓和持久；散剂起效迅速但刺激性大。' },
              { q: '儿童剂量如何计算更准确？', a: '常用方法：① 按年龄折算 ② 按体重计算 ③ Young公式。建议遵医嘱。' },
              { q: '老年人用药需要注意什么？', a: '老年人代谢慢，应从小剂量开始，注意药物相互作用，定期监测肝肾功能。' }
            ], (item: Record<string, string>, index: number) => {
              Column({ space: 8 }) {
                Text('Q：' + item['q'])
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1677FF')
                  .width('100%');

                Text('A：' + item['a'])
                  .fontSize(12)
                  .fontColor('#666666')
                  .lineHeight(19)
                  .width('100%');
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .border({ width: 1, color: '#F0F0F0', style: BorderStyle.Solid });
            }, (_item: Record<string, string>, _index: number) => _index.toString());
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 6, color: '#0000000A', offsetX: 0, offsetY: 2 });
        }
        .width('90%')
        .padding({ top: 20, bottom: 40 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
