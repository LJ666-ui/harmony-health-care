if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface DepartmentPage_Params {
    departments?: string[];
    selectedDept?: number;
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
class DepartmentPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__departments = new ObservedPropertyObjectPU(['内科', '外科', '老年病科', '骨科', '康复科'], this, "departments");
        this.__selectedDept = new ObservedPropertySimplePU(-1, this, "selectedDept");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: DepartmentPage_Params) {
        if (params.departments !== undefined) {
            this.departments = params.departments;
        }
        if (params.selectedDept !== undefined) {
            this.selectedDept = params.selectedDept;
        }
    }
    updateStateVars(params: DepartmentPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__departments.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedDept.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__departments.aboutToBeDeleted();
        this.__selectedDept.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __departments: ObservedPropertyObjectPU<string[]>;
    get departments() {
        return this.__departments.get();
    }
    set departments(newValue: string[]) {
        this.__departments.set(newValue);
    }
    private __selectedDept: ObservedPropertySimplePU<number>;
    get selectedDept() {
        return this.__selectedDept.get();
    }
    set selectedDept(newValue: number) {
        this.__selectedDept.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(12:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '科室选择', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/DepartmentPage.ets", line: 13, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '科室选择',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '科室选择', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(15:7)", "entry");
            Column.flexGrow(1);
            Column.width('80%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('选择科室');
            Text.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(16:9)", "entry");
            Text.fontSize(24);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 20, bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = (_item, index: number) => {
                const item = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Row.create();
                    Row.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(23:11)", "entry");
                    Row.width('100%');
                    Row.padding(16);
                    Row.backgroundColor(this.selectedDept === index ? '#E6F4FF' : '#FFFFFF');
                    Row.borderRadius(8);
                    Row.border({ width: 1, color: this.selectedDept === index ? '#1677FF' : '#f0f0f0' });
                    Row.onClick(() => {
                        this.selectedDept = index;
                        router.pushUrl({ url: 'pages/Appointments' });
                    });
                }, Row);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(24:13)", "entry");
                    Column.width(56);
                    Column.height(56);
                    Column.backgroundColor(this.selectedDept === index ? '#1677FF' : '#1677FF20');
                    Column.borderRadius(28);
                    Column.justifyContent(FlexAlign.Center);
                    Column.alignItems(HorizontalAlign.Center);
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(item);
                    Text.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(25:15)", "entry");
                    Text.fontSize(18);
                    Text.fontWeight('bold');
                    Text.fontColor(this.selectedDept === index ? '#FFFFFF' : '#1677FF');
                }, Text);
                Text.pop();
                Column.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(37:13)", "entry");
                    Column.layoutWeight(1);
                    Column.alignItems(HorizontalAlign.Start);
                    Column.margin({ left: 16 });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(item);
                    Text.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(38:15)", "entry");
                    Text.fontSize(16);
                    Text.fontWeight('bold');
                    Text.fontColor('#333333');
                    Text.margin({ bottom: 4 });
                }, Text);
                Text.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('点击进入' + item + '预约管理');
                    Text.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(43:15)", "entry");
                    Text.fontSize(13);
                    Text.fontColor('#666666');
                }, Text);
                Text.pop();
                Column.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('›');
                    Text.debugLine("entry/src/main/ets/pages/DepartmentPage.ets(51:13)", "entry");
                    Text.fontSize(22);
                    Text.fontColor('#999999');
                }, Text);
                Text.pop();
                Row.pop();
            };
            this.forEachUpdateFunction(elmtId, this.departments, forEachItemGenFunction, (item: string, index: number) => item + '_' + index.toString(), true, true);
        }, ForEach);
        ForEach.pop();
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 1 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/DepartmentPage.ets", line: 71, col: 7 });
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
        return "DepartmentPage";
    }
}
registerNamedRoute(() => new DepartmentPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/DepartmentPage", pageFullPath: "entry/src/main/ets/pages/DepartmentPage", integratedHsp: "false", moduleType: "followWithHap" });
