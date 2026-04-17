import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface AuthItem {
  id: string;
  name: string;
  icon: string;
  type: string;
  isAuthorized: boolean;
}

interface PermissionItem {
  id: string;
  name: string;
  icon: string;
  description: string;
  isEnabled: boolean;
}

interface AccessLogItem {
  id: string;
  time: string;
  subject: string;
  content: string;
  action: string;
}

@Entry
@Component
struct PrivacySettingPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State authItems: AuthItem[] = [
    { id: '1', name: '智能手环 HUAWEI Band 8', icon: '⌚', type: '设备', isAuthorized: true } as AuthItem,
    { id: '2', name: '血压监测仪', icon: '🩺', type: '设备', isAuthorized: true } as AuthItem,
    { id: '3', name: '第三方健康平台', icon: '🏥', type: '应用', isAuthorized: false } as AuthItem
  ];

  @State permissionItems: PermissionItem[] = [
    { id: '1', name: '相机权限', icon: '📷', description: '用于拍摄健康档案照片', isEnabled: false } as PermissionItem,
    { id: '2', name: '位置权限', icon: '📍', description: '用于查找附近医疗机构', isEnabled: true } as PermissionItem,
    { id: '3', name: '存储权限', icon: '💾', description: '用于保存健康报告文件', isEnabled: true } as PermissionItem,
    { id: '4', name: '相册权限', icon: '🖼️', description: '用于上传古医图片', isEnabled: true } as PermissionItem
  ];

  @State accessLogs: AccessLogItem[] = [
    { id: '1', time: '2026-04-10 09:30', subject: '智能手环', content: '同步心率数据', action: '读取' } as AccessLogItem,
    { id: '2', time: '2026-04-09 14:20', subject: '血压监测仪', content: '上传血压记录', action: '写入' } as AccessLogItem,
    { id: '3', time: '2026-04-08 08:15', subject: '本应用', content: '查看健康档案', action: '读取' } as AccessLogItem,
    { id: '4', time: '2026-04-07 16:45', subject: '第三方平台', content: '请求数据共享', action: '拒绝' } as AccessLogItem,
    { id: '5', time: '2026-04-06 11:00', subject: '本应用', content: '导出健康报告', action: '读取' } as AccessLogItem
  ];

  @State healthDataVisibility: number = 0;
  @State pushNotificationEnabled: boolean = true;
  @State reminderTypes: string[] = ['用药提醒', '复诊提醒', '健康评估'];
  @State cacheSize: string = '23.5MB';

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  toggleAuth(item: AuthItem): void {
    item.isAuthorized = !item.isAuthorized;
    ToastUtil.showInfo(item.isAuthorized ? `已授权 ${item.name}` : `已撤销 ${item.name} 授权`);
  }

  togglePermission(item: PermissionItem): void {
    item.isEnabled = !item.isEnabled;
    ToastUtil.showInfo(item.isEnabled ? `${item.name} 已开启` : `${item.name} 已关闭`);
  }

  viewPrivacyPolicy(): void {
    router.pushUrl({ url: 'pages/PrivacyPolicyPage' });
  }

  goToDataAuth(): void {
    router.pushUrl({ url: 'pages/DataAuthPage' });
  }

  goToAncientMedicalImg(): void {
    router.pushUrl({ url: 'pages/AncientMedicalImgPage' });
  }

  changePassword(): void {
    promptAction.showDialog({
      title: '修改密码',
      message: '此功能将跳转到修改密码页面',
      buttons: [{ text: '取消', color: '#999999' }, { text: '确定', color: '#1677FF' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        ToastUtil.operationSuccess();
      }
    });
  }

  logout(): void {
    promptAction.showDialog({
      title: '退出登录',
      message: '确定要退出当前账号吗？',
      buttons: [{ text: '取消', color: '#999999' }, { text: '确定退出', color: '#FF4D4F' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        ToastUtil.showInfo('已退出登录');
        router.replaceUrl({ url: 'pages/Login' });
      }
    });
  }

  deleteAccount(): void {
    promptAction.showDialog({
      title: '注销账号',
      message: '注销后您的所有数据将被永久删除且无法恢复，确定要继续吗？',
      buttons: [{ text: '取消', color: '#999999' }, { text: '确定注销', color: '#FF4D4F' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        ToastUtil.showInfo('账号注销申请已提交');
      }
    });
  }

  exportData(): void {
    promptAction.showDialog({
      title: '导出我的数据',
      message: '选择导出格式：',
      buttons: [{ text: 'JSON格式', color: '#1677FF' }, { text: 'PDF格式', color: '#1677FF' }, { text: '取消', color: '#999999' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 0 || result.index === 1) {
        const format: string = result.index === 0 ? 'JSON' : 'PDF';
        ToastUtil.operationSuccess(`正在生成${format}文件...`);
      }
    });
  }

  clearCache(): void {
    promptAction.showDialog({
      title: '清除缓存',
      message: `当前缓存大小：${this.cacheSize}，确定要清除吗？`,
      buttons: [{ text: '取消', color: '#999999' }, { text: '清除', color: '#1677FF' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.cacheSize = '0B';
        ToastUtil.operationSuccess('缓存已清除');
      }
    });
  }

  toggleReminderType(type: string): void {
    const index: number = this.reminderTypes.indexOf(type);
    if (index > -1) {
      this.reminderTypes.splice(index, 1);
    } else {
      this.reminderTypes.push(type);
    }
  }

  build() {
    Column() {
      Header({
        title: '隐私与安全',
        showBack: true
      });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {

          Column() {
            Text('🔐 账户安全')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            this.buildSettingItem('🔑', '修改密码', '定期更换保障账户安全', () => this.changePassword());
            this.buildSettingItem('🚪', '退出登录', '切换到其他账号', () => this.logout(), true);
            this.buildSettingItem('⛔', '注销账号', '永久删除所有数据', () => this.deleteAccount(), true);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column() {
            Text('🔒 隐私权限')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Column() {
              Row() {
                Text('健康数据可见性')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#333333')
                  .layoutWeight(1);

                Text(['仅自己', '授权医生', '家庭成员'][this.healthDataVisibility])
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor('#1677FF');
              }
              .width('100%');

              Row({ space: 8 }) {
                ForEach(['仅自己', '授权医生', '家庭成员'], (option: string, index: number) => {
                  Text(option)
                    .fontSize(11)
                    .fontColor(this.healthDataVisibility === index ? '#FFFFFF' : '#666666')
                    .backgroundColor(this.healthDataVisibility === index ? '#1677FF' : '#F5F5F5')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .borderRadius(15)
                    .onClick(() => {
                      this.healthDataVisibility = index;
                      ToastUtil.showInfo(`已设置为：${option}`);
                    });
                }, (option: string, index: number) => `${option}_${index}`);
              }
              .width('100%')
              .margin({ top: 8 });
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 8 });

            ForEach(this.permissionItems.slice(0, 3), (item: PermissionItem) => {
              this.buildPermissionItem(item);
            }, (item: PermissionItem) => item.id);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column() {
            Text('💾 数据管理')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            this.buildSettingItem('📤', '导出我的数据', '支持 JSON/PDF 格式', () => this.exportData());
            this.buildSettingItem('🗑️', '清除缓存', `当前 ${this.cacheSize}`, () => this.clearCache());

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('📋 数据授权管理')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#333333')
                .layoutWeight(1);

              Text('›')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#1677FF');
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .onClick(() => this.goToDataAuth());

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('🖼️ 古医图管理')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#333333')
                .layoutWeight(1);

              Text('›')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#1677FF');
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ top: 8 })
            .onClick(() => this.goToAncientMedicalImg());
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column() {
            Text('🔔 通知设置')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Row() {
              Text('推送通知')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#333333')
                .layoutWeight(1);

              Text(this.pushNotificationEnabled ? '开' : '关')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(this.pushNotificationEnabled ? '#FFFFFF' : '#999999')
                .backgroundColor(this.pushNotificationEnabled ? '#52C41A' : '#E8E8E8')
                .width(this.isElderMode ? 56 : 44)
                .height(this.isElderMode ? 32 : 26)
                .borderRadius(13)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  this.pushNotificationEnabled = !this.pushNotificationEnabled;
                  ToastUtil.showInfo(this.pushNotificationEnabled ? '推送通知已开启' : '推送通知已关闭');
                });
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FAFAFA')
            .borderRadius(8);

            Column({ space: 8 }) {
              Text('提醒类型')
                .fontSize(12)
                .fontColor('#666666')
                .width('100%');

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(['用药提醒', '复诊提醒', '健康评估', '异常预警'], (type: string) => {
                  Text(type)
                    .fontSize(11)
                    .fontColor(this.reminderTypes.includes(type) ? '#FFFFFF' : '#666666')
                    .backgroundColor(this.reminderTypes.includes(type) ? '#1677FF' : '#F5F5F5')
                    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                    .borderRadius(12)
                    .margin(3)
                    .onClick(() => this.toggleReminderType(type));
                }, (type: string) => type);
              }
              .width('100%');
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ top: 8 });
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column() {
            Text('📜 隐私政策与帮助')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            this.buildSettingItem('📄', '查看隐私政策', '了解我们如何保护您的隐私', () => this.viewPrivacyPolicy());
            this.buildSettingItem('❓', '帮助与反馈', '遇到问题？联系我们', () => {});
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildSettingItem(icon: string, title: string, desc: string, onClick: () => void, isDanger?: boolean) {
    Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
      Text(icon)
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode));

      Column({ space: 4 }) {
        Text(title)
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor(isDanger ? '#FF4D4F' : '#333333')
          .fontWeight(FontWeight.Medium);

        Text(desc)
          .fontSize(11)
          .fontColor('#999999');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });

      Text('›')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontColor(isDanger ? '#FF4D4F' : '#CCCCCC');
    }
    .width('100%')
    .padding(GlobalTheme.getSpacingMD(this.isElderMode))
    .backgroundColor(isDanger ? '#FFF7F7' : '#FAFAFA')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(onClick);
  }

  @Builder
  buildPermissionItem(item: PermissionItem) {
    Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
      Text(item.icon)
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode));

      Column({ space: 4 }) {
        Text(item.name)
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium);

        Text(item.description)
          .fontSize(11)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });

      Text(item.isEnabled ? '开' : '关')
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(item.isEnabled ? '#FFFFFF' : '#999999')
        .backgroundColor(item.isEnabled ? '#52C41A' : '#E8E8E8')
        .width(this.isElderMode ? 56 : 44)
        .height(this.isElderMode ? 32 : 26)
        .borderRadius(13)
        .textAlign(TextAlign.Center)
        .onClick(() => this.togglePermission(item));
    }
    .width('100%')
    .padding(GlobalTheme.getSpacingMD(this.isElderMode))
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .margin({ bottom: 8 });
  }
}