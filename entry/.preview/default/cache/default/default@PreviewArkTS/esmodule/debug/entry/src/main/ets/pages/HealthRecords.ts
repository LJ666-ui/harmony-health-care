if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface HealthRecords_Params {
    records?: HealthRecord[];
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
import { Card } from "@normalized:N&&&entry/src/main/ets/components/Card&";
import type { HealthRecord } from '../models/HealthData';
class HealthRecords extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__records = new ObservedPropertyObjectPU([
            {
                id: '1',
                type: '血压',
                value: '120/80',
                unit: 'mmHg',
                date: '2024-01-15',
                time: '08:30',
                notes: '',
                icon: '',
                color: '#1677FF',
                createdAt: 0,
                updatedAt: 0
            },
            {
                id: '2',
                type: '血糖',
                value: '5.6',
                unit: 'mmol/L',
                date: '2024-01-14',
                time: '07:00',
                notes: '',
                icon: '',
                color: '#1677FF',
                createdAt: 0,
                updatedAt: 0
            },
            {
                id: '3',
                type: '心率',
                value: '72',
                unit: '次/分',
                date: '2024-01-15',
                time: '09:00',
                notes: '',
                icon: '',
                color: '#1677FF',
                createdAt: 0,
                updatedAt: 0
            },
            {
                id: '4',
                type: '体重',
                value: '65',
                unit: 'kg',
                date: '2024-01-13',
                time: '06:30',
                notes: '',
                icon: '',
                color: '#1677FF',
                createdAt: 0,
                updatedAt: 0
            }
        ], this, "records");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: HealthRecords_Params) {
        if (params.records !== undefined) {
            this.records = params.records;
        }
    }
    updateStateVars(params: HealthRecords_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__records.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__records.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __records: ObservedPropertyObjectPU<HealthRecord[]>;
    get records() {
        return this.__records.get();
    }
    set records(newValue: HealthRecord[]) {
        this.__records.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/HealthRecords.ets(66:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '健康记录', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/HealthRecords.ets", line: 67, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '健康记录',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '健康记录', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/HealthRecords.ets(69:7)", "entry");
            Scroll.flexGrow(1);
            Scroll.scrollBar(BarState.Off);
            Scroll.align(Alignment.Top);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/pages/HealthRecords.ets(70:9)", "entry");
            Column.width('85%');
            Column.padding({ top: 20, bottom: 24 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('健康记录');
            Text.debugLine("entry/src/main/ets/pages/HealthRecords.ets(71:11)", "entry");
            Text.fontSize(24);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 20, bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create({ space: 12 });
            List.debugLine("entry/src/main/ets/pages/HealthRecords.ets(77:11)", "entry");
            List.width('100%');
            List.layoutWeight(1);
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
                        ListItem.debugLine("entry/src/main/ets/pages/HealthRecords.ets(79:15)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        {
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                if (isInitialRender) {
                                    let componentCall = new Card(this, {
                                        title: item.type,
                                        value: item.value + item.unit,
                                        description: item.date + ' ' + item.time,
                                        status: '正常'
                                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/HealthRecords.ets", line: 80, col: 17 });
                                    ViewPU.create(componentCall);
                                    let paramsLambda = () => {
                                        return {
                                            title: item.type,
                                            value: item.value + item.unit,
                                            description: item.date + ' ' + item.time,
                                            status: '正常'
                                        };
                                    };
                                    componentCall.paramsGenerator_ = paramsLambda;
                                }
                                else {
                                    this.updateStateVarsOfChildByElmtId(elmtId, {
                                        title: item.type,
                                        value: item.value + item.unit,
                                        description: item.date + ' ' + item.time,
                                        status: '正常'
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
            this.forEachUpdateFunction(elmtId, this.records, forEachItemGenFunction, (item: HealthRecord) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        List.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('+ 添加记录');
            Button.debugLine("entry/src/main/ets/pages/HealthRecords.ets(92:11)", "entry");
            Button.width('100%');
            Button.height(50);
            Button.fontSize(17);
            Button.fontColor('#FFFFFF');
            Button.backgroundColor('#1677FF');
            Button.borderRadius(25);
            Button.onClick(() => {
                console.log('添加记录');
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('📊 健康风险评估');
            Button.debugLine("entry/src/main/ets/pages/HealthRecords.ets(103:11)", "entry");
            Button.width('100%');
            Button.height(50);
            Button.fontSize(17);
            Button.fontColor('#FFFFFF');
            Button.backgroundColor('#1677FF');
            Button.borderRadius(25);
            Button.margin({ top: 12 });
            Button.onClick(() => {
                router.pushUrl({ url: 'pages/RiskAssessmentPage' });
            });
        }, Button);
        Button.pop();
        Column.pop();
        Scroll.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 0 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/HealthRecords.ets", line: 122, col: 7 });
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
        return "HealthRecords";
    }
}
registerNamedRoute(() => new HealthRecords(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/HealthRecords", pageFullPath: "entry/src/main/ets/pages/HealthRecords", integratedHsp: "false", moduleType: "followWithHap" });
