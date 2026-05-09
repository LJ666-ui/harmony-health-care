import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

@Entry
@Component
export struct MedicalPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentIndex: number = 1;
  private theme: AccessibilityConfig = new AccessibilityConfig();

  private medicalServices: MedicalService[] = [
    { id: 'appointment', icon: '📅', title: '预约挂号', desc: '在线预约专家号源', color: '#3498DB' },
    { id: 'queue', icon: '⏰', title: '排队叫号', desc: '实时查看就诊进度', color: '#9B59B6' },
    { id: 'report', icon: '📋', title: '报告查询', desc: '检验检查结果查询', color: '#2ECC71' },
    { id: 'prescription', icon: '💊', title: '处方查询', desc: '电子处方及用药指导', color: '#E74C3C' },
    { id: 'payment', icon: '💳', title: '缴费支付', desc: '在线缴纳医疗费用', color: '#F39C12' },
    { id: 'hospital_nav', icon: '🏥', title: '院内导航', desc: '科室位置智能导航', color: '#1ABC9C' }
  ];

  private hotDepartments: DepartmentInfo[] = [
    { name: '内科', doctors: 128, waiting: 15, color: '#3498DB' },
    { name: '外科', doctors: 96, waiting: 23, color: '#E74C3C' },
    { name: '儿科', doctors: 64, waiting: 31, color: '#F39C12' },
    { name: '妇产科', doctors: 72, waiting: 18, color: '#9B59B6' },
    { name: '眼科', doctors: 45, waiting: 12, color: '#2ECC71' },
    { name: '口腔科', doctors: 56, waiting: 27, color: '#16A085' }
  ];

  aboutToAppear(): void {
    this.theme = AccessibilityConfig.getInstance();
  }

  build() {
    Column() {
      Header({ title: '就医服务' })

      Scroll() {
        Column({ space: this.isElderMode ? 16 : 12 }) {
          this.buildSearchBar()
          this.buildMedicalServices()
          this.buildHotDepartments()
          this.buildQuickLinks()
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      Footer({ activeIndex: this.currentIndex })
    }
    .height('100%')
    .backgroundColor(AccessibilityConfig.getBackgroundColor())
  }

  @Builder buildSearchBar(): void {
    Row({ space: 12 }) {
      Row({ space: 8 }) {
        Text('🔍')
          .fontSize(18)

        Text('搜索医生、科室、疾病...')
          .fontSize(this.isElderMode ? 16 : 14)
          .fontColor('#999999')
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#F8F9FA')
      .borderRadius(20)

      Text('搜索')
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
        .backgroundColor('#3498DB')
        .borderRadius(20)
    }
    .width('100%')
  }

  @Builder buildMedicalServices(): void {
    Column({ space: 12 }) {
      Text('医疗服务')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      Grid() {
        ForEach(this.medicalServices, (service: MedicalService) => {
          GridItem() {
            Column({ space: 10 }) {
              Text(service.icon)
                .fontSize(this.isElderMode ? 40 : 32)

              Text(service.title)
                .fontSize(this.isElderMode ? 15 : 13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text(service.desc)
                .fontSize(this.isElderMode ? 12 : 11)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .padding({ top: 16, bottom: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' })
            .onClick(() => {
              try {
                // 统一项目有效路由，匹配main_pages.json配置
                if (service.id === 'appointment') {
                  router.pushUrl({ url: 'pages/HospitalPage' });
                } else if (service.id === 'queue') {
                  // 排队叫号功能 - 跳转到预约管理页面查看排队信息
                  router.pushUrl({ url: 'pages/AppointmentManagementPage' });
                } else if (service.id === 'report') {
                  router.pushUrl({ url: 'pages/HealthRecords' });
                } else if (service.id === 'prescription') {
                  router.pushUrl({ url: 'pages/PrescriptionListPage' });
                } else if (service.id === 'payment') {
                  // 缴费支付功能 - 跳转到预约管理页面查看费用信息
                  router.pushUrl({ url: 'pages/AppointmentManagementPage' });
                } else if (service.id === 'hospital_nav') {
                  router.pushUrl({ url: 'pages/DestinationSelectPage' });
                } else {
                  console.log(`服务 ${service.title} 暂未开放`);
                }
              } catch (error) {
                console.error('导航失败:', error);
              }
            })
          }
        }, (service: MedicalService) => service.id)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
    }
  }

  @Builder buildHotDepartments(): void {
    Column({ space: 12 }) {
      Row() {
        Text('热门科室')
          .fontSize(this.isElderMode ? 18 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('查看全部 >')
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor('#3498DB')
          .onClick(() => {
            try {
              router.pushUrl({ url: 'pages/DepartmentListPage' });
            } catch (error) {
              console.error('导航失败:', error);
            }
          })
      }
      .width('100%')

      List({ space: 10 }) {
        ForEach(this.hotDepartments, (dept: DepartmentInfo) => {
          ListItem() {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(dept.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')

                Row({ space: 16 }) {
                  Text(`${dept.doctors}位医生`)
                    .fontSize(13)
                    .fontColor('#666666')

                  Text(`候诊${dept.waiting}人`)
                    .fontSize(13)
                    .fontColor(dept.waiting > 20 ? '#E74C3C' : '#2ECC71')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column({ space: 4 }) {
                Text('预约')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .backgroundColor(dept.color)
                  .borderRadius(16)

                Text(`${dept.waiting}人排队`)
                  .fontSize(11)
                  .fontColor('#999999')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#F0F0F0' })
            .onClick(() => {
              try {
                // 跳转医院页面并传递科室参数
                router.pushUrl({
                  url: 'pages/HospitalPage',
                  params: { targetDepartment: dept.name }
                });
              } catch (error) {
                console.error('导航失败:', error);
              }
            })
          }
        }, (dept: DepartmentInfo) => dept.name)
      }
      .width('100%')
      .height(280)
      .divider({ strokeWidth: 0 })
    }
  }

  @Builder buildQuickLinks(): void {
    Column({ space: 12 }) {
      Text('快捷入口')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      Row({ space: 10 }) {
        ForEach([
          { title: '我的挂号', icon: '📝', route: 'pages/Appointments' },
          { title: '就诊记录', icon: '📖', route: 'pages/MedicalRecord' },
          { title: '费用明细', icon: '💰', route: 'pages/MedicalRecord' },
          { title: '满意度评价', icon: '⭐', route: 'pages/Profile' }
        ], (link: QuickLink) => {
          Column({ space: 6 }) {
            Text(link.icon)
              .fontSize(28)

            Text(link.title)
              .fontSize(this.isElderMode ? 13 : 11)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
          }
          .layoutWeight(1)
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .border({ width: 1, color: '#F0F0F0' })
          .onClick(() => {
            try {
              router.pushUrl({ url: link.route });
            } catch (error) {
              console.error('导航失败:', error);
            }
          })
        }, (link: QuickLink) => link.title)
      }
      .width('100%')
    }
  }
}

// 类型接口定义
interface MedicalService {
  id: string;
  icon: string;
  title: string;
  desc: string;
  color: string;
}

interface DepartmentInfo {
  name: string;
  doctors: number;
  waiting: number;
  color: string;
}

interface QuickLink {
  title: string;
  icon: string;
  route: string;
}