if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface RehabListPage_Params {
    courses?: RehabCourse[];
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
export interface RehabCourse {
    id: string;
    icon: string;
    title: string;
    description: string;
    duration: string;
    difficulty: string;
}
class RehabListPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__courses = new ObservedPropertyObjectPU([
            {
                id: '1',
                icon: '🦴',
                title: '颈椎病康复',
                description: '针对颈椎问题的专业康复训练课程',
                duration: '30分钟/次',
                difficulty: '初级'
            },
            {
                id: '2',
                icon: '❤️',
                title: '高血压康复',
                description: '高血压患者的运动康复指导方案',
                duration: '45分钟/次',
                difficulty: '中级'
            },
            {
                id: '3',
                icon: '💪',
                title: '肌力训练',
                description: '全身肌肉力量增强训练计划',
                duration: '40分钟/次',
                difficulty: '中级'
            },
            {
                id: '4',
                icon: '⚖️',
                title: '平衡训练',
                description: '提升身体协调性和平衡能力训练',
                duration: '25分钟/次',
                difficulty: '初级'
            }
        ], this, "courses");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: RehabListPage_Params) {
        if (params.courses !== undefined) {
            this.courses = params.courses;
        }
    }
    updateStateVars(params: RehabListPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__courses.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__courses.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __courses: ObservedPropertyObjectPU<RehabCourse[]>;
    get courses() {
        return this.__courses.get();
    }
    set courses(newValue: RehabCourse[]) {
        this.__courses.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/RehabListPage.ets(54:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '康复课程', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/RehabListPage.ets", line: 55, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '康复课程',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '康复课程', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/RehabListPage.ets(57:7)", "entry");
            Scroll.flexGrow(1);
            Scroll.scrollBar(BarState.Off);
            Scroll.align(Alignment.Top);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/pages/RehabListPage.ets(58:9)", "entry");
            Column.width('85%');
            Column.padding({ bottom: 24 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('选择康复课程');
            Text.debugLine("entry/src/main/ets/pages/RehabListPage.ets(59:11)", "entry");
            Text.fontSize(22);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 16, bottom: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create();
            List.debugLine("entry/src/main/ets/pages/RehabListPage.ets(65:11)", "entry");
            List.width('100%');
            List.layoutWeight(1);
        }, List);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const course = _item;
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
                        ListItem.padding({ bottom: 8 });
                        ListItem.debugLine("entry/src/main/ets/pages/RehabListPage.ets(67:15)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create();
                            Column.debugLine("entry/src/main/ets/pages/RehabListPage.ets(68:17)", "entry");
                            Column.width('100%');
                            Column.padding(16);
                            Column.backgroundColor('#FFFFFF');
                            Column.borderRadius(12);
                            Column.border({ width: 1, color: '#f0f0f0' });
                            Column.onClick(() => {
                                router.pushUrl({ url: 'pages/Rehab3DPage' });
                            });
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create();
                            Row.debugLine("entry/src/main/ets/pages/RehabListPage.ets(69:19)", "entry");
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create();
                            Column.debugLine("entry/src/main/ets/pages/RehabListPage.ets(70:21)", "entry");
                            Column.width(64);
                            Column.height(64);
                            Column.backgroundColor('#1677FF20');
                            Column.borderRadius(32);
                            Column.justifyContent(FlexAlign.Center);
                            Column.alignItems(HorizontalAlign.Center);
                            Column.margin({ right: 16 });
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(course.icon);
                            Text.debugLine("entry/src/main/ets/pages/RehabListPage.ets(71:23)", "entry");
                            Text.fontSize(36);
                        }, Text);
                        Text.pop();
                        Column.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create({ space: 6 });
                            Column.debugLine("entry/src/main/ets/pages/RehabListPage.ets(82:21)", "entry");
                            Column.layoutWeight(1);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(course.title);
                            Text.debugLine("entry/src/main/ets/pages/RehabListPage.ets(83:23)", "entry");
                            Text.fontSize(17);
                            Text.fontWeight('bold');
                            Text.fontColor('#333333');
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(course.description);
                            Text.debugLine("entry/src/main/ets/pages/RehabListPage.ets(88:23)", "entry");
                            Text.fontSize(13);
                            Text.fontColor('#666666');
                            Text.maxLines(2);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create({ space: 12 });
                            Row.debugLine("entry/src/main/ets/pages/RehabListPage.ets(93:23)", "entry");
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(`⏱ ${course.duration}`);
                            Text.debugLine("entry/src/main/ets/pages/RehabListPage.ets(94:25)", "entry");
                            Text.fontSize(12);
                            Text.fontColor('#999999');
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(`📊 ${course.difficulty}`);
                            Text.debugLine("entry/src/main/ets/pages/RehabListPage.ets(97:25)", "entry");
                            Text.fontSize(12);
                            Text.fontColor('#1677FF');
                        }, Text);
                        Text.pop();
                        Row.pop();
                        Column.pop();
                        Row.pop();
                        Column.pop();
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.courses, forEachItemGenFunction, (course: RehabCourse) => course.id, false, false);
        }, ForEach);
        ForEach.pop();
        List.pop();
        Column.pop();
        Scroll.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 2 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/RehabListPage.ets", line: 127, col: 7 });
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
        return "RehabListPage";
    }
}
registerNamedRoute(() => new RehabListPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/RehabListPage", pageFullPath: "entry/src/main/ets/pages/RehabListPage", integratedHsp: "false", moduleType: "followWithHap" });
