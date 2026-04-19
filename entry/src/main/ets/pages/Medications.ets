import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Medication } from '../models/HealthData';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

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
struct Medications {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State searchText: string = '';
  @State selectedCategory: string = '全部';
  @State medications: MedicationInfo[] = [
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
      description: '阿莫西林是一种半合成青霉素类广谱β-内酰胺类抗生素，用于治疗多种细菌感染。',
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
      description: '布洛芬是一种非甾体抗炎药，具有解热、镇痛、抗炎作用。',
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
      description: '硝苯地平是一种钙通道阻滞剂，用于治疗高血压和心绞痛。',
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
      description: '二甲双胍是一种双胍类降糖药，通过减少肝脏葡萄糖的产生和提高胰岛素敏感性来降低血糖。',
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
      description: '维生素C是一种水溶性维生素，具有抗氧化作用，参与体内多种代谢过程。',
      sideEffects: ['腹泻', '皮疹', '胃痉挛'],
      contraindications: ['对维生素C过敏'],
      interactions: ['华法林', '口服避孕药'],
      storage: '密封，在阴凉处保存。',
      status: 'taken',
      reminder: false,
      times: ['09:00']
    }
  ];
  @State filteredMedications: MedicationInfo[] = [];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.filteredMedications = this.medications;
  }

  handleSearch(): void {
    this.filterMedications();
  }

  handleCategoryFilter(category: string): void {
    this.selectedCategory = category;
    this.filterMedications();
  }

  filterMedications(): void {
    let result: MedicationInfo[] = [];
    for (let i = 0; i < this.medications.length; i++) {
      result.push(this.medications[i]);
    }
    
    // 搜索筛选
    if (this.searchText.trim()) {
      const searchLower = this.searchText.toLowerCase();
      let searchResult: MedicationInfo[] = [];
      for (let j = 0; j < result.length; j++) {
        const med = result[j];
        if (med.name.toLowerCase().includes(searchLower) || med.genericName.toLowerCase().includes(searchLower)) {
          searchResult.push(med);
        }
      }
      result = searchResult;
    }
    
    // 分类筛选
    if (this.selectedCategory !== '全部') {
      let categoryResult: MedicationInfo[] = [];
      for (let k = 0; k < result.length; k++) {
        if (result[k].category === this.selectedCategory) {
          categoryResult.push(result[k]);
        }
      }
      result = categoryResult;
    }
    
    this.filteredMedications = result;
  }

  navigateToMedicationDetail(med: MedicationInfo): void {
    router.pushUrl({
      url: 'pages/MedicationDetailPage',
      params: { medicationId: med.id }
    }).catch((error: Error) => {
      console.error('跳转药品详情失败:', error.message);
    });
  }

  build() {
    Column() {
      Header({ title: '用药管理', showBack: true });

      // 搜索框
      Row() {
        Row() {
          Text('🔍')
            .fontSize(16)
            .margin({ left: 12 })
          TextInput({
            placeholder: '搜索药品...',
            text: this.searchText
          })
            .fontSize(this.isElderMode ? 16 : 14)
            .width('100%')
            .height(40)
            .padding({ left: 8, right: 12 })
            .backgroundColor('transparent')
            .onChange((value: string) => {
              this.searchText = value;
            })
            .onSubmit(() => {
              this.handleSearch();
            })
        }
        .width('90%')
        .height(48)
        .backgroundColor('#F5F7FA')
        .borderRadius(24)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ top: 16, bottom: 8, left: 16, right: 16 })

      // 分类筛选
      Text('药品分类')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ left: 16, top: 16, bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start);

      Scroll() {
        Row({ space: 12 }) {
          ForEach(['全部', '降压药', '降糖药', '抗生素', '抗炎药', '维生素类'], (category: string) => {
            Text(category)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor(this.selectedCategory === category ? '#1677FF' : '#666666')
              .backgroundColor(this.selectedCategory === category ? '#E6F4FF' : '#F5F7FA')
              .borderRadius(20)
              .onClick(() => this.handleCategoryFilter(category));
          }, (category: string) => category);
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)

      // 药品列表
      Text('药品列表')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ left: 16, top: 16, bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start);

      Scroll() {
        Column() {
          if (this.filteredMedications.length === 0) {
            // 空状态
            Column() {
              Text('💊')
                .fontSize(48)
                .margin({ bottom: 16 });
              Text('未找到相关药品')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#999999');
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else {
            ForEach(this.filteredMedications, (med: MedicationInfo) => {
              Column() {
                Row() {
                  Text(med.name)
                    .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .layoutWeight(1);
                  Text(med.genericName)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ right: 8 });
                }
                .margin({ bottom: 8 });
                Text('规格: ' + med.dosage)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 4 });
                Text('适应症: ' + med.indications.substring(0, 50) + '...')
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ bottom: 4 });
                Text('用法: ' + med.usage)
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ bottom: 4 });
                Row() {
                  Text('价格: ' + med.price)
                    .fontSize(12)
                    .fontColor('#FF4757')
                    .fontWeight(FontWeight.Bold);
                  Text(med.status === 'taken' ? '已服用' : '待服用')
                    .fontSize(12)
                    .fontColor(med.status === 'taken' ? '#52C41A' : '#1677FF')
                    .margin({ left: 16 });
                }
              }
              .width('85%')
              .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#F0F0F0' })
              .onClick(() => this.navigateToMedicationDetail(med));
            }, (med: MedicationInfo) => med.id);
          }
        }
        .width('100%')
        .padding({ top: 8, bottom: 100 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
