import { AccessibilityConfig, FontSizeLevel, ColorMode, AnimationMode } from '../utils/AccessibilityConfig';

interface GuideStep {
  id: string;
  targetId: string;
  title: string;
  description: string;
  icon: string;
  position: 'top' | 'bottom' | 'left' | 'right' | 'center';
}

interface TargetPosition {
  x: number;
  y: number;
}

const DEFAULT_GUIDE_STEPS: GuideStep[] = [
  {
    id: 'step_1',
    targetId: 'home_tab',
    title: '首页',
    description: '这里可以查看您的健康概览、快速记录和常用功能入口',
    icon: '🏠',
    position: 'bottom'
  },
  {
    id: 'step_2',
    targetId: 'medical_tab',
    title: '就医服务',
    description: '预约挂号、查看医院科室、管理您的就诊记录',
    icon: '🏥',
    position: 'bottom'
  },
  {
    id: 'step_3',
    targetId: 'rehab_tab',
    title: '康复中心',
    description: '康复训练计划、3D动作指导和康复进度追踪',
    icon: '🧘',
    position: 'bottom'
  },
  {
    id: 'step_4',
    targetId: 'science_tab',
    title: '科普知识',
    description: '健康科普文章、中医养生知识和疾病预防指南',
    icon: '📚',
    position: 'bottom'
  },
  {
    id: 'step_5',
    targetId: 'profile_tab',
    title: '个人中心',
    description: '健康档案、设备绑定、隐私设置和适老化模式开关',
    icon: '👤',
    position: 'top'
  }
];

@Component
export struct FirstTimeGuide {
  @State isVisible: boolean = false;
  @State currentStepIndex: number = 0;
  @Prop guideSteps: GuideStep[] | null = null;

  private steps: GuideStep[] = [];

  aboutToAppear(): void {
    this.steps = this.guideSteps || DEFAULT_GUIDE_STEPS;

    if (!AccessibilityConfig.isFirstTimeGuideShown()) {
      setTimeout(() => {
        this.isVisible = true;
      }, 500);
    }
  }

  getCurrentStep(): GuideStep {
    return this.steps[this.currentStepIndex];
  }

  goToNext(): void {
    if (this.currentStepIndex < this.steps.length - 1) {
      this.currentStepIndex++;
    } else {
      this.completeGuide();
    }
  }

  goToPrev(): void {
    if (this.currentStepIndex > 0) {
      this.currentStepIndex--;
    }
  }

  skipGuide(): void {
    this.isVisible = false;
    AccessibilityConfig.markFirstTimeGuideShown();
  }

  completeGuide(): void {
    this.isVisible = false;
    AccessibilityConfig.markFirstTimeGuideShown();
  }

  build() {
    if (!this.isVisible) {
      Column()
        .height(0);
    } else {
      Stack({ alignContent: Alignment.Center }) {

        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#00000070')
          .onClick(() => {
            this.skipGuide();
          });

        Column({ space: 20 }) {

          Text(this.getCurrentStep().icon)
            .fontSize(56);

          Text(`${this.currentStepIndex + 1} / ${this.steps.length}`)
            .fontSize(13)
            .fontColor(AccessibilityConfig.getTextHint());

          Text(this.getCurrentStep().title)
            .fontSize(AccessibilityConfig.getFontSizeSubtitle())
            .fontWeight(FontWeight.Bold)
            .fontColor(AccessibilityConfig.getTextPrimary())
            .textAlign(TextAlign.Center);

          Text(this.getCurrentStep().description)
            .fontSize(AccessibilityConfig.getFontSizeBody())
            .fontColor(AccessibilityConfig.getTextSecondary())
            .textAlign(TextAlign.Center)
            .width('85%')
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Row({ space: 12 }) {

            if (this.currentStepIndex > 0) {
              Button('上一步')
                .height(AccessibilityConfig.getButtonHeight())
                .backgroundColor('#F5F5F5')
                .fontColor(AccessibilityConfig.getTextPrimary())
                .fontSize(AccessibilityConfig.getFontSizeButton())
                .borderRadius(AccessibilityConfig.getButtonHeight() / 2)
                .flexGrow(1)
                .onClick(() => {
                  this.goToPrev();
                });
            }

            Button(this.currentStepIndex === this.steps.length - 1 ? '开始使用' : '下一步')
              .height(AccessibilityConfig.getButtonHeight())
              .backgroundColor(AccessibilityConfig.getThemeColor())
              .fontColor('#FFFFFF')
              .fontSize(AccessibilityConfig.getFontSizeButton())
              .fontWeight(FontWeight.Medium)
              .borderRadius(AccessibilityConfig.getButtonHeight() / 2)
              .flexGrow(1)
              .onClick(() => {
                this.goToNext();
              });
          }
          .width('100%');

          if (this.steps.length > 1) {
            Row({ space: 6 }) {
              ForEach(this.steps, (_step: GuideStep, index: number) => {
                Column()
                  .width(index === this.currentStepIndex ? 24 : 8)
                  .height(8)
                  .borderRadius(4)
                  .backgroundColor(index === this.currentStepIndex ? AccessibilityConfig.getThemeColor() : '#E0E0E0');
              }, (_step: GuideStep, index: number) => `dot_${index}`);
            }
          }

          Button('跳过引导')
            .width(120)
            .height(36)
            .backgroundColor('transparent')
            .fontColor(AccessibilityConfig.getTextHint())
            .fontSize(13)
            .onClick(() => {
              this.skipGuide();
            });
        }
        .width('85%')
        .padding({
          top: AccessibilityConfig.getSpacingLG(),
          bottom: AccessibilityConfig.getSpacingLG(),
          left: AccessibilityConfig.getSpacingMD(),
          right: AccessibilityConfig.getSpacingMD()
        })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .alignItems(HorizontalAlign.Center);
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .accessibilityText(`新手引导第${this.currentStepIndex + 1}步：${this.getCurrentStep().title}`);
    }
  }
}

@Component
export struct FeatureHighlight {
  @Prop showHighlight: boolean = false;
  @Prop highlightText: string = '';
  @Prop targetPosition?: TargetPosition;

