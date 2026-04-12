if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface FormInputItem_Params {
    label?: string;
    required?: boolean;
    error?: string;
    content?: () => void;
}
interface FormInputGroup_Params {
    children?: () => void;
}
interface SearchInput_Params {
    value?: string;
    placeholder?: string;
    onSearch?: (value: string) => void;
    onChange?: (value: string) => void;
}
interface Input_Params {
    placeholder?: string;
    inputType?: 'text' | 'password';
    text?: string;
    onChange?: (value: string) => void;
}
export class Input extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__placeholder = new SynchedPropertySimpleOneWayPU(params.placeholder, this, "placeholder");
        this.__inputType = new SynchedPropertySimpleOneWayPU(params.inputType, this, "inputType");
        this.__text = new SynchedPropertySimpleTwoWayPU(params.text, this, "text");
        this.onChange = undefined;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Input_Params) {
        if (params.placeholder === undefined) {
            this.__placeholder.set('');
        }
        if (params.inputType === undefined) {
            this.__inputType.set('text');
        }
        if (params.onChange !== undefined) {
            this.onChange = params.onChange;
        }
    }
    updateStateVars(params: Input_Params) {
        this.__placeholder.reset(params.placeholder);
        this.__inputType.reset(params.inputType);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__placeholder.purgeDependencyOnElmtId(rmElmtId);
        this.__inputType.purgeDependencyOnElmtId(rmElmtId);
        this.__text.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__placeholder.aboutToBeDeleted();
        this.__inputType.aboutToBeDeleted();
        this.__text.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 提示文字
    private __placeholder: SynchedPropertySimpleOneWayPU<string>;
    get placeholder() {
        return this.__placeholder.get();
    }
    set placeholder(newValue: string) {
        this.__placeholder.set(newValue);
    }
    // 输入类型
    private __inputType: SynchedPropertySimpleOneWayPU<'text' | 'password'>;
    get inputType() {
        return this.__inputType.get();
    }
    set inputType(newValue: 'text' | 'password') {
        this.__inputType.set(newValue);
    }
    // 输入内容（双向绑定）
    private __text: SynchedPropertySimpleTwoWayPU<string>;
    get text() {
        return this.__text.get();
    }
    set text(newValue: string) {
        this.__text.set(newValue);
    }
    // 内容变化回调
    private onChange?: (value: string) => void;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({
                placeholder: this.placeholder
            });
            TextInput.debugLine("entry/src/main/ets/components/Input.ets(18:5)", "entry");
            TextInput.placeholderColor('#999999');
            TextInput.fontSize(16);
            TextInput.fontColor('#1a1a1a');
            TextInput.padding(12);
            TextInput.backgroundColor('#ffffff');
            TextInput.borderRadius(8);
            TextInput.border({ width: 1, color: '#E5E6EB' });
            TextInput.width('100%');
            TextInput.onChange((value: string) => {
                this.text = value;
                if (this.onChange) {
                    this.onChange(value);
                }
            });
        }, TextInput);
    }
    rerender() {
        this.updateDirtyElements();
    }
}
export class SearchInput extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__value = new ObservedPropertySimplePU('', this, "value");
        this.placeholder = '搜索...';
        this.onSearch = undefined;
        this.onChange = undefined;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: SearchInput_Params) {
        if (params.value !== undefined) {
            this.value = params.value;
        }
        if (params.placeholder !== undefined) {
            this.placeholder = params.placeholder;
        }
        if (params.onSearch !== undefined) {
            this.onSearch = params.onSearch;
        }
        if (params.onChange !== undefined) {
            this.onChange = params.onChange;
        }
    }
    updateStateVars(params: SearchInput_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__value.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__value.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 搜索值
    private __value: ObservedPropertySimplePU<string>;
    get value() {
        return this.__value.get();
    }
    set value(newValue: string) {
        this.__value.set(newValue);
    }
    // 占位符文本
    private placeholder: string;
    // 搜索事件
    private onSearch?: (value: string) => void;
    // 值变化事件
    private onChange?: (value: string) => void;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
            Row.debugLine("entry/src/main/ets/components/Input.ets(54:5)", "entry");
            Row.padding({ left: 12, right: 12 });
            Row.backgroundColor('#ffffff');
            Row.borderRadius(20);
            Row.border({ width: 1, color: '#e0e0e0' });
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 搜索图标
            Text.create('🔍');
            Text.debugLine("entry/src/main/ets/components/Input.ets(56:7)", "entry");
            // 搜索图标
            Text.fontSize(16);
            // 搜索图标
            Text.fontColor('#666666');
        }, Text);
        // 搜索图标
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 输入框
            TextInput.create({
                placeholder: this.placeholder,
                text: this.value
            });
            TextInput.debugLine("entry/src/main/ets/components/Input.ets(61:7)", "entry");
            // 输入框
            TextInput.placeholderColor('#999999');
            // 输入框
            TextInput.height(40);
            // 输入框
            TextInput.fontSize(14);
            // 输入框
            TextInput.fontColor('#1a1a1a');
            // 输入框
            TextInput.backgroundColor('#ffffff');
            // 输入框
            TextInput.border({ width: 0 });
            // 输入框
            TextInput.layoutWeight(1);
            // 输入框
            TextInput.onChange((value: string) => {
                this.value = value;
                if (this.onChange) {
                    this.onChange(value);
                }
            });
            // 输入框
            TextInput.onSubmit(() => {
                if (this.onSearch) {
                    this.onSearch(this.value);
                }
            });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 清除按钮
            if (this.value) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('✕');
                        Text.debugLine("entry/src/main/ets/components/Input.ets(86:9)", "entry");
                        Text.fontSize(16);
                        Text.fontColor('#999999');
                        Text.onClick(() => {
                            this.value = '';
                            if (this.onChange) {
                                this.onChange('');
                            }
                        });
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
        Row.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
