import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { AccessibilitySettingsPanel, FirstTimeGuide } from '../components/GuideComponents';
import { NetworkStatusBanner } from '../components/ErrorComponents';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { HttpUtil, BaseResponse, RequestOptions } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import EventPersistenceManager from '../utils/EventPersistenceManager';
import { UserInfoCard } from '../components/UserInfoCard';
import { HealthStatsCard } from '../components/HealthStatsCard';
import { ServiceList } from '../components/ServiceList';
import { SettingsList } from '../components/SettingsList';
import { CarouselBanner } from '../components/CarouselBanner';
import { BannerItem } from '../components/CarouselBanner';

interface UserInfo {
  username: string;
  avatar: string;
  age: number;
  gender: string;
}

interface MenuItem {
  icon: string;
  title: string;
  color: string;
  url: string;
}

interface HealthStats {
  healthRecordCount: number;
  collectCount: number;
  browseHistoryCount: number;
}

@Entry
@Component
struct Profile {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') userId: number = 0;
  @StorageLink('username') storedUsername: string = '';

  @State showAccessibilityPanel: boolean = false;
  @State banners: BannerItem[] = [];
  @State healthStats: HealthStats = {
    healthRecordCount: 0,
    collectCount: 0,
    browseHistoryCount: 0
  };
  // 保留动态用户信息展示
  @State displayUsername: string = '星云用户';
  @State displayPhone: string = '';

  @State menuItems: MenuItem[] = [
    { icon: '📋', title: '我的挂号', color: '#1677FF', url: 'pages/Appointments' },
    { icon: '📱', title: '设备绑定', color: '#1677FF', url: 'pages/DeviceDiscoveryPage' },
    { icon: '👥', title: '家属管理', color: '#52C41A', url: 'pages/FamilyPage' },
    { icon: '🎤', title: '语音助手', color: '#1677FF', url: 'pages/VoiceAssistantPage' },
    { icon: '📊', title: '健康统计报告', color: '#52C41A', url: 'pages/StatisticsPage' },
    { icon: '🏆', title: '社区排行榜', color: '#FAAD14', url: 'pages/RankingPage' },
    { icon: '📋', title: '我的病历', color: '#1677FF', url: 'pages/MedicalRecord' },
    { icon: '❤️', title: '我的收藏', color: '#FF4757', url: 'pages/MyCollectPage' },
    { icon: '📖', title: '浏览历史', color: '#1677FF', url: 'pages/BrowseHistoryPage' }
  ];

  @State settingsItems: MenuItem[] = [
    { icon: '♿', title: '无障碍/老年模式', color: '#722ED1', url: '' },
    { icon: '🔔', title: '通知设置', color: '#1677FF', url: 'pages/ReminderSettingsPage' },
    { icon: '👥', title: '紧急联系人', color: '#1677FF', url: 'pages/EmergencyContactsPage' },
    { icon: '💊', title: '提醒设置', color: '#52C41A', url: 'pages/ReminderSettingsPage' },
    { icon: '🔒', title: '隐私与安全', color: '#1677FF', url: 'pages/PrivacySettingPage' },
    { icon: 'ℹ️', title: '关于我们', color: '#333333', url: 'pages/TestPage' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    // 初始化用户信息 + 加载数据
    this.initUserInfo();
    this.loadAllData();
  }

  // 初始化用户信息（动态读取存储数据）
  initUserInfo(): void {
    if (this.storedUsername && this.storedUsername.trim() !== '') {
      this.displayUsername = this.storedUsername;
    }
    const userInfo: Object | undefined = AppStorage.get<Object>('userInfo');
    if (userInfo) {
      const info: Record<string, Object> = userInfo as Record<string, Object>;
      const phone: string = (info['phone'] !== undefined && info['phone'] !== null)
        ? String(info['phone']) : '';
      const name: string = (info['username'] !== undefined && info['username'] !== null)
        ? String(info['username']) : '';
      if (name.trim() !== '') { this.displayUsername = name; }
      if (phone.trim() !== '') {
        this.displayPhone = phone.length > 7
          ? phone.substring(0, 3) + '****' + phone.substring(phone.length - 4) : phone;
      }
    }
  }

  loadAllData() {
    this.loadBanners();
    this.loadHealthStats();
  }

  loadBanners() {
  }

  loadHealthStats() {
  }

  toggleElderMode(): void {
    this.isElderMode = !this.isElderMode;
    AppStorage.setOrCreate<boolean>('isOldModeEnabled', this.isElderMode);
  }

  handleMenuClick(item: MenuItem): void {
    if (item.title === '无障碍/老年模式') {
      this.showAccessibilityPanel = true;
      return;
    }
    if (item.url) {
      try {
        router.pushUrl({ url: item.url });
      } catch (e) {
        console.error('路由跳转失败:', e);
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Header({
          title: '个人中心',
          showBack: true,
          rightAction: {
            icon: '♿',
            label: '无障碍设置',
            onClick: () => {
              this.showAccessibilityPanel = true;
            }
          }
        });

        Scroll() {
          Column() {
            // 动态用户信息卡片
            UserInfoCard({
              username: this.displayUsername,
              phone: this.displayPhone || '未绑定手机',
              userId: this.userId || 0
            });

            if (this.banners.length > 0) {
              CarouselBanner({ banners: this.banners })
                .margin({ top: 12 });
            }

            HealthStatsCard({
              healthRecordCount: this.healthStats.healthRecordCount,
              collectCount: this.healthStats.collectCount,
              browseHistoryCount: this.healthStats.browseHistoryCount
            })
              .margin({ top: 16 });

            ServiceList({
              menuItems: this.menuItems,
              onMenuClick: (item: MenuItem) => {
                this.handleMenuClick(item);
              }
            });

            SettingsList({
              settingsItems: this.settingsItems,
              onMenuClick: (item: MenuItem) => {
                this.handleMenuClick(item);
              }
            });

            // 退出登录按钮（统一样式）
            Button('退出登录')
              .width('85%')
              .height(44)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FF4D4F')
              .backgroundColor('#FFF1F0')
              .borderRadius(22)
              .margin({ top: 20, bottom: 24 })
              .accessibilityText('退出登录按钮')
              .onClick(async () => {
                try {
                  const settings: SettingsUtil = SettingsUtil.getInstance();
                  await settings.clearAllLoginData();
                  EventPersistenceManager.clearUserCache();
                  ToastUtil.showInfo('已退出登录');
                  router.replaceUrl({ url: 'pages/Login' });
                } catch (error) {
                  console.error('退出登录失败:', error);
                }
              });
          }
          .width('100%');
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);

        Footer({ activeIndex: 4 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AccessibilityConfig.getBgColor());

      // 无障碍设置弹窗
      if (this.showAccessibilityPanel) {
        AccessibilitySettingsPanel({
          onDismiss: () => {
            this.showAccessibilityPanel = false;
          }
        });
      }
    }
    .width('100%')
    .height('100%');
  }
}