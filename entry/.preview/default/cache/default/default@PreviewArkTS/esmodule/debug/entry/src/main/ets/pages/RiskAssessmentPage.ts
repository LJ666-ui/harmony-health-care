if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface RiskAssessmentPage_Params {
    riskItems?: RiskItem[];
    score?: number;
    scoreLevel?: string;
    scoreLevelColor?: string;
    showReportToast?: boolean;
}
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { RISK_INDICATORS, HEALTH_SCORE, SCORE_LEVEL, SCORE_LEVEL_COLOR } from "@normalized:N&&&entry/src/main/ets/mock/riskMock&";
interface RiskItem {
    id: string;
    name: string;
    icon: string;
    level: string;
    levelColor: string;
    progress: number;
    description: string;
}
class RiskAssessmentPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__riskItems = new ObservedPropertyObjectPU(RISK_INDICATORS as RiskItem[], this, "riskItems");
        this.__score = new ObservedPropertySimplePU(HEALTH_SCORE, this, "score");
        this.__scoreLevel = new ObservedPropertySimplePU(SCORE_LEVEL, this, "scoreLevel");
        this.__scoreLevelColor = new ObservedPropertySimplePU(SCORE_LEVEL_COLOR, this, "scoreLevelColor");
        this.__showReportToast = new ObservedPropertySimplePU(false, this, "showReportToast");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: RiskAssessmentPage_Params) {
        if (params.riskItems !== undefined) {
            this.riskItems = params.riskItems;
        }
        if (params.score !== undefined) {
            this.score = params.score;
        }
        if (params.scoreLevel !== undefined) {
            this.scoreLevel = params.scoreLevel;
        }
        if (params.scoreLevelColor !== undefined) {
            this.scoreLevelColor = params.scoreLevelColor;
        }
        if (params.showReportToast !== undefined) {
            this.showReportToast = params.showReportToast;
        }
    }
    updateStateVars(params: RiskAssessmentPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__riskItems.purgeDependencyOnElmtId(rmElmtId);
        this.__score.purgeDependencyOnElmtId(rmElmtId);
        this.__scoreLevel.purgeDependencyOnElmtId(rmElmtId);
        this.__scoreLevelColor.purgeDependencyOnElmtId(rmElmtId);
        this.__showReportToast.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__riskItems.aboutToBeDeleted();
        this.__score.aboutToBeDeleted();
        this.__scoreLevel.aboutToBeDeleted();
        this.__scoreLevelColor.aboutToBeDeleted();
        this.__showReportToast.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __riskItems: ObservedPropertyObjectPU<RiskItem[]>;
    get riskItems() {
        return this.__riskItems.get();
    }
    set riskItems(newValue: RiskItem[]) {
        this.__riskItems.set(newValue);
    }
    private __score: ObservedPropertySimplePU<number>;
    get score() {
        return this.__score.get();
    }
    set score(newValue: number) {
        this.__score.set(newValue);
    }
    private __scoreLevel: ObservedPropertySimplePU<string>;
    get scoreLevel() {
        return this.__scoreLevel.get();
    }
    set scoreLevel(newValue: string) {
        this.__scoreLevel.set(newValue);
    }
    private __scoreLevelColor: ObservedPropertySimplePU<string>;
    get scoreLevelColor() {
        return this.__scoreLevelColor.get();
    }
    set scoreLevelColor(newValue: string) {
        this.__scoreLevelColor.set(newValue);
    }
    private __showReportToast: ObservedPropertySimplePU<boolean>;
    get showReportToast() {
        return this.__showReportToast.get();
    }
    set showReportToast(newValue: boolean) {
        this.__showReportToast.set(newValue);
    }
    getLevelBgColor(levelColor: string): string {
        if (levelColor === '#52C41A') {
            return '#F6FFED';
        }
        if (levelColor === '#FAAD14') {
            return '#FFFBE6';
        }
        return '#FFF1F0';
    }
    handleGenerateReport(): void {
        this.showReportToast = true;
        setTimeout(() => {
            this.showReportToast = false;
        }, 2000);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(42:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '健康风险评估', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/RiskAssessmentPage.ets", line: 43, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '健康风险评估',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '健康风险评估', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(45:7)", "entry");
            Scroll.flexGrow(1);
            Scroll.scrollBar(BarState.Off);
            Scroll.align(Alignment.Top);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 20 });
            Column.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(46:9)", "entry");
            Column.width('85%');
            Column.padding({ top: 20, bottom: 40 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(47:11)", "entry");
            Column.width('100%');
            Column.padding(20);
            Column.backgroundColor('#FFFFFF');
            Column.borderRadius(16);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('综合健康评分');
            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(48:13)", "entry");
            Text.fontSize(22);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create({ alignContent: Alignment.Center });
            Stack.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(53:13)", "entry");
            Stack.width(200);
            Stack.height(200);
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Progress.create({
                value: this.score,
                total: 100,
                type: ProgressType.Ring
            });
            Progress.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(54:15)", "entry");
            Progress.width(180);
            Progress.height(180);
            Progress.color('#1677FF');
            Progress.backgroundColor('#F0F0F0');
            Progress.style({ strokeWidth: 12 });
        }, Progress);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 4 });
            Column.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(65:15)", "entry");
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.score.toString());
            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(66:17)", "entry");
            Text.fontSize(48);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.scoreLevel);
            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(71:17)", "entry");
            Text.fontSize(18);
            Text.fontColor(this.scoreLevelColor);
            Text.fontWeight('bold');
        }, Text);
        Text.pop();
        Column.pop();
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('基于您的健康记录数据综合评估');
            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(82:13)", "entry");
            Text.fontSize(13);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 12 });
            Column.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(92:11)", "entry");
            Column.width('100%');
            Column.padding(16);
            Column.backgroundColor('#FFFFFF');
            Column.borderRadius(16);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(93:13)", "entry");
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('风险指标详情');
            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(94:15)", "entry");
            Text.fontSize(20);
            Text.fontWeight('bold');
            Text.fontColor('#333333');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(99:15)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.riskItems.length + ' 项指标');
            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(101:15)", "entry");
            Text.fontSize(13);
            Text.fontColor('#999999');
            Text.backgroundColor('#F5F5F5');
            Text.padding({ left: 10, right: 10, top: 4, bottom: 4 });
            Text.borderRadius(10);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create({ space: 12 });
            List.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(110:13)", "entry");
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
                        ListItem.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(112:17)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create({ space: 12 });
                            Column.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(113:19)", "entry");
                            Column.width('100%');
                            Column.padding(16);
                            Column.backgroundColor('#FFFFFF');
                            Column.borderRadius(12);
                            Column.border({ width: 1, color: '#F0F0F0' });
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create({ space: 12 });
                            Row.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(114:21)", "entry");
                            Row.width('100%');
                            Row.alignItems(VerticalAlign.Top);
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item.icon);
                            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(115:23)", "entry");
                            Text.fontSize(28);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create({ space: 4 });
                            Column.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(118:23)", "entry");
                            Column.layoutWeight(1);
                            Column.alignItems(HorizontalAlign.Start);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item.name);
                            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(119:25)", "entry");
                            Text.fontSize(16);
                            Text.fontWeight('bold');
                            Text.fontColor('#333333');
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item.description);
                            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(124:25)", "entry");
                            Text.fontSize(12);
                            Text.fontColor('#888888');
                            Text.maxLines(2);
                        }, Text);
                        Text.pop();
                        Column.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create();
                            Column.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(132:23)", "entry");
                            Column.padding({ left: 10, right: 10, top: 6, bottom: 6 });
                            Column.backgroundColor(this.getLevelBgColor(item.levelColor));
                            Column.borderRadius(8);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item.level + '风险');
                            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(133:25)", "entry");
                            Text.fontSize(13);
                            Text.fontWeight('bold');
                            Text.fontColor(item.levelColor);
                        }, Text);
                        Text.pop();
                        Column.pop();
                        Row.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create({ space: 8 });
                            Column.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(145:21)", "entry");
                            Column.width('100%');
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create();
                            Row.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(146:23)", "entry");
                            Row.width('100%');
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create('风险程度');
                            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(147:25)", "entry");
                            Text.fontSize(12);
                            Text.fontColor('#666666');
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Blank.create();
                            Blank.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(151:25)", "entry");
                        }, Blank);
                        Blank.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item.progress + '%');
                            Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(153:25)", "entry");
                            Text.fontSize(12);
                            Text.fontColor(item.levelColor);
                            Text.fontWeight('bold');
                        }, Text);
                        Text.pop();
                        Row.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Progress.create({
                                value: item.progress,
                                total: 100,
                                type: ProgressType.Linear
                            });
                            Progress.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(160:23)", "entry");
                            Progress.width('100%');
                            Progress.height(8);
                            Progress.color(item.levelColor);
                            Progress.backgroundColor('#F0F0F0');
                            Progress.borderRadius(4);
                        }, Progress);
                        Column.pop();
                        Column.pop();
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.riskItems, forEachItemGenFunction, (item: RiskItem) => item.id, false, false);
        }, ForEach);
        ForEach.pop();
        List.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('📋 生成完整报告');
            Button.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(189:11)", "entry");
            Button.width('100%');
            Button.height(52);
            Button.fontSize(17);
            Button.fontColor('#FFFFFF');
            Button.backgroundColor('#1677FF');
            Button.borderRadius(26);
            Button.onClick(() => this.handleGenerateReport());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.showReportToast) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('✅ 报告生成成功！');
                        Text.debugLine("entry/src/main/ets/pages/RiskAssessmentPage.ets(199:13)", "entry");
                        Text.fontSize(15);
                        Text.fontColor('#52C41A');
                        Text.backgroundColor('#F6FFED');
                        Text.padding({ left: 24, right: 24, top: 12, bottom: 12 });
                        Text.borderRadius(25);
                        Text.border({ width: 1, color: '#B7EB8F' });
                        Text.margin({ top: 8 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
        Scroll.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "RiskAssessmentPage";
    }
}
registerNamedRoute(() => new RiskAssessmentPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/RiskAssessmentPage", pageFullPath: "entry/src/main/ets/pages/RiskAssessmentPage", integratedHsp: "false", moduleType: "followWithHap" });
