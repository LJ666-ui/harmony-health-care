if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Rehab3DPage_Params {
    isElderMode?: boolean;
    isPlaying?: boolean;
    currentStep?: number;
    selectedCourseId?: string;
    scaleValue?: number;
    rotateAngle?: number;
    progressAnim?: number;
    webController?: webview.WebviewController;
    timer?: number;
    courseConfigs?: CourseConfig[];
}
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
import { GlobalTheme } from "@normalized:N&&&entry/src/main/ets/global&";
import webview from "@ohos:web.webview";
interface CourseConfig {
    id: string;
    name: string;
    icon: string;
    iconLabel: string;
    steps: string[];
    color: string;
}
class Rehab3DPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__isElderMode = this.createStorageLink('isOldModeEnabled', false, "isElderMode");
        this.__isPlaying = new ObservedPropertySimplePU(false, this, "isPlaying");
        this.__currentStep = new ObservedPropertySimplePU(0, this, "currentStep");
        this.__selectedCourseId = new ObservedPropertySimplePU('1', this, "selectedCourseId");
        this.__scaleValue = new ObservedPropertySimplePU(1.0, this, "scaleValue");
        this.__rotateAngle = new ObservedPropertySimplePU(0, this, "rotateAngle");
        this.__progressAnim = new ObservedPropertySimplePU(0, this, "progressAnim");
        this.webController = new webview.WebviewController();
        this.timer = -1;
        this.courseConfigs = [
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
                iconLabel: '单腿训练',
                steps: ['双脚并拢', '单脚抬起', '保持平衡', '换脚训练', '放松休息'],
                color: '#722ED1'
            }
        ];
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Rehab3DPage_Params) {
        if (params.isPlaying !== undefined) {
            this.isPlaying = params.isPlaying;
        }
        if (params.currentStep !== undefined) {
            this.currentStep = params.currentStep;
        }
        if (params.selectedCourseId !== undefined) {
            this.selectedCourseId = params.selectedCourseId;
        }
        if (params.scaleValue !== undefined) {
            this.scaleValue = params.scaleValue;
        }
        if (params.rotateAngle !== undefined) {
            this.rotateAngle = params.rotateAngle;
        }
        if (params.progressAnim !== undefined) {
            this.progressAnim = params.progressAnim;
        }
        if (params.webController !== undefined) {
            this.webController = params.webController;
        }
        if (params.timer !== undefined) {
            this.timer = params.timer;
        }
        if (params.courseConfigs !== undefined) {
            this.courseConfigs = params.courseConfigs;
        }
    }
    updateStateVars(params: Rehab3DPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__isElderMode.purgeDependencyOnElmtId(rmElmtId);
        this.__isPlaying.purgeDependencyOnElmtId(rmElmtId);
        this.__currentStep.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedCourseId.purgeDependencyOnElmtId(rmElmtId);
        this.__scaleValue.purgeDependencyOnElmtId(rmElmtId);
        this.__rotateAngle.purgeDependencyOnElmtId(rmElmtId);
        this.__progressAnim.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__isElderMode.aboutToBeDeleted();
        this.__isPlaying.aboutToBeDeleted();
        this.__currentStep.aboutToBeDeleted();
        this.__selectedCourseId.aboutToBeDeleted();
        this.__scaleValue.aboutToBeDeleted();
        this.__rotateAngle.aboutToBeDeleted();
        this.__progressAnim.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __isElderMode: ObservedPropertyAbstractPU<boolean>;
    get isElderMode() {
        return this.__isElderMode.get();
    }
    set isElderMode(newValue: boolean) {
        this.__isElderMode.set(newValue);
    }
    private __isPlaying: ObservedPropertySimplePU<boolean>;
    get isPlaying() {
        return this.__isPlaying.get();
    }
    set isPlaying(newValue: boolean) {
        this.__isPlaying.set(newValue);
    }
    private __currentStep: ObservedPropertySimplePU<number>;
    get currentStep() {
        return this.__currentStep.get();
    }
    set currentStep(newValue: number) {
        this.__currentStep.set(newValue);
    }
    private __selectedCourseId: ObservedPropertySimplePU<string>;
    get selectedCourseId() {
        return this.__selectedCourseId.get();
    }
    set selectedCourseId(newValue: string) {
        this.__selectedCourseId.set(newValue);
    }
    private __scaleValue: ObservedPropertySimplePU<number>;
    get scaleValue() {
        return this.__scaleValue.get();
    }
    set scaleValue(newValue: number) {
        this.__scaleValue.set(newValue);
    }
    private __rotateAngle: ObservedPropertySimplePU<number>;
    get rotateAngle() {
        return this.__rotateAngle.get();
    }
    set rotateAngle(newValue: number) {
        this.__rotateAngle.set(newValue);
    }
    private __progressAnim: ObservedPropertySimplePU<number>;
    get progressAnim() {
        return this.__progressAnim.get();
    }
    set progressAnim(newValue: number) {
        this.__progressAnim.set(newValue);
    }
    // WebController 实例，用于控制 Web 组件
    private webController: webview.WebviewController;
    private timer: number;
    private courseConfigs: CourseConfig[];
    getCurrentCourse(): CourseConfig {
        return this.courseConfigs.find(c => c.id === this.selectedCourseId) ?? this.courseConfigs[0];
    }
    getCourseSteps(): string[] {
        return this.getCurrentCourse().steps;
    }
    getProgressPercent(): number {
        return ((this.currentStep + 1) / this.getCourseSteps().length) * 100;
    }
    aboutToAppear(): void {
        if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
            AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
        }
        else {
            this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
        }
    }
    aboutToDisappear(): void {
        if (this.timer !== -1) {
            clearInterval(this.timer);
            this.timer = -1;
        }
    }
    startAnimation(): void {
        this.rotateAngle = 0;
        const animTimer = setInterval(() => {
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
        }
        else {
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
            const steps = this.getCourseSteps();
            if (this.currentStep < steps.length - 1) {
                this.currentStep++;
                this.progressAnim = this.getProgressPercent();
            }
            else {
                this.isPlaying = false;
                clearInterval(this.timer);
                this.timer = -1;
            }
        }, 2500);
    }
    handleReset(): void {
        this.isPlaying = false;
        if (this.timer !== -1) {
            clearInterval(this.timer);
            this.timer = -1;
        }
        this.currentStep = 0;
        this.progressAnim = 0;
        this.scaleValue = 1.0;
        this.rotateAngle = 0;
    }
    handleStepClick(index: number): void {
        if (this.timer !== -1) {
            clearInterval(this.timer);
            this.timer = -1;
        }
        this.isPlaying = false;
        this.currentStep = index;
        this.progressAnim = this.getProgressPercent();
    }
    handleCourseSelect(courseId: string): void {
        this.selectedCourseId = courseId;
        this.handleReset();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(169:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(GlobalTheme.BG_COLOR);
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '康复训练', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Rehab3DPage.ets", line: 170, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '康复训练',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '康复训练', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(172:7)", "entry");
            Scroll.flexGrow(1);
            Scroll.scrollBar(BarState.Off);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: GlobalTheme.getSpacingLG(this.isElderMode) });
            Column.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(173:9)", "entry");
            Column.width('85%');
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 课程选择栏
            Row.create({ space: GlobalTheme.getSpacingSM(this.isElderMode) });
            Row.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(175:11)", "entry");
            // 课程选择栏
            Row.width('100%');
            // 课程选择栏
            Row.justifyContent(FlexAlign.Start);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const course = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(177:15)", "entry");
                    Column.padding(GlobalTheme.getSpacingSM(this.isElderMode));
                    Column.backgroundColor(this.selectedCourseId === course.id ? this.getCurrentCourse().color : '#F5F5F5');
                    Column.borderRadius(GlobalTheme.RADIUS_LG);
                    Column.onClick(() => this.handleCourseSelect(course.id));
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(course.icon);
                    Text.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(178:17)", "entry");
                    Text.fontSize(GlobalTheme.getFontSizeBody(this.isElderMode));
                }, Text);
                Text.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(course.name);
                    Text.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(180:17)", "entry");
                    Text.fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode));
                    Text.fontColor(this.selectedCourseId === course.id ? '#FFFFFF' : GlobalTheme.TEXT_SECONDARY);
                }, Text);
                Text.pop();
                Column.pop();
            };
            this.forEachUpdateFunction(elmtId, this.courseConfigs, forEachItemGenFunction, (course: CourseConfig) => course.id, false, false);
        }, ForEach);
        ForEach.pop();
        // 课程选择栏
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 3D模型区域 ✅【已修复】
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(194:11)", "entry");
            // 3D模型区域 ✅【已修复】
            Column.width('100%');
            // 3D模型区域 ✅【已修复】
            Column.backgroundColor('#FAFBFF');
            // 3D模型区域 ✅【已修复】
            Column.borderRadius(20);
            // 3D模型区域 ✅【已修复】
            Column.border({ width: 2, color: `${this.getCurrentCourse().color}40` });
            // 3D模型区域 ✅【已修复】
            Column.shadow({ radius: 20, color: `${this.getCurrentCourse().color}20`, offsetX: 0, offsetY: 6 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create({ alignContent: Alignment.Bottom });
            Stack.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(195:13)", "entry");
            Stack.width('100%');
            Stack.height(300);
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(196:15)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 直接传入 $rawfile，不做任何拼接，避免类型错误
            Web.create({ src: { "id": 0, "type": 30000, params: ['viewer/index.html'], "bundleName": "com.example.harmonyhealthcare", "moduleName": "entry" }, controller: this.webController });
            Web.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(198:17)", "entry");
            // 直接传入 $rawfile，不做任何拼接，避免类型错误
            Web.width(this.isElderMode ? 180 : 150);
            // 直接传入 $rawfile，不做任何拼接，避免类型错误
            Web.height(this.isElderMode ? 180 : 150);
            // 直接传入 $rawfile，不做任何拼接，避免类型错误
            Web.scale({ x: this.scaleValue, y: this.scaleValue });
            // 直接传入 $rawfile，不做任何拼接，避免类型错误
            Web.rotate({ z: 1, angle: this.isPlaying ? Math.sin(this.rotateAngle * Math.PI / 180) * 8 : 0 });
            // 直接传入 $rawfile，不做任何拼接，避免类型错误
            Web.margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });
        }, Web);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.getCurrentCourse().iconLabel);
            Text.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(205:17)", "entry");
            Text.fontSize(GlobalTheme.getFontSizeBody(this.isElderMode));
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor(this.getCurrentCourse().color);
            Text.backgroundColor(`${this.getCurrentCourse().color}15`);
            Text.padding({ left: 15, right: 15, top: 5, bottom: 5 });
            Text.borderRadius(GlobalTheme.RADIUS_MD);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.getCourseSteps()[this.currentStep]);
            Text.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(213:17)", "entry");
            Text.fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode));
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ top: 10 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`步骤 ${this.currentStep + 1} / ${this.getCourseSteps().length}`);
            Text.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(218:17)", "entry");
            Text.fontSize(14);
            Text.fontColor('#888888');
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 进度条
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(227:15)", "entry");
            // 进度条
            Row.width(`${this.getProgressPercent()}%`);
            // 进度条
            Row.height(28);
            // 进度条
            Row.linearGradient({ angle: 90, colors: [[this.getCurrentCourse().color, 0], [`${this.getCurrentCourse().color}CC`, 1]] });
            // 进度条
            Row.borderRadius({ topLeft: 14, bottomLeft: 14 });
            // 进度条
            Row.justifyContent(FlexAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`进度 ${Math.round(this.getProgressPercent())}%`);
            Text.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(228:17)", "entry");
            Text.fontSize(12);
            Text.fontColor('#FFFFFF');
        }, Text);
        Text.pop();
        // 进度条
        Row.pop();
        Stack.pop();
        // 3D模型区域 ✅【已修复】
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 按钮区
            Row.create({ space: GlobalTheme.getSpacingMD(this.isElderMode) });
            Row.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(248:11)", "entry");
            // 按钮区
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.isPlaying ? '暂停' : '播放');
            Button.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(249:13)", "entry");
            Button.layoutWeight(1);
            Button.height(GlobalTheme.getButtonHeight(this.isElderMode));
            Button.backgroundColor(this.isPlaying ? '#FF7800' : this.getCurrentCourse().color);
            Button.onClick(() => this.handlePlay());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('重置');
            Button.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(255:13)", "entry");
            Button.layoutWeight(1);
            Button.height(GlobalTheme.getButtonHeight(this.isElderMode));
            Button.backgroundColor(GlobalTheme.BORDER_COLOR);
            Button.onClick(() => this.handleReset());
        }, Button);
        Button.pop();
        // 按钮区
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 步骤列表
            List.create({ space: GlobalTheme.getSpacingSM(this.isElderMode) });
            List.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(264:11)", "entry");
            // 步骤列表
            List.width('100%');
            // 步骤列表
            List.height(300);
            // 步骤列表
            List.padding({ bottom: 20 });
        }, List);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = (_item, index: number) => {
                const step = _item;
                {
                    const itemCreation = (elmtId, isInitialRender) => {
                        ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                        ListItem.create(deepRenderFunction, true);
                        if (!isInitialRender) {
                            ListItem.pop();
                        }
                        ViewStackProcessor.StopGetAccessRecording();
                    };
                    const itemCreation2 = (elmtId, isInitialRender) => {
                        ListItem.create(deepRenderFunction, true);
                        ListItem.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(266:15)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create();
                            Row.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(267:17)", "entry");
                            Row.width('100%');
                            Row.padding(15);
                            Row.backgroundColor(this.currentStep === index ? `${this.getCurrentCourse().color}08` : '#FFFFFF');
                            Row.borderRadius(12);
                            Row.onClick(() => this.handleStepClick(index));
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(`${index + 1}`);
                            Text.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(268:19)", "entry");
                            Text.fontSize(14);
                            Text.fontColor(this.currentStep === index ? '#FFFFFF' : this.getCurrentCourse().color);
                            Text.width(30);
                            Text.height(30);
                            Text.backgroundColor(this.currentStep === index ? this.getCurrentCourse().color : `${this.getCurrentCourse().color}15`);
                            Text.borderRadius(15);
                            Text.textAlign(TextAlign.Center);
                            Text.textVerticalAlign(TextVerticalAlign.CENTER);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(step);
                            Text.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(278:19)", "entry");
                            Text.fontSize(16);
                            Text.layoutWeight(1);
                            Text.margin({ left: 10 });
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(index < this.currentStep ? '✅' : (this.currentStep === index && this.isPlaying ? '🔵' : '○'));
                            Text.debugLine("entry/src/main/ets/pages/Rehab3DPage.ets(283:19)", "entry");
                            Text.fontSize(20);
                        }, Text);
                        Text.pop();
                        Row.pop();
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.getCourseSteps(), forEachItemGenFunction, (index: number) => index.toString(), true, false);
        }, ForEach);
        ForEach.pop();
        // 步骤列表
        List.pop();
        Column.pop();
        Scroll.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 2 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Rehab3DPage.ets", line: 304, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            activeIndex: 2
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        activeIndex: 2
                    });
                }
            }, { name: "Footer" });
        }
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Rehab3DPage";
    }
}
registerNamedRoute(() => new Rehab3DPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/Rehab3DPage", pageFullPath: "entry/src/main/ets/pages/Rehab3DPage", integratedHsp: "false", moduleType: "followWithHap" });
