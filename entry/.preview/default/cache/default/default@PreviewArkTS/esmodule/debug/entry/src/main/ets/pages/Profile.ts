if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Profile_Params {
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
class Profile extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Profile_Params) {
    }
    updateStateVars(params: Profile_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
    }
    aboutToBeDeleted() {
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    initialRender(): void {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Profile.ets(9:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, {
                        title: '个人中心',
                        showBack: true
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Profile.ets", line: 10, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '个人中心',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '个人中心',
                        showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({
                space: 16
            });
            Column.debugLine("entry/src/main/ets/pages/Profile.ets(15:7)", "entry");
            Column.flexGrow(1);
            Column.width('80%');
            Column.justifyContent(FlexAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('个人中心');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(18:9)", "entry");
            Text.fontSize(24);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ top: 20, bottom: 16 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({
                space: 12
            });
            Column.debugLine("entry/src/main/ets/pages/Profile.ets(24:9)", "entry");
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({
                space: 16
            });
            Row.debugLine("entry/src/main/ets/pages/Profile.ets(27:11)", "entry");
            Row.width('100%');
            Row.padding(16);
            Row.backgroundColor('#FFFFFF');
            Row.borderRadius(12);
            Row.border({ width: 1, color: '#f0f0f0' });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create();
            Circle.debugLine("entry/src/main/ets/pages/Profile.ets(30:13)", "entry");
            Circle.width(80);
            Circle.height(80);
            Circle.fill('#4a90e220');
            Circle.stroke('#1677FF');
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({
                space: 4
            });
            Column.debugLine("entry/src/main/ets/pages/Profile.ets(36:13)", "entry");
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('星云用户');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(39:15)", "entry");
            Text.fontSize(18);
            Text.fontWeight('bold');
            Text.fontColor('#333333');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('138****1234');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(43:15)", "entry");
            Text.fontSize(14);
            Text.fontColor('#666666');
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({
                space: 1
            });
            Column.debugLine("entry/src/main/ets/pages/Profile.ets(55:9)", "entry");
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({
                space: 12
            });
            Row.debugLine("entry/src/main/ets/pages/Profile.ets(58:11)", "entry");
            Row.width('100%');
            Row.padding(16);
            Row.backgroundColor('#FFFFFF');
            Row.borderRadius({ topLeft: 12, topRight: 12 });
            Row.border({ width: 1, color: '#f0f0f0' });
            Row.onClick(() => {
                router.pushUrl({ url: 'pages/DeviceDiscoveryPage' });
            });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('📱 设备绑定');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(61:13)", "entry");
            Text.fontSize(16);
            Text.fontColor('#1677FF');
            Text.fontWeight('bold');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/Profile.ets(65:13)", "entry");
            Blank.layoutWeight(1);
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('›');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(67:13)", "entry");
            Text.fontSize(20);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({
                space: 12
            });
            Row.debugLine("entry/src/main/ets/pages/Profile.ets(80:11)", "entry");
            Row.width('100%');
            Row.padding(16);
            Row.backgroundColor('#FFFFFF');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('账号设置');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(83:13)", "entry");
            Text.fontSize(16);
            Text.fontColor('#333333');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/Profile.ets(86:13)", "entry");
            Blank.layoutWeight(1);
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('›');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(88:13)", "entry");
            Text.fontSize(20);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({
                space: 12
            });
            Row.debugLine("entry/src/main/ets/pages/Profile.ets(96:11)", "entry");
            Row.width('100%');
            Row.padding(16);
            Row.backgroundColor('#FFFFFF');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('隐私设置');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(99:13)", "entry");
            Text.fontSize(16);
            Text.fontColor('#333333');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/Profile.ets(102:13)", "entry");
            Blank.layoutWeight(1);
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('›');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(104:13)", "entry");
            Text.fontSize(20);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({
                space: 12
            });
            Row.debugLine("entry/src/main/ets/pages/Profile.ets(112:11)", "entry");
            Row.width('100%');
            Row.padding(16);
            Row.backgroundColor('#FFFFFF');
            Row.borderRadius({ bottomLeft: 12, bottomRight: 12 });
            Row.border({ width: 1, color: '#f0f0f0' });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('关于我们');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(115:13)", "entry");
            Text.fontSize(16);
            Text.fontColor('#333333');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/Profile.ets(118:13)", "entry");
            Blank.layoutWeight(1);
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('›');
            Text.debugLine("entry/src/main/ets/pages/Profile.ets(120:13)", "entry");
            Text.fontSize(20);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('退出登录');
            Button.debugLine("entry/src/main/ets/pages/Profile.ets(131:9)", "entry");
            Button.width('100%');
            Button.height(48);
            Button.fontSize(16);
            Button.fontColor('#FFFFFF');
            Button.backgroundColor('#1677FF');
            Button.borderRadius(8);
            Button.margin({ top: 20, bottom: 20 });
            Button.onClick((): void => {
                router.pushUrl({ url: 'pages/Index' });
            });
        }, Button);
        Button.pop();
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Footer(this, { activeIndex: 4 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Profile.ets", line: 147, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            activeIndex: 4
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        activeIndex: 4
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
        return "Profile";
    }
}
registerNamedRoute(() => new Profile(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/Profile", pageFullPath: "entry/src/main/ets/pages/Profile", integratedHsp: "false", moduleType: "followWithHap" });
