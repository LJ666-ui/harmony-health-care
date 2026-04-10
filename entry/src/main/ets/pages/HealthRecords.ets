import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Card } from '../components/Card';
import { HealthRecord } from '../models/HealthData';

@Entry
@Component
struct HealthRecords {
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

  build() {
    Column() {
      Header({ title: '健康记录', showBack: true });

      Scroll() {
        Column({ space: 16 }) {
          Text('健康记录')
            .fontSize(24)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 20, bottom: 16 });

          List({ space: 12 }) {
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

          Button('+ 添加记录')
            .width('100%')
            .height(50)
            .fontSize(17)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(25)
            .onClick(() => {
              console.log('添加记录');
            });

          Button('📊 健康风险评估')
            .width('100%')
            .height(50)
            .fontSize(17)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(25)
            .margin({ top: 12 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/RiskAssessmentPage' });
            });


        }
        .width('85%')
        .padding({ top: 20, bottom: 24 });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
