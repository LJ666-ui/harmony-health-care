if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface IconCard_Params {
    icon?: string;
    iconColor?: string;
    iconBackgroundColor?: string;
    title?: string;
    description?: string;
}
interface Card_Params {
    title?: string;
    value?: string;
    description?: string;
    status?: string;
}
export class Card extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__title = new SynchedPropertySimpleOneWayPU(params.title, this, "title");
        this.__value = new SynchedPropertySimpleOneWayPU(params.value, this, "value");
        this.__description = new SynchedPropertySimpleOneWayPU(params.description, this, "description");
        this.__status = new SynchedPropertySimpleOneWayPU(params.status, this, "status");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Card_Params) {
        if (params.title === undefined) {
            this.__title.set('');
        }
        if (params.value === undefined) {
            this.__value.set('');
        }
        if (params.description === undefined) {
            this.__description.set('');
        }
        if (params.status === undefined) {
            this.__status.set('');
        }
    }
    updateStateVars(params: Card_Params) {
        this.__title.reset(params.title);
        this.__value.reset(params.value);
        this.__description.reset(params.description);
        this.__status.reset(params.status);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__title.purgeDependencyOnElmtId(rmElmtId);
        this.__value.purgeDependencyOnElmtId(rmElmtId);
        this.__description.purgeDependencyOnElmtId(rmElmtId);
        this.__status.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__title.aboutToBeDeleted();
        this.__value.aboutToBeDeleted();
        this.__description.aboutToBeDeleted();
        this.__status.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __title: SynchedPropertySimpleOneWayPU<string>;
    get title() {
        return this.__title.get();
    }
    set title(newValue: string) {
        this.__title.set(newValue);
    }
    private __value: SynchedPropertySimpleOneWayPU<string>;
    get value() {
        return this.__value.get();
    }
    set value(newValue: string) {
        this.__value.set(newValue);
    }
    private __description: SynchedPropertySimpleOneWayPU<string>;
    get description() {
        return this.__description.get();
    }
    set description(newValue: string) {
        this.__description.set(newValue);
    }
    private __status: SynchedPropertySimpleOneWayPU<string>;
    get status() {
        return this.__status.get();
    }
    set status(newValue: string) {
        this.__status.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/components/Card.ets(9:5)", "entry");
            Column.width('100%');
            Column.padding(16);
            Column.backgroundColor('#FFFFFF');
            Column.borderRadius(8);
            Column.margin({ bottom: 12 });
            Column.border({ width: 1, color: '#f0f0f0' });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/components/Card.ets(10:7)", "entry");
            Row.margin({ bottom: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.title);
            Text.debugLine("entry/src/main/ets/components/Card.ets(11:9)", "entry");
            Text.fontSize(16);
            Text.fontWeight('bold');
            Text.fontColor('#333333');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/components/Card.ets(15:9)", "entry");
            Blank.layoutWeight(1);
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.status);
            Text.debugLine("entry/src/main/ets/components/Card.ets(16:9)", "entry");
            Text.fontSize(14);
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.value);
            Text.debugLine("entry/src/main/ets/components/Card.ets(22:7)", "entry");
            Text.fontSize(20);
            Text.fontWeight('bold');
            Text.fontColor('#333333');
            Text.margin({ bottom: 4 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.description);
            Text.debugLine("entry/src/main/ets/components/Card.ets(28:7)", "entry");
            Text.fontSize(14);
            Text.fontColor('#666666');
        }, Text);
        Text.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
export class IconCard extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__icon = new SynchedPropertySimpleOneWayPU(params.icon, this, "icon");
        this.__iconColor = new SynchedPropertySimpleOneWayPU(params.iconColor, this, "iconColor");
        this.__iconBackgroundColor = new SynchedPropertySimpleOneWayPU(params.iconBackgroundColor, this, "iconBackgroundColor");
        this.__title = new SynchedPropertySimpleOneWayPU(params.title, this, "title");
        this.__description = new SynchedPropertySimpleOneWayPU(params.description, this, "description");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: IconCard_Params) {
        if (params.icon === undefined) {
            this.__icon.set('');
        }
        if (params.iconColor === undefined) {
            this.__iconColor.set('');
        }
        if (params.iconBackgroundColor === undefined) {
            this.__iconBackgroundColor.set('');
        }
        if (params.title === undefined) {
            this.__title.set('');
        }
        if (params.description === undefined) {
            this.__description.set('');
        }
    }
    updateStateVars(params: IconCard_Params) {
        this.__icon.reset(params.icon);
        this.__iconColor.reset(params.iconColor);
        this.__iconBackgroundColor.reset(params.iconBackgroundColor);
        this.__title.reset(params.title);
        this.__description.reset(params.description);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__icon.purgeDependencyOnElmtId(rmElmtId);
        this.__iconColor.purgeDependencyOnElmtId(rmElmtId);
        this.__iconBackgroundColor.purgeDependencyOnElmtId(rmElmtId);
        this.__title.purgeDependencyOnElmtId(rmElmtId);
        this.__description.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__icon.aboutToBeDeleted();
        this.__iconColor.aboutToBeDeleted();
        this.__iconBackgroundColor.aboutToBeDeleted();
        this.__title.aboutToBeDeleted();
        this.__description.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __icon: SynchedPropertySimpleOneWayPU<string>;
    get icon() {
        return this.__icon.get();
    }
    set icon(newValue: string) {
        this.__icon.set(newValue);
    }
    private __iconColor: SynchedPropertySimpleOneWayPU<string>;
    get iconColor() {
        return this.__iconColor.get();
    }
    set iconColor(newValue: string) {
        this.__iconColor.set(newValue);
    }
    private __iconBackgroundColor: SynchedPropertySimpleOneWayPU<string>;
    get iconBackgroundColor() {
        return this.__iconBackgroundColor.get();
    }
    set iconBackgroundColor(newValue: string) {
        this.__iconBackgroundColor.set(newValue);
    }
    private __title: SynchedPropertySimpleOneWayPU<string>;
    get title() {
        return this.__title.get();
    }
    set title(newValue: string) {
        this.__title.set(newValue);
    }
    private __description: SynchedPropertySimpleOneWayPU<string>;
    get description() {
        return this.__description.get();
    }
    set description(newValue: string) {
        this.__description.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/components/Card.ets(50:5)", "entry");
            Column.width('100%');
            Column.padding(16);
            Column.backgroundColor('#FFFFFF');
            Column.borderRadius(8);
            Column.border({ width: 1, color: '#f0f0f0' });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/components/Card.ets(51:7)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/components/Card.ets(52:9)", "entry");
            Column.width(64);
            Column.height(64);
            Column.backgroundColor(this.iconBackgroundColor);
            Column.borderRadius(32);
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
            Column.margin({ right: 16 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.icon);
            Text.debugLine("entry/src/main/ets/components/Card.ets(53:11)", "entry");
            Text.fontSize(32);
            Text.fontColor(this.iconColor);
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/components/Card.ets(65:9)", "entry");
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.title);
            Text.debugLine("entry/src/main/ets/components/Card.ets(66:11)", "entry");
            Text.fontSize(18);
            Text.fontWeight('bold');
            Text.fontColor('#333333');
            Text.margin({ bottom: 4 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.description);
            Text.debugLine("entry/src/main/ets/components/Card.ets(71:11)", "entry");
            Text.fontSize(14);
            Text.fontColor('#666666');
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
