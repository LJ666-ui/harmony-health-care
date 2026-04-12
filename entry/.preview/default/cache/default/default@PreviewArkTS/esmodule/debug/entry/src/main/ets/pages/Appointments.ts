if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Appointments_Params {
    appointments?: Appointment[];
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
import { Card } from "@normalized:N&&&entry/src/main/ets/components/Card&";
import type { Appointment } from '../models/HealthData';
class Appointments extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__appointments = new ObservedPropertyObjectPU([
            {
                id: '1',
                doctor: '张医生',
                specialty: '内科',
                hospital: '星云医院',
                date: '2024-01-20',
                time: '09:00',
                status: 'confirmed',
                location: '门诊楼3层',
                notes: '',
                avatarColor: '#1677FF',
                createdAt: 0,
                updatedAt: 0
            },
            {
                id: '2',
                doctor: '李医生',
                specialty: '外科',
                hospital: '星云医院',
                date: '2024-01-25',
                time: '14:30',
                status: 'confirmed',
                location: '门诊楼5层',
                notes: '',
                avatarColor: '#1677FF',
                createdAt: 0,
                updatedAt: 0
            }
        ], this, "appointments");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Appointments_Params) {
        if (params.appointments !== undefined) {
            this.appointments = params.appointments;
        }
    }
    updateStateVars(params: Appointments_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__appointments.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__appointments.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __appointments: ObservedPropertyObjectPU<Appointment[]>;
    get appointments() {
        return this.__appointments.get();
    }
    set appointments(newValue: Appointment[]) {
        this.__appointments.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Appointments.ets(42:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '预约管理', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Appointments.ets", line: 43, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '预约管理',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '预约管理', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/pages/Appointments.ets(45:7)", "entry");
            Column.flexGrow(1);
            Column.width('80%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('预约管理');
            Text.debugLine("entry/src/main/ets/pages/Appointments.ets(46:9)", "entry");
            Text.fontSize(24);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 20, bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create();
            List.debugLine("entry/src/main/ets/pages/Appointments.ets(52:9)", "entry");
            List.width('100%');
            List.height('70%');
        }, List);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const item = _item;
                {
                    const itemCreation = (elmtId, isInitialRender) => {
                        ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                        ListItem.create(deepRenderFunction, true);
                        if (!isInitialRender) {
                            ListItem.pop();
                        }
                        ViewStackProcessor.StopGetAccessRecording();
                    };
                    const itemCreation2 = (elmtId, isInitialRender) => {
                        ListItem.create(deepRenderFunction, true);
                        ListItem.debugLine("entry/src/main/ets/pages/Appointments.ets(54:13)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        {
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                if (isInitialRender) {
                                    let componentCall = new Card(this, {
                                        title: item.hospital,
                                        value: item.specialty,
                                        description: item.date + ' ' + item.time,
                                        status: item.status === 'confirmed' ? '已预约' : '待确认'
                                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Appointments.ets", line: 55, col: 15 });
                                    ViewPU.create(componentCall);
                                    let paramsLambda = () => {
                                        return {
                                            title: item.hospital,
                                            value: item.specialty,
                                            description: item.date + ' ' + item.time,
                                            status: item.status === 'confirmed' ? '已预约' : '待确认'
                                        };
                                    };
                                    componentCall.paramsGenerator_ = paramsLambda;
                                }
                                else {
                                    this.updateStateVarsOfChildByElmtId(elmtId, {
                                        title: item.hospital,
                                        value: item.specialty,
                                        description: item.date + ' ' + item.time,
                                        status: item.status === 'confirmed' ? '已预约' : '待确认'
                                    });
                                }
                            }, { name: "Card" });
                        }
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.appointments, forEachItemGenFunction, (item: Appointment) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        List.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('新增预约');
            Button.debugLine("entry/src/main/ets/pages/Appointments.ets(67:9)", "entry");
            Button.width('100%');
            Button.height(48);
            Button.fontSize(16);
            Button.fontColor('#FFFFFF');
            Button.backgroundColor('#1677FF');
            Button.borderRadius(8);
            Button.margin({ top: 16 });
            Button.onClick(() => {
                router.pushUrl({ url: 'pages/AddAppointmentPage' });
            });
        }, Button);
        Button.pop();
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 0 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Appointments.ets", line: 84, col: 7 });
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
        return "Appointments";
    }
}
registerNamedRoute(() => new Appointments(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/Appointments", pageFullPath: "entry/src/main/ets/pages/Appointments", integratedHsp: "false", moduleType: "followWithHap" });
