import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface CourseParams {
  courseId?: string;
  courseTitle?: string;
  courseIcon?: string;
  courseDescription?: string;
  courseDuration?: string;
  courseDifficulty?: string;
  courseTargetGroup?: string;
  videoUrl?: string;
}

@Entry
@Component
struct RehabCourseVideoPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  
  @State courseId: string = '';
  @State courseTitle: string = '';
  @State courseIcon: string = '';
  @State courseDescription: string = '';
  @State courseDuration: string = '';
  @State courseDifficulty: string = '';
  @State courseTargetGroup: string = '';
  @State videoUrl: string = '';
  
  @State isPlaying: boolean = false;
  @State currentTime: number = 0;
  @State duration: number = 0;
  @State showControls: boolean = true;
  @State isLoading: boolean = true;
  
  private videoController: VideoController = new VideoController();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    
    const params = router.getParams() as CourseParams;
    if (params) {
      this.courseId = params.courseId || '';
      this.courseTitle = params.courseTitle || '康复课程';
      this.courseIcon = params.courseIcon || '🏥';
      this.courseDescription = params.courseDescription || '';
      this.courseDuration = params.courseDuration || '';
      this.courseDifficulty = params.courseDifficulty || '';
      this.courseTargetGroup = params.courseTargetGroup || '';
      this.videoUrl = (params.videoUrl || '').replace('localhost:8080', '10.0.2.2:8080');
    }
    
    if (!this.videoUrl) {
      ToastUtil.showError('该课程暂无视频');
    }
  }

  formatTime(seconds: number): string {
    if (isNaN(seconds)) return '00:00';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  handlePlayPause(): void {
    if (this.isPlaying) {
      this.videoController.pause();
      this.isPlaying = false;
    } else {
      this.videoController.start();
      this.isPlaying = true;
    }
  }

  handleVideoStart(): void {
    this.isLoading = false;
    this.isPlaying = true;
  }

  handleVideoPause(): void {
    this.isPlaying = false;
  }

  handleVideoFinish(): void {
    this.isPlaying = false;
    ToastUtil.showSuccess('视频播放完成！');
  }

  handleVideoError(): void {
    this.isLoading = false;
    ToastUtil.showError('视频加载失败，请检查网络连接');
  }

  handleTimeUpdate(currentTime: number, duration: number): void {
    this.currentTime = currentTime;
    this.duration = duration;
  }

  toggleControls(): void {
    this.showControls = !this.showControls;
  }

  startTraining(): void {
    router.pushUrl({
      url: 'pages/Rehab3DPage',
      params: { courseId: this.courseId }
    }).catch((error: Error) => {
      console.error('跳转3D训练页失败:', error.message);
      ToastUtil.showError('功能开发中');
    });
  }

  build() {
    Column() {
      Header({ title: this.courseTitle, showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Video({
            src: this.videoUrl,
            controller: this.videoController
          })
            .key(this.videoUrl || 'default')
            .width('100%')
            .height(220)
            .borderRadius(GlobalTheme.RADIUS_LG)
            .objectFit(ImageFit.Contain)
            .autoPlay(false)
            .loop(false)
            .muted(false)
            .controls(this.showControls)
            .onStart(() => this.handleVideoStart())
            .onPause(() => this.handleVideoPause())
            .onFinish(() => this.handleVideoFinish())
            .onError(() => this.handleVideoError())
            .onUpdate((data: object) => {
              const info = data as Record<string, number>;
              this.handleTimeUpdate(info['time'] || 0, info['duration'] || 0);
            })
            .onClick(() => this.toggleControls());

          if (this.isLoading && this.videoUrl) {
            Column() {
              LoadingProgress()
                .width(48)
                .height(48)
                .color('#1677FF')
                .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });
              Text('正在加载视频...')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
            }
            .width('100%')
            .height(220)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#F5F5F5')
            .borderRadius(GlobalTheme.RADIUS_LG);
          }

          Row({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
            Text(this.courseIcon + ' ' + this.courseTitle)
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .layoutWeight(1);

            if (this.courseDifficulty) {
              Text(this.courseDifficulty)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#FFFFFF')
                .backgroundColor(this.getDifficultyColor())
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .borderRadius(12);
            }
          }
          .width('100%');

          if (this.courseDescription) {
            Text(this.courseDescription)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .lineHeight(22)
              .width('100%')
              .textAlign(TextAlign.Start);
          }

          Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Column({ space: GlobalTheme.getSpacingXS(this.isElderMode) }) {
              Text('⏱ 时长')
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT);
              Text(this.courseDuration)
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight('bold')
                .fontColor(GlobalTheme.TEXT_PRIMARY);
            }
            .layoutWeight(1)
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FAFBFF')
            .borderRadius(GlobalTheme.RADIUS_MD);

            Column({ space: GlobalTheme.getSpacingXS(this.isElderMode) }) {
              Text('👥 适用人群')
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT);
              Text(this.courseTargetGroup.length > 8 ? 
                this.courseTargetGroup.substring(0, 8) + '...' : 
                this.courseTargetGroup)
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight('bold')
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .maxLines(1);
            }
            .layoutWeight(1)
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FAFBFF')
            .borderRadius(GlobalTheme.RADIUS_MD);
          }
          .width('100%');

          Button('🎯 开始3D训练')
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(GlobalTheme.RADIUS_LG)
            .shadow({
              radius: 10,
              color: '#1677FF40',
              offsetX: 0,
              offsetY: 4
            })
            .onClick(() => this.startTraining());
        }
        .padding(GlobalTheme.getSpacingLG(this.isElderMode))
        .width('85%');
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }

  getDifficultyColor(): string {
    switch (this.courseDifficulty) {
      case '初级':
        return '#52C41A';
      case '中级':
        return '#FAAD14';
      case '高级':
        return '#FF4D4F';
      default:
        return '#999999';
    }
  }
}
