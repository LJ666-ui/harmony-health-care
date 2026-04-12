if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
}
import router from "@ohos:router";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
    }
    aboutToBeDeleted() {
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(8:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 中间内容区
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(10:7)", "entry");
            // 中间内容区
            Column.flexGrow(1);
            // 中间内容区
            Column.width('100%');
            // 中间内容区
            Column.justifyContent(FlexAlign.Center);
            // 中间内容区
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标题
            Text.create('星云医疗助手');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(12:9)", "entry");
            // 标题
            Text.fontSize(32);
            // 标题
            Text.fontWeight('bold');
            // 标题
            Text.fontColor('#1677FF');
            // 标题
            Text.margin({ bottom: 16 });
        }, Text);
        // 标题
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 引导文字
            Text.create('守护健康，从这里开始');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(19:9)", "entry");
            // 引导文字
            Text.fontSize(18);
            // 引导文字
            Text.fontColor('#666666');
            // 引导文字
            Text.margin({ bottom: 48 });
        }, Text);
        // 引导文字
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 去登录按钮
            Button.createWithLabel('去登录');
            Button.debugLine("entry/src/main/ets/pages/Index.ets(25:9)", "entry");
            // 去登录按钮
            Button.width('80%');
            // 去登录按钮
            Button.height(48);
            // 去登录按钮
            Button.fontSize(16);
            // 去登录按钮
            Button.fontWeight('medium');
            // 去登录按钮
            Button.fontColor('#FFFFFF');
            // 去登录按钮
            Button.backgroundColor('#1677FF');
            // 去登录按钮
            Button.borderRadius(8);
            // 去登录按钮
            Button.onClick(() => {
                // 路由跳转到Login页面
                router.pushUrl({
                    url: 'pages/Login'
                });
            });
        }, Button);
        // 去登录按钮
        Button.pop();
        // 中间内容区
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 底部Tab栏
                    Footer(this, { activeIndex: 0 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 46, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            activeIndex: 0
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        activeIndex: 0
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
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
