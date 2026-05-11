import router from '@ohos.router'
import { SampleImageItem } from '../model/SampleImageModel'

export class ImageSelectHandler {
  
  private static instance: ImageSelectHandler
  
  static getInstance(): ImageSelectHandler {
    if (!ImageSelectHandler.instance) {
      ImageSelectHandler.instance = new ImageSelectHandler()
    }
    return ImageSelectHandler.instance
  }
  
  async handleSampleImageSelect(selectedImage: SampleImageItem): Promise<void> {
    try {
      console.info(`[ImageSelectHandler] 处理示例图片选择: ${selectedImage.imageId}`)
      
      const rawfilePath = this.extractRawfilePath(selectedImage.imageUrl)
      
      router.pushUrl({
        url: 'pages/medicalimage/MedicalImageDiagnosisPage',
        params: {
          mode: 'sample',
          imageUrl: selectedImage.imageUrl,
          imageType: selectedImage.imageType,
          imageId: selectedImage.imageId,
          imageName: selectedImage.imageName,
          format: selectedImage.format
        }
      })
      
      console.info('[ImageSelectHandler] 跳转到影像诊断页面成功')
    } catch (error) {
      console.error(`[ImageSelectHandler] 处理示例图片选择失败: ${error}`)
      this.showToast('使用示例图片失败，请重试')
    }
  }
  
  private extractRawfilePath(resourceUrl: string): string {
    const prefix = 'resource://RAWFILE/'
    if (resourceUrl.startsWith(prefix)) {
      return resourceUrl.substring(prefix.length)
    }
    return resourceUrl
  }
  
  private showToast(message: string): void {
    console.warn(`[Toast] ${message}`)
  }
  
  validateImage(selectedImage: SampleImageItem): boolean {
    if (!selectedImage) {
      this.showToast('请先选择一张示例图片')
      return false
    }
    
    if (!selectedImage.imageId || !selectedImage.imageUrl) {
      this.showToast('图片信息不完整')
      return false
    }
    
    return true
  }
}

export default ImageSelectHandler.getInstance()
