import { router } from '@kit.ArkUI';

export interface Image3DViewerProps {
  imageUrl: string;
  model3dUrl: string;
  title: string;
  onClose: () => void;
}

@Component
export struct Image3DViewer {
  @Prop imageUrl: string = '';
  @Prop model3dUrl: string = '';
  @Prop title: string = '';
  @Prop onClose: () => void = () => {};

  @State rotationX: number = 0;
  @State rotationY: number = 0;
  @State scale: number = 1.0;
  @State isAutoRotating: boolean = true;
  @State showInfo: boolean = true;

  private autoRotateTimer: number = -1;

  aboutToAppear(): void {
    this.startAutoRotate();
  }

  aboutToDisappear(): void {
    this.stopAutoRotate();
  }

  startAutoRotate(): void {
    if (this.autoRotateTimer === -1) {
      this.autoRotateTimer = setInterval(() => {
        if (this.isAutoRotating) {
          this.rotationY = (this.rotationY + 1.5) % 360;
        }
      }, 50);
    }
  }

  stopAutoRotate(): void {
    if (this.autoRotateTimer !== -1) {
      clearInterval(this.autoRotateTimer);
      this.autoRotateTimer = -1;
    }
  }

  handleTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.isAutoRotating = false;
    } else if (event.type === TouchType.Move) {
      const touch = event.touches[0];
      this.rotationY += touch.dx * 0.5;
      this.rotationX += touch.dy * 0.5;

      if (this.rotationX > 45) this.rotationX = 45;
      if (this.rotationX < -45) this.rotationX = -45;
    } else if (event.type === TouchType.Up) {
      setTimeout(() => {
        this.isAutoRotating = true;
      }, 2000);
    }
  }

  resetView(): void {
    this.rotationX = 0;
    this.rotationY = 0;
    this.scale = 1.0;
    this.isAutoRotating = true;
  }

  zoomIn(): void {
    if (this.scale < 2.0) {
      this.scale += 0.2;
    }
  }

  zoomOut(): void {
    if (this.scale > 0.5) {
      this.scale -= 0.2;
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('🎮 3D场景查看')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1);

          Button(this.showInfo ? '隐藏信息' : '显示信息')
            .height(28)
            .fontSize(12)
            .fontColor('#1677FF')
            .backgroundColor('#E6F7FF')
            .borderRadius(14)
            .onClick(() => {
              this.showInfo = !this.showInfo;
            });

          Text('✕')
            .fontSize(24)
            .fontColor('#999999')
            .margin({ left: 12 })
            .onClick(() => {
              this.onClose();
            });
        }
        .width('100%')
        .padding(16);

        Scroll() {
          Column({ space: 20 }) {

            Column()
              .width('100%')
              .height(350)
              .borderRadius(16)
              .linearGradient({
                angle: 135,
                colors: [['#667eea', 0], ['#764ba2', 1]]
              })
              .shadow({ radius: 20, color: '#00000030', offsetX: 0, offsetY: 8 })
              .clip(true)
              .onTouch((event: TouchEvent) => this.handleTouch(event));

            Stack() {
              Column()
                .width(280)
                .height(320)
                .borderRadius(20)
                .backgroundColor('#FFFFFF')
                .shadow({ radius: 15, color: '#00000025', offsetX: 0, offsetY: 6 })
                .scale({ x: this.scale, y: this.scale })
                .rotate({ x: this.rotationX, y: this.rotationY });

              if (this.showInfo) {
                Column({ space: 8 }) {
                  Text('🔄 自动旋转中')
                    .fontSize(11)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#52C41A90')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .borderRadius(10);

                  Text(`旋转 X: ${this.rotationX.toFixed(1)}° Y: ${this.rotationY.toFixed(1)}°`)
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#00000060')
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .borderRadius(8);
                }
                .alignItems(HorizontalAlign.End)
                .position({ x: 10, y: 10 });
              }
            }
            .width('100%')
            .height(340)
            .justifyContent(FlexAlign.Center);

            if (this.showInfo) {
              Column({ space: 12 }) {
                Text('📖 场景信息')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%');

                Column({ space: 8 }) {
                  this.buildInfoRow('📷 原图', this.title);
                  this.buildInfoRow('🎨 分辨率', 'AI超分辨率增强至 4K');
                  this.buildInfoRow('🎮 模型格式', 'GLB/GLTF 3D模型');
                  this.buildInfoRow('✨ 渲染引擎', 'HiAI 3D渲染引擎');
                  this.buildInfoRow('💡 操作提示', '拖拽旋转 | 双指缩放');
                }
                .width('100%')
                .padding(14)
                .backgroundColor('#F7F8FA')
                .borderRadius(12);
              }
              .width('100%')
              .padding({ left: 16, right: 16 });
            }

            Row({ space: 12 }) {
              Button('➖ 缩小')
                .layoutWeight(1)
                .height(40)
                .fontSize(13)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(20)
                .onClick(() => this.zoomOut());

              Button('🔄 重置视图')
                .layoutWeight(2)
                .height(40)
                .fontSize(13)
                .fontColor('#FFFFFF')
                .backgroundColor('#722ED1')
                .borderRadius(20)
                .onClick(() => this.resetView());

              Button('➕ 放大')
                .layoutWeight(1)
                .height(40)
                .fontSize(13)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(20)
                .onClick(() => this.zoomIn());
            }
            .width('100%')
            .padding({ left: 16, right: 16 });

            Row({ space: 12 }) {
              Button('⏸️ 暂停旋转')
                .layoutWeight(1)
                .height(38)
                .fontSize(13)
                .fontColor(this.isAutoRotating ? '#666666' : '#1677FF')
                .backgroundColor(this.isAutoRotating ? '#F5F5F5' : '#E6F7FF')
                .borderRadius(19)
                .onClick(() => {
                  this.isAutoRotating = !this.isAutoRotating;
                });

              Button('💾 保存模型')
                .layoutWeight(1)
                .height(38)
                .fontSize(13)
                .fontColor('#FFFFFF')
                .backgroundColor('#52C41A')
                .borderRadius(19)
                .onClick(() => {
                  console.info('保存3D模型');
                });

              Button('📤 分享场景')
                .layoutWeight(1)
                .height(38)
                .fontSize(13)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(19)
                .onClick(() => {
                  console.info('分享3D场景');
                });
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 24 });
          }
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .layoutWeight(1);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FAFBFC');
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#666666')
        .width(100);

      Text(value)
        .fontSize(13)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.End);
    }
    .width('100%');
  }
}
