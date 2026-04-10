import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Card } from '../components/Card';
import { EmptyState } from '../components/EmptyState';
import { Loading } from '../components/Loading';
import { HealthRecord } from '../models/HealthData';
import { GlobalTheme } from '../global';

@Entry
@Component
struct HealthRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State records: HealthRecord[] = [
    {
      id: '1',
      type: '血压',
      value: '120/80',
      unit: 'mmHg',
      date: '2024-01-15',
      time: '08:30',
      notes: '',
      icon: '',
      color: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '2',
      type: '血糖',
      value: '5.6',
      unit: 'mmol/L',
      date: '2024-01-14',
      time: '07:00',
      notes: '',
      icon: '',
      color: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '3',
      type: '心率',
      value: '72',
      unit: '次/分',
      date: '2024-01-15',
      time: '09:00',
      notes: '',
      icon: '',
      color: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '4',
      type: '体重',
      value: '65',
      unit: 'kg',
      date: '2024-01-13',
      time: '06:30',
      notes: '',
      icon: '',
      color: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    }
  ];
  @State isLoading: boolean = false;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
    this.simulateLoading();
  }

  simulateLoading(): void {
    this.isLoading = true;
    setTimeout(() => {
      this.isLoading = false;
    }, 800);
  }

  handleAddRecord(): void {
    console.log('添加记录');
  }

  get hasRecords(): boolean {
    return this.records.length > 0;
  }

  build() {
    Column() {
      Header({ title: '健康记录', showBack: true });

      if (this.isLoading) {
        Loading({
          text: '加载健康数据...',
          show: this.isLoading
        })
          .layoutWeight(1);
      } else {
        Scroll() {
          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('健康记录')
              .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#1677FF')
              .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            if (this.hasRecords) {
              List({ space: 8 }) {
                ForEach(this.records, (item: HealthRecord) => {
                  ListItem() {
                    Card({
                      title: item.type,
                      value: item.value + item.unit,
                      description: item.date + ' ' + item.time,
                      status: '正常'
                    });
                  }
                }, (item: HealthRecord) => item.id);
              }
              .width('100%')
              .layoutWeight(1);
            } else {
              EmptyState({
                icon: '📋',
                title: '暂无健康记录',
                description: '点击下方按钮添加您的第一条健康数据',
                buttonText: '+ 添加记录',
                onAdd: () => this.handleAddRecord()
              });
            }

            Button('+ 添加记录')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(25)
              .onClick(() => this.handleAddRecord());

            Button('📊 健康风险评估')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(25)
              .margin({ top: 8 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/RiskAssessmentPage' });
              });
          }
          .width('85%')
          .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
        }
        .flexGrow(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .layoutWeight(1);
      }

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
