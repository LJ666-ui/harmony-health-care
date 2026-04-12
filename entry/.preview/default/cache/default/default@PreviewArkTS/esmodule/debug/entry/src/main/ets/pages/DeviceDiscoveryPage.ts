if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface DeviceDiscoveryPage_Params {
    devices?: BleDevice[];
    isScanning?: boolean;
}
import { Header } from "@normalized:N&&&entry/src/main/ets/components/Header&";
interface BleDevice {
    id: string;
    name: string;
    icon: string;
    type: string;
    signal: string;
    isConnected: boolean;
}
class DeviceDiscoveryPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__devices = new ObservedPropertyObjectPU([
            { id: '1', name: '华为 WATCH GT5 Pro', icon: '⌚', type: '智能手表', signal: '信号强', isConnected: false },
            { id: '2', name: '欧姆龙智能血压计 J760', icon: '🩺', type: '血压计', signal: '信号强', isConnected: false },
            { id: '3', name: '云康宝体脂秤 CS20A', icon: '⚖️', type: '体脂秤', signal: '信号中', isConnected: false }
        ], this, "devices");
        this.__isScanning = new ObservedPropertySimplePU(false, this, "isScanning");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: DeviceDiscoveryPage_Params) {
        if (params.devices !== undefined) {
            this.devices = params.devices;
        }
        if (params.isScanning !== undefined) {
            this.isScanning = params.isScanning;
        }
    }
    updateStateVars(params: DeviceDiscoveryPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__devices.purgeDependencyOnElmtId(rmElmtId);
        this.__isScanning.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__devices.aboutToBeDeleted();
        this.__isScanning.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __devices: ObservedPropertyObjectPU<BleDevice[]>;
    get devices() {
        return this.__devices.get();
    }
    set devices(newValue: BleDevice[]) {
        this.__devices.set(newValue);
    }
    private __isScanning: ObservedPropertySimplePU<boolean>;
    get isScanning() {
        return this.__isScanning.get();
    }
    set isScanning(newValue: boolean) {
        this.__isScanning.set(newValue);
    }
    getConnectedCount(): number {
        let count: number = 0;
        for (let i: number = 0; i < this.devices.length; i++) {
            if (this.devices[i].isConnected) {
                count++;
            }
        }
        return count;
    }
    toggleDevice(deviceId: string): void {
        const newDevices: BleDevice[] = [];
        for (let i: number = 0; i < this.devices.length; i++) {
            const device: BleDevice = this.devices[i];
            if (device.id === deviceId) {
                newDevices.push({ id: device.id, name: device.name, icon: device.icon, type: device.type, signal: device.signal, isConnected: !device.isConnected });
            }
            else {
                newDevices.push(device);
            }
        }
        this.devices = newDevices;
    }
    handleRescan(): void {
        this.isScanning = true;
        const resetDevices: BleDevice[] = [];
        for (let i: number = 0; i < this.devices.length; i++) {
            const device: BleDevice = this.devices[i];
            resetDevices.push({ id: device.id, name: device.name, icon: device.icon, type: device.type, signal: device.signal, isConnected: false });
        }
        this.devices = resetDevices;
        setTimeout(() => {
            this.isScanning = false;
        }, 1500);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(61:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F7FA');
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new Header(this, { title: '设备绑定', showBack: true }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/DeviceDiscoveryPage.ets", line: 62, col: 7 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            title: '设备绑定',
                            showBack: true
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        title: '设备绑定', showBack: true
                    });
                }
            }, { name: "Header" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(64:7)", "entry");
            Scroll.flexGrow(1);
            Scroll.scrollBar(BarState.Off);
            Scroll.align(Alignment.Top);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(65:9)", "entry");
            Column.width('85%');
            Column.padding({ top: 20, bottom: 32 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({
                space: 12
            });
            Column.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(66:11)", "entry");
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('附近设备');
            Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(69:13)", "entry");
            Text.fontSize(20);
            Text.fontWeight('bold');
            Text.fontColor('#1677FF');
            Text.margin({ bottom: 4 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('请选择要绑定的健康设备，点击按钮切换连接状态');
            Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(75:13)", "entry");
            Text.fontSize(13);
            Text.fontColor('#888888');
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(82:11)", "entry");
            Row.width('100%');
            Row.padding({ left: 4, right: 4 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.isScanning ? '🔍 扫描中...' : '🔍 重新扫描');
            Button.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(83:13)", "entry");
            Button.height(38);
            Button.fontSize(14);
            Button.fontColor(this.isScanning ? '#1677FF' : '#FFFFFF');
            Button.backgroundColor(this.isScanning ? '#F0F5FF' : '#1677FF');
            Button.borderRadius(19);
            Button.border(this.isScanning ? { width: 1, color: '#1677FF' } : { width: 0 });
            Button.onClick(() => this.handleRescan());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('已发现 ' + this.devices.length + ' 台');
            Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(92:13)", "entry");
            Text.fontSize(13);
            Text.fontColor('#999999');
            Text.margin({ left: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(97:13)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.getConnectedCount() + '/' + this.devices.length + ' 已连接');
            Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(99:13)", "entry");
            Text.fontSize(12);
            Text.fontColor('#52C41A');
            Text.backgroundColor('#F6FFED');
            Text.padding({ left: 10, right: 10, top: 4, bottom: 4 });
            Text.borderRadius(10);
            Text.border({ width: 1, color: '#B7EB8F' });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create({
                space: 12
            });
            List.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(110:11)", "entry");
            List.width('100%');
            List.layoutWeight(1);
        }, List);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const device = _item;
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
                        ListItem.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(114:15)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create({
                                space: 14
                            });
                            Row.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(115:17)", "entry");
                            Row.width('100%');
                            Row.padding(16);
                            Row.backgroundColor('#FFFFFF');
                            Row.borderRadius(12);
                            Row.border({
                                width: device.isConnected ? 1.5 : 1,
                                color: device.isConnected ? '#52C41A50' : '#F0F0F0'
                            });
                            Row.shadow(device.isConnected ? {
                                radius: 8,
                                color: '#52C41A15',
                                offsetX: 0,
                                offsetY: 2
                            } : undefined);
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create({
                                space: 4
                            });
                            Column.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(118:19)", "entry");
                            Column.width(64);
                            Column.height(64);
                            Column.backgroundColor(device.isConnected ? '#F6FFED' : '#F0F5FF');
                            Column.borderRadius(12);
                            Column.justifyContent(FlexAlign.Center);
                            Column.border(device.isConnected ? { width: 1.5, color: '#52C41A' } : { width: 1, color: '#E8E8E8' });
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(device.icon);
                            Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(121:21)", "entry");
                            Text.fontSize(36);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(device.signal);
                            Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(124:21)", "entry");
                            Text.fontSize(10);
                            Text.fontColor(device.signal === '信号强' ? '#52C41A' : '#FAAD14');
                        }, Text);
                        Text.pop();
                        Column.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create({
                                space: 6
                            });
                            Column.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(135:19)", "entry");
                            Column.layoutWeight(1);
                            Column.alignItems(HorizontalAlign.Start);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(device.name);
                            Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(138:21)", "entry");
                            Text.fontSize(16);
                            Text.fontWeight('bold');
                            Text.fontColor('#333333');
                            Text.maxLines(1);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create({
                                space: 8
                            });
                            Row.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(144:21)", "entry");
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(device.type);
                            Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(147:23)", "entry");
                            Text.fontSize(12);
                            Text.fontColor('#1677FF');
                            Text.backgroundColor('#1677FF10');
                            Text.padding({ left: 8, right: 8, top: 2, bottom: 2 });
                            Text.borderRadius(4);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            If.create();
                            if (device.isConnected) {
                                this.ifElseBranchUpdateFunction(0, () => {
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create('● 已连接');
                                        Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(155:25)", "entry");
                                        Text.fontSize(12);
                                        Text.fontColor('#52C41A');
                                        Text.fontWeight('bold');
                                    }, Text);
                                    Text.pop();
                                });
                            }
                            else {
                                this.ifElseBranchUpdateFunction(1, () => {
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create('未连接');
                                        Text.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(160:25)", "entry");
                                        Text.fontSize(12);
                                        Text.fontColor('#999999');
                                    }, Text);
                                    Text.pop();
                                });
                            }
                        }, If);
                        If.pop();
                        Row.pop();
                        Column.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Button.createWithLabel(device.isConnected ? '断开' : '连接');
                            Button.debugLine("entry/src/main/ets/pages/DeviceDiscoveryPage.ets(169:19)", "entry");
                            Button.width(68);
                            Button.height(34);
                            Button.fontSize(13);
                            Button.fontColor(device.isConnected ? '#FF4D4F' : '#FFFFFF');
                            Button.backgroundColor(device.isConnected ? '#FFF1F0' : '#1677FF');
                            Button.borderRadius(17);
                            Button.border(device.isConnected ? { width: 1, color: '#FFCCC7' } : { width: 0 });
                            Button.onClick(() => this.toggleDevice(device.id));
                        }, Button);
                        Button.pop();
                        Row.pop();
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.devices, forEachItemGenFunction, (device: BleDevice) => device.id, false, false);
        }, ForEach);
        ForEach.pop();
        List.pop();
        Column.pop();
        Scroll.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "DeviceDiscoveryPage";
    }
}
registerNamedRoute(() => new DeviceDiscoveryPage(undefined, {}), "", { bundleName: "com.example.harmonyhealthcare", moduleName: "entry", pagePath: "pages/DeviceDiscoveryPage", pageFullPath: "entry/src/main/ets/pages/DeviceDiscoveryPage", integratedHsp: "false", moduleType: "followWithHap" });
