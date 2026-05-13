import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse, RequestOptions } from '../common/utils/HttpUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

interface FamilyInfo {
  id: number;
  name: string;
  phone: string;
  relation: string;
  age?: number;
  gender?: number;
  healthCondition?: string;
  isEmergencyContact: number;
  userId: number;
}

interface RelatedUser {
  id: number;
  username: string;
  realName?: string;
  phone?: string;
}

interface HealthRecord {
  id: number;
  recordType: string;
  value: string;
  unit: string;
  recordTime: string;
  remark?: string;
}

@Entry
@Component
struct FamilyHome {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('familyInfo') familyInfo: FamilyInfo | null = null;
  @State isFamilyLoggedIn: boolean = false;

  @State isLoading: boolean = false;
  @State relatedUser: RelatedUser | null = null;
  @State healthRecords: HealthRecord[] = [];
  @State activeTab: number = 0;
  @State aiHealthDashboard: string = '';
  @State aiFamilyCareAdvice: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  async aboutToAppear(): Promise<void> {
    console.log('[FamilyHome] aboutToAppear开始执行');

    try {
      // 从AppStorage获取登录状态
      this.isFamilyLoggedIn = AppStorage.get<boolean>('isFamilyLoggedIn') || false;
      console.log('[FamilyHome] isFamilyLoggedIn:', this.isFamilyLoggedIn);

      // 检查登录状态 - 添加Token验证
      const familyToken: string | undefined = AppStorage.get<string>('familyToken');
      console.log('[FamilyHome] familyToken:', familyToken ? (familyToken.substring(0, 20) + '...') : '未获取');

      if (!this.isFamilyLoggedIn || !familyToken || familyToken.length === 0) {
        console.error('[FamilyHome] 家属未登录或Token无效,跳转到登录页');
        router.replaceUrl({ url: 'pages/FamilyLogin' });
        return;
      }

      console.log('[FamilyHome] 登录验证通过,开始加载数据');
      // 加载数据 - 使用try-catch保护整个加载过程
      await this.loadData();
    } catch (error) {
      console.error('[FamilyHome] aboutToAppear发生异常:', error);
      // 设置默认值，防止UI渲染崩溃
      this.setDefaultValues();
    }
  }

  private setDefaultValues(): void {
    const defaultInfo: FamilyInfo = {
      id: 0,
      name: '家属',
      phone: '',
      relation: '未知',
      userId: 0,
      isEmergencyContact: 0
    };
    this.familyInfo = defaultInfo;

    const defaultUser: RelatedUser = {
      id: 0,
      username: '患者',
      realName: '',
      phone: ''
    };
    this.relatedUser = defaultUser;
    this.isLoading = false;
  }

  // 加载数据
  private async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      // 使用家属Token进行认证
      const response: BaseResponse<FamilyInfo> = await HttpUtil.get<FamilyInfo>('/family/info');

