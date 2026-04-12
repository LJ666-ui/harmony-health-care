if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface HospitalPage_Params {
    hospitals?: Hospital[];
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
import { Card } from "@normalized:N&&&entry/src/main/ets/components/Card&";
import type { Hospital } from '../models/HealthData';
class HospitalPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__hospitals = new ObservedPropertyObjectPU([
            {
                id: '1',
                name: '星云综合医院',
                address: '北京市海淀区中关村大街1号',
                phone: '010-88888888',
                departments: ['内科', '外科', '骨科', '康复科'],
                rating: 4.8,
                distance: 2.5
            },
            {
                id: '2',
                name: '协和医疗中心',
                address: '北京市朝阳区建国路88号',
                phone: '010-66666666',
                departments: ['内科', '外科', '老年病科', '骨科'],
                rating: 4.9,
                distance: 3.2
            },
            {
                id: '3',
                name: '仁爱专科医院',
                address: '北京市西城区金融街15号',
                phone: '010-55555555',
                departments: ['内科', '康复科', '老年病科'],
                rating: 4.6,
                distance: 1.8
            },
            {
                id: '4',
                name: '康宁中医医院',
                address: '北京市东城区王府井大街20号',
                phone: '010-44444444',
                departments: ['内科', '康复科', '骨科'],
                rating: 4.7,
                distance: 4.0
            },
            {
                id: '5',
                name: '博爱国际医院',
                address: '北京市丰台区科技园路50号',
                phone: '010-33333333',
                departments: ['内科', '外科', '骨科', '老年病科', '康复科'],
                rating: 4.5,
                distance: 5.5
            },
            {
                id: '6',
                name: '安泰社区医院',
                address: '北京市石景山区古城路8号',
                phone: '010-22222222',
                departments: ['内科', '康复科'],
                rating: 4.3,
                distance: 0.8
            }
        ], this, "hospitals");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: HospitalPage_Params) {
        if (params.hospitals !== undefined) {
            this.hospitals = params.hospitals;
        }
    }
    updateStateVars(params: HospitalPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__hospitals.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__hospitals.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __hospitals: ObservedPropertyObjectPU<Hospital[]>;
    get hospitals() {
        return this.__hospitals.get();
    }
    set hospitals(newValue: Hospital[]) {
        this.__hospitals.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/HospitalPage.ets(68:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '医院列表', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/HospitalPage.ets", line: 69, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '医院列表',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '医院列表', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/pages/HospitalPage.ets(71:7)", "entry");
            Column.flexGrow(1);
            Column.width('80%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('医院列表');
            Text.debugLine("entry/src/main/ets/pages/HospitalPage.ets(72:9)", "entry");
            Text.fontSize(24);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 20, bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create();
            List.debugLine("entry/src/main/ets/pages/HospitalPage.ets(78:9)", "entry");
            List.width('100%');
            List.height('70%');
            List.borderRadius(8);
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
                        ListItem.debugLine("entry/src/main/ets/pages/HospitalPage.ets(80:13)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            __Common__.create();
                            __Common__.onClick(() => {
                                router.pushUrl({ url: 'pages/DepartmentPage' });
                            });
                        }, __Common__);
                        {
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                if (isInitialRender) {
                                    let componentCall = new Card(this, {
                                        title: item.name,
                                        value: item.distance + 'km | ⭐' + item.rating.toFixed(1) + '分',
                                        description: item.address,
                                        status: '查看科室'
                                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/HospitalPage.ets", line: 81, col: 15 });
                                    ViewPU.create(componentCall);
                                    let paramsLambda = () => {
                                        return {
                                            title: item.name,
                                            value: item.distance + 'km | ⭐' + item.rating.toFixed(1) + '分',
                                            description: item.address,
                                            status: '查看科室'
                                        };
                                    };
                                    componentCall.paramsGenerator_ = paramsLambda;
                                }
                                else {
                                    this.updateStateVarsOfChildByElmtId(elmtId, {
                                        title: item.name,
                                        value: item.distance + 'km | ⭐' + item.rating.toFixed(1) + '分',
                                        description: item.address,
                                        status: '查看科室'
                                    });
                                }
                            }, { name: "Card" });
                        }
                        __Common__.pop();
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.hospitals, forEachItemGenFunction, (item: Hospital) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        List.pop();
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 1 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/HospitalPage.ets", line: 102, col: 7 });
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
        return "HospitalPage";
    }
}
registerNamedRoute(() => new HospitalPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/HospitalPage", pageFullPath: "entry/src/main/ets/pages/HospitalPage", integratedHsp: "false", moduleType: "followWithHap" });
