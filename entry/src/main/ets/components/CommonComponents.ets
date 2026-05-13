import { LoadingState } from '../model/StateModel';

@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索患者姓名';
  @Link searchText: string;
  onSearch?: (keyword: string) => void;

  build() {
    Row() {
      Image($r('app.media.startIcon'))
        .width(20)
        .height(20)
        .margin({ left: 12, right: 8 })

      TextInput({ placeholder: this.placeholder, text: this.searchText })
        .layoutWeight(1)
        .height(36)
        .backgroundColor(Color.Transparent)
        .fontSize(14)
        .onChange((value: string) => {
          this.searchText = value;
          if (this.onSearch) {
            this.onSearch(value);
          }
        })

      if (this.searchText.length > 0) {
        Image($r('sys.media.ohos_ic_public_cancel'))
          .width(16)
          .height(16)
          .margin({ right: 12 })
          .onClick(() => {
            this.searchText = '';
            if (this.onSearch) {
              this.onSearch('');
            }
          })
      }
    }
    .width('100%')
    .height(44)
    .backgroundColor('#F5F5F5')
    .borderRadius(22)
    .margin({ left: 16, right: 16 })
  }
}

@Component
export struct LoadingComponent {
  @Prop message: string = '加载中...';

  build() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#007DFF')

      Text(this.message)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct ErrorComponent {
  @Prop message: string = '加载失败';
  onRetry?: () => void;

  build() {
    Column() {
      Image($r('app.media.startIcon'))
        .width(64)
        .height(64)

      Text(this.message)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })

      Button('重试')
        .fontSize(14)
        .fontColor('#007DFF')
        .backgroundColor(Color.Transparent)
        .margin({ top: 12 })
        .onClick(() => {
          if (this.onRetry) {
            this.onRetry();
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct EmptyComponent {
  @Prop message: string = '暂无患者信息';

  build() {
    Column() {
      Image($r('app.media.startIcon'))
        .width(64)
        .height(64)

      Text(this.message)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct StateComponent {
  @Prop state: LoadingState = LoadingState.IDLE;
  @Prop errorMessage: string = '';
  onRetry?: () => void;

  build() {
    if (this.state === LoadingState.LOADING) {
      LoadingComponent({ message: '加载中...' })
    } else if (this.state === LoadingState.ERROR) {
      ErrorComponent({ 
        message: this.errorMessage || '加载失败',
        onRetry: this.onRetry
      })
    } else if (this.state === LoadingState.EMPTY) {
      EmptyComponent({ message: '暂无患者信息' })
    }
  }
}