export class FormInputGroup extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.children = undefined;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: FormInputGroup_Params) {
        if (params.children !== undefined) {
            this.children = params.children;
        }
    }
    updateStateVars(params: FormInputGroup_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
    }
    aboutToBeDeleted() {
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 表单项
    private __children?;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.debugLine("entry/src/main/ets/components/Input.ets(112:5)", "entry");
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.children) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.children.bind(this)();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
export class FormInputItem extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.label = '';
        this.required = false;
        this.error = '';
        this.content = undefined;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: FormInputItem_Params) {
        if (params.label !== undefined) {
            this.label = params.label;
        }
        if (params.required !== undefined) {
            this.required = params.required;
        }
        if (params.error !== undefined) {
            this.error = params.error;
        }
        if (params.content !== undefined) {
            this.content = params.content;
        }
    }
    updateStateVars(params: FormInputItem_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
    }
    aboutToBeDeleted() {
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 标签
    private label: string;
    // 是否必填
    private required: boolean;
    // 错误信息
    private error?: string;
    // 输入框内容
    private __content?;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 4 });
            Column.debugLine("entry/src/main/ets/components/Input.ets(137:5)", "entry");
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标签
            Row.create();
            Row.debugLine("entry/src/main/ets/components/Input.ets(139:7)", "entry");
            // 标签
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.label);
            Text.debugLine("entry/src/main/ets/components/Input.ets(140:9)", "entry");
            Text.fontSize(14);
            Text.fontColor('#1a1a1a');
            Text.fontWeight('medium');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.required) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('*');
                        Text.debugLine("entry/src/main/ets/components/Input.ets(146:11)", "entry");
                        Text.fontSize(14);
                        Text.fontColor('#ff6b6b');
                        Text.margin({ left: 2 });
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
        // 标签
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 输入框内容
            if (this.content) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.content.bind(this)();
                });
            }
            // 错误信息
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 错误信息
            if (this.error) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.error);
                        Text.debugLine("entry/src/main/ets/components/Input.ets(161:9)", "entry");
                        Text.fontSize(12);
                        Text.fontColor('#ff6b6b');
                        Text.width('100%');
                        Text.margin({ top: 4 });
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
    }
    rerender() {
        this.updateDirtyElements();
    }
}
