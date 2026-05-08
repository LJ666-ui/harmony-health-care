import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse, RequestOptions } from '../common/utils/HttpUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

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
  @StorageLink('isFamilyLoggedIn') isFamilyLoggedIn: boolean = false;

  @State isLoading: boolean = false;
  @State relatedUser: RelatedUser | null = null;
  @State healthRecords: HealthRecord[] = [];
  @State activeTab: number = 0; // 0: 个人信息, 1: 健康记录, 2: 关联用户

  async aboutToAppear(): Promise<void> {
    // 检查登录状态
    if (!this.isFamilyLoggedIn) {
      router.replaceUrl({ url: 'pages/FamilyLogin' });
      return;
    }

    // 加载数据
    await this.loadData();
  }

  // 加载数据
  private async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      // 获取家属详细信息
      const options: RequestOptions = { skipAuth: false };
      const response = await HttpUtil.get<FamilyInfo>('/family/info', options);

      if (response.success && response.data) {
        this.familyInfo = response.data;
        AppStorage.setOrCreate<FamilyInfo>('familyInfo', response.data);
      }
    } catch (error) {
      console.error('加载家属信息失败:', error);
      ToastUtil.showError('加载信息失败');
    } finally {
      this.isLoading = false;
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

      // 主要内容区域
      Column() {
        // 家属信息卡片
        if (this.familyInfo) {
          Column() {
            // 头像和姓名
            Row() {
              Image($r('app.media.startIcon'))
                .width(60)
                .height(60)
                .borderRadius(30)
                .margin({ right: 15 })

              Column() {
                Text(this.familyInfo.name)
                  .fontSize(this.isElderMode ? 22 : 18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)

                Text(this.getRelationText(this.familyInfo.relation))
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: 5 })

                if (this.familyInfo.isEmergencyContact === 1) {
                  Text('紧急联系人')
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#FF5722')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(4)
                    .margin({ top: 5 })
                }
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(15)

            // 基本信息
            Row() {
              this.InfoItem('手机号', this.familyInfo.phone || '未设置')
              Divider().vertical(true).height(30).color('#E0E0E0')
              this.InfoItem('年龄', this.familyInfo.age ? `${this.familyInfo.age}岁` : '未设置')
              Divider().vertical(true).height(30).color('#E0E0E0')
              this.InfoItem('性别', this.getGenderText(this.familyInfo.gender))
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .padding({ top: 10, bottom: 10 })
            .backgroundColor('#FAFAFA')

            // 健康状况
            if (this.familyInfo.healthCondition) {
              Column() {
                Text('健康状况')
                  .fontSize(14)
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .margin({ bottom: 5 })

                Text(this.familyInfo.healthCondition)
                  .fontSize(this.isElderMode ? 18 : 16)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(15)
              .backgroundColor('#FFFFFF')
              .margin({ top: 10 })
            }
          }
          .width('95%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 15 })
          .shadow({ radius: 5, color: '#E0E0E0', offsetX: 0, offsetY: 2 })
        }

        // 功能菜单
        Column() {
          Text('功能菜单')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .margin({ bottom: 15 })

          // 菜单项
          Column() {
            this.MenuItem('📋 查看健康记录', '查看您和关联用户的健康记录', () => {
              router.pushUrl({ url: 'pages/FamilyHealthRecords' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('👥 查看关联用户', '查看关联用户的信息', () => {
              router.pushUrl({ url: 'pages/FamilyPage' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('💬 咨询聊天', '与医护人员在线沟通', () => {
              router.pushUrl({ url: 'pages/FamilyChatListPage' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('💊 用药管理', '查看和管理用药信息', () => {
              router.pushUrl({ url: 'pages/FamilyMedication' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('🏥 医疗记录', '查看医疗和就诊记录', () => {
              router.pushUrl({ url: 'pages/FamilyHealthRecords' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('📊 健康监测', '查看健康数据和趋势', () => {
              router.pushUrl({ url: 'pages/FamilyHealthRecords' });
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('🔔 消息通知', '查看健康提醒和通知', () => {
              ToastUtil.showInfo('消息通知功能开发中');
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('🔐 修改密码', '修改登录密码', () => {
              ToastUtil.showInfo('修改密码功能开发中');
            })

            Divider().width('100%').color('#E0E0E0')

            this.MenuItem('👨‍👩‍👧 家属管理', '管理家属成员信息', () => {
              router.pushUrl({ url: 'pages/FamilyPage' });
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }
        .width('95%')
        .margin({ top: 20 })
        .padding(15)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 5, color: '#E0E0E0', offsetX: 0, offsetY: 2 })

        // 底部提示
        Text('家属登录功能 v1.0')
          .fontSize(12)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .margin({ top: 30, bottom: 20 })
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F5F5')

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
