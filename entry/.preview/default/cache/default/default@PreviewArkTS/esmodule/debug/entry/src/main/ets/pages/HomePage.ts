if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface HomePage_Params {
    clickedCard?: number;
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
class HomePage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__clickedCard = new ObservedPropertySimplePU(-1, this, "clickedCard");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: HomePage_Params) {
        if (params.clickedCard !== undefined) {
            this.clickedCard = params.clickedCard;
        }
    }
    updateStateVars(params: HomePage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__clickedCard.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__clickedCard.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __clickedCard: ObservedPropertySimplePU<number>;
    get clickedCard() {
        return this.__clickedCard.get();
    }
    set clickedCard(newValue: number) {
        this.__clickedCard.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/HomePage.ets(11:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '首页', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/HomePage.ets", line: 12, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '首页',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '首页', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 20 });
            Column.debugLine("entry/src/main/ets/pages/HomePage.ets(14:7)", "entry");
            Column.flexGrow(1);
            Column.width('80%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('首页');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(15:9)", "entry");
            Text.fontSize(24);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('欢迎使用星云医疗助手');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(21:9)", "entry");
            Text.fontSize(16);
            Text.fontColor('#666666');
            Text.margin({ bottom: 32 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/HomePage.ets(26:9)", "entry");
            Row.width('100%');
            Row.padding(16);
            Row.backgroundColor(this.clickedCard === 0 ? '#E6F4FF' : '#FFFFFF');
            Row.borderRadius(8);
            Row.border({ width: 1, color: this.clickedCard === 0 ? '#1677FF' : '#f0f0f0' });
            Row.onClick(() => {
                this.clickedCard = 0;
                try {
                    router.pushUrl({ url: 'pages/HealthRecords' });
                }
                catch (e) {
                    console.error('路由跳转失败:', e);
                }
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/HomePage.ets(27:11)", "entry");
            Column.width(64);
            Column.height(64);
            Column.backgroundColor(this.clickedCard === 0 ? '#1677FF' : '#1677FF20');
            Column.borderRadius(32);
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('📋');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(28:13)", "entry");
            Text.fontSize(32);
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/HomePage.ets(39:11)", "entry");
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Start);
            Column.margin({ left: 16 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('健康记录');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(40:13)", "entry");
            Text.fontSize(18);
            Text.fontWeight('bold');
            Text.fontColor('#333333');
            Text.margin({ bottom: 4 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.clickedCard === 0 ? '>>> 点击已触发！<<<' : '查看和管理您的健康数据');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(45:13)", "entry");
            Text.fontSize(14);
            Text.fontColor(this.clickedCard === 0 ? '#1677FF' : '#666666');
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/HomePage.ets(67:9)", "entry");
            Row.width('100%');
            Row.padding(16);
            Row.backgroundColor(this.clickedCard === 1 ? '#E6F4FF' : '#FFFFFF');
            Row.borderRadius(8);
            Row.border({ width: 1, color: this.clickedCard === 1 ? '#1677FF' : '#f0f0f0' });
            Row.onClick(() => {
                this.clickedCard = 1;
                try {
                    router.pushUrl({ url: 'pages/Appointments' });
                }
                catch (e) {
                    console.error('路由跳转失败:', e);
                }
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/HomePage.ets(68:11)", "entry");
            Column.width(64);
            Column.height(64);
            Column.backgroundColor(this.clickedCard === 1 ? '#1677FF' : '#1677FF20');
            Column.borderRadius(32);
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('📅');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(69:13)", "entry");
            Text.fontSize(32);
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/HomePage.ets(80:11)", "entry");
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Start);
            Column.margin({ left: 16 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('预约管理');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(81:13)", "entry");
            Text.fontSize(18);
            Text.fontWeight('bold');
            Text.fontColor('#333333');
            Text.margin({ bottom: 4 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.clickedCard === 1 ? '>>> 点击已触发！<<<' : '管理您的医疗预约');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(86:13)", "entry");
            Text.fontSize(14);
            Text.fontColor(this.clickedCard === 1 ? '#1677FF' : '#666666');
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/HomePage.ets(108:9)", "entry");
            Row.width('100%');
            Row.padding(16);
            Row.backgroundColor(this.clickedCard === 2 ? '#E6F4FF' : '#FFFFFF');
            Row.borderRadius(8);
            Row.border({ width: 1, color: this.clickedCard === 2 ? '#1677FF' : '#f0f0f0' });
            Row.onClick(() => {
                this.clickedCard = 2;
                try {
                    router.pushUrl({ url: 'pages/Medications' });
                }
                catch (e) {
                    console.error('路由跳转失败:', e);
                }
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/HomePage.ets(109:11)", "entry");
            Column.width(64);
            Column.height(64);
            Column.backgroundColor(this.clickedCard === 2 ? '#1677FF' : '#1677FF20');
            Column.borderRadius(32);
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('💊');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(110:13)", "entry");
            Text.fontSize(32);
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/HomePage.ets(121:11)", "entry");
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Start);
            Column.margin({ left: 16 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('用药管理');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(122:13)", "entry");
            Text.fontSize(18);
            Text.fontWeight('bold');
            Text.fontColor('#333333');
            Text.margin({ bottom: 4 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.clickedCard === 2 ? '>>> 点击已触发！<<<' : '跟踪您的用药情况');
            Text.debugLine("entry/src/main/ets/pages/HomePage.ets(127:13)", "entry");
            Text.fontSize(14);
            Text.fontColor(this.clickedCard === 2 ? '#1677FF' : '#666666');
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 0 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/HomePage.ets", line: 154, col: 7 });
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
        return "HomePage";
    }
}
registerNamedRoute(() => new HomePage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/HomePage", pageFullPath: "entry/src/main/ets/pages/HomePage", integratedHsp: "false", moduleType: "followWithHap" });
