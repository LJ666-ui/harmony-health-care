if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface AddAppointmentPage_Params {
    selectedHospital?: string;
    selectedDepartment?: string;
    selectedDate?: string;
    selectedTime?: string;
    hospitals?: string[];
    departments?: string[];
    dates?: string[];
    times?: string[];
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
class AddAppointmentPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__selectedHospital = new ObservedPropertySimplePU('星云综合医院', this, "selectedHospital");
        this.__selectedDepartment = new ObservedPropertySimplePU('内科', this, "selectedDepartment");
        this.__selectedDate = new ObservedPropertySimplePU('', this, "selectedDate");
        this.__selectedTime = new ObservedPropertySimplePU('', this, "selectedTime");
        this.hospitals = ['星云综合医院', '协和医疗中心', '仁爱专科医院', '康宁中医医院'];
        this.departments = ['内科', '外科', '骨科', '康复科', '老年病科'];
        this.dates = [];
        this.times = ['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '14:00', '14:30', '15:00', '15:30'];
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: AddAppointmentPage_Params) {
        if (params.selectedHospital !== undefined) {
            this.selectedHospital = params.selectedHospital;
        }
        if (params.selectedDepartment !== undefined) {
            this.selectedDepartment = params.selectedDepartment;
        }
        if (params.selectedDate !== undefined) {
            this.selectedDate = params.selectedDate;
        }
        if (params.selectedTime !== undefined) {
            this.selectedTime = params.selectedTime;
        }
        if (params.hospitals !== undefined) {
            this.hospitals = params.hospitals;
        }
        if (params.departments !== undefined) {
            this.departments = params.departments;
        }
        if (params.dates !== undefined) {
            this.dates = params.dates;
        }
        if (params.times !== undefined) {
            this.times = params.times;
        }
    }
    updateStateVars(params: AddAppointmentPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__selectedHospital.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedDepartment.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedDate.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedTime.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__selectedHospital.aboutToBeDeleted();
        this.__selectedDepartment.aboutToBeDeleted();
        this.__selectedDate.aboutToBeDeleted();
        this.__selectedTime.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __selectedHospital: ObservedPropertySimplePU<string>;
    get selectedHospital() {
        return this.__selectedHospital.get();
    }
    set selectedHospital(newValue: string) {
        this.__selectedHospital.set(newValue);
    }
    private __selectedDepartment: ObservedPropertySimplePU<string>;
    get selectedDepartment() {
        return this.__selectedDepartment.get();
    }
    set selectedDepartment(newValue: string) {
        this.__selectedDepartment.set(newValue);
    }
    private __selectedDate: ObservedPropertySimplePU<string>;
    get selectedDate() {
        return this.__selectedDate.get();
    }
    set selectedDate(newValue: string) {
        this.__selectedDate.set(newValue);
    }
    private __selectedTime: ObservedPropertySimplePU<string>;
    get selectedTime() {
        return this.__selectedTime.get();
    }
    set selectedTime(newValue: string) {
        this.__selectedTime.set(newValue);
    }
    private hospitals: string[];
    private departments: string[];
    private dates: string[];
    private times: string[];
    aboutToAppear(): void {
        const today = new Date();
        for (let i = 0; i < 7; i++) {
            const date = new Date(today);
            date.setDate(today.getDate() + i);
            this.dates.push(`${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`);
        }
        if (this.dates.length > 0) {
            this.selectedDate = this.dates[0];
        }
        this.selectedTime = this.times[0];
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(32:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '新增预约', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/AddAppointmentPage.ets", line: 33, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '新增预约',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '新增预约', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(35:7)", "entry");
            Scroll.flexGrow(1);
            Scroll.scrollBar(BarState.Off);
            Scroll.align(Alignment.Top);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 20 });
            Column.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(36:9)", "entry");
            Column.width('85%');
            Column.padding({ bottom: 24 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('填写预约信息');
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(37:11)", "entry");
            Text.fontSize(20);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 16, bottom: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 12 });
            Column.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(43:11)", "entry");
            Column.width('100%');
            Column.padding(16);
            Column.backgroundColor('#FFFFFF');
            Column.borderRadius(12);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('选择医院');
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(44:13)", "entry");
            Text.fontSize(16);
            Text.fontColor('#333333');
            Text.alignSelf(ItemAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(49:13)", "entry");
            Row.width('100%');
            Row.height(48);
            Row.padding({ left: 16, right: 16 });
            Row.backgroundColor('#FFFFFF');
            Row.borderRadius(8);
            Row.border({ width: 1, color: '#e0e0e0' });
            Row.justifyContent(FlexAlign.Center);
            Row.onClick(() => {
                this.selectedHospital = this.hospitals[(this.hospitals.indexOf(this.selectedHospital) + 1) % this.hospitals.length];
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.selectedHospital);
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(50:15)", "entry");
            Text.fontSize(15);
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(53:15)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('▼');
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(54:15)", "entry");
            Text.fontSize(12);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('选择科室');
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(69:13)", "entry");
            Text.fontSize(16);
            Text.fontColor('#333333');
            Text.alignSelf(ItemAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(74:13)", "entry");
            Row.width('100%');
            Row.height(48);
            Row.padding({ left: 16, right: 16 });
            Row.backgroundColor('#FFFFFF');
            Row.borderRadius(8);
            Row.border({ width: 1, color: '#e0e0e0' });
            Row.justifyContent(FlexAlign.Center);
            Row.onClick(() => {
                this.selectedDepartment = this.departments[(this.departments.indexOf(this.selectedDepartment) + 1) % this.departments.length];
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.selectedDepartment);
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(75:15)", "entry");
            Text.fontSize(15);
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(78:15)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('▼');
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(79:15)", "entry");
            Text.fontSize(12);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('选择日期');
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(94:13)", "entry");
            Text.fontSize(16);
            Text.fontColor('#333333');
            Text.alignSelf(ItemAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(99:13)", "entry");
            Row.width('100%');
            Row.height(48);
            Row.padding({ left: 16, right: 16 });
            Row.backgroundColor('#FFFFFF');
            Row.borderRadius(8);
            Row.border({ width: 1, color: '#e0e0e0' });
            Row.justifyContent(FlexAlign.Center);
            Row.onClick(() => {
                this.selectedDate = this.dates[(this.dates.indexOf(this.selectedDate) + 1) % this.dates.length];
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.selectedDate);
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(100:15)", "entry");
            Text.fontSize(15);
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(103:15)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('▼');
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(104:15)", "entry");
            Text.fontSize(12);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('选择时间');
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(119:13)", "entry");
            Text.fontSize(16);
            Text.fontColor('#333333');
            Text.alignSelf(ItemAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(124:13)", "entry");
            Row.width('100%');
            Row.height(48);
            Row.padding({ left: 16, right: 16 });
            Row.backgroundColor('#FFFFFF');
            Row.borderRadius(8);
            Row.border({ width: 1, color: '#e0e0e0' });
            Row.justifyContent(FlexAlign.Center);
            Row.onClick(() => {
                this.selectedTime = this.times[(this.times.indexOf(this.selectedTime) + 1) % this.times.length];
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.selectedTime);
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(125:15)", "entry");
            Text.fontSize(15);
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(128:15)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('▼');
            Text.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(129:15)", "entry");
            Text.fontSize(12);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('提交预约');
            Button.debugLine("entry/src/main/ets/pages/AddAppointmentPage.ets(149:11)", "entry");
            Button.width('100%');
            Button.height(48);
            Button.fontSize(16);
            Button.fontColor('#FFFFFF');
            Button.backgroundColor('#1677FF');
            Button.borderRadius(8);
            Button.onClick(() => {
                router.back();
            });
        }, Button);
        Button.pop();
        Column.pop();
        Scroll.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 0 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/AddAppointmentPage.ets", line: 167, col: 7 });
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
        return "AddAppointmentPage";
    }
}
registerNamedRoute(() => new AddAppointmentPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/AddAppointmentPage", pageFullPath: "entry/src/main/ets/pages/AddAppointmentPage", integratedHsp: "false", moduleType: "followWithHap" });
