if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Login_Params {
    username?: string;
    password?: string;
}
import router from "@ohos:router";
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
import { Footer } from "@normalized:N&&&entry/src/main/ets/components/Footer&";
import { Input } from "@normalized:N&&&entry/src/main/ets/components/Input&";
class Login extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__username = new ObservedPropertySimplePU('', this, "username");
        this.__password = new ObservedPropertySimplePU('', this, "password");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Login_Params) {
        if (params.username !== undefined) {
            this.username = params.username;
        }
        if (params.password !== undefined) {
            this.password = params.password;
        }
    }
    updateStateVars(params: Login_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__username.purgeDependencyOnElmtId(rmElmtId);
        this.__password.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__username.aboutToBeDeleted();
        this.__password.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __username: ObservedPropertySimplePU<string>;
    get username() {
        return this.__username.get();
    }
    set username(newValue: string) {
        this.__username.set(newValue);
    }
    private __password: ObservedPropertySimplePU<string>;
    get password() {
        return this.__password.get();
    }
    set password(newValue: string) {
        this.__password.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Login.ets(13:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 顶部导航栏
                    Header(this, {
                        title: '登录',
                        showBack: true
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Login.ets", line: 15, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '登录',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '登录',
                        showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 中间内容区
            Column.create({ space: 24 });
            Column.debugLine("entry/src/main/ets/pages/Login.ets(21:7)", "entry");
            // 中间内容区
            Column.flexGrow(1);
            // 中间内容区
            Column.width('80%');
            // 中间内容区
            Column.justifyContent(FlexAlign.Center);
            // 中间内容区
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 账号输入框
                    Input(this, {
                        placeholder: '请输入账号',
                        inputType: 'text',
                        text: this.__username,
                        onChange: (value) => {
                            console.log('账号变化:', value);
                        }
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Login.ets", line: 23, col: 9 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            placeholder: '请输入账号',
                            inputType: 'text',
                            text: this.username,
                            onChange: (value) => {
                                console.log('账号变化:', value);
                            }
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        placeholder: '请输入账号',
                        inputType: 'text'
                    });
                }
            }, { name: "Input" });
        }
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 密码输入框
                    Input(this, {
                        placeholder: '请输入密码',
                        inputType: 'password',
                        text: this.__password,
                        onChange: (value) => {
                            console.log('密码变化:', value);
                        }
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Login.ets", line: 33, col: 9 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            placeholder: '请输入密码',
                            inputType: 'password',
                            text: this.password,
                            onChange: (value) => {
                                console.log('密码变化:', value);
                            }
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        placeholder: '请输入密码',
                        inputType: 'password'
                    });
                }
            }, { name: "Input" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 登录按钮
            Button.createWithLabel('登录');
            Button.debugLine("entry/src/main/ets/pages/Login.ets(43:9)", "entry");
            // 登录按钮
            Button.width('100%');
            // 登录按钮
            Button.height(48);
            // 登录按钮
            Button.fontSize(16);
            // 登录按钮
            Button.fontWeight('medium');
            // 登录按钮
            Button.fontColor('#FFFFFF');
            // 登录按钮
            Button.backgroundColor('#1677FF');
            // 登录按钮
            Button.borderRadius(8);
            // 登录按钮
            Button.onClick(() => {
                // 路由跳转到HomePage页面
                router.pushUrl({
                    url: 'pages/HomePage'
                });
            });
        }, Button);
        // 登录按钮
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 忘记密码
            Text.create('忘记密码');
            Text.debugLine("entry/src/main/ets/pages/Login.ets(59:9)", "entry");
            // 忘记密码
            Text.fontSize(14);
            // 忘记密码
            Text.fontColor('#1677FF');
            // 忘记密码
            Text.onClick(() => {
                console.log('忘记密码点击');
            });
        }, Text);
        // 忘记密码
        Text.pop();
        // 中间内容区
        Column.pop();
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 底部Tab栏
                    Footer(this, { activeIndex: 1 }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Login.ets", line: 72, col: 7 });
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
        return "Login";
    }
}
registerNamedRoute(() => new Login(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/Login", pageFullPath: "entry/src/main/ets/pages/Login", integratedHsp: "false", moduleType: "followWithHap" });
