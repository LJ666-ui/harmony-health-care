if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface ScienceListPage_Params {
    articles?: ScienceArticle[];
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
export interface ScienceArticle {
    id: string;
    title: string;
    coverIcon: string;
    summary: string;
    publishTime: string;
    category: string;
    readCount: string;
}
class ScienceListPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__articles = new ObservedPropertyObjectPU([
            {
                id: '1',
                title: '高血压患者的日常饮食指南',
                coverIcon: '🩺',
                summary: '科学合理的饮食是控制血压的重要手段，本文详细介绍高血压患者应遵循的饮食原则和注意事项。',
                publishTime: '2026-04-08',
                category: '心血管健康',
                readCount: '3.2k'
            },
            {
                id: '2',
                title: '颈椎病预防与康复锻炼方法',
                coverIcon: '🦴',
                summary: '长期伏案工作容易导致颈椎问题，学习正确的坐姿和颈部锻炼方法，有效预防和缓解颈椎病。',
                publishTime: '2026-04-07',
                category: '骨科康复',
                readCount: '2.8k'
            },
            {
                id: '3',
                title: '糖尿病患者的运动处方',
                coverIcon: '🏃',
                summary: '适度运动对糖尿病患者血糖控制有显著帮助，了解适合的运动类型、强度和时间安排。',
                publishTime: '2026-04-05',
                category: '内分泌',
                readCount: '4.1k'
            },
            {
                id: '4',
                title: '老年人跌倒风险评估与预防',
                coverIcon: '🧓',
                summary: '老年人跌倒是常见的意外伤害，掌握风险评估方法和预防措施，保护家人安全。',
                publishTime: '2026-04-03',
                category: '老年医学',
                readCount: '1.9k'
            },
            {
                id: '5',
                title: '心理健康：焦虑与抑郁的自我调节',
                coverIcon: '🧠',
                summary: '现代生活压力下，心理问题日益普遍。学会识别情绪信号，掌握科学的自我调节方法。',
                publishTime: '2026-04-01',
                category: '心理健康',
                readCount: '5.6k'
            },
            {
                id: '6',
                title: '春季过敏防治全攻略',
                coverIcon: '🌸',
                summary: '花粉、柳絮等过敏原在春季活跃，了解过敏症状识别、预防措施及合理用药建议。',
                publishTime: '2026-03-28',
                category: '过敏防治',
                readCount: '2.3k'
            }
        ], this, "articles");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: ScienceListPage_Params) {
        if (params.articles !== undefined) {
            this.articles = params.articles;
        }
    }
    updateStateVars(params: ScienceListPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__articles.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__articles.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __articles: ObservedPropertyObjectPU<ScienceArticle[]>;
    get articles() {
        return this.__articles.get();
    }
    set articles(newValue: ScienceArticle[]) {
        this.__articles.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(76:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '健康科普', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/ScienceListPage.ets", line: 77, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '健康科普',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '健康科普', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(79:7)", "entry");
            Scroll.flexGrow(1);
            Scroll.scrollBar(BarState.Off);
            Scroll.align(Alignment.Top);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 14 });
            Column.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(80:9)", "entry");
            Column.width('85%');
            Column.padding({ bottom: 24 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('健康科普');
            Text.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(81:11)", "entry");
            Text.fontSize(22);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 16, bottom: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create({ space: 12 });
            List.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(87:11)", "entry");
            List.width('100%');
            List.layoutWeight(1);
        }, List);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const article = _item;
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
                        ListItem.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(89:15)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create();
                            Column.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(90:17)", "entry");
                            Column.width('100%');
                            Column.padding(16);
                            Column.backgroundColor('#FFFFFF');
                            Column.borderRadius(12);
                            Column.border({ width: 1, color: '#F0F0F0' });
                            Column.shadow({
                                radius: 8,
                                color: '#00000008',
                                offsetX: 0,
                                offsetY: 3
                            });
                            Column.onClick(() => {
                                router.pushUrl({
                                    url: 'pages/ScienceDetailPage',
                                    params: { articleId: article.id }
                                });
                            });
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create({ space: 14 });
                            Row.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(91:19)", "entry");
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create();
                            Column.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(92:21)", "entry");
                            Column.width(72);
                            Column.height(72);
                            Column.backgroundColor('#F0F5FF');
                            Column.borderRadius(12);
                            Column.justifyContent(FlexAlign.Center);
                            Column.alignItems(HorizontalAlign.Center);
                            Column.flexShrink(0);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(article.coverIcon);
                            Text.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(93:23)", "entry");
                            Text.fontSize(40);
                        }, Text);
                        Text.pop();
                        Column.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create({ space: 6 });
                            Column.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(104:21)", "entry");
                            Column.layoutWeight(1);
                            Column.alignItems(HorizontalAlign.Start);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(article.title);
                            Text.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(105:23)", "entry");
                            Text.fontSize(16);
                            Text.fontWeight('bold');
                            Text.fontColor('#333333');
                            Text.maxLines(2);
                            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(article.summary);
                            Text.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(112:23)", "entry");
                            Text.fontSize(13);
                            Text.fontColor('#888888');
                            Text.maxLines(2);
                            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create({ space: 12 });
                            Row.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(118:23)", "entry");
                            Row.width('100%');
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(article.category);
                            Text.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(119:25)", "entry");
                            Text.fontSize(11);
                            Text.fontColor('#1677FF');
                            Text.backgroundColor('#1677FF10');
                            Text.padding({ left: 8, right: 8, top: 2, bottom: 2 });
                            Text.borderRadius(4);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(`👁 ${article.readCount}`);
                            Text.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(126:25)", "entry");
                            Text.fontSize(11);
                            Text.fontColor('#999999');
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Blank.create();
                            Blank.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(130:25)", "entry");
                        }, Blank);
                        Blank.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(article.publishTime);
                            Text.debugLine("entry/src/main/ets/pages/ScienceListPage.ets(132:25)", "entry");
                            Text.fontSize(11);
                            Text.fontColor('#BBBBBB');
                        }, Text);
                        Text.pop();
                        Row.pop();
                        Column.pop();
                        Row.pop();
                        Column.pop();
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.articles, forEachItemGenFunction, (article: ScienceArticle) => article.id, false, false);
        }, ForEach);
        ForEach.pop();
        List.pop();
        Column.pop();
        Scroll.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 3 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/ScienceListPage.ets", line: 172, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            activeIndex: 3
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        activeIndex: 3
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
        return "ScienceListPage";
    }
}
registerNamedRoute(() => new ScienceListPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/ScienceListPage", pageFullPath: "entry/src/main/ets/pages/ScienceListPage", integratedHsp: "false", moduleType: "followWithHap" });
