import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface DosageResult {
  adultDosage: string;
  childDosage: string;
  unit: string;
  formula: string;
}

@Entry
@Component
struct DosageCalc {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State age: number = 30;
  @State weight: number = 60;
  @State dosageType: string = '汤剂';
  @State isPregnant: boolean = false;
  @State showResult: boolean = false;
  @State result: DosageResult = {
    adultDosage: '',
    childDosage: '',
    unit: 'g',
    formula: ''
  };

  private dosageTypes: string[] = ['汤剂', '丸剂', '散剂'];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
  }

  calculateDosage(): void {
    let baseDosage: number = 10;
    let multiplier: number = 1;

    if (this.dosageType === '汤剂') {
      baseDosage = this.weight * 0.15;
      multiplier = 1.0;
    } else if (this.dosageType === '丸剂') {
      baseDosage = this.weight * 0.08;
      multiplier = 0.6;
    } else if (this.dosageType === '散剂') {
      baseDosage = this.weight * 0.05;
      multiplier = 0.4;
    }

    const adultDose: number = Math.round(baseDosage * multiplier * 10) / 10;
    let childDose: number = 0;
    let formula: string = '';

    if (this.isPregnant) {
      childDose = Math.round(adultDose * 0.5 * 10) / 10;
      formula = `孕妇剂量 = 成人剂量 × 50%（需遵医嘱）`;
    } else if (this.age < 18) {
      childDose = Math.round(adultDose * (this.age / (this.age + 12)) * 10) / 10;
      formula = `儿童剂量 = 成人剂量 × 年龄/(年龄+12)`;
    } else if (this.age >= 65) {
      childDose = Math.round(adultDose * 0.7 * 10) / 10;
      formula = `老年剂量 = 成人剂量 × 70%`;
    } else {
      childDose = adultDose;
      formula = `标准成人剂量`;
    }

    this.result = {
      adultDosage: String(adultDose),
      childDosage: String(childDose),
      unit: 'g',
      formula: formula
    };
    this.showResult = true;
  }

  getWarningMessage(): string[] {
    const warnings: string[] = [];

    if (this.isPregnant) {
      warnings.push('🤰 孕妇用药需极其谨慎，请务必咨询医生');
      warnings.push('⛔ 部分中药具有活血化瘀作用，可能影响胎儿发育');
      warnings.push('📋 建议使用安全性高的药材，避免峻下、有毒之品');
    }
    if (this.age < 12) {
      warnings.push('⚠️ 儿童用药需严格遵医嘱，建议减量使用');
    }
    if (this.age >= 65) {
      warnings.push('👴 老年人肝肾功能减退，建议减量20-30%');
    }
    if (this.weight < 40) {
      warnings.push('💪 体重偏低，建议适当减少剂量');
    }
    if (this.weight > 90) {
      warnings.push('⚖️ 体重偏高，请咨询医生调整剂量');
    }

    return warnings;
  }

  build() {
    Column() {
      Header({ title: '用法用量计算器', showBack: true });

      Scroll() {
        Column({ space: 16 }) {
          Text('中药用法用量智能计算')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 8 });

          Column({ space: 20 }) {
            Column({ space: 8 }) {
              Text('年龄（岁）')
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#666666');

              Row() {
                Button('-')
                  .width(40)
                  .height(36)
                  .fontSize(18)
                  .fontColor('#1677FF')
                  .backgroundColor('#F0F5FF')
                  .borderRadius(8)
                  .onClick(() => {
                    if (this.age > 1) {
                      this.age--;
                      this.showResult = false;
                    }
                  });

                Text(String(this.age))
                  .fontSize(this.isElderMode ? 18 : 16)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                  .width(80)
                  .textAlign(TextAlign.Center);

                Button('+')
                  .width(40)
                  .height(36)
                  .fontSize(18)
                  .fontColor('#1677FF')
                  .backgroundColor('#F0F5FF')
                  .borderRadius(8)
                  .onClick(() => {
                    if (this.age < 120) {
                      this.age++;
                      this.showResult = false;
                    }
                  });
              }
              .justifyContent(FlexAlign.SpaceBetween);
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);

            Column({ space: 8 }) {
              Text('体重（kg）')
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#666666');

              Row() {
                Button('-')
                  .width(40)
                  .height(36)
                  .fontSize(18)
                  .fontColor('#1677FF')
                  .backgroundColor('#F0F5FF')
                  .borderRadius(8)
                  .onClick(() => {
                    if (this.weight > 10) {
                      this.weight -= 5;
                      this.showResult = false;
                    }
                  });

                Text(String(this.weight))
                  .fontSize(this.isElderMode ? 18 : 16)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                  .width(80)
                  .textAlign(TextAlign.Center);

                Button('+')
                  .width(40)
                  .height(36)
                  .fontSize(18)
                  .fontColor('#1677FF')
                  .backgroundColor('#F0F5FF')
                  .borderRadius(8)
                  .onClick(() => {
                    if (this.weight < 200) {
                      this.weight += 5;
                      this.showResult = false;
                    }
                  });
              }
              .justifyContent(FlexAlign.SpaceBetween);
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);

            Column({ space: 10 }) {
              Text('选择剂型')
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#666666');

              Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                ForEach(this.dosageTypes, (type: string) => {
                  Text(type)
                    .fontSize(this.isElderMode ? 14 : 13)
                    .fontColor(this.dosageType === type ? '#FFFFFF' : '#666666')
                    .padding({ left: 24, right: 24, top: 10, bottom: 10 })
                    .backgroundColor(this.dosageType === type ? '#1677FF' : '#F5F5F5')
                    .borderRadius(20)
                    .margin({ right: 12, bottom: 8 })
                    .onClick(() => {
                      this.dosageType = type;
                      this.showResult = false;
                    });
                }, (type: string) => type);
              }
              .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);

            Column({ space: 10 }) {
              Text('特殊人群')
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#666666');

              Row() {
                Text('🤰 是否为孕妇：')
                  .fontSize(this.isElderMode ? 14 : 13)
                  .fontColor('#333333');

                Toggle({ type: ToggleType.Switch, isOn: this.isPregnant })
                  .selectedColor('#FF4D4F')
                  .switchPointColor('#FFFFFF')
                  .onChange((isOn: boolean) => {
                    this.isPregnant = isOn;
                    this.showResult = false;
                  });
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center);
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFF1F0')
            .borderRadius(12)
            .border({ width: 1, color: '#FFCCC7' });

            Button('开始计算')
              .width('100%')
              .height(48)
              .fontSize(this.isElderMode ? 17 : 15)
              .fontColor('#FFFFFF')
              .backgroundColor('#52C41A')
              .borderRadius(24)
              .margin({ top: 8 })
              .onClick(() => this.calculateDosage());

            if (this.showResult) {
              Column({ space: 16 }) {
                Text(this.isPregnant ? '⚠️ 孕妇用药建议' : '计算结果')
                  .fontSize(this.isElderMode ? 17 : 15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isPregnant ? '#FF4D4F' : '#333333')
                  .width('100%')
                  .textAlign(TextAlign.Center);

                Column({ space: 12 }) {
                  Row() {
                    Text('成人参考剂量：')
                      .fontSize(this.isElderMode ? 15 : 14)
                      .fontColor('#666666');
                    Text(this.result.adultDosage + ' ' + this.result.unit)
                      .fontSize(this.isElderMode ? 17 : 16)
                      .fontColor('#1677FF')
                      .fontWeight(FontWeight.Bold);
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween);

                  Row() {
                    Text(this.isPregnant ? '孕妇建议剂量：' : '调整后剂量：')
                      .fontSize(this.isElderMode ? 15 : 14)
                      .fontColor('#666666');
                    Text(this.result.childDosage + ' ' + this.result.unit)
                      .fontSize(this.isElderMode ? 17 : 16)
                      .fontColor(this.isPregnant ? '#FF4D4F' : '#52C41A')
                      .fontWeight(FontWeight.Bold);
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween);

                  Divider()
                    .color('#F0F0F0');

                  Text('计算公式：' + this.result.formula)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#999999')
                    .width('100%');
                }
                .width('100%')
                .padding(16)
                .backgroundColor(this.isPregnant ? '#FFF1F0' : '#FAFFF0')
                .borderRadius(12)
                .border({ width: 1, color: this.isPregnant ? '#FFCCC7' : '#B7EB8F' });

                if (this.getWarningMessage().length > 0) {
                  Column({ space: 8 }) {
                    Text(this.isPregnant ? '🚨 孕妇安全警示' : '温馨提示')
                      .fontSize(this.isElderMode ? 15 : 14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.isPregnant ? '#CF1322' : '#FAAD14')
                      .width('100%');

                    ForEach(this.getWarningMessage(), (warning: string, index: number) => {
                      Text(warning)
                        .fontSize(this.isElderMode ? 14 : 13)
                        .fontColor(this.isPregnant ? '#CF1322' : '#D46B08')
                        .width('100%')
                        .lineHeight(20);
                    }, (warning: string, index: number) => String(index));
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(this.isPregnant ? '#FFF1F0' : '#FFFBE6')
                  .borderRadius(12)
                  .border({ width: 1, color: this.isPregnant ? '#FFCCC7' : '#FFE58F' });
                }
              }
              .width('100%')
              .padding(20)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 8, color: '#00000015', offsetX: 0, offsetY: 4 });
            }

            Column({ space: 12 }) {
              Text('常见剂型说明')
                .fontSize(this.isElderMode ? 16 : 14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%');

              Column({ space: 10 }) {
                this.buildDosageInfoItem('汤剂', '水煎服用，吸收快，药效强', '常用量：10-30g/次');
                this.buildDosageInfoItem('丸剂', '便于储存，作用缓和持久', '常用量：6-9g/次');
                this.buildDosageInfoItem('散剂', '见效快，但口感较差', '常用量：1-3g/次');
              }
              .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 80 });
          }
          .width('90%')
          .padding({ top: 16 });
        }
        .width('100%');
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .layoutWeight(1);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }

  @Builder
  buildDosageInfoItem(title: string, desc: string, usage: string): void {
    Column({ space: 6 }) {
      Row() {
        Text(title)
          .fontSize(this.isElderMode ? 15 : 14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1677FF');
        Blank();
        Text(usage)
          .fontSize(this.isElderMode ? 13 : 12)
          .fontColor('#999999');
      }
      .width('100%');

      Text(desc)
        .fontSize(this.isElderMode ? 13 : 12)
        .fontColor('#666666')
        .width('100%');
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F9F9F9')
    .borderRadius(8);
  }
}
