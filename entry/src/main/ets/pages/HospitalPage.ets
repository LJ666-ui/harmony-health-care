import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Card } from '../components/Card';
import { Hospital } from '../models/HealthData';
import { GlobalTheme } from '../global';

@Entry
@Component
struct HospitalPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitals: Hospital[] = [
    {
      id: '1',
      name: '星云综合医院',
      address: '北京市海淀区中关村大街1号',
      phone: '010-88888888',
      departments: ['内科', '外科', '骨科', '康复科'],
      rating: 4.8,
      distance: 2.5
    },
    {
      id: '2',
      name: '协和医疗中心',
      address: '北京市朝阳区建国路88号',
      phone: '010-66666666',
      departments: ['内科', '外科', '老年病科', '骨科'],
      rating: 4.9,
      distance: 3.2
    },
    {
      id: '3',
      name: '仁爱专科医院',
      address: '北京市西城区金融街15号',
      phone: '010-55555555',
      departments: ['内科', '康复科', '老年病科'],
      rating: 4.6,
      distance: 1.8
    },
    {
      id: '4',
      name: '康宁中医医院',
      address: '北京市东城区王府井大街20号',
      phone: '010-44444444',
      departments: ['内科', '康复科', '骨科'],
      rating: 4.7,
      distance: 4.0
    },
    {
      id: '5',
      name: '博爱国际医院',
      address: '北京市丰台区科技园路50号',
      phone: '010-33333333',
      departments: ['内科', '外科', '骨科', '老年病科', '康复科'],
      rating: 4.5,
      distance: 5.5
    },
    {
      id: '6',
      name: '安泰社区医院',
      address: '北京市石景山区古城路8号',
      phone: '010-22222222',
      departments: ['内科', '康复科'],
      rating: 4.3,
      distance: 0.8
    }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  openARNavigation(): void {
    router.pushUrl({ url: 'pages/ARNavigationPage' });
  }

  build() {
    Column() {
      Header({ title: '医院列表', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('医院列表')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Button('🧭 院内AR导航')
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(12)
            .onClick(() => this.openARNavigation());

          List({ space: 12 }) {
            ForEach(this.hospitals, (item: Hospital) => {
              ListItem() {
                Card({
                  title: item.name,
                  value: item.distance + 'km | ⭐' + item.rating.toFixed(1) + '分',
                  description: item.address,
                  status: '查看科室'
                })
                  .onClick(() => {
                    router.pushUrl({ url: 'pages/DepartmentPage' });
                  });
              }
            }, (item: Hospital) => item.id);
          }
          .width('100%')
          .layoutWeight(1)
          .borderRadius(8);
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .layoutWeight(1);

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
