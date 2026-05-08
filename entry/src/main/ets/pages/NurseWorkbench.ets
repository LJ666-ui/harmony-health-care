import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

interface NurseInfo {
  id: number;
  userId: number;
  nurseNo: string;
  name: string;
  gender: number;
  phone: string;
  department: string;
  title: string;
  certificateNo: string;
  workYears: number;
  avatar: string;
  status: number;
}

interface QuickAction {
  id: string;
  icon: string;
  title: string;
  color: string;
  route: string;
}

interface GridConfig {
  rowsTemplate: string;
  height: number;
}

@Entry
@Component
struct NurseWorkbench {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('nurseInfo') nurseInfo: NurseInfo | null = null;
  @State currentIndex: number = 0;

  private quickActions: QuickAction[] = [
    { id: 'patient_manage', icon: '👥', title: '患者管理', color: '#3498DB', route: 'pages/NursePatientList' },
    { id: 'health_record', icon: '📋', title: '健康档案', color: '#9B59B6', route: 'pages/NurseHealthRecords' },
    { id: 'medication_manage', icon: '💊', title: '用药管理', color: '#E74C3C', route: 'pages/NurseMedicationPage' },
    { id: 'nursing_record', icon: '📝', title: '护理记录', color: '#2ECC71', route: 'pages/NurseMedicalRecord' },
    { id: 'vital_signs', icon: '📊', title: '生命体征', color: '#F39C12', route: 'pages/NurseHealthPage' },
    { id: 'schedule', icon: '📅', title: '排班查看', color: '#1ABC9C', route: 'pages/NurseStationDashboard' },
    { id: 'patient_chat', icon: '💬', title: '患者聊天', color: '#13C2C2', route: 'pages/NursePatientList' },
    { id: 'family_chat', icon: '👨‍👩‍👧', title: '家属沟通', color: '#F5A623', route: 'pages/NurseFamilyList' }
  ];

  private calculateGridConfig(): GridConfig {
    const itemCount = this.quickActions.length;
    const columns = 3;
    const rows = Math.ceil(itemCount / columns);
    const rowHeight = 120;
    const gap = 12;
    const totalHeight = rows * rowHeight + (rows - 1) * gap;
    
    const rowsTemplateArray: string[] = [];
    for (let i = 0; i < rows; i++) {
      rowsTemplateArray.push('1fr');
    }
    
    const config: GridConfig = {
      rowsTemplate: rowsTemplateArray.join(' '),
      height: totalHeight
    };
    
    return config;
  }

  async aboutToAppear(): Promise<void> {
    // 检查登录状态
    const settings = SettingsUtil.getInstance();
    const isLoggedIn = await settings.isNurseLoggedIn();

    if (!isLoggedIn) {
      ToastUtil.showError('请先登录');
      router.replaceUrl({ url: 'pages/NurseLogin' });
      return;
    }

    // 加载护士信息
    if (!this.nurseInfo) {
      const savedInfo = await settings.getNurseInfo();
      if (savedInfo) {
        this.nurseInfo = savedInfo as NurseInfo;
      }
    }
  }

  private handleLogout(): void {
    AlertDialog.show({
      title: '提示',
      message: '确定要退出登录吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        action: async () => {
          const settings = SettingsUtil.getInstance();
          await settings.clearNurseAuth();
          AppStorage.setOrCreate<string>('nurseToken', '');
          AppStorage.setOrCreate<NurseInfo | null>('nurseInfo', null);
          AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
          router.replaceUrl({ url: 'pages/Index' });
        }
      }
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      Header({ title: '护士工作台' })

      Scroll() {
        Column({ space: 16 }) {
          // 欢迎卡片
          Column() {
            Row() {
              // 头像
              Image(this.nurseInfo?.avatar || $r('app.media.startIcon'))
                .width(60)
                .height(60)
                .borderRadius(30)
                .backgroundColor('#E0E0E0')

              Column() {
                Text(`欢迎，${this.nurseInfo?.name || '护士'}`)
                  .fontSize(this.isElderMode ? 22 : 18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)

                Text(`工号：${this.nurseInfo?.nurseNo || '-'}`)
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: 4 })

                Text(`${this.nurseInfo?.department || '-'} | ${this.nurseInfo?.title || '-'}`)
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 16 })
              .layoutWeight(1)

              // 退出按钮
              Button('退出')
                .fontSize(14)
                .height(36)
                .backgroundColor('#FF6B6B')
                .onClick(() => {
                  this.handleLogout();
                })
            }
            .width('100%')
            .padding(20)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

          // 快捷功能
          Column() {
            Text('快捷功能')
              .fontSize(this.isElderMode ? 20 : 18)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .width('100%')
              .margin({ bottom: 16 })

            Grid() {
              ForEach(this.quickActions, (action: QuickAction) => {
                GridItem() {
                  Column() {
                    Text(action.icon)
                      .fontSize(32)
                      .margin({ bottom: 8 })

                    Text(action.title)
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontColor(GlobalTheme.TEXT_PRIMARY)
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    router.pushUrl({ url: action.route });
                  })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsTemplate(this.calculateGridConfig().rowsTemplate)
            .columnsGap(12)
            .rowsGap(12)
            .width('100%')
            .height(this.calculateGridConfig().height)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

          // 工作统计
          Column() {
            Text('今日工作')
              .fontSize(this.isElderMode ? 20 : 18)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .width('100%')
              .margin({ bottom: 16 })

            Row() {
              Column() {
                Text('12')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#3498DB')
                Text('待护理')
                  .fontSize(14)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Column() {
                Text('8')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2ECC71')
                Text('已完成')
                  .fontSize(14)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Column() {
                Text('3')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F39C12')
                Text('待处理')
                  .fontSize(14)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F5F5')

      // 底部导航
      Row() {
        Column() {
          Text('🏠')
            .fontSize(24)
          Text('工作台')
            .fontSize(12)
            .fontColor(this.currentIndex === 0 ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentIndex = 0;
        })

        Column() {
          Text('👤')
            .fontSize(24)
          Text('个人中心')
            .fontSize(12)
            .fontColor(this.currentIndex === 1 ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .onClick(() => {
          router.pushUrl({ url: 'pages/NurseProfile' });
        })
      }
      .width('100%')
      .height(60)
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: '#E0E0E0' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
