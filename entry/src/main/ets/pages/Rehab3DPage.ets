import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

interface CourseConfig {
  id: string;
  name: string;
  icon: string;
  iconLabel: string;
  steps: string[];
  color: string;
}

@Entry
@Component
struct Rehab3DPage {
  @State isPlaying: boolean = false;
  @State currentStep: number = 0;
  @State selectedCourseId: string = '1';
  @State scaleValue: number = 1.0;
  @State rotateAngle: number = 0;
  @State progressAnim: number = 0;

  private timer: number = -1;

  private courseConfigs: CourseConfig[] = [
    {
      id: '1',
      name: '颈椎病康复',
      icon: '🧘',
      iconLabel: '颈部拉伸',
      steps: ['头部中立', '左侧拉伸', '右侧拉伸', '前屈低头', '后仰抬头', '放松休息'],
      color: '#1677FF'
    },
    {
      id: '2',
      name: '高血压康复',
      icon: '🚶',
      iconLabel: '慢走/太极',
      steps: ['站立准备', '抬腿迈步', '手臂摆动', '深呼吸', '缓慢收势', '放松休息'],
      color: '#52C41A'
    },
    {
      id: '3',
      name: '肌力训练',
      icon: '🏋️',
      iconLabel: '哑铃训练',
      steps: ['站姿准备', '弯举动作', '推举动作', '侧平举', '放下还原', '放松休息'],
      color: '#FA8C16'
    },
    {
      id: '4',
      name: '平衡训练',
      icon: '🧍',
      iconLabel: '单腿站立',
      steps: ['双脚并拢', '单腿抬起', '保持平衡', '换腿重复', '双脚落地', '放松休息'],
      color: '#722ED1'
    }
  ];

  getCurrentCourse(): CourseConfig {
    return this.courseConfigs.find(c => c.id === this.selectedCourseId) ?? this.courseConfigs[0];
  }

  getCurrentSteps(): string[] {
    return this.getCurrentCourse().steps;
  }

  getProgressPercent(): number {
    return ((this.currentStep + 1) / this.getCurrentSteps().length) * 100;
  }

  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  startAnimation(): void {
    this.rotateAngle = 0;
    let animTimer = setInterval(() => {
      if (!this.isPlaying) {
        clearInterval(animTimer);
        return;
      }
      this.rotateAngle = (this.rotateAngle + 6) % 360;
      this.scaleValue = 1.0 + Math.sin(this.rotateAngle * Math.PI / 180) * 0.08;
    }, 50);
  }

  handlePlay(): void {
    this.isPlaying = !this.isPlaying;
    if (this.isPlaying) {
      this.startAnimation();
      this.startAutoPlay();
    } else {
      if (this.timer !== -1) {
        clearInterval(this.timer);
        this.timer = -1;
      }
    }
  }

