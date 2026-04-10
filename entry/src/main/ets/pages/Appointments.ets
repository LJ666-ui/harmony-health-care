import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Card } from '../components/Card';
import { Appointment } from '../models/HealthData';

@Entry
@Component
struct Appointments {
  @State appointments: Appointment[] = [
    {
      id: '1',
      doctor: '张医生',
      specialty: '内科',
      hospital: '星云医院',
      date: '2024-01-20',
      time: '09:00',
      status: 'confirmed',
      location: '门诊楼3层',
      notes: '',
      avatarColor: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '2',
      doctor: '李医生',
      specialty: '外科',
      hospital: '星云医院',
      date: '2024-01-25',
      time: '14:30',
      status: 'confirmed',
      location: '门诊楼5层',
      notes: '',
      avatarColor: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    }
  ];

  build() {
    Column() {
      Header({ title: '预约管理', showBack: true });
      
      Column({ space: 16 }) {
        Text('预约管理')
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ top: 20, bottom: 16 });
        
        List() {
          ForEach(this.appointments, (item: Appointment) => {
            ListItem() {
              Card({
                title: item.hospital,
                value: item.specialty,
                description: item.date + ' ' + item.time,
                status: item.status === 'confirmed' ? '已预约' : '待确认'
              });
            }
          }, (item: Appointment) => item.id);
        }
        .width('100%')
        .height('70%');
        
        Button('新增预约')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .margin({ top: 16 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddAppointmentPage' });
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
