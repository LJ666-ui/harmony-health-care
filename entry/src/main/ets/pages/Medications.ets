import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface MedicineItem {
  id: number;
  name: string;
  indication: string;
  usageDesc: string;
  taboo: string;
  source: string;
}

@Entry
@Component
struct Medications {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State searchText: string = '';
  @State selectedCategory: string = '全部';
  @State allMedicines: MedicineItem[] = [];
  @State filteredMedicines: MedicineItem[] = [];
  @State categories: string[] = ['全部'];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadMedicines();
  }

  async loadMedicines(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    
    console.log('[Medications] 开始加载药品数据...');
    console.log('[Medications] API地址:', ApiConstants.MEDICINE_LIST);
    console.log('[Medications] 完整URL:', ApiConstants.BASE_URL + ApiConstants.MEDICINE_LIST);

    try {
      const response: BaseResponse<MedicineItem[]> = await HttpUtil.get<MedicineItem[]>(ApiConstants.MEDICINE_LIST);
      
      console.log('[Medications] API响应成功');
      console.log('[Medications] response.success:', response.success);
      console.log('[Medications] response.message:', response.message);
      console.log('[Medications] response.code:', response.code);
      console.log('[Medications] response.data类型:', typeof response.data);
      console.log('[Medications] response.data是否为数组:', Array.isArray(response.data));
      
      if (response.data) {
        console.log('[Medications] 数据长度:', (response.data as MedicineItem[]).length);
        if ((response.data as MedicineItem[]).length > 0) {
          console.log('[Medications] 第一条数据:', JSON.stringify((response.data as MedicineItem[])[0]));
        }
      }

      if (response.success && response.data) {
        const dataArray = response.data as MedicineItem[];

        const cleanedData: MedicineItem[] = [];
        for (let i = 0; i < dataArray.length; i++) {
          const item = dataArray[i];
          const medicineItem: MedicineItem = {
            id: item.id || 0,
            name: item.name ? item.name.trim() : '未知药品',
            indication: item.indication ? item.indication.trim() : '',
            usageDesc: item.usageDesc ? item.usageDesc.trim() : '',
            taboo: item.taboo ? item.taboo.trim() : '',
            source: item.source ? item.source.trim() : ''
          };
          cleanedData.push(medicineItem);
        }

        console.log('[Medications] 清洗后数据长度:', cleanedData.length);

        this.allMedicines = cleanedData;
        this.extractCategories();
        this.filterMedicines();

        console.log('[Medications] 最终显示数据长度:', this.filteredMedicines.length);
      } else {
        console.warn('[Medications] API返回失败，使用默认数据');
        this.loadDefaultMedicines();
      }
    } catch (error) {
      console.error('[Medications] 加载药品数据异常:', error);
      console.log('[Medications] 使用默认药品数据作为备选');
      this.loadDefaultMedicines();
    } finally {
      this.isLoading = false;
    }
  }

  loadDefaultMedicines(): void {
    const defaultMeds: MedicineItem[] = [
      {
        id: 1,
        name: '阿莫西林胶囊',
        indication: '用于敏感菌所致的各种感染，如呼吸道感染、泌尿道感染、皮肤软组织感染等',
        usageDesc: '口服，成人一次0.5g，每6-8小时1次，每日剂量不超过4g',
        taboo: '青霉素过敏者禁用',
        source: '抗生素'
      },
      {
        id: 2,
        name: '布洛芬缓释胶囊',
        indication: '用于缓解轻至中度疼痛如头痛、关节痛、偏头痛、牙痛、肌肉痛、神经痛、痛经',
        usageDesc: '口服，成人一次1粒（0.3g），一日2次',
        taboo: '活动性消化道溃疡者禁用',
        source: '解热镇痛'
      },
      {
        id: 3,
        name: '复方甘草片',
        indication: '用于镇咳祛痰，适用于上呼吸道感染、支气管炎等引起的咳嗽',
        usageDesc: '口服，成人一次3-4片，一日3次',
        taboo: '孕妇及哺乳期妇女慎用',
        source: '止咳化痰'
      },
      {
        id: 4,
        name: '维生素C片',
        indication: '用于预防坏血病，也可用于各种急慢性传染疾病及紫癜等的辅助治疗',
        usageDesc: '口服，成人一次1-2片，一日3次',
        taboo: '长期过量服用可能引起腹泻等不良反应',
        source: '维生素类'
      },
      {
        id: 5,
        name: '奥美拉唑肠溶胶囊',
        indication: '用于胃溃疡、十二指肠溃疡、反流性食管炎等酸相关性疾病',
        usageDesc: '口服，晨起吞服，一次20mg，一日1-2次',
        taboo: '严重肾功能不全者禁用',
        source: '消化系统'
      },
      {
        id: 6,
        name: '氯雷他定片',
        indication: '用于缓解过敏性鼻炎有关的症状，如喷嚏、流涕、鼻痒、鼻塞以及眼部痒及烧灼感',
        usageDesc: '口服，成人一次10mg，一日1次',
        taboo: '对本品过敏者禁用',
        source: '抗过敏药'
      },
      {
        id: 7,
        name: '二甲双胍缓释片',
        indication: '用于2型糖尿病，尤其是肥胖的2型糖尿病患者',
        usageDesc: '口服，起始剂量为一次0.5g，一日1-2次',
        taboo: '严重肾功能不全者禁用',
        source: '降糖药'
      },
      {
        id: 8,
        name: '氨氯地平片',
        indication: '用于高血压及心绞痛的治疗',
        usageDesc: '口服，初始剂量一次5mg，一日1次',
        taboo: '严重主动脉瓣狭窄者禁用',
        source: '心血管药'
      }
    ];

    this.allMedicines = defaultMeds;
    this.extractCategories();
    this.filterMedicines();
  }

  extractCategories(): void {
    const categorySet: Set<string> = new Set<string>();
    for (let i = 0; i < this.allMedicines.length; i++) {
      if (this.allMedicines[i].source && this.allMedicines[i].source.trim()) {
        categorySet.add(this.allMedicines[i].source.trim());
      }
    }
    this.categories = ['全部', ...Array.from(categorySet)];
    console.log('[Medications] 提取到的分类:', JSON.stringify(this.categories));
  }

  handleSearch(): void {
    this.filterMedicines();
  }

  handleCategoryFilter(category: string): void {
    this.selectedCategory = category;
    this.filterMedicines();
  }

  filterMedicines(): void {
    let result: MedicineItem[] = [];

    for (let i = 0; i < this.allMedicines.length; i++) {
      result.push(this.allMedicines[i]);
    }

    if (this.searchText.trim()) {
      const searchLower = this.searchText.toLowerCase();
      let searchResult: MedicineItem[] = [];
      for (let j = 0; j < result.length; j++) {
        const med = result[j];
        if (med.name.toLowerCase().includes(searchLower) ||
            med.indication.toLowerCase().includes(searchLower)) {
          searchResult.push(med);
        }
      }
      result = searchResult;
    }

    if (this.selectedCategory !== '全部') {
      let categoryResult: MedicineItem[] = [];
      for (let k = 0; k < result.length; k++) {
        if (result[k].source === this.selectedCategory) {
          categoryResult.push(result[k]);
        }
      }
      result = categoryResult;
    }

    this.filteredMedicines = result;
  }

  navigateToMedicineDetail(med: MedicineItem): void {
    router.pushUrl({
      url: 'pages/MedicationDetailPage',
      params: { medicineId: med.id }
    }).catch((error: Error) => {
      console.error('跳转药品详情失败:', error.message);
    });
  }

  build() {
    Column() {
      Header({ title: '用药管理', showBack: true });

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

      Row() {
        Text('⏰')
          .fontSize(18)
        Text('用药提醒')
          .fontSize(14)
          .fontColor('#1677FF')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 6 })
        Blank()
        Text('管理我的服药时间 >')
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('90%')
      .height(44)
      .backgroundColor('#E6F4FF')
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 20, right: 20 })
      .onClick(() => {
        router.pushUrl({
          url: 'pages/MedicationReminderListPage'
        }).catch((error: Error) => {
          console.error('跳转用药提醒失败:', error.message);
        });
      })
      .margin({ bottom: 12, left: '5%', right: '5%' })

      Text('药品分类')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ left: 16, top: 16, bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start);

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.categories, (category: string) => {
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

      Text('药品列表')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ left: 16, top: 16, bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start);

      Scroll() {
        Column() {
          if (this.isLoading) {
            Column() {
              Text('⏳')
                .fontSize(48)
                .margin({ bottom: 16 });
              Text('正在加载药品数据...')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#666666');
              Text('请确保后端服务已启动')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 8 });
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else if (this.filteredMedicines.length === 0) {
            Column() {
              Text('💊')
                .fontSize(48)
                .margin({ bottom: 16 });
              Text('未找到相关药品')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#999999');
              
              if (this.errorMessage) {
                Text('错误信息: ' + this.errorMessage)
                  .fontSize(12)
                  .fontColor('#FF4757')
                  .margin({ top: 12 })
                  .textAlign(TextAlign.Center);
              }
              
              Button('重新加载')
                .margin({ top: 20 })
                .onClick(() => {
                  this.loadMedicines();
                });
            }
            .width('100%')
            .height(350)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else {
            ForEach(this.filteredMedicines, (med: MedicineItem) => {
              Column() {
                Row() {
                  Text(med.name)
                    .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .layoutWeight(1);
                  Text(med.source ? med.source.substring(0, 10) + (med.source.length > 10 ? '...' : '') : '')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ right: 8 });
                }
                .margin({ bottom: 8 });
                
                Text('ID: ' + med.id)
                  .fontSize(11)
                  .fontColor('#CCCCCC')
                  .margin({ bottom: 4 });
                  
                Text('适应症: ' + (med.indication ? med.indication.substring(0, 50) + (med.indication.length > 50 ? '...' : '') : '暂无'))
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ bottom: 4 });
                Text('用法: ' + (med.usageDesc ? med.usageDesc.substring(0, 40) + (med.usageDesc.length > 40 ? '...' : '') : '暂无'))
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ bottom: 4 });
                Row() {
                  Text(med.source || '未知来源')
                    .fontSize(12)
                    .fontColor('#1677FF')
                    .backgroundColor('#E6F4FF')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .borderRadius(4);
                }
              }
              .width('85%')
              .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#F0F0F0' })
              .onClick(() => this.navigateToMedicineDetail(med));
            }, (med: MedicineItem) => med.id.toString());
            
            Text('共 ' + this.filteredMedicines.length + ' 条药品记录')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 8, bottom: 20 })
              .textAlign(TextAlign.Center);
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
