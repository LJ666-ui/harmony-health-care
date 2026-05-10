import { SampleImageItem, ImageTypeGroup, IMAGE_TYPE_CONFIG } from '../common/model/SampleImageModel'
import sampleImageLoader from '../common/service/SampleImageLoader'
import imageSelectHandler from '../common/handler/ImageSelectHandler'
import { SampleImageCard } from '../components/SampleImageCard'
import router from '@ohos.router'

@Entry
@Component
struct SampleGalleryPage {
  @State sampleImages: SampleImageItem[] = []
  @State selectedImage: SampleImageItem | null = null
  @State isLoading: boolean = true
  @State imageGroups: ImageTypeGroup[] = []
  
  async aboutToAppear() {
    console.info('[SampleGalleryPage] 页面加载')
    await this.loadSampleImages()
  }
  
  async loadSampleImages() {
    try {
      this.isLoading = true
      const images = await sampleImageLoader.loadAllSampleImages()
      this.sampleImages = images
      this.imageGroups = this.groupImagesByType(images)
      console.info(`[SampleGalleryPage] 成功加载 ${images.length} 张示例图片`)
    } catch (error) {
      console.error(`[SampleGalleryPage] 加载示例图片失败: ${error}`)
    } finally {
      this.isLoading = false
    }
  }
  
  groupImagesByType(images: SampleImageItem[]): ImageTypeGroup[] {
    const groups: ImageTypeGroup[] = []
    
    for (const [type, config] of IMAGE_TYPE_CONFIG) {
      const typeImages = images.filter(img => img.imageType === type)
      
      if (typeImages.length > 0) {
        groups.push({
          type: type,
          typeName: config.name,
          typeIcon: config.icon,
          images: typeImages,
          isExpanded: true
        })
      }
    }
    
    return groups
  }
  
  handleImageSelect(image: SampleImageItem) {
    console.info(`[SampleGalleryPage] 选择图片: ${image.imageId}`)
  }
  
  async handleConfirmUse() {
    if (!this.selectedImage) {
      console.warn('[SampleGalleryPage] 未选择图片')
      return
    }
    
    console.info(`[SampleGalleryPage] 确认使用图片: ${this.selectedImage.imageId}`)
    await imageSelectHandler.handleSampleImageSelect(this.selectedImage)
  }
  
  handleCancel() {
    router.back()
  }
  
  build() {
    Column() {
      this.renderTitle()
      
      if (this.isLoading) {
        this.renderLoading()
      } else if (this.imageGroups.length === 0) {
        this.renderEmpty()
      } else {
        this.renderImageGroups()
        this.renderBottomActions()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  @Builder
  renderTitle() {
    Row() {
      Text('示例图库')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
      
      Blank()
      
      Text(`${this.sampleImages.length} 张图片`)
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(Color.White)
  }
  
  @Builder
  renderLoading() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#1890FF')
      
      Text('加载示例图片...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
  
  @Builder
  renderEmpty() {
    Column() {
      Text('📂')
        .fontSize(48)
      
      Text('暂无示例图片')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 16 })
      
      Text('请将测试图片放入 entry/src/main/resources/rawfile/medical-images/ 目录')
        .fontSize(12)
        .fontColor('#CCCCCC')
        .margin({ top: 8 })
        .textAlign(TextAlign.Center)
        .width('80%')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
  
  @Builder
  renderImageGroups() {
    Scroll() {
      Column() {
        ForEach(this.imageGroups, (group: ImageTypeGroup) => {
          this.renderImageGroup(group)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
  
  @Builder
  renderImageGroup(group: ImageTypeGroup) {
    Column() {
      Row() {
        Text(group.typeIcon)
          .fontSize(20)
        
        Text(group.typeName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 8 })
        
        Blank()
        
        Text(`${group.images.length} 张`)
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(group.images, (image: SampleImageItem) => {
          Column() {
            SampleImageCard({
              imageItem: image,
              selectedImage: $selectedImage,
              onSelect: (img: SampleImageItem) => {
                this.handleImageSelect(img)
              }
            })
          }
          .margin({ right: 12, bottom: 12 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ top: 8 })
  }
  
  @Builder
  renderBottomActions() {
    Row() {
      Button('取消')
        .type(ButtonType.Normal)
        .width('40%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .fontColor('#666666')
        .onClick(() => {
          this.handleCancel()
        })
      
      Button('使用示例图片')
        .type(ButtonType.Normal)
        .width('55%')
        .height(44)
        .backgroundColor(this.selectedImage ? '#1890FF' : '#CCCCCC')
        .fontColor(Color.White)
        .enabled(!!this.selectedImage)
        .onClick(() => {
          this.handleConfirmUse()
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
