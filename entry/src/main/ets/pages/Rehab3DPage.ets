import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import web_webview from '@ohos.web.webview';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';

interface RouterParams {
  courseId?: string | number;
}

interface RehabActionData {
  id: number;
  planId: number;
  actionName: string;
  actionDesc: string;
  duration: number;
  sets: number;
  reps: number;
  videoUrl: string;
  model3dUrl: string;
}

interface ActionDetailResponse {
  action: RehabActionData;
  difficulty: string;
}

interface CourseConfig {
  id: string;
  name: string;
  icon: string;
  iconLabel: string;
  steps: string[];
  color: string;
}

interface MovementMetadata {
  context: string;
  exercise: string;
  course: string;
  deviceType: string;
}

@Entry
@Component
struct Rehab3DPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State isPlaying: boolean = false;
  @State currentStep: number = 0;
  @State selectedCourseId: string = '1';
  @State scaleValue: number = 1.0;
  @State rotateAngle: number = 0;
  @State progressAnim: number = 0;
  @State modelUrl: string = '';
  @State isLoadingModel: boolean = true;
  @State modelDifficulty: string = '';
  @State actionName: string = '';
  @State actionDesc: string = '';
  @State loadError: string = '';
  @State aiCorrection: string = '';
  @State exerciseScore: number = 0;
  @State aiRealTimeFeedback: string = '';

  private timer: number = -1;
  private webController: web_webview.WebviewController = new web_webview.WebviewController();
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

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
      name: '膝关节康复',
      icon: '🦵',
      iconLabel: '膝关节训练',
      steps: ['站立准备', '屈膝下蹲', '直腿抬高', '侧向抬腿', '伸展放松', '放松休息'],
      color: '#52C41A'
    },
    {
      id: '3',
      name: '腰椎康复',
      icon: '🔙',
      iconLabel: '腰椎训练',
      steps: ['仰卧准备', '骨盆倾斜', '膝胸拉伸', '桥式运动', '猫牛式', '放松休息'],
      color: '#FA8C16'
    },
    {
      id: '4',
      name: '肩周炎康复',
      icon: '💪',
      iconLabel: '肩部训练',
      steps: ['站立准备', '前屈上举', '侧平举', '内旋拉伸', '外旋拉伸', '放松休息'],
      color: '#722ED1'
    },
    {
      id: '5',
      name: '平衡训练',
      icon: '⚖️',
      iconLabel: '平衡训练',
      steps: ['双脚并拢', '单腿抬起', '保持平衡', '换腿重复', '双脚落地', '放松休息'],
      color: '#13C2C2'
    },
    {
      id: '6',
      name: '帕金森康复',
      icon: '🎯',
      iconLabel: '协调训练',
      steps: ['坐姿准备', '手指对捏', '手臂摆动', '踏步训练', '转身练习', '放松休息'],
      color: '#EB2F96'
    },
    {
      id: '7',
      name: '呼吸康复',
      icon: '🫁',
      iconLabel: '呼吸训练',
      steps: ['坐姿准备', '腹式呼吸', '缩唇呼吸', '深呼吸', '咳嗽训练', '放松休息'],
      color: '#1890FF'
    },
    {
      id: '8',
      name: '中风康复',
      icon: '🤸',
      iconLabel: '肢体训练',
      steps: ['卧位准备', '被动运动', '主动辅助', '主动运动', '抗阻运动', '放松休息'],
      color: '#FA541C'
    }
  ];

  getCurrentCourse(): CourseConfig {
    for (let i = 0; i < this.courseConfigs.length; i++) {
      if (this.courseConfigs[i].id === this.selectedCourseId) {
        return this.courseConfigs[i];
      }
    }
    return this.courseConfigs[0];
  }

  getCurrentSteps(): string[] {
    return this.getCurrentCourse().steps;
  }

  getProgressPercent(): number {
    return ((this.currentStep + 1) / this.getCurrentSteps().length) * 100;
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      const elderMode = AppStorage.get<boolean>('isOldModeEnabled');
      this.isElderMode = elderMode ? elderMode : false;
    }

    const params = router.getParams() as RouterParams;
    if (params && params.courseId !== undefined) {
      this.selectedCourseId = String(params.courseId);
    }

    this.fetchActionDetail();
  }

  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  async analyzeMovementWithAI(sensorData: number[]): Promise<void> {
    try {
      const meta: MovementMetadata = {
        context: 'movement_analysis',
        exercise: this.actionName,
        course: this.getCurrentCourse().name,
        deviceType: 'phone'
      };
      const request = AIRequestBuilder.createWithMetadata(
        JSON.stringify(sensorData),
        meta
      );
      const response = await this.orchestrator.process(request);
      const content = response.output.content;
      this.aiCorrection = typeof content === 'string' ? content : JSON.stringify(content);
      this.exerciseScore = Math.round(response.output.confidence * 100);
      this.aiRealTimeFeedback = `动作评分：${this.exerciseScore}分`;
    } catch (error) {
      console.error('[Rehab3DPage] AI动作分析失败:', error);
      this.aiCorrection = 'AI分析暂时不可用';
      this.aiRealTimeFeedback = '无法获取实时反馈';
    }
  }

  async getAICorrectionGuidance(): Promise<void> {
    try {
      const currentStepName = this.getCurrentSteps()[this.currentStep] || '';
      const request = AIRequestBuilder.createWithIntent(
        `当前动作：${currentStepName}，课程：${this.getCurrentCourse().name}，请给出标准的动作要领和常见错误纠正`,
        'rehabilitation_guidance'
      );
      const response = await this.orchestrator.process(request);
      const content = response.output.content;
      this.aiCorrection = typeof content === 'string' ? content : JSON.stringify(content);
    } catch (error) {
      console.error('[Rehab3DPage] AI纠正指导失败:', error);
      this.aiCorrection = 'AI纠正指导暂时不可用';
    }
  }

  fetchActionDetail(): void {
    this.isLoadingModel = true;
    this.loadError = '';
    this.modelUrl = '';

    HttpUtil.get<ActionDetailResponse>(ApiConstants.REHAB_ACTION_DETAIL + this.selectedCourseId)
      .then((response: BaseResponse<ActionDetailResponse>) => {
        if (response.success && response.data) {
          const detail: ActionDetailResponse = response.data;
          if (detail.action) {
            this.actionName = detail.action.actionName || '';
            this.actionDesc = detail.action.actionDesc || '';
            this.modelDifficulty = detail.difficulty || '';
            let rawUrl: string = detail.action.model3dUrl || '';
            rawUrl = rawUrl.replace('`', '').replace(',', '').trim();
            if (rawUrl) {
              this.modelUrl = rawUrl.startsWith('http') ? rawUrl : ('http://10.0.2.2:8080' + rawUrl);
            }
          }
        } else {
          this.loadError = response.message || '加载失败';
        }
        this.isLoadingModel = false;
      })
      .catch((error: Error) => {
        console.error('加载3D模型失败:', error.message);
        this.loadError = error.message || '网络请求失败';
        this.isLoadingModel = false;
      });
  }

  get3DViewerUrl(): string {
    const fullUrl: string = this.modelUrl;
    const htmlContent: string = `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"><\/script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/examples/js/controls/OrbitControls.js"><\/script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/examples/js/loaders/GLTFLoader.js"><\/script>
<style>body{margin:0;overflow:hidden;background:#f5f5f5;}canvas{display:block;width:100%;height:100%;}#loading{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:16px;color:#999;}#error{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:14px;color:#FF4F4F;text-align:center;}</style>
</head>
<body>
<div id="container" style="width:100%;height:100vh;"></div>
<div id="loading">加载3D模型中...</div>
<div id="error" style="display:none;"></div>
<script>
var scene,camera,renderer,controls,model;
scene=new THREE.Scene();
scene.background=new THREE.Color(0xf5f5f5);
camera=new THREE.PerspectiveCamera(45,1,0.1,1000);
camera.position.set(0,1,3);
renderer=new THREE.WebGLRenderer({antialias:true});
renderer.setPixelRatio(window.devicePixelRatio);
document.getElementById('container').appendChild(renderer.domElement);
controls=new THREE.OrbitControls(camera,renderer.domElement);
controls.enableDamping=true;
controls.dampingFactor=0.05;
var light=new THREE.DirectionalLight(0xffffff,1);
light.position.set(5,10,7);
scene.add(light);
scene.add(new THREE.AmbientLight(0xffffff,0.6));
var loader=new THREE.GLTFLoader();
loader.load('${fullUrl}',function(gltf){
model=gltf.scene;
var box=new THREE.Box3().setFromObject(model);
var center=box.getCenter(new THREE.Vector3());
var size=box.getSize(new THREE.Vector3());
var maxDim=Math.max(size.x,size.y,size.z);
camera.position.set(center.x,center.y+maxDim*1.5,center.z+maxDim*2.5);
camera.lookAt(center);
controls.target.copy(center);
scene.add(model);
document.getElementById('loading').style.display='none';
animate();
},function(progress){
},function(err){
document.getElementById('loading').style.display='none';
document.getElementById('error').style.display='block';
document.getElementById('error').innerText='模型加载失败';
console.error(err);
});
function animate(){requestAnimationFrame(animate);controls.update();renderer.render(scene,camera);}
window.addEventListener('resize',function(){var w=document.getElementById('container').clientWidth;
var h=document.getElementById('container').clientHeight;
camera.aspect=w/h;camera.updateProjectionMatrix();renderer.setSize(w,h);});
setTimeout(function(){var w=document.getElementById('container').clientWidth;
var h=document.getElementById('container').clientHeight;renderer.setSize(w,h);},100);
<\/script></body></html>`;
    return 'data:text/html;charset=utf-8,' + encodeURIComponent(htmlContent);
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
    this.fetchActionDetail();
  }

  build() {
    Column() {
      Header({ title: '3D康复训练', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('3D 康复训练')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingXS(this.isElderMode) });

          Row({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
            ForEach(this.courseConfigs, (course: CourseConfig) => {
              Column() {
                Text(course.icon)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode));
                Text(course.name.length > 4 ? course.name.substring(0, 4) : course.name)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(this.selectedCourseId === course.id ? '#FFFFFF' : GlobalTheme.TEXT_SECONDARY)
                  .margin({ top: GlobalTheme.getSpacingXS(this.isElderMode) })
              }
              .padding({ top: GlobalTheme.getSpacingSM(this.isElderMode), bottom: GlobalTheme.getSpacingSM(this.isElderMode), left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
              .backgroundColor(this.selectedCourseId === course.id ? this.getCurrentCourse().color : '#F5F5F5')
              .borderRadius(GlobalTheme.RADIUS_LG)
              .border(this.selectedCourseId === course.id ? { width: 1.5, color: this.getCurrentCourse().color } : { width: 0 })
              .onClick(() => this.handleCourseSelect(course.id))
            }, (course: CourseConfig) => course.id)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start);

          if (this.isLoadingModel) {
            Column() {
              LoadingProgress()
                .width(48)
                .height(48)
                .color(this.getCurrentCourse().color)
                .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });
              Text('正在加载3D模型...')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#FAFBFF')
            .borderRadius(GlobalTheme.RADIUS_LG)
            .border({ width: 2, color: this.getCurrentCourse().color + '40' });
          } else if (this.modelUrl) {
            Column() {
              Stack({ alignContent: Alignment.Bottom }) {
                Web({ src: this.get3DViewerUrl(), controller: this.webController })
                  .width('100%')
                  .height(270)
                  .backgroundColor('#F5F5F5');

                Row() {
                  Text('进度 ' + Math.round(this.getProgressPercent()) + '%')
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#FFFFFF')
                }
                .width(this.getProgressPercent() + '%')
                .height(28)
                .linearGradient({
                  angle: 90,
                  colors: [[this.getCurrentCourse().color, 0], [this.getCurrentCourse().color + 'CC', 1]]
                })
                .borderRadius({ topLeft: 14, bottomLeft: 14 })
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .animation({ duration: 400, curve: Curve.EaseOut });
              }
              .width('100%')
              .height(300)

              Row({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
                if (this.modelDifficulty) {
                  Text('难度：' + this.modelDifficulty)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#FF9800')
                    .backgroundColor('#FFF3E0')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(12);
                }
                Text('可拖拽旋转 · 双指缩放')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_HINT);
              }
              .margin({ top: GlobalTheme.getSpacingXS(this.isElderMode) });
            }
            .width('100%')
            .backgroundColor('#FAFBFF')
            .borderRadius(GlobalTheme.RADIUS_LG)
            .border({ width: 2, color: this.getCurrentCourse().color + '40' })
            .shadow({
              radius: 20,
              color: this.getCurrentCourse().color + '18',
              offsetX: 0,
              offsetY: 6
            })
            .clip(true)
            .padding(GlobalTheme.getSpacingSM(this.isElderMode));
          } else {
            Column() {
              Text('📭')
                .fontSize(48)
                .margin({ bottom: 10 });
              Text('该课程暂无3D演示模型')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
              Text('请先通过后端上传3D文件并关联到该课程')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT)
                .margin({ top: 4 });
            }
            .width('100%')
            .height(250)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#FAFBFF')
            .borderRadius(GlobalTheme.RADIUS_LG)
            .border({ width: 2, color: this.getCurrentCourse().color + '40' });
          }

          if (this.actionName) {
            Column({ space: GlobalTheme.getSpacingXS(this.isElderMode) }) {
              Text(this.actionName)
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight('bold')
                .fontColor(GlobalTheme.TEXT_PRIMARY);
              if (this.actionDesc) {
                Text(this.actionDesc)
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
                  .maxLines(2);
              }
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor(GlobalTheme.CARD_BG)
            .borderRadius(GlobalTheme.RADIUS_MD)
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR });
          }

          Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Button(this.isPlaying ? '⏸ 暂停' : '▶ 播放')
              .layoutWeight(1)
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#FFFFFF')
              .backgroundColor(this.isPlaying ? GlobalTheme.WARNING_COLOR : this.getCurrentCourse().color)
              .borderRadius(GlobalTheme.RADIUS_LG)
              .shadow(this.isPlaying ? undefined : {
                radius: 8,
                color: this.getCurrentCourse().color + '50',
                offsetX: 0,
                offsetY: 3
              })
              .onClick(() => this.handlePlay());

            Button('🔄 重置')
              .layoutWeight(1)
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .backgroundColor(GlobalTheme.BORDER_COLOR)
              .borderRadius(GlobalTheme.RADIUS_LG)
              .onClick(() => this.handleReset());
          }
          .width('100%');

          Text('训练步骤')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .margin({ top: GlobalTheme.getSpacingXS(this.isElderMode) });

          List({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
            ForEach(this.getCurrentSteps(), (step: string, index: number) => {
              ListItem() {
                Row() {
                  Column() {
                    Text('' + (index + 1))
                      .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                      .fontWeight('bold')
                      .fontColor(this.currentStep === index ? '#FFFFFF' : this.getCurrentCourse().color);
                  }
                  .width(30)
                  .height(30)
                  .backgroundColor(this.currentStep === index ? this.getCurrentCourse().color : this.getCurrentCourse().color + '15')
                  .borderRadius(GlobalTheme.RADIUS_LG)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center);

                  Column({ space: GlobalTheme.getSpacingXS(this.isElderMode) }) {
                    Text(step)
                      .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                      .fontColor(this.currentStep === index ? this.getCurrentCourse().color : GlobalTheme.TEXT_PRIMARY)
                      .fontWeight(this.currentStep === index ? 'bold' : 'normal');

                    if (this.currentStep === index && this.isPlaying) {
                      Text('正在执行...')
                        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                        .fontColor(this.getCurrentCourse().color);
                    } else if (index < this.currentStep) {
                      Text('已完成')
                        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                        .fontColor(GlobalTheme.SUCCESS_COLOR);
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });

                  Text(index < this.currentStep ? '✅' : (this.currentStep === index && this.isPlaying ? '🔵' : '○'))
                    .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                    .fontColor(index < this.currentStep ? GlobalTheme.SUCCESS_COLOR : (this.currentStep === index && this.isPlaying ? this.getCurrentCourse().color : GlobalTheme.TEXT_LIGHT));
                }
                .width('100%')
                .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode), top: GlobalTheme.getSpacingSM(this.isElderMode), bottom: GlobalTheme.getSpacingSM(this.isElderMode) })
                .backgroundColor(this.currentStep === index ? this.getCurrentCourse().color + '08' : GlobalTheme.CARD_BG)
                .borderRadius(GlobalTheme.RADIUS_MD)
                .border({
                  width: this.currentStep === index ? 1.5 : 1,
                  color: this.currentStep === index ? this.getCurrentCourse().color + '60' : GlobalTheme.BORDER_COLOR
                })
                .shadow(this.currentStep === index ? {
                  radius: 6,
                  color: this.getCurrentCourse().color + '15',
                  offsetX: 0,
                  offsetY: 2
                } : undefined)
                .onClick(() => this.handleStepClick(index));
              }
            }, (step: string, index: number) => '' + this.selectedCourseId + '-' + step + '-' + index);
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ top: GlobalTheme.getSpacingXS(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });
        }
        .height(0)
        .layoutWeight(1)
        .width('85%')
        .alignItems(HorizontalAlign.Center);
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
