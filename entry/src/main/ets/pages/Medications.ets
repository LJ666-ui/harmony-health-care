import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Card } from '../components/Card';
import { Medication } from '../models/HealthData';

@Entry
@Component
struct Medications {
  @State medications: Medication[] = [
    {
      id: '1',
      name: '阿莫西林',
      dosage: '500mg',
      frequency: '每日3次',
      times: ['08:00', '12:00', '20:00'],
      status: 'pending',
      reminder: true,
      startDate: '2024-01-15',
      notes: '',
      color: '#1677FF',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '2',
      name: '布洛芬',
      dosage: '200mg',
      frequency: '每日2次',
      times: ['08:00', '20:00'],
      status: 'pending',
      reminder: true,
      startDate: '2024-01-15',
      notes: '',
      color: '#1677FF',
      icon: '',
      createdAt: 0,
      updatedAt: 0
    }
  ];

  build() {
    Column() {
      Header({ title: '用药管理', showBack: true });
      
      Column({ space: 16 }) {
        Text('用药管理')
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ top: 20, bottom: 16 });
        
        List() {
          ForEach(this.medications, (item: Medication) => {
            ListItem() {
              Card({
                title: item.name,
                value: item.dosage + ' - ' + item.frequency,
                description: item.times.join(', '),
                status: item.status === 'taken' ? '已服用' : '待服用'
              });
            }
          }, (item: Medication) => item.id);
        }
        .width('100%')
        .height('70%');
        
        Button('添加药物')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .margin({ top: 16 })
          .onClick(() => {
            console.log('添加药物');
          });
      }
      .flexGrow(1)
      .width('80%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
      
      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
