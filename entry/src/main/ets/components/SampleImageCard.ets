import { SampleImageItem } from '../common/model/SampleImageModel'

@Component
export struct SampleImageCard {
  @Prop imageItem: SampleImageItem
  @Link selectedImage: SampleImageItem | null
  private onSelect: (image: SampleImageItem) => void = () => {}
  
  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.imageItem.thumbnailUrl)
          .width(120)
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .border({
            width: this.isSelected() ? 2 : 1,
            color: this.isSelected() ? '#1890FF' : '#E0E0E0',
            radius: 8
          })
        
        if (this.isSelected()) {
          Row() {
            Text('✓')
              .fontSize(12)
              .fontColor(Color.White)
          }
          .width(20)
          .height(20)
          .borderRadius(10)
          .backgroundColor('#1890FF')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 4, right: 4 })
        }
      }
      .width(120)
      .height(120)
      
      Text(this.imageItem.imageName)
        .fontSize(12)
        .fontColor('#333333')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(120)
        .margin({ top: 4 })
      
      Text(this.formatFileSize(this.imageItem.size))
        .fontSize(10)
        .fontColor('#999999')
        .margin({ top: 2 })
    }
    .width(120)
    .onClick(() => {
      this.handleSelect()
    })
  }
  
  private isSelected(): boolean {
    return this.selectedImage?.imageId === this.imageItem.imageId
  }
  
  private handleSelect(): void {
    if (this.isSelected()) {
      this.selectedImage = null
    } else {
      this.selectedImage = this.imageItem
      this.onSelect(this.imageItem)
    }
  }
  
  private formatFileSize(bytes: number): string {
    if (bytes < 1024) {
      return `${bytes} B`
    } else if (bytes < 1024 * 1024) {
      return `${(bytes / 1024).toFixed(1)} KB`
    } else {
      return `${(bytes / 1024 / 1024).toFixed(2)} MB`
    }
  }
}
