import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface VoiceCommand {
  id: string;
  icon: string;
  title: string;
  description: string;
  targetPage: string;
}

@Entry
@Component
struct VoiceAssistantPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State isRecording: boolean = false;
  @State recordStatus: string = '点击开始语音交互';
  @State scaleValue: number = 1.0;
  @State rippleOpacity: number = 0;

  @State voiceCommands: VoiceCommand[] = [
    { id: '1', icon: '📋', title: '挂号/预约', description: '快速预约医生门诊', targetPage: 'pages/Appointments' },
    { id: '2', icon: '🗺️', title: '打开院内AR导航', description: '智能导航到科室位置', targetPage: 'pages/ARNavigationPage' },
    { id: '3', icon: '📊', title: '查询健康记录', description: '查看历史健康数据', targetPage: 'pages/HealthRecords' },
    { id: '4', icon: '💊', title: '设置用药提醒', description: '管理药物服用时间', targetPage: 'pages/Medications' },
    { id: '5', icon: '⚠️', title: '查看健康风险评估', description: '获取个性化风险报告', targetPage: 'pages/RiskAssessmentPage' },
    { id: '6', icon: '🏥', title: '查找附近医院', description: '搜索周边医疗机构', targetPage: 'pages/HospitalPage' },
    { id: '7', icon: '🧘', title: '开始康复训练', description: '进入康复课程列表', targetPage: 'pages/RehabListPage' },
    { id: '8', icon: '📖', title: '阅读健康科普文章', description: '浏览医学知识库', targetPage: 'pages/ScienceListPage' },
    { id: '9', icon: '⌚', title: '连接智能设备', description: '配对健康监测设备', targetPage: 'pages/DeviceDiscoveryPage' },
    { id: '10', icon: '🔒', title: '查看隐私设置', description: '管理数据访问权限', targetPage: 'pages/PrivacyPage' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  startRecording(): void {
    if (this.isRecording) return;

    this.isRecording = true;
    this.recordStatus = '正在聆听...';
    this.scaleValue = 1.1;
    this.rippleOpacity = 0.6;

    setTimeout(() => {
      this.recordStatus = '识别中...';
      this.scaleValue = 0.95;
    }, 1500);

    setTimeout(() => {
      this.recordStatus = '指令执行中';
      this.scaleValue = 1.05;
    }, 3000);

    setTimeout(() => {
      this.resetRecording();
    }, 4500);
  }

  resetRecording(): void {
    this.isRecording = false;
    this.recordStatus = '点击开始语音交互';
    this.scaleValue = 1.0;
    this.rippleOpacity = 0;
  }

  executeCommand(command: VoiceCommand): void {
    promptAction.showToast({
      message: `已为您执行：${command.title}`,
      duration: 2000
    });

    setTimeout(() => {
      router.pushUrl({ url: command.targetPage });
    }, 500);
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#1677FF')
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          });

        Text('小艺语音助手')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Blank().width(40);
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center);

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('语音助手')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Stack({ alignContent: Alignment.Center }) {
              if (this.rippleOpacity > 0) {
                Circle()
                  .width(this.isElderMode ? 160 : 140)
                  .height(this.isElderMode ? 160 : 140)
                  .fill('#1677FF15')
                  .opacity(this.rippleOpacity)
                  .animation({
                    duration: 1000,
                    curve: Curve.EaseInOut,
                    iterations: -1,
                    playMode: PlayMode.Alternate
                  });
              }

              Circle()
                .width(this.isElderMode ? 120 : 100)
                .height(this.isElderMode ? 120 : 100)
                .fill('#1677FF')
                .scale({ x: this.scaleValue, y: this.scaleValue })
                .animation({
                  duration: 300,
                  curve: Curve.EaseInOut
                })
                .onClick(() => {
                  this.startRecording();
                });

              Column({ space: 4 }) {
                Text('🎤')
                  .fontSize(this.isElderMode ? 36 : 28);

                Text(this.isRecording ? '●' : '')
                  .fontSize(12)
                  .fontColor('#FFFFFF');
              }
            }
            .width(this.isElderMode ? 180 : 160)
            .height(this.isElderMode ? 180 : 160)
            .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Text(this.recordStatus)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(this.isRecording ? '#1677FF' : '#666666')
              .fontWeight(this.isRecording ? FontWeight.Bold : FontWeight.Normal)
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });
          }
          .width('85%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 12, color: '#00000008', offsetX: 0, offsetY: 4 });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('支持的语音指令')
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: this.isElderMode ? 12 : 8 });

            ForEach(this.voiceCommands, (command: VoiceCommand) => {
              Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                Text(command.icon)
                  .fontSize(this.isElderMode ? 32 : 24);

                Column({ space: 4 }) {
                  Text(command.title)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight('bold')
                    .fontColor('#333333');

                  Text(command.description)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor('#999999');
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);

                Text('›')
                  .fontSize(24)
                  .fontColor('#CCCCCC');
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FAFBFC')
              .borderRadius(12)
              .border({ width: 1, color: '#F0F0F0' })
              .onClick(() => {
                this.executeCommand(command);
              });
            }, (command: VoiceCommand) => command.id);
          }
          .width('85%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 12, color: '#00000008', offsetX: 0, offsetY: 4 });
        }
        .width('100%')
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
