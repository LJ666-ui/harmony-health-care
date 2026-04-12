if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MedicalPage_Params {
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
import { IconCard } from "@normalized:N&&&entry/src/main/ets/components/Card&";
class MedicalPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MedicalPage_Params) {
    }
    updateStateVars(params: MedicalPage_Params) {
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
            Column.debugLine("entry/src/main/ets/pages/MedicalPage.ets(10:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 顶部导航栏
                    Header(this, {
                        title: '就医',
                        showBack: false
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MedicalPage.ets", line: 12, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '就医',
                            showBack: false
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '就医',
                        showBack: false
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 中间内容区
            Column.create({
                space: 16
            });
            Column.debugLine("entry/src/main/ets/pages/MedicalPage.ets(18:7)", "entry");
            // 中间内容区
            Column.flexGrow(1);
            // 中间内容区
            Column.width('80%');
            // 中间内容区
            Column.justifyContent(FlexAlign.Center);
            // 中间内容区
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 页面标题
            Text.create('就医模块');
            Text.debugLine("entry/src/main/ets/pages/MedicalPage.ets(22:9)", "entry");
            // 页面标题
            Text.fontSize(24);
            // 页面标题
            Text.fontWeight('bold');
            // 页面标题
            Text.fontColor('#1677FF');
            // 页面标题
            Text.margin({ top: 20, bottom: 16 });
        }, Text);
        // 页面标题
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            __Common__.create();
            __Common__.onClick(() => {
                router.pushUrl({ url: 'pages/HospitalPage' });
            });
        }, __Common__);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 就医模块内容
                    IconCard(this, {
                        icon: '🏥',
                        iconColor: '#1677FF',
                        iconBackgroundColor: '#1677FF20',
                        title: '就医服务',
                        description: '提供便捷的就医服务'
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MedicalPage.ets", line: 29, col: 9 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            icon: '🏥',
                            iconColor: '#1677FF',
                            iconBackgroundColor: '#1677FF20',
                            title: '就医服务',
                            description: '提供便捷的就医服务'
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        icon: '🏥',
                        iconColor: '#1677FF',
                        iconBackgroundColor: '#1677FF20',
                        title: '就医服务',
                        description: '提供便捷的就医服务'
                    });
                }
            }, { name: "IconCard" });
        }
        __Common__.pop();
        // 中间内容区
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 底部Tab栏
                    Footer(this, { activeIndex: 1 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MedicalPage.ets", line: 46, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            activeIndex: 1
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        activeIndex: 1
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
        return "MedicalPage";
    }
}
registerNamedRoute(() => new MedicalPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/MedicalPage", pageFullPath: "entry/src/main/ets/pages/MedicalPage", integratedHsp: "false", moduleType: "followWithHap" });
