if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Medications_Params {
    medications?: Medication[];
}
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
import { Card } from "@normalized:N&&&entry/src/main/ets/components/Card&";
import type { Medication } from '../models/HealthData';
class Medications extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__medications = new ObservedPropertyObjectPU([
            {
                id: '1',
                name: '阿莫西林',
                dosage: '500mg',
                frequency: '每日3次',
                times: ['08:00', '12:00', '20:00'],
                status: 'pending',
                reminder: true,
                startDate: '2024-01-15',
                notes: '',
                color: '#1677FF',
                icon: '',
                createdAt: 0,
                updatedAt: 0
            },
            {
                id: '2',
                name: '布洛芬',
                dosage: '200mg',
                frequency: '每日2次',
                times: ['08:00', '20:00'],
                status: 'pending',
                reminder: true,
                startDate: '2024-01-15',
                notes: '',
                color: '#1677FF',
                icon: '',
                createdAt: 0,
                updatedAt: 0
            }
        ], this, "medications");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Medications_Params) {
        if (params.medications !== undefined) {
            this.medications = params.medications;
        }
    }
    updateStateVars(params: Medications_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__medications.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__medications.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __medications: ObservedPropertyObjectPU<Medication[]>;
    get medications() {
        return this.__medications.get();
    }
    set medications(newValue: Medication[]) {
        this.__medications.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Medications.ets(44:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '用药管理', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Medications.ets", line: 45, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '用药管理',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '用药管理', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/pages/Medications.ets(47:7)", "entry");
            Column.flexGrow(1);
            Column.width('80%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('用药管理');
            Text.debugLine("entry/src/main/ets/pages/Medications.ets(48:9)", "entry");
            Text.fontSize(24);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 20, bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create();
            List.debugLine("entry/src/main/ets/pages/Medications.ets(54:9)", "entry");
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
                        ListItem.debugLine("entry/src/main/ets/pages/Medications.ets(56:13)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        {
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                if (isInitialRender) {
                                    let componentCall = new Card(this, {
                                        title: item.name,
                                        value: item.dosage + ' - ' + item.frequency,
                                        description: item.times.join(', '),
                                        status: item.status === 'taken' ? '已服用' : '待服用'
                                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Medications.ets", line: 57, col: 15 });
                                    ViewPU.create(componentCall);
                                    let paramsLambda = () => {
                                        return {
                                            title: item.name,
                                            value: item.dosage + ' - ' + item.frequency,
                                            description: item.times.join(', '),
                                            status: item.status === 'taken' ? '已服用' : '待服用'
                                        };
                                    };
                                    componentCall.paramsGenerator_ = paramsLambda;
                                }
                                else {
                                    this.updateStateVarsOfChildByElmtId(elmtId, {
                                        title: item.name,
                                        value: item.dosage + ' - ' + item.frequency,
                                        description: item.times.join(', '),
                                        status: item.status === 'taken' ? '已服用' : '待服用'
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
            this.forEachUpdateFunction(elmtId, this.medications, forEachItemGenFunction, (item: Medication) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        List.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('添加药物');
            Button.debugLine("entry/src/main/ets/pages/Medications.ets(69:9)", "entry");
            Button.width('100%');
            Button.height(48);
            Button.fontSize(16);
            Button.fontColor('#FFFFFF');
            Button.backgroundColor('#1677FF');
            Button.borderRadius(8);
            Button.margin({ top: 16 });
            Button.onClick(() => {
                console.log('添加药物');
            });
        }, Button);
        Button.pop();
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 0 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Medications.ets", line: 86, col: 7 });
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
        return "Medications";
    }
}
registerNamedRoute(() => new Medications(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/Medications", pageFullPath: "entry/src/main/ets/pages/Medications", integratedHsp: "false", moduleType: "followWithHap" });
