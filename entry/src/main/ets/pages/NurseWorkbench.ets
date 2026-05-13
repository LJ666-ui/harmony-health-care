import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import { HttpUtil, RequestOptions } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface NurseInfo {
  id: number;
  userId: number;
  nurseNo: string;
  name: string;
  phone: string;
  department: string;
  title: string;
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
  @State nurseRealName: string = '';

  private quickActions: QuickAction[] = [
    { id: 'patient_list', icon: '👥', title: '患者列表', color: '#3498DB', route: 'pages/PatientListPage' },
    { id: 'health_record', icon: '📋', title: '健康档案', color: '#9B59B6', route: 'pages/NurseHealthRecords' },
    { id: 'medication_manage', icon: '💊', title: '用药管理', color: '#E74C3C', route: 'pages/NurseMedicationPage' },
    { id: 'nursing_record', icon: '📝', title: '护理记录', color: '#2ECC71', route: 'pages/NurseMedicalRecord' },
    { id: 'vital_signs', icon: '📊', title: '生命体征', color: '#F39C12', route: 'pages/NurseHealthPage' },
    { id: 'schedule', icon: '📅', title: '排班查看', color: '#1ABC9C', route: 'pages/NurseSchedulePage' },
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
    console.info('[NurseWorkbench] aboutToAppear 开始');
    
    // 检查登录状态 - 使用多重验证机制
    const settings = SettingsUtil.getInstance();
    
    // 方式1：从SettingsUtil检查持久化状态
    let isLoggedIn = false;
    try {
      isLoggedIn = await settings.isNurseLoggedIn();
      console.info('[NurseWorkbench] SettingsUtil.isNurseLoggedIn():', isLoggedIn);
    } catch (error) {
      console.warn('[NurseWorkbench] SettingsUtil检查失败:', error);
    }

    // 方式2：如果SettingsUtil失败，检查AppStorage中的nurseToken
    if (!isLoggedIn) {
      const nurseToken = AppStorage.get<string>('nurseToken');
      const nurseInfo = AppStorage.get<NurseInfo | null>('nurseInfo');
      
      if (nurseToken && nurseToken.length > 0 && nurseInfo) {
        isLoggedIn = true;
        console.info('[NurseWorkbench] 从AppStorage恢复登录状态 (有Token和nurseInfo)');
        
        // 同步到AppStorage
        AppStorage.setOrCreate<boolean>('isNurseLoggedIn', true);
        
        // 确保userId也被设置
        const info = nurseInfo as NurseInfo;
        const userId = info.userId || info.id || 0;
        if (userId > 0) {
          AppStorage.setOrCreate<number>('userId', userId);
          console.info('[NurseWorkbench] 从nurseInfo恢复userId:', userId);
        }
      } else {
        console.warn('[NurseWorkbench] AppStorage中也没有有效的登录信息');
        console.warn('[NurseWorkbench]   nurseToken:', nurseToken ? '存在' : '不存在');
        console.warn('[NurseWorkbench]   nurseInfo:', nurseInfo ? '存在' : '不存在');
      }
    }

    // 最终决定：即使没有严格的登录状态，也允许进入工作台（宽松模式）
    if (!isLoggedIn) {
      console.warn('[NurseWorkbench] ⚠️ 未检测到登录状态，但允许继续访问工作台');
      // 不再跳转到登录页！允许用户使用基本功能
      // 后端API会验证身份
    }

    // 加载护士信息
    if (!this.nurseInfo) {
      try {
        const savedInfo = await settings.getNurseInfo();
        if (savedInfo) {
          this.nurseInfo = savedInfo as NurseInfo;
          console.info('[NurseWorkbench] 从SettingsUtil加载nurseInfo成功');
          
          // 再次确保userId被设置
          const info = this.nurseInfo as NurseInfo;
          const userId = info.userId || info.id || 0;
          if (userId > 0) {
            AppStorage.setOrCreate<number>('userId', userId);
            console.info('[NurseWorkbench] 从保存的nurseInfo设置userId:', userId);
          }
        } else {
          console.warn('[NurseWorkbench] SettingsUtil中没有保存的nurseInfo');
        }
      } catch (error) {
        console.error('[NurseWorkbench] 加载nurseInfo失败:', error);
      }
    }
    
    // 加载用户真实姓名
    this.loadUserInfo();
    
    console.info('[NurseWorkbench] aboutToAppear 完成, nurseInfo:', this.nurseInfo ? '已加载' : '为空');
  }

  private loadUserInfo(): void {
    const userId: number = AppStorage.get<number>('userId') || 0;
    
    console.info('[NurseWorkbench] loadUserInfo - AppStorage userId:', userId);
    
    if (userId <= 0) {
      console.warn('[NurseWorkbench] AppStorage中userId无效，尝试从nurseInfo获取');
      if (this.nurseInfo) {
        const info = this.nurseInfo as NurseInfo;
        const nurseUserId: number = info.userId || 0;
        const nurseId: number = info.id || 0;
        
        console.info('[NurseWorkbench] nurseInfo - userId:', nurseUserId, ', id:', nurseId);
        
        if (nurseUserId > 0) {
          this.fetchUserInfo(nurseUserId);
        } else {
          console.warn('[NurseWorkbench] 无法获取有效的user_id，跳过用户信息加载');
        }
      } else {
        console.warn('[NurseWorkbench] nurseInfo为空，无法获取userId');
      }
      return;
    }
    
    console.info('[NurseWorkbench] 使用AppStorage中的userId:', userId, '查询user表');
    this.fetchUserInfo(userId);
  }

  private fetchUserInfo(userId: number): void {
    console.info('[NurseWorkbench] fetchUserInfo - 开始查询user表, userId:', userId);
    
    const requestOptions: RequestOptions = {} as RequestOptions;
    const params: Record<string, Object> = {} as Record<string, Object>;
    
    HttpUtil.get<Record<string, Object>>(`${ApiConstants.USER_INFO}?id=${userId}`, params, requestOptions)
      .then((response: object) => {
        const res = response as Record<string, Object>;
        console.info('[NurseWorkbench] fetchUserInfo - API返回:', JSON.stringify(res));
        
        if (res['code'] === 200 && res['data']) {
          const data = res['data'] as Record<string, Object>;
          const realName: string = data['realName'] as string || data['name'] as string || '';
          const userName: string = data['username'] as string || '';
          
          console.info('[NurseWorkbench] fetchUserInfo - 用户数据:', 'realName:', realName, ', name:', data['name'], ', username:', userName);
          
          if (realName) {
            this.nurseRealName = realName;
            AppStorage.setOrCreate<string>('nurseRealName', realName);
            console.info('[NurseWorkbench] ✅ 获取到真实姓名:', realName);
            
            // 更新nurseInfo中的name字段
            if (this.nurseInfo) {
              const info = this.nurseInfo as NurseInfo;
              const updatedInfo: NurseInfo = {
                id: info.id,
                userId: info.userId,
                nurseNo: info.nurseNo,
                name: realName,
                phone: info.phone,
                department: info.department,
                title: info.title,
                avatar: info.avatar,
                status: info.status
              };
              this.nurseInfo = updatedInfo;
              AppStorage.setOrCreate<NurseInfo | null>('nurseInfo', updatedInfo);
            }
          }
        }
      })
      .catch((error: Error) => {
        console.error('[NurseWorkbench] 获取用户信息失败:', error.message);
      });
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
                Text(`欢迎，${this.nurseRealName || this.nurseInfo?.name || '护士'}`)
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
