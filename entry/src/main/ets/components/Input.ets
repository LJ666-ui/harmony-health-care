// 通用输入框组件

@Component
export struct Input {
  // 提示文字
  @Prop placeholder: string = '';
  
  // 输入类型
  @Prop inputType: 'text' | 'password' = 'text';
  
  // 输入内容（双向绑定）
  @Link text: string;
  
  // 内容变化回调
  private onChange?: (value: string) => void;

  build() {
    TextInput({
      placeholder: this.placeholder
    })
      .placeholderColor('#999999')
      .fontSize(16)
      .fontColor('#1a1a1a')
      .padding(12)
      .backgroundColor('#ffffff')
      .borderRadius(8)
      .border({ width: 1, color: '#E5E6EB' })
      .width('100%')
      .onChange((value: string) => {
        this.text = value;
        if (this.onChange) {
          this.onChange(value);
        }
      })
  }
}

// 搜索输入框组件
@Component
export struct SearchInput {
  // 搜索值
  @State value: string = '';
  
  // 占位符文本
  private placeholder: string = '搜索...';
  
  // 搜索事件
  private onSearch?: (value: string) => void;
  
  // 值变化事件
  private onChange?: (value: string) => void;

  build() {
    Row({ space: 8 }) {
      // 搜索图标
      Text('🔍')
        .fontSize(16)
        .fontColor('#666666')

      // 输入框
      TextInput({
        placeholder: this.placeholder,
        text: this.value
      })
        .placeholderColor('#999999')
        .height(40)
        .fontSize(14)
        .fontColor('#1a1a1a')
        .backgroundColor('#ffffff')
        .border({ width: 0 })
        .layoutWeight(1)
        .onChange((value: string) => {
          this.value = value;
          if (this.onChange) {
            this.onChange(value);
          }
        })
        .onSubmit(() => {
          if (this.onSearch) {
            this.onSearch(this.value);
          }
        })

      // 清除按钮
      if (this.value) {
        Text('✕')
          .fontSize(16)
          .fontColor('#999999')
          .onClick(() => {
            this.value = '';
            if (this.onChange) {
              this.onChange('');
            }
          })
      }
    }
    .padding({ left: 12, right: 12 })
    .backgroundColor('#ffffff')
    .borderRadius(20)
    .border({ width: 1, color: '#e0e0e0' })
    .width('100%')
  }
}

// 表单输入框组
@Component
export struct FormInputGroup {
  // 表单项
  @BuilderParam children: () => void = this.defaultChildren;

  @Builder
  private defaultChildren() {}

  build() {
    Column({ space: 16 }) {
      this.children()
    }
    .width('100%')
  }
}

// 表单输入项
@Component
export struct FormInputItem {
  // 标签
  private label: string = '';

  // 是否必填
  private required: boolean = false;

  // 错误信息
  private error?: string = '';

  // 输入框内容
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  private defaultContent() {}

  build() {
    Column({ space: 4 }) {
      // 标签
      Row() {
        Text(this.label)
          .fontSize(14)
          .fontColor('#1a1a1a')
          .fontWeight('medium')

        if (this.required) {
          Text('*')
            .fontSize(14)
            .fontColor('#ff6b6b')
            .margin({ left: 2 })
        }
      }
      .width('100%')

      // 输入框内容
      this.content()

      // 错误信息
      if (this.error) {
        Text(this.error)
          .fontSize(12)
          .fontColor('#ff6b6b')
          .width('100%')
          .margin({ top: 4 })
      }
    }
    .width('100%')
  }
}