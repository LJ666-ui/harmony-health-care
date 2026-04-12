if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface SciencePage_Params {
}
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
class SciencePage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: SciencePage_Params) {
    }
    updateStateVars(params: SciencePage_Params) {
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
            Column.debugLine("entry/src/main/ets/pages/SciencePage.ets(9:5)", "entry");
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
                        title: '科普',
                        showBack: false
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/SciencePage.ets", line: 11, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '科普',
                            showBack: false
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '科普',
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
            Column.debugLine("entry/src/main/ets/pages/SciencePage.ets(17:7)", "entry");
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
            Text.create('科普模块');
            Text.debugLine("entry/src/main/ets/pages/SciencePage.ets(21:9)", "entry");
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
            // 科普模块内容
            Text.create('科普模块页面');
            Text.debugLine("entry/src/main/ets/pages/SciencePage.ets(28:9)", "entry");
            // 科普模块内容
            Text.fontSize(16);
            // 科普模块内容
            Text.fontColor('#666666');
            // 科普模块内容
            Text.margin({ top: 40 });
        }, Text);
        // 科普模块内容
        Text.pop();
        // 中间内容区
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 底部Tab栏
                    Footer(this, { activeIndex: 3 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/SciencePage.ets", line: 39, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            activeIndex: 3
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        activeIndex: 3
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
        return "SciencePage";
    }
}
registerNamedRoute(() => new SciencePage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/SciencePage", pageFullPath: "entry/src/main/ets/pages/SciencePage", integratedHsp: "false", moduleType: "followWithHap" });
