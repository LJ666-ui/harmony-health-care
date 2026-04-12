if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface RehabPage_Params {
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
import { IconCard } from "@normalized:N&&&entry/src/main/ets/components/Card&";
class RehabPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: RehabPage_Params) {
    }
    updateStateVars(params: RehabPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
    }
    aboutToBeDeleted() {
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    initialRender(): void {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/RehabPage.ets(10:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, {
                        title: '康复',
                        showBack: false
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/RehabPage.ets", line: 11, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '康复',
                            showBack: false
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '康复',
                        showBack: false
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({
                space: 16
            });
            Column.debugLine("entry/src/main/ets/pages/RehabPage.ets(16:7)", "entry");
            Column.flexGrow(1);
            Column.width('80%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('康复模块');
            Text.debugLine("entry/src/main/ets/pages/RehabPage.ets(19:9)", "entry");
            Text.fontSize(24);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 20, bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/RehabPage.ets(25:9)", "entry");
            Column.onClick(() => {
                router.pushUrl({ url: 'pages/RehabListPage' });
            });
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new IconCard(this, {
                        icon: '🏃',
                        iconColor: '#1677FF',
                        iconBackgroundColor: '#1677FF20',
                        title: '康复课程',
                        description: '专业康复训练课程'
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/RehabPage.ets", line: 26, col: 11 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            icon: '🏃',
                            iconColor: '#1677FF',
                            iconBackgroundColor: '#1677FF20',
                            title: '康复课程',
                            description: '专业康复训练课程'
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        icon: '🏃',
                        iconColor: '#1677FF',
                        iconBackgroundColor: '#1677FF20',
                        title: '康复课程',
                        description: '专业康复训练课程'
                    });
                }
            }, { name: "IconCard" });
        }
        Column.pop();
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 2 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/RehabPage.ets", line: 43, col: 7 });
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
        return "RehabPage";
    }
}
registerNamedRoute(() => new RehabPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/RehabPage", pageFullPath: "entry/src/main/ets/pages/RehabPage", integratedHsp: "false", moduleType: "followWithHap" });