      if (response.success && response.data) {
        this.familyInfo = response.data;
        AppStorage.setOrCreate<FamilyInfo>('familyInfo', response.data);
        console.log('[FamilyHome] 家属信息加载成功:', JSON.stringify(response.data));

        // 安全地获取userId
        const userId: number = response.data.userId || 0;
        if (userId > 0) {
          console.log('[FamilyHome] 开始加载关联用户,userId:', userId);
          // 先设置默认值，防止加载过程中UI崩溃
          const tempUser: RelatedUser = { id: userId, username: '加载中...', realName: '', phone: '' };
          this.relatedUser = tempUser;

          await this.loadRelatedUserInfo(userId);
        } else {
          console.warn('[FamilyHome] 家属没有关联患者');
          const defaultUser: RelatedUser = { id: 0, username: '未关联', realName: '', phone: '' };
          this.relatedUser = defaultUser;
        }
      } else {
        // 请求失败 - 设置默认值而不是让页面崩溃
        console.error('[FamilyHome] 加载家属信息失败:', response.message);
        const defaultInfo: FamilyInfo = {
          id: 0,
          name: '家属',
          phone: '',
          relation: '未知',
          userId: 0,
          isEmergencyContact: 0
        };
        this.familyInfo = defaultInfo;
        const defaultUser: RelatedUser = { id: 0, username: '患者', realName: '', phone: '' };
        this.relatedUser = defaultUser;

        if (response.code !== 401) {
          ToastUtil.showError(response.message || '加载信息失败');
        }
      }
    } catch (error) {
      console.error('[FamilyHome] loadData发生异常:', error);
      // 异常时设置默认值，确保UI能正常渲染
      this.setDefaultValues();
      ToastUtil.showError('加载信息失败');
    } finally {
      this.isLoading = false;
    }
  }

  private async loadRelatedUserInfo(userId: number): Promise<void> {
    try {
      console.log('[FamilyHome] 开始加载关联用户信息,userId:', userId);
      const queryParams: Record<string, number> = { 'id': userId };
      const response = await HttpUtil.get<RelatedUser>('/user/info', queryParams);
      if (response.success && response.data) {
        this.relatedUser = response.data;
        AppStorage.setOrCreate<RelatedUser>('relatedUser', response.data);
        console.log('[FamilyHome] 关联用户信息加载成功:', JSON.stringify(response.data));
      } else {
        console.error('[FamilyHome] 加载关联用户信息失败:', response.message);
        const defaultUser: RelatedUser = { id: userId, username: '患者', realName: '', phone: '' };
        this.relatedUser = defaultUser;
      }
    } catch (error) {
      console.error('[FamilyHome] 加载关联用户信息异常:', error);
      const defaultUser: RelatedUser = { id: userId, username: '患者', realName: '', phone: '' };
      this.relatedUser = defaultUser;
    }
  }

  // 退出登录
  private async handleLogout(): Promise<void> {
    try {
      const settings = SettingsUtil.getInstance();
      await settings.clearFamilyAuth();

      AppStorage.setOrCreate<string>('familyToken', '');
      AppStorage.setOrCreate<FamilyInfo | null>('familyInfo', null);
      AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);

      ToastUtil.showSuccess('已退出登录');
      router.replaceUrl({ url: 'pages/Login' });
    } catch (error) {
      console.error('退出登录失败:', error);
    }
  }

  async generateHealthDashboard(): Promise<void> {
    const healthSummary = this.healthRecords.map(r =>
      `${r.recordType}: ${r.value}${r.unit} (${r.recordTime})`
    ).join('\n');
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `家庭成员健康数据：\n${healthSummary}\n请生成健康仪表盘摘要`
        }
      });
      this.aiHealthDashboard = response.output.content as string;
    } catch (error) {
      console.error('[FamilyHome] AI健康仪表盘失败:', error);
      this.aiHealthDashboard = '';
    }
  }

  async getFamilyCareAdvice(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: '请给出家庭护理建议和注意事项'
        }
      });
      this.aiFamilyCareAdvice = response.output.content as string;
    } catch (error) {
      console.error('[FamilyHome] AI护理建议失败:', error);
      this.aiFamilyCareAdvice = '';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Header({
        title: '家属中心',
        showBack: false,
        rightAction: {
          icon: '🚪',
          label: '退出',
          onClick: () => {
            this.handleLogout();
          }
        }
      })

      // 主要内容区域 - 添加Scroll组件支持滚动
      Scroll() {
        Column() {
          // 家属信息卡片(简化版)
          if (this.familyInfo) {
          Row() {
            Image($r('app.media.startIcon'))
              .width(40)
              .height(40)
              .borderRadius(20)
              .margin({ right: 12 })

            Column() {
              Text(`${this.familyInfo.name} (${this.getRelationText(this.familyInfo.relation)})`)
                .fontSize(this.isElderMode ? 18 : 16)
                .fontWeight(FontWeight.Bold)
                .fontColor(GlobalTheme.TEXT_PRIMARY)

              if (this.familyInfo.isEmergencyContact === 1) {
                Text('紧急联系人')
                  .fontSize(12)
                  .fontColor('#FF5722')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('95%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 10 })
        }

        // 关联患者信息卡片(重点展示)
        if (this.relatedUser) {
          Column() {
            Row() {
              Text('👤 关联患者')
                .fontSize(this.isElderMode ? 18 : 16)
                .fontWeight(FontWeight.Bold)
                .fontColor(GlobalTheme.TEXT_PRIMARY)

              Blank()

              Button('查看详情 >')
                .height(28)
                .fontSize(12)
                .fontColor('#3498DB')
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  if (this.relatedUser && this.relatedUser.id) {
                    console.log('[FamilyHome] 跳转到患者详情, userId:', this.relatedUser.id);
                    router.pushUrl({
                      url: 'pages/FamilyPatientDetail',
                      params: { userId: this.relatedUser.id }
                    });
                  } else if (this.familyInfo && this.familyInfo.userId) {
                    // 如果relatedUser没有数据，使用familyInfo中的userId
                    console.log('[FamilyHome] 使用familyInfo.userId跳转:', this.familyInfo.userId);
                    router.pushUrl({
                      url: 'pages/FamilyPatientDetail',
                      params: { userId: this.familyInfo.userId }
                    });
                  } else {
                    ToastUtil.showError('未找到关联患者信息');
                  }
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 8 })

            Divider().color('#E0E0E0')

            Row() {
              Image($r('app.media.startIcon'))
                .width(60)
                .height(60)
                .borderRadius(30)
                .margin({ right: 16 })

              Column() {
                Text(this.relatedUser.realName || this.relatedUser.username || '患者')
                  .fontSize(this.isElderMode ? 22 : 20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)

                Text(`患者ID: ${this.relatedUser.id}`)
                  .fontSize(13)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: 4 })

                if (this.relatedUser.phone) {
                  Text(`联系电话: ${this.relatedUser.phone}`)
                    .fontSize(13)
                    .fontColor(GlobalTheme.TEXT_SECONDARY)
                    .margin({ top: 2 })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(16)
          }
          .width('95%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 12 })
          .shadow({ radius: 5, color: '#E0E0E0', offsetX: 0, offsetY: 2 })
        }

        // 快捷功能入口
        Column() {
          Text('快捷服务')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .margin({ bottom: 12 })

          Row({ space: 12 }) {
            this.QuickCard('📋', '就诊记录', '诊断和就诊历史', '#3498DB', () => {
              router.pushUrl({ url: 'pages/FamilyMedicalRecords' });
            })

            this.QuickCard('💊', '处方记录', '医生开具的处方', '#27AE60', () => {
              router.pushUrl({ url: 'pages/FamilyPrescription' });
            })
          }
          .width('100%')

          Row({ space: 12 }) {
            this.QuickCard('📊', '健康数据', '血压血糖等指标', '#9B59B6', () => {
              router.pushUrl({ url: 'pages/FamilyHealthRecords' });
            })

            this.QuickCard('🔔', '复诊安排', '预约和复查日期', '#F39C12', () => {
              router.pushUrl({ url: 'pages/FamilyFollowUp' });
            })
          }
          .width('100%')
          .margin({ top: 12 })
        }
        .width('95%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ top: 16 })
        .shadow({ radius: 5, color: '#E0E0E0', offsetX: 0, offsetY: 2 })

        // 其他功能
        Column() {
          Text('更多功能')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .margin({ bottom: 12 })

          Column() {
            this.MenuItem('💬 在线咨询', '与医生、护士在线沟通', () => {
              router.pushUrl({ url: 'pages/FamilyChatListPage' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('💊 用药计划', '定时用药提醒设置', () => {
              router.pushUrl({ url: 'pages/FamilyMedication' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('👤 患者详情', '查看完整个人信息', () => {
              if (this.familyInfo && this.familyInfo.userId) {
                router.pushUrl({
                  url: 'pages/FamilyPatientDetail',
                  params: { userId: this.familyInfo.userId }
                });
              } else {
                ToastUtil.showError('未找到关联患者信息');
              }
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }
        .width('95%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ top: 16 })
        .shadow({ radius: 5, color: '#E0E0E0', offsetX: 0, offsetY: 2 })

        // 底部提示
        Text('家属服务 v2.0 - 关爱从了解开始')
          .fontSize(12)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .margin({ top: 20, bottom: 20 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F5F5')
      .scrollable(ScrollDirection.Vertical)  // 允许垂直滚动
      .scrollBar(BarState.Auto)  // 自动显示滚动条
      .edgeEffect(EdgeEffect.Spring)  // 添加弹性效果

      // Loading遮罩
      if (this.isLoading) {
        Loading()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 信息项组件
  @Builder
  InfoItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor(GlobalTheme.TEXT_SECONDARY)

      Text(value)
        .fontSize(this.isElderMode ? 18 : 16)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .margin({ top: 5 })
    }
  }

  // 菜单项组件
  @Builder
  MenuItem(title: string, description: string, onClick: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(this.isElderMode ? 18 : 16)
          .fontColor(GlobalTheme.TEXT_PRIMARY)

        Text(description)
          .fontSize(12)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(20)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(15)
    .onClick(onClick)
  }

  // 快捷卡片组件
  @Builder
  QuickCard(icon: string, title: string, description: string, color: string, onClick: () => void) {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: 8 })

      Text(title)
        .fontSize(this.isElderMode ? 16 : 14)
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY)

      Text(description)
        .fontSize(11)
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .margin({ top: 4 })
        .maxLines(2)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(color + '15')
    .borderRadius(12)
    .border({ width: 1, color: color + '40' })
    .onClick(onClick)
  }

  // 获取关系文本
  private getRelationText(relation: string): string {
    const relationMap: Record<string, string> = {
      '配偶': '配偶',
      '子女': '子女',
      '父母': '父母',
      '兄弟姐妹': '兄弟姐妹',
      '其他': '其他'
    };
    return relationMap[relation] || relation;
  }

  // 获取性别文本
  private getGenderText(gender?: number): string {
    if (gender === 1) return '男';
    if (gender === 2) return '女';
    return '未知';
  }
}
