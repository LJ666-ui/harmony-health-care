import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Card } from '../components/Card';
import { Hospital } from '../models/HealthData';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

@Entry
@Component
struct HospitalPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitals: Hospital[] = [
    {
      id: '1',
      name: '星云综合医院（三甲）',
      address: '北京市海淀区中关村大街1号',
      phone: '010-88888888',
      departments: ['内科', '外科', '骨科', '康复科', '儿科', '妇科', '眼科'],
      rating: 4.9,
      distance: 2.5
    },
    {
      id: '2',
      name: '协和医疗中心（三甲）',
      address: '北京市朝阳区建国路88号',
      phone: '010-66666666',
      departments: ['内科', '外科', '老年病科', '骨科', '心血管科'],
      rating: 4.9,
      distance: 3.2
    },
    {
      id: '3',
      name: '仁爱专科医院（三甲）',
      address: '北京市西城区金融街15号',
      phone: '010-55555555',
      departments: ['内科', '康复科', '老年病科', '儿科'],
      rating: 4.7,
      distance: 1.8
    },
    {
      id: '4',
      name: '康宁中医医院（三甲）',
      address: '北京市东城区王府井大街20号',
      phone: '010-44444444',
      departments: ['内科', '康复科', '骨科', '针灸推拿科'],
      rating: 4.8,
      distance: 4.0
    },
    {
      id: '5',
      name: '博爱国际医院（三甲）',
      address: '北京市丰台区科技园路50号',
      phone: '010-33333333',
      departments: ['内科', '外科', '骨科', '老年病科', '康复科', '神经科'],
      rating: 4.6,
      distance: 5.5
    },
    {
      id: '6',
      name: '安泰社区医院（社区）',
      address: '北京市石景山区古城路8号',
      phone: '010-22222222',
      departments: ['内科', '康复科', '全科'],
      rating: 4.4,
      distance: 0.8
    },
    {
      id: '7',
      name: '阳光儿童专科医院（专科）',
      address: '北京市海淀区万柳中路12号',
      phone: '010-77777777',
      departments: ['儿科', '新生儿科', '儿童保健科', '眼科'],
      rating: 4.8,
      distance: 3.8
    },
    {
      id: '8',
      name: '仁心骨科专科医院（专科）',
      address: '北京市朝阳区望京西路30号',
      phone: '010-99999999',
      departments: ['骨科', '运动医学科', '康复科', '疼痛科'],
      rating: 4.7,
      distance: 6.2
    },
    {
      id: '9',
      name: '和睦家社区卫生服务中心（社区）',
      address: '北京市海淀区上地东路18号',
      phone: '010-11111111',
      departments: ['全科', '内科', '康复科', '中医科'],
      rating: 4.3,
      distance: 1.2
    },
    {
      id: '10',
      name: '慈铭体检中心（专科）',
      address: '北京市朝阳区三元桥霄云路32号',
      phone: '010-88887777',
      departments: ['体检科', '健康管理科', '内科', '外科'],
      rating: 4.5,
      distance: 7.0
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
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Button('🧭 院内AR导航')
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#FFFFFF')
            .backgroundColor(GlobalTheme.THEME_COLOR)
            .borderRadius(GlobalTheme.RADIUS_LG)
            .onClick(() => this.openARNavigation());

          List({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
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
          .borderRadius(GlobalTheme.RADIUS_MD);
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