  build() {
    if (this.showHighlight && this.targetPosition) {
      Stack() {

        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#00000050');

        Column() {
          Text(this.highlightText)
            .fontSize(14)
            .fontColor('#333333');
        }
        .width(200)
        .padding(12)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 })
        .position({
          x: Math.max(10, this.targetPosition!.x - 100),
          y: Math.max(60, this.targetPosition!.y - 80)
        });

        Column()
          .width(80)
          .height(80)
          .borderRadius(40)
          .border({ width: 3, color: AccessibilityConfig.getThemeColor(), style: BorderStyle.Dashed })
          .position({
            x: Math.max(0, this.targetPosition!.x - 40),
            y: Math.max(0, this.targetPosition!.y - 40)
          });
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .onClick(() => {

      });
    } else {
      Column()
        .height(0);
    }
  }
}

@Component
export struct AccessibilitySettingsPanel {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State fontSizeLevel: FontSizeLevel = FontSizeLevel.MEDIUM;
  @State colorMode: ColorMode = ColorMode.NORMAL;
  @State animationMode: AnimationMode = AnimationMode.NORMAL;
  @State ttsEnabled: boolean = false;
  onDismiss?: () => void;

  aboutToAppear(): void {
    this.fontSizeLevel = AccessibilityConfig.getFontSizeLevel();
    this.colorMode = AccessibilityConfig.getColorMode();
    this.animationMode = AccessibilityConfig.getAnimationMode();
    this.ttsEnabled = AccessibilityConfig.isTTSEnabled();
  }

  getFontSizeForLevel(level: FontSizeLevel): number {
    if (level === FontSizeLevel.EXTRA_LARGE) {
      return 18;
    } else if (level === FontSizeLevel.LARGE) {
      return 16;
    } else if (level === FontSizeLevel.SMALL) {
      return 12;
    }
    return 14;
  }

  applyFontSizeLevel(level: FontSizeLevel): void {
    this.fontSizeLevel = level;
    AccessibilityConfig.setFontSizeLevel(level);
  }

  applyColorMode(mode: ColorMode): void {
    this.colorMode = mode;
    AccessibilityConfig.setColorMode(mode);
  }

  applyAnimationMode(mode: AnimationMode): void {
    this.animationMode = mode;
    AccessibilityConfig.setAnimationMode(mode);
  }

  toggleTTS(): void {
    this.ttsEnabled = !this.ttsEnabled;
    AccessibilityConfig.setTTSEnabled(this.ttsEnabled);
  }

