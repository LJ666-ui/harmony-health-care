import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';

interface MedicationInfo {
  id: string;
  name: string; // 商品名
  genericName: string; // 通用名
  category: string; // 分类
  dosage: string; // 规格
  indications: string; // 适应症
  usage: string; // 用法用量
  precautions: string; // 注意事项
  price: string; // 价格参考
  description: string; // 完整说明书
  sideEffects: string[]; // 副作用
  contraindications: string[]; // 禁忌
  interactions: string[]; // 相互作用
  storage: string; // 存储条件
  status: string; // 状态
  reminder: boolean; // 提醒
  times: string[]; // 服药时间
}

@Entry
@Component
struct MedicationDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State medication: MedicationInfo | null = null;
  @State loading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    this.loadMedicationDetail();
  }

  loadMedicationDetail(): void {
    // 模拟从本地数据加载药品详情
    const medications: MedicationInfo[] = [
      {
        id: '1',
        name: '阿莫西林胶囊',
        genericName: '阿莫西林',
        category: '抗生素',
        dosage: '500mg',
        indications: '用于敏感菌所致的感染，如中耳炎、鼻窦炎、咽炎、扁桃体炎等上呼吸道感染，以及急性支气管炎、肺炎等下呼吸道感染。',
        usage: '成人一次1-2粒，一日3次，饭后服用。',
        precautions: '对青霉素类药物过敏者禁用；肾功能不全者慎用。',
        price: '¥15.00-¥30.00',
        description: '阿莫西林是一种半合成青霉素类广谱β-内酰胺类抗生素，用于治疗多种细菌感染。它通过抑制细菌细胞壁的合成来杀死细菌，对革兰阳性菌和部分革兰阴性菌有良好的抗菌作用。',
        sideEffects: ['恶心', '呕吐', '腹泻', '皮疹'],
        contraindications: ['青霉素过敏史', '传染性单核细胞增多症'],
        interactions: ['丙磺舒', '口服避孕药'],
        storage: '密封，在凉暗干燥处保存。',
        status: 'pending',
        reminder: true,
        times: ['08:00', '12:00', '20:00']
      },
      {
        id: '2',
        name: '布洛芬缓释胶囊',
        genericName: '布洛芬',
        category: '抗炎药',
        dosage: '200mg',
        indications: '用于缓解轻至中度疼痛，如头痛、关节痛、偏头痛、牙痛、肌肉痛、神经痛、痛经。也用于普通感冒或流行性感冒引起的发热。',
        usage: '成人一次1粒，一日2次，早晚各一次。',
        precautions: '对阿司匹林等非甾体抗炎药过敏者禁用；活动性消化性溃疡或胃肠道出血者禁用。',
        price: '¥20.00-¥40.00',
        description: '布洛芬是一种非甾体抗炎药，具有解热、镇痛、抗炎作用。它通过抑制前列腺素的合成来发挥作用，适用于缓解各种疼痛和发热症状。',
        sideEffects: ['胃肠道不适', '头痛', '头晕', '皮疹'],
        contraindications: ['对非甾体抗炎药过敏', '活动性消化性溃疡', '严重肝肾功能不全'],
        interactions: ['肝素', '华法林', '利尿剂'],
        storage: '密封，在阴凉处保存。',
        status: 'taken',
        reminder: true,
        times: ['08:00', '20:00']
      },
      {
        id: '3',
        name: '硝苯地平控释片',
        genericName: '硝苯地平',
        category: '降压药',
        dosage: '30mg',
        indications: '用于治疗高血压、冠心病、慢性稳定型心绞痛（劳累性心绞痛）。',
        usage: '成人一次1片，一日1次，晨起空腹服用。',
        precautions: '低血压患者慎用；肝肾功能不全者慎用。',
        price: '¥30.00-¥60.00',
        description: '硝苯地平是一种钙通道阻滞剂，用于治疗高血压和心绞痛。它通过阻止钙离子进入血管平滑肌细胞，从而扩张血管，降低血压，缓解心绞痛。',
        sideEffects: ['头痛', '面部潮红', '心悸', '踝部水肿'],
        contraindications: ['对硝苯地平过敏', '心源性休克', '急性心肌梗死'],
        interactions: ['西柚汁', '利福平', '苯妥英钠'],
        storage: '密封，在阴凉处保存。',
        status: 'pending',
        reminder: true,
        times: ['07:00']
      },
      {
        id: '4',
        name: '二甲双胍片',
        genericName: '二甲双胍',
        category: '降糖药',
        dosage: '500mg',
        indications: '用于2型糖尿病的治疗，尤其是肥胖且伴有高胰岛素血症者。',
        usage: '成人一次1片，一日3次，餐中或餐后服用。',
        precautions: '肝肾功能不全者慎用；孕妇慎用。',
        price: '¥10.00-¥30.00',
        description: '二甲双胍是一种双胍类降糖药，通过减少肝脏葡萄糖的产生和提高胰岛素敏感性来降低血糖。它是2型糖尿病的一线治疗药物，尤其适用于肥胖患者。',
        sideEffects: ['胃肠道不适', '腹泻', '恶心', '金属味'],
        contraindications: ['严重肝肾功能不全', '糖尿病酮症酸中毒', '对二甲双胍过敏'],
        interactions: ['西咪替丁', '呋塞米', '地高辛'],
        storage: '密封，在阴凉处保存。',
        status: 'missed',
        reminder: true,
        times: ['07:00', '12:00', '18:00']
      },
      {
        id: '5',
        name: '维生素C片',
        genericName: '维生素C',
        category: '维生素类',
        dosage: '100mg',
        indications: '用于预防和治疗维生素C缺乏症，如坏血病。也用于增强免疫力，促进铁吸收。',
        usage: '成人一次1片，一日1次。',
        precautions: '过量服用可能引起腹泻、皮疹等不良反应。',
        price: '¥5.00-¥20.00',
        description: '维生素C是一种水溶性维生素，具有抗氧化作用，参与体内多种代谢过程。它在胶原蛋白合成、免疫功能调节、铁吸收等方面发挥重要作用。',
        sideEffects: ['腹泻', '皮疹', '胃痉挛'],
        contraindications: ['对维生素C过敏'],
        interactions: ['华法林', '口服避孕药'],
        storage: '密封，在阴凉处保存。',
        status: 'taken',
        reminder: false,
        times: ['09:00']
      }
    ];

    const params = router.getParams() as Record<string, string>;
    if (params && params.medicationId) {
      const medicationId = params.medicationId;
      let foundMed: MedicationInfo | null = null;
      for (let i = 0; i < medications.length; i++) {
        if (medications[i].id === medicationId) {
          foundMed = medications[i];
          break;
        }
      }
      this.medication = foundMed;
    }
    this.loading = false;
  }

  build() {
    Column() {
      // 头部
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

      if (this.loading) {
        // 加载状态
        Column() {
          Text('加载中...')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#999999');
        }
        .width('100%')
        .height(400)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else if (!this.medication) {
        // 药品不存在
        Column() {
          Text('💊')
            .fontSize(48)
            .margin({ bottom: 16 });
          Text('药品不存在')
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
            // 药品基本信息
            Column() {
              Text('💊')
                .fontSize(80)
                .margin({ bottom: 16 });
              Text(this.medication.name)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 4 });
              Text(this.medication.genericName)
                .fontSize(14)
                .fontColor('#999999')
                .margin({ bottom: 12 });
              Row() {
                Text(this.medication.category)
                  .fontSize(12)
                  .fontColor('#1677FF')
                  .backgroundColor('#E6F4FF')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(4);
                Text(this.medication.dosage)
                  .fontSize(12)
                  .fontColor('#52C41A')
                  .backgroundColor('#F6FFED')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(4)
                  .margin({ left: 8 });
                Text(this.medication.price)
                  .fontSize(12)
                  .fontColor('#FF4757')
                  .backgroundColor('#FFF1F0')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(4)
                  .margin({ left: 8 });
              }
            }
            .width('100%')
            .padding({ top: 24, bottom: 24 })
            .backgroundColor('#FFFFFF')
            .alignItems(HorizontalAlign.Center);

            // 适应症
            Column() {
              Text('适应症')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.medication.indications)
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

            // 用法用量
            Column() {
              Text('用法用量')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.medication.usage)
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start);
              Text('服药时间: ' + this.joinTimes(this.medication.times))
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ top: 8 });
            }
            .width('85%')
            .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            // 注意事项
            Column() {
              Text('注意事项')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.medication.precautions)
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

            // 完整说明书
            Column() {
              Text('完整说明书')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.medication.description)
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

            // 副作用
            Column() {
              Text('副作用')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Row({ space: 8 }) {
                ForEach(this.medication.sideEffects, (item: string) => {
                  Text(item)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .fontSize(14)
                    .fontColor('#FF4757')
                    .backgroundColor('#FFF1F0')
                    .borderRadius(16);
                }, (item: string) => item);
              }
            }
            .width('85%')
            .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            // 禁忌
            Column() {
              Text('禁忌')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Row({ space: 8 }) {
                ForEach(this.medication.contraindications, (item: string) => {
                  Text(item)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .fontSize(14)
                    .fontColor('#FF4757')
                    .backgroundColor('#FFF1F0')
                    .borderRadius(16);
                }, (item: string) => item);
              }
            }
            .width('85%')
            .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            // 相互作用
            Column() {
              Text('相互作用')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Row({ space: 8 }) {
                ForEach(this.medication.interactions, (item: string) => {
                  Text(item)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .fontSize(14)
                    .fontColor('#1677FF')
                    .backgroundColor('#E6F4FF')
                    .borderRadius(16);
                }, (item: string) => item);
              }
            }
            .width('85%')
            .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            // 存储条件
            Column() {
              Text('存储条件')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.medication.storage)
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

  private joinTimes(times: string[]): string {
    let result = '';
    for (let i = 0; i < times.length; i++) {
      if (i > 0) {
        result = result + ', ';
      }
      result = result + times[i];
    }
    return result;
  }
}