if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Header_Params {
    title?: string;
    showBack?: boolean;
}
import router from "@ohos:router";
export class Header extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__title = new SynchedPropertySimpleOneWayPU(params.title, this, "title");
        this.__showBack = new SynchedPropertySimpleOneWayPU(params.showBack, this, "showBack");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Header_Params) {
        if (params.title === undefined) {
            this.__title.set('');
        }
        if (params.showBack === undefined) {
            this.__showBack.set(false);
        }
    }
    updateStateVars(params: Header_Params) {
        this.__title.reset(params.title);
        this.__showBack.reset(params.showBack);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__title.purgeDependencyOnElmtId(rmElmtId);
        this.__showBack.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__title.aboutToBeDeleted();
        this.__showBack.aboutToBeDeleted();
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
    private __showBack: SynchedPropertySimpleOneWayPU<boolean>;
    get showBack() {
        return this.__showBack.get();
    }
    set showBack(newValue: boolean) {
        this.__showBack.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/components/Header.ets(9:5)", "entry");
            Row.width('100%');
            Row.height(56);
            Row.backgroundColor('#FFFFFF');
            Row.justifyContent(FlexAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.showBack) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('←');
                        Text.debugLine("entry/src/main/ets/components/Header.ets(11:9)", "entry");
                        Text.fontSize(24);
                        Text.fontColor('#1677FF');
                        Text.margin({ left: 16 });
                        Text.onClick(() => {
                            router.back();
                        });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                        Blank.debugLine("entry/src/main/ets/components/Header.ets(19:9)", "entry");
                        Blank.width(40);
                    }, Blank);
                    Blank.pop();
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.title);
            Text.debugLine("entry/src/main/ets/components/Header.ets(22:7)", "entry");
            Text.fontSize(18);
            Text.fontWeight('bold');
            Text.fontColor('#333333');
            Text.layoutWeight(1);
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/components/Header.ets(29:7)", "entry");
            Blank.width(40);
        }, Blank);
        Blank.pop();
        Row.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
