import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

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
    { id: '1', name: '智能手环 HUAWEI Band 8', icon: '⌚', type: '设备', isAuthorized: true },
    { id: '2', name: '血压监测仪', icon: '🩺', type: '设备', isAuthorized: true },
    { id: '3', name: '第三方健康平台', icon: '🏥', type: '应用', isAuthorized: false }
  ];

  @State permissionItems: PermissionItem[] = [
    { id: '1', name: '相机权限', icon: '📷', description: '用于拍摄健康档案照片', isEnabled: false },
    { id: '2', name: '位置权限', icon: '📍', description: '用于查找附近医疗机构', isEnabled: true },
    { id: '3', name: '存储权限', icon: '💾', description: '用于保存健康报告文件', isEnabled: true },
    { id: '4', name: '通知权限', icon: '🔔', description: '用于接收健康提醒通知', isEnabled: true }
  ];

  @State accessLogs: AccessLogItem[] = [
    { id: '1', time: '2026-04-10 09:30', subject: '智能手环', content: '同步心率数据', action: '读取' },
    { id: '2', time: '2026-04-09 14:20', subject: '血压监测仪', content: '上传血压记录', action: '写入' },
    { id: '3', time: '2026-04-08 08:15', subject: '本应用', content: '查看健康档案', action: '读取' },
    { id: '4', time: '2026-04-07 16:45', subject: '第三方平台', content: '请求数据共享', action: '拒绝' },
    { id: '5', time: '2026-04-06 11:00', subject: '本应用', content: '导出健康报告', action: '读取' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  toggleAuth(item: AuthItem): void {
    item.isAuthorized = !item.isAuthorized;
  }

  togglePermission(item: PermissionItem): void {
    item.isEnabled = !item.isEnabled;
  }

  viewPrivacyPolicy(): void {
    router.pushUrl({ url: 'pages/PrivacyPolicyPage' });
  }

  requestDeleteData(): void {
    console.log('申请删除个人数据');
  }

  build() {
    Column() {
      Header({
        title: '隐私与权限',
        showBack: true
      });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('隐私与权限')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Column() {
            Text('🛡️ 个人信息保护')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('📄 查看隐私政策')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#1677FF')
                .layoutWeight(1);

              Text('›')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#1677FF');
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#f0f0f0' })
            .onClick(() => this.viewPrivacyPolicy());

            Button('申请删除我的数据')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#FF4D4F')
              .backgroundColor('#FFF1F0')
              .borderRadius(12)
              .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode) })
              .onClick(() => this.requestDeleteData());
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Column() {
            Text('🔗 数据授权管理')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            ForEach(this.authItems, (item: AuthItem) => {
              Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                Column({ space: 4 }) {
                  Text(item.icon)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode));
                  Text(`[${item.type}]`)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#999999');
                }
                .alignItems(HorizontalAlign.Center);

                Column({ space: 4 }) {
                  Text(item.name)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });

                  Text(item.isAuthorized ? '已授权' : '未授权')
                    .fontSize(11)
                    .fontColor(item.isAuthorized ? '#52C41A' : '#999999');
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });

                Text(item.isAuthorized ? '已开启' : '已关闭')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(item.isAuthorized ? '#52C41A' : '#999999')
                  .backgroundColor(item.isAuthorized ? '#F6FFED' : '#F5F5F5')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(16);
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .onClick(() => this.toggleAuth(item));
            }, (item: AuthItem) => item.id);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Column() {
            Text('⚙️ 设备权限控制')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            ForEach(this.permissionItems, (item: PermissionItem) => {
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
                  .backgroundColor(item.isEnabled ? '#1677FF' : '#E8E8E8')
                  .width(this.isElderMode ? 56 : 44)
                  .height(this.isElderMode ? 32 : 26)
                  .borderRadius(13)
                  .textAlign(TextAlign.Center)
                  .onClick(() => this.togglePermission(item));
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FAFAFA')
              .borderRadius(8);
            }, (item: PermissionItem) => item.id);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });

          Column() {
            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('📋 数据访问日志')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight('bold')
                .fontColor('#333333');

              Blank();

              Text(`${this.accessLogs.length} 条记录`)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor('#999999');
            }
            .width('100%')
            .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            ForEach(this.accessLogs, (log: AccessLogItem) => {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Text(log.time)
                    .fontSize(11)
                    .fontColor('#999999');

                  Blank();

                  Text(log.action === '读取' || log.action === '写入' ? log.action : log.action)
                    .fontSize(11)
                    .fontColor(log.action === '拒绝' ? '#FF4D4F' : log.action === '写入' ? '#FAAD14' : '#52C41A')
                    .backgroundColor(log.action === '拒绝' ? '#FFF1F0' : log.action === '写入' ? '#FFFBE6' : '#F6FFED')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(4);
                }
                .width('100%');

                Row({ space: 8 }) {
                  Text(`[${log.subject}]`)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#1677FF')
                    .fontWeight(FontWeight.Medium);

                  Text(log.content)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#666666')
                    .flexShrink(1);
                }
                .width('100%');
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
              .border({ width: 1, color: '#F0F0F0' });
            }, (log: AccessLogItem) => log.id);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });
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
}