  startAutoPlay(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
    this.timer = setInterval(() => {
      if (!this.isPlaying) {
        clearInterval(this.timer);
        this.timer = -1;
        return;
      }
      let steps = this.getCurrentSteps();
      if (this.currentStep < steps.length - 1) {
        animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
          this.currentStep++;
          this.progressAnim = this.getProgressPercent();
        });
      } else {
        this.isPlaying = false;
        if (this.timer !== -1) {
          clearInterval(this.timer);
          this.timer = -1;
        }
      }
    }, 2500);
  }

  handleReset(): void {
    this.isPlaying = false;
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.currentStep = 0;
      this.progressAnim = 0;
      this.scaleValue = 1.0;
      this.rotateAngle = 0;
    });
  }

  handleStepClick(index: number): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    this.isPlaying = false;
    animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
      this.currentStep = index;
      this.progressAnim = this.getProgressPercent();
    });
  }

  handleCourseSelect(courseId: string): void {
    this.selectedCourseId = courseId;
    this.handleReset();
  }

  build() {
    Column() {
      Header({ title: '3D康复训练', showBack: true });

      Scroll() {
        Column({ space: 16 }) {
          Text('3D 康复训练')
            .fontSize(22)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 16, bottom: 4 });

          Row({ space: 8 }) {
            ForEach(this.courseConfigs, (course: CourseConfig) => {
              Column() {
                Text(course.icon)
                  .fontSize(20);
                Text(course.name.length > 4 ? course.name.substring(0, 4) : course.name)
                  .fontSize(10)
                  .fontColor(this.selectedCourseId === course.id ? '#FFFFFF' : '#666666')
                  .margin({ top: 2 })
              }
              .padding({ top: 6, bottom: 6, left: 10, right: 10 })
              .backgroundColor(this.selectedCourseId === course.id ? this.getCurrentCourse().color : '#F5F5F5')
              .borderRadius(20)
              .border(this.selectedCourseId === course.id ? { width: 1.5, color: this.getCurrentCourse().color } : { width: 0 })
              .onClick(() => this.handleCourseSelect(course.id))
            }, (course: CourseConfig) => course.id)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start);

          Column() {
            Stack({ alignContent: Alignment.Bottom }) {
              Column() {
                Text(this.getCurrentCourse().icon)
                  .fontSize(90)
                  .scale({ x: this.scaleValue, y: this.scaleValue })
                  .rotate({ angle: this.isPlaying ? Math.sin(this.rotateAngle * Math.PI / 180) * 8 : 0 })
                  .animation({
                    duration: 150,
                    curve: Curve.EaseInOut,
                    iterations: -1,
                    playMode: PlayMode.Alternate
                  })
                  .margin({ bottom: 8 });

                Text(this.getCurrentCourse().iconLabel)
                  .fontSize(14)
                  .fontWeight('bold')
                  .fontColor(this.getCurrentCourse().color)
                  .backgroundColor(`${this.getCurrentCourse().color}15`)
                  .padding({ left: 16, right: 16, top: 4, bottom: 4 })
                  .borderRadius(12);

                Text(this.getCurrentSteps()[this.currentStep])
                  .fontSize(18)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ top: 12 });

                Text(`步骤 ${this.currentStep + 1} / ${this.getCurrentSteps().length}`)
                  .fontSize(13)
                  .fontColor('#999999')
                  .margin({ top: 4 });
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);

              Row() {
                Text(`进度 ${Math.round(this.getProgressPercent())}%`)
                  .fontSize(12)
                  .fontColor('#FFFFFF')
              }
              .width(`${this.getProgressPercent()}%`)
              .height(28)
              .linearGradient({
                angle: 90,
                colors: [[this.getCurrentCourse().color, 0], [`${this.getCurrentCourse().color}CC`, 1]]
              })
              .borderRadius({ topLeft: 14, bottomLeft: 14 })
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .animation({ duration: 400, curve: Curve.EaseOut });
            }
            .width('100%')
            .height(300)
          }
          .width('100%')
          .backgroundColor('#FAFBFF')
          .borderRadius(16)
          .border({ width: 2, color: `${this.getCurrentCourse().color}40` })
          .shadow({
            radius: 20,
            color: `${this.getCurrentCourse().color}18`,
            offsetX: 0,
            offsetY: 6
          })
          .clip(true);

          Row({ space: 16 }) {
            Button(this.isPlaying ? '⏸ 暂停' : '▶ 播放')
              .layoutWeight(1)
              .height(46)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .backgroundColor(this.isPlaying ? '#FAAD14' : this.getCurrentCourse().color)
              .borderRadius(23)
              .shadow(this.isPlaying ? undefined : {
                radius: 8,
                color: `${this.getCurrentCourse().color}50`,
                offsetX: 0,
                offsetY: 3
              })
              .onClick(() => this.handlePlay());

            Button('🔄 重置')
              .layoutWeight(1)
              .height(46)
              .fontSize(15)
              .fontColor('#666666')
              .backgroundColor('#F0F0F0')
              .borderRadius(23)
              .onClick(() => this.handleReset());
          }
          .width('100%');

          Text('训练步骤')
            .fontSize(17)
            .fontWeight('bold')
            .fontColor('#333333')
            .width('100%')
            .margin({ top: 4 });

          List({ space: 8 }) {
            ForEach(this.getCurrentSteps(), (step: string, index: number) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(`${index + 1}`)
                      .fontSize(13)
                      .fontWeight('bold')
                      .fontColor(this.currentStep === index ? '#FFFFFF' : this.getCurrentCourse().color);
                  }
                  .width(30)
                  .height(30)
                  .backgroundColor(this.currentStep === index ? this.getCurrentCourse().color : `${this.getCurrentCourse().color}15`)
                  .borderRadius(15)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center);

                  Column({ space: 2 }) {
                    Text(step)
                      .fontSize(15)
                      .fontColor(this.currentStep === index ? this.getCurrentCourse().color : '#333333')
                      .fontWeight(this.currentStep === index ? 'bold' : 'normal');

                    if (this.currentStep === index && this.isPlaying) {
                      Text('正在执行...')
                        .fontSize(11)
                        .fontColor(this.getCurrentCourse().color);
                    } else if (index < this.currentStep) {
                      Text('已完成')
                        .fontSize(11)
                        .fontColor('#52C41A');
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 });

                  Text(index < this.currentStep ? '✅' : (this.currentStep === index && this.isPlaying ? '🔵' : '○'))
                    .fontSize(18)
                    .fontColor(index < this.currentStep ? '#52C41A' : (this.currentStep === index && this.isPlaying ? this.getCurrentCourse().color : '#CCCCCC'));
                }
                .width('100%')
                .padding({ left: 14, right: 14, top: 12, bottom: 12 })
                .backgroundColor(this.currentStep === index ? `${this.getCurrentCourse().color}08` : '#FFFFFF')
                .borderRadius(10)
                .border({
                  width: this.currentStep === index ? 1.5 : 1,
                  color: this.currentStep === index ? `${this.getCurrentCourse().color}60` : '#F0F0F0'
                })
                .shadow(this.currentStep === index ? {
                  radius: 6,
                  color: `${this.getCurrentCourse().color}15`,
                  offsetX: 0,
                  offsetY: 2
                } : undefined)
                .onClick(() => this.handleStepClick(index));
              }
            }, (step: string, index: number) => `${this.selectedCourseId}-${step}-${index}`);
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ top: 4, bottom: 16 });
        }
        .flexGrow(1)
        .width('85%')
        .alignItems(HorizontalAlign.Center);
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