  resetAll(): void {
    AccessibilityConfig.resetToDefault();
    this.fontSizeLevel = FontSizeLevel.MEDIUM;
    this.colorMode = ColorMode.NORMAL;
    this.animationMode = AnimationMode.NORMAL;
    this.ttsEnabled = false;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000040')
        .onClick(() => {
          if (this.onDismiss) {
            this.onDismiss();
          }
        });

      Column({ space: 20 }) {

        Row() {
          Text('无障碍设置')
            .fontSize(AccessibilityConfig.getFontSizeSubtitle())
            .fontWeight(FontWeight.Bold)
            .fontColor(AccessibilityConfig.getTextPrimary())
            .layoutWeight(1);

          Text('✕')
            .fontSize(22)
            .fontColor(AccessibilityConfig.getTextSecondary())
            .onClick(() => {
              if (this.onDismiss) {
                this.onDismiss();
              }
            });
        }
        .width('100%');

        Column({ space: 12 }) {
          Text('字体大小')
            .fontSize(AccessibilityConfig.getFontSizeBody())
            .fontWeight(FontWeight.Medium)
            .fontColor(AccessibilityConfig.getTextPrimary())
            .width('100%');

          Row({ space: 12 }) {
            this.buildFontSizeOption('小', FontSizeLevel.SMALL);
            this.buildFontSizeOption('中', FontSizeLevel.MEDIUM);
            this.buildFontSizeOption('大', FontSizeLevel.LARGE);
            this.buildFontSizeOption('特大', FontSizeLevel.EXTRA_LARGE);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FAFAFA')
        .borderRadius(12);

        Column({ space: 12 }) {
          Text('颜色模式')
            .fontSize(AccessibilityConfig.getFontSizeBody())
            .fontWeight(FontWeight.Medium)
            .fontColor(AccessibilityConfig.getTextPrimary())
            .width('100%');

          Row({ space: 12 }) {
            this.buildColorModeOption('标准', ColorMode.NORMAL);
            this.buildColorModeOption('高对比度', ColorMode.HIGH_CONTRAST);
            this.buildColorModeOption('色盲友好', ColorMode.COLOR_BLIND_FRIENDLY);
          }
          .width('100%');
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FAFAFA')
        .borderRadius(12);

        Column({ space: 12 }) {
          Text('动画效果')
            .fontSize(AccessibilityConfig.getFontSizeBody())
            .fontWeight(FontWeight.Medium)
            .fontColor(AccessibilityConfig.getTextPrimary())
            .width('100%');

          Row({ space: 12 }) {
            this.buildAnimModeOption('正常', AnimationMode.NORMAL);
            this.buildAnimModeOption('减弱', AnimationMode.REDUCED);
            this.buildAnimModeOption('关闭', AnimationMode.NONE);
          }
          .width('100%');
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FAFAFA')
        .borderRadius(12);

        Row({ space: 16 }) {
          Column({ space: 4 }) {
            Text('语音播报')
              .fontSize(AccessibilityConfig.getFontSizeBody())
              .fontColor(AccessibilityConfig.getTextPrimary());
            Text('开启后重要信息会朗读出来')
              .fontSize(AccessibilityConfig.getFontSizeTiny())
              .fontColor(AccessibilityConfig.getTextHint());
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Toggle({ type: ToggleType.Switch, isOn: this.ttsEnabled })
            .onChange((isOn: boolean) => {
              this.toggleTTS();
            });
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FAFAFA')
        .borderRadius(12);

        Button('恢复默认设置')
          .width('100%')
          .height(AccessibilityConfig.getButtonHeight())
          .backgroundColor('#F5F5F5')
          .fontColor(AccessibilityConfig.getTextSecondary())
          .fontSize(AccessibilityConfig.getFontSizeButton())
          .borderRadius(AccessibilityConfig.getButtonHeight() / 2)
          .onClick(() => {
            this.resetAll();
          });
      }
      .width('90%')
      .constraintSize({ maxHeight: '85%' })
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 20 });
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }

  @Builder
  buildFontSizeOption(label: string, level: FontSizeLevel) {
    Text(label)
      .fontSize(this.getFontSizeForLevel(level))
      .fontColor(this.fontSizeLevel === level ? '#FFFFFF' : AccessibilityConfig.getTextSecondary())
      .backgroundColor(this.fontSizeLevel === level ? AccessibilityConfig.getThemeColor() : '#F5F5F5')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .borderRadius(16)
      .onClick(() => {
        this.applyFontSizeLevel(level);
      });
  }

  @Builder
  buildColorModeOption(label: string, mode: ColorMode) {
    Text(label)
      .fontSize(AccessibilityConfig.getFontSizeSmall())
      .fontColor(this.colorMode === mode ? '#FFFFFF' : AccessibilityConfig.getTextSecondary())
      .backgroundColor(this.colorMode === mode ? AccessibilityConfig.getThemeColor() : '#F5F5F5')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .borderRadius(16)
      .onClick(() => {
        this.applyColorMode(mode);
      });
  }

  @Builder
  buildAnimModeOption(label: string, mode: AnimationMode) {
    Text(label)
      .fontSize(AccessibilityConfig.getFontSizeSmall())
      .fontColor(this.animationMode === mode ? '#FFFFFF' : AccessibilityConfig.getTextSecondary())
      .backgroundColor(this.animationMode === mode ? AccessibilityConfig.getThemeColor() : '#F5F5F5')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .borderRadius(16)
      .onClick(() => {
        this.applyAnimationMode(mode);
      });
  }
}
