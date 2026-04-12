if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Footer_Params {
    activeIndex?: number;
}
import router from "@ohos:router";
export class Footer extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__activeIndex = new SynchedPropertySimpleOneWayPU(params.activeIndex, this, "activeIndex");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Footer_Params) {
        if (params.activeIndex === undefined) {
            this.__activeIndex.set(0);
        }
    }
    updateStateVars(params: Footer_Params) {
        this.__activeIndex.reset(params.activeIndex);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__activeIndex.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__activeIndex.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __activeIndex: SynchedPropertySimpleOneWayPU<number>;
    get activeIndex() {
        return this.__activeIndex.get();
    }
    set activeIndex(newValue: number) {
        this.__activeIndex.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/components/Footer.ets(8:5)", "entry");
            Row.width('100%');
            Row.height(60);
            Row.backgroundColor('#FFFFFF');
            Row.padding({ left: 16, right: 16 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/components/Footer.ets(9:7)", "entry");
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
            Column.onClick(() => {
                router.pushUrl({ url: 'pages/HomePage' });
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('🏠');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(10:9)", "entry");
            Text.fontSize(24);
            Text.fontColor(this.activeIndex === 0 ? '#1677FF' : '#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('首页');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(13:9)", "entry");
            Text.fontSize(12);
            Text.fontColor(this.activeIndex === 0 ? '#1677FF' : '#999999');
            Text.margin({ top: 4 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/components/Footer.ets(24:7)", "entry");
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
            Column.onClick(() => {
                router.pushUrl({ url: 'pages/MedicalPage' });
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('🏥');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(25:9)", "entry");
            Text.fontSize(24);
            Text.fontColor(this.activeIndex === 1 ? '#1677FF' : '#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('就医');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(28:9)", "entry");
            Text.fontSize(12);
            Text.fontColor(this.activeIndex === 1 ? '#1677FF' : '#999999');
            Text.margin({ top: 4 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/components/Footer.ets(39:7)", "entry");
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
            Column.onClick(() => {
                router.pushUrl({ url: 'pages/RehabPage' });
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('🧘');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(40:9)", "entry");
            Text.fontSize(24);
            Text.fontColor(this.activeIndex === 2 ? '#1677FF' : '#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('康复');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(43:9)", "entry");
            Text.fontSize(12);
            Text.fontColor(this.activeIndex === 2 ? '#1677FF' : '#999999');
            Text.margin({ top: 4 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/components/Footer.ets(54:7)", "entry");
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
            Column.onClick(() => {
                router.pushUrl({ url: 'pages/ScienceListPage' });
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('📚');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(55:9)", "entry");
            Text.fontSize(24);
            Text.fontColor(this.activeIndex === 3 ? '#1677FF' : '#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('科普');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(58:9)", "entry");
            Text.fontSize(12);
            Text.fontColor(this.activeIndex === 3 ? '#1677FF' : '#999999');
            Text.margin({ top: 4 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/components/Footer.ets(69:7)", "entry");
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
            Column.onClick(() => {
                router.pushUrl({ url: 'pages/Profile' });
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('👤');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(70:9)", "entry");
            Text.fontSize(24);
            Text.fontColor(this.activeIndex === 4 ? '#1677FF' : '#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('我的');
            Text.debugLine("entry/src/main/ets/components/Footer.ets(73:9)", "entry");
            Text.fontSize(12);
            Text.fontColor(this.activeIndex === 4 ? '#1677FF' : '#999999');
            Text.margin({ top: 4 });
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
