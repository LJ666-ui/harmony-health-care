import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface AuthDevice {
  id: string;
  name: string;
  icon: string;
  type: string;
  isAuthorized: boolean;
}

interface SystemPermission {
  id: string;
  name: string;
  icon: string;
  description: string;
  isEnabled: boolean;
}

interface AccessLog {
  id: string;
  visitor: string;
  time: string;
  content: string;
  permissionType: string;
}

@Entry
@Component
struct PrivacyPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State authDevices: AuthDevice[] = [
    { id: '1', name: '华为智能手环 Band 8', icon: '⌚', type: '健康设备', isAuthorized: true },
    { id: '2', name: '欧姆龙血压计', icon: '🩺', type: '医疗设备', isAuthorized: true },
    { id: '3', name: '第三方健康平台', icon: '🏥', type: '外部应用', isAuthorized: false }
  ];

  @State permissions: SystemPermission[] = [
    { id: '1', name: '相机权限', icon: '📷', description: '用于拍摄健康档案和处方照片', isEnabled: false },
    { id: '2', name: '存储权限', icon: '💾', description: '用于保存健康报告和检查单据', isEnabled: true },
    { id: '3', name: '位置权限', icon: '📍', description: '用于查找附近医院和药店', isEnabled: true }
  ];

  @State accessLogs: AccessLog[] = [
    { id: '1', visitor: '张医生', time: '2026-04-11 09:30', content: '查看血压历史记录', permissionType: '读取' },
    { id: '2', visitor: '李护士', time: '2026-04-10 14:20', content: '更新用药提醒设置', permissionType: '修改' },
    { id: '3', visitor: '系统管理员', time: '2026-04-09 16:45', content: '导出健康数据报告', permissionType: '读取' },
    { id: '4', visitor: '王医生', time: '2026-04-08 10:15', content: '查看血糖监测数据', permissionType: '读取' },
    { id: '5', visitor: '赵医生', time: '2026-04-07 11:00', content: '修改预约信息', permissionType: '修改' },
    { id: '6', visitor: '刘医生', time: '2026-04-06 09:00', content: '查看康复训练进度', permissionType: '读取' },
    { id: '7', visitor: '用户本人', time: '2026-04-05 20:30', content: '登录账户', permissionType: '登录' },
    { id: '8', visitor: '陈医生', time: '2026-04-04 15:40', content: '查看体检报告', permissionType: '读取' },
    { id: '9', visitor: '孙护士', time: '2026-04-03 13:25', content: '更新个人信息', permissionType: '修改' },
    { id: '10', visitor: '周医生', time: '2026-04-02 08:50', content: '查看设备连接状态', permissionType: '读取' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  toggleAuth(device: AuthDevice): void {
    device.isAuthorized = !device.isAuthorized;
  }

  togglePermission(perm: SystemPermission): void {
    perm.isEnabled = !perm.isEnabled;
  }

  goToPrivacyPolicy(): void {
    router.pushUrl({ url: 'pages/PrivacyPolicyPage' });
  }

  handleLogoutAccount(): void {
    console.log('申请注销账号');
  }

  handleDeleteData(): void {
    console.log('申请删除个人数据');
  }

  getPermissionColor(action: string): string {
    if (action === '读取') {
      return '#52C41A';
    } else if (action === '写入') {
      return '#FAAD14';
    } else if (action === '导出') {
      return '#1677FF';
    }
    return '#999999';
  }

  getPermissionBgColor(action: string): string {
    if (action === '读取') {
      return '#F6FFED';
    } else if (action === '写入') {
      return '#FFFBE6';
    } else if (action === '导出') {
      return '#E6F4FF';
    }
    return '#F5F5F5';
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
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) })
            .textAlign(TextAlign.Center)
            .width('100%');

          Column() {
            Text('🛡️ 个人信息保护')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('📄')
                .fontSize(20);
              Text('查看隐私政策')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#1677FF')
                .layoutWeight(1);
              Text('›')
                .fontSize(24)
                .fontColor('#1677FF');
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .border({ width: 1, color: '#E8E8E8' })
            .onClick(() => this.goToPrivacyPolicy());

            Button('注销账号')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#FF4D4F')
              .backgroundColor('#FFF1F0')
              .borderRadius(10)
              .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode) })
              .onClick(() => this.handleLogoutAccount());

            Button('删除个人数据')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#FF4D4F')
              .backgroundColor('#FFF1F0')
              .borderRadius(10)
              .onClick(() => this.handleDeleteData());
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#E8E8E8' });

          Column() {
            Row() {
              Text('🔗 数据授权管理')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight('bold')
                .fontColor('#333333');
              Blank();
              Text(`${this.authDevices.filter(d => d.isAuthorized).length}/${this.authDevices.length} 已授权`)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor('#999999');
            }
            .width('100%')
            .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            ForEach(this.authDevices, (device: AuthDevice) => {
              Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                Text(device.icon)
                  .fontSize(24);

                Column({ space: 4 }) {
                  Text(device.name)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                  Text(device.type)
                    .fontSize(11)
                    .fontColor('#999999');
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });

                Text(device.isAuthorized ? '已授权' : '已撤销')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(device.isAuthorized ? '#52C41A' : '#999999')
                  .backgroundColor(device.isAuthorized ? '#F6FFED' : '#F5F5F5')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(16);
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FAFAFA')
              .borderRadius(10)
              .onClick(() => this.toggleAuth(device));
            }, (device: AuthDevice) => device.id);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#E8E8E8' });

          Column() {
            Text('⚙️ 设备权限控制')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            ForEach(this.permissions, (perm: SystemPermission) => {
              Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                Text(perm.icon)
                  .fontSize(24);

                Column({ space: 4 }) {
                  Text(perm.name)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium);
                  Text(perm.description)
                    .fontSize(11)
                    .fontColor('#999999')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });

                Text(perm.isEnabled ? '开' : '关')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor(perm.isEnabled ? '#FFFFFF' : '#999999')
                  .backgroundColor(perm.isEnabled ? '#1677FF' : '#E0E0E0')
                  .width(this.isElderMode ? 56 : 44)
                  .height(this.isElderMode ? 32 : 26)
                  .borderRadius(13)
                  .textAlign(TextAlign.Center)
                  .onClick(() => this.togglePermission(perm));
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FAFAFA')
              .borderRadius(10);
            }, (perm: SystemPermission) => perm.id);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#E8E8E8' });

          Column() {
            Row() {
              Text('📋 数据访问日志')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight('bold')
                .fontColor('#333333');
              Blank();
              Text(`共 ${this.accessLogs.length} 条记录`)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor('#999999');
            }
            .width('100%')
            .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            ForEach(this.accessLogs, (log: AccessLog) => {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Text(`👤 ${log.visitor}`)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor('#1677FF')
                    .fontWeight(FontWeight.Medium);
                  Blank();
                  Text(log.permissionType)
                    .fontSize(11)
                    .fontColor(this.getPermissionColor(log.permissionType))
                    .backgroundColor(this.getPermissionBgColor(log.permissionType))
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(4);
                }
                .width('100%');

                Text(log.content)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor('#666666')
                  .width('100%');

                Row() {
                  Text(`🕐 ${log.time}`)
                    .fontSize(11)
                    .fontColor('#999999');
                }
                .width('100%');
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FAFAFA')
              .borderRadius(10)
              .border({ width: 1, color: '#F0F0F0' });
            }, (log: AccessLog) => log.id);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#E8E8E8' });
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .layoutWeight(1);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
