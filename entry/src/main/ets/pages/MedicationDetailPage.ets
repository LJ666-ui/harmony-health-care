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
        try {
          const url = ApiConstants.MEDICINE_DETAIL + medicineId;
          const response: BaseResponse<MedicineDetail> = await HttpUtil.get<MedicineDetail>(url);
          if (response.success && response.data) {
            this.medicine = response.data;
          } else {
            console.warn('API获取药品详情失败，使用默认数据');
            this.loadDefaultMedicine(medicineId);
          }
        } catch (apiError) {
          console.error('API请求异常:', apiError);
          console.log('使用默认药品详情数据');
          this.loadDefaultMedicine(medicineId);
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

  loadDefaultMedicine(medicineId: number): void {
    const defaultMedicines: Record<number, MedicineDetail> = {
      1: {
        id: 1,
        name: '阿莫西林胶囊',
        indication: '用于敏感菌所致的各种感染，如呼吸道感染、泌尿道感染、皮肤软组织感染等。也可用于治疗幽门螺杆菌感染。',
        usageDesc: '口服，成人一次0.5g，每6-8小时1次，每日剂量不超过4g。儿童按体重一日20-40mg/kg，分3次服用。疗程一般为7-14天。',
        taboo: '青霉素过敏者禁用。传染性单核细胞增多症患者禁用。孕妇及哺乳期妇女慎用。',
        source: '抗生素'
      },
      2: {
        id: 2,
        name: '布洛芬缓释胶囊',
        indication: '用于缓解轻至中度疼痛如头痛、关节痛、偏头痛、牙痛、肌肉痛、神经痛、痛经。也用于普通感冒或流行性感冒引起的发热。',
        usageDesc: '口服，成人一次1粒（0.3g），一日2次（早晚各一次）。饭后服用，不可空腹服用。',
        taboo: '活动性消化道溃疡者禁用。对本品过敏者禁用。孕妇及哺乳期妇女禁用。',
        source: '解热镇痛'
      },
      3: {
        id: 3,
        name: '复方甘草片',
        indication: '用于镇咳祛痰，适用于上呼吸道感染、支气管炎等引起的咳嗽、咳痰症状。',
        usageDesc: '口服，成人一次3-4片，一日3次。含服或吞服均可。',
        taboo: '孕妇及哺乳期妇女慎用。本品含有阿片粉，不宜长期服用。',
        source: '止咳化痰'
      },
      4: {
        id: 4,
        name: '维生素C片',
        indication: '用于预防坏血病，也可用于各种急慢性传染疾病及紫癜等的辅助治疗。增强机体抵抗力。',
        usageDesc: '口服，成人预防用量一次100-200mg，一日3次；治疗用量一次300-600mg，一日3次。',
        taboo: '长期过量服用可能引起腹泻、皮疹等不良反应。',
        source: '维生素类'
      },
      5: {
        id: 5,
        name: '奥美拉唑肠溶胶囊',
        indication: '用于胃溃疡、十二指肠溃疡、反流性食管炎等酸相关性疾病。也用于卓-艾综合征的治疗。',
        usageDesc: '口服，晨起吞服，一次20mg，一日1-2次。胃溃疡和十二指肠溃疡疗程通常为4-8周。',
        taboo: '严重肾功能不全者禁用。对本品过敏者禁用。',
        source: '消化系统'
      },
      6: {
        id: 6,
        name: '氯雷他定片',
        indication: '用于缓解过敏性鼻炎有关的症状，如喷嚏、流涕、鼻痒、鼻塞以及眼部痒及烧灼感。也用于缓解慢性荨麻疹的症状。',
        usageDesc: '口服，成人一次10mg，一日1次。可在进食时或空腹时服用。',
        taboo: '对本品过敏者禁用。',
        source: '抗过敏药'
      },
      7: {
        id: 7,
        name: '二甲双胍缓释片',
        indication: '用于2型糖尿病，尤其是肥胖的2型糖尿病患者。可单独用药或与其他降糖药联合使用。',
        usageDesc: '口服，起始剂量为一次0.5g，一日1-2次。根据血糖情况逐渐增加剂量，最大日剂量不超过2g。',
        taboo: '严重肾功能不全、肝功能不全、心力衰竭、急性心肌梗死者禁用。',
        source: '降糖药'
      },
      8: {
        id: 8,
        name: '氨氯地平片',
        indication: '用于高血压及心绞痛的治疗。可单独应用或与其他抗高血压药物联合使用。',
        usageDesc: '口服，初始剂量一次5mg，一日1次。根据患者反应可调整剂量至最大10mg/日。',
        taboo: '严重主动脉瓣狭窄者禁用。对二氢吡啶类钙拮抗剂过敏者禁用。',
        source: '心血管药'
      }
    };

    this.medicine = defaultMedicines[medicineId] || {
      id: medicineId,
      name: '未知药品',
      indication: '暂无详细信息',
      usageDesc: '暂无用法说明',
      taboo: '暂无禁忌信息',
      source: '未知分类'
    };
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
