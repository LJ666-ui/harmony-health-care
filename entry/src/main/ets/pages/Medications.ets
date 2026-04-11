import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Medication } from '../models/HealthData';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

@Entry
@Component
struct Medications {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State medications: Medication[] = [
    {
      id: '1',
      name: '阿莫西林胶囊',
      dosage: '500mg',
      frequency: '每日3次',
      times: ['08:00', '12:00', '20:00'],
      status: 'pending',
      reminder: true,
      startDate: '2026-04-10',
      notes: '饭后服用，连续7天，过敏者禁用',
      color: '#1677FF',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '2',
      name: '布洛芬缓释胶囊',
      dosage: '200mg',
      frequency: '每日2次',
      times: ['08:00', '20:00'],
      status: 'taken',
      reminder: true,
      startDate: '2026-04-08',
      notes: '用于缓解关节疼痛，不可空腹服用',
      color: '#FAAD14',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '3',
      name: '硝苯地平控释片',
      dosage: '30mg',
      frequency: '每日1次',
      times: ['07:00'],
      status: 'pending',
      reminder: true,
      startDate: '2026-01-15',
      notes: '降压药，晨起空腹服用，定期监测血压',
      color: '#FF4D4F',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '4',
      name: '二甲双胍片',
      dosage: '500mg',
      frequency: '每日3次',
      times: ['07:00', '12:00', '18:00'],
      status: 'missed',
      reminder: true,
      startDate: '2026-03-20',
      notes: '降糖药，餐中服用，注意低血糖反应',
      color: '#52C41A',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '5',
      name: '维生素C片',
      dosage: '100mg',
      frequency: '每日1次',
      times: ['09:00'],
      status: 'taken',
      reminder: false,
      startDate: '2026-04-01',
      notes: '补充维生素，增强免疫力，可长期服用',
      color: '#722ED1',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '6',
      name: '钙尔奇D3片',
      dosage: '600mg',
      frequency: '每日1次',
      times:['20:00'],
      status: 'pending',
      reminder: true,
      startDate: '2026-02-10',
      notes: '补钙预防骨质疏松，睡前服用吸收更好',
      color: '#13C2C2',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '7',
      name: '氯雷他定片',
      dosage: '10mg',
      frequency: '每日1次',
      times: ['08:00'],
      status: 'taken',
      reminder: false,
      startDate: '2026-04-05',
      notes: '抗过敏药，春季花粉季服用，嗜睡副作用轻微',
      color: '#FA8C16',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '8',
      name: '甲钴胺片',
      dosage: '0.5mg',
      frequency: '每日3次',
      times: ['08:00', '13:00', '19:00'],
      status: 'pending',
      reminder: true,
      startDate: '2026-04-09',
      notes: '营养神经药物，治疗周围神经病变，疗程4周',
      color: '#EB2F96',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    }
  ];

  @State isRefreshing: boolean = false;

  handleRefresh(): void {
    this.isRefreshing = true;

    setTimeout(() => {
      this.isRefreshing = false;

      ToastUtil.refreshSuccess();
    }, 1500);
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  build() {
    Column() {
      Header({ title: '用药管理', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('用药管理')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          List() {
              ForEach(this.medications, (item: Medication) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text(item.name)
                        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                        .fontWeight('bold')
                        .fontColor(GlobalTheme.TEXT_PRIMARY);

                      Blank();

                      Text(item.status === 'taken' ? '已服用' : '待服用')
                        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                        .fontColor(item.status === 'taken' ? '#52C41A' : GlobalTheme.THEME_COLOR);
                    }
                    .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });

                    Text(item.dosage + ' - ' + item.frequency)
                      .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                      .fontWeight('bold')
                      .fontColor(GlobalTheme.TEXT_PRIMARY)
                      .margin({ bottom: 4 });

                    Text(item.times.join(', '))
                      .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                      .fontColor(GlobalTheme.TEXT_SECONDARY);
                  }
                  .width('100%')
                  .padding(GlobalTheme.getSpacingMD(this.isElderMode))
                  .backgroundColor('#FFFFFF')
                  .borderRadius(GlobalTheme.RADIUS_MD)
                  .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
                  .onClick(() => {
                    console.log('药物项被点击:', item.id);
                  });
                }
              }, (item: Medication) => item.id);
            }
            .width('100%')
            .height(0)
            .layoutWeight(1);

            Button('添加药物')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(24)
              .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode) })
              .onClick(() => {
                console.log('添加药物');
              });
          }
          .width('85%')
          .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
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
