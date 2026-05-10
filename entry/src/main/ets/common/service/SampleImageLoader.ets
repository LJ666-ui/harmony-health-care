import { ImageType, SampleImageItem, IMAGE_TYPE_CONFIG } from '../model/SampleImageModel'

export class SampleImageLoader {
  
  private static instance: SampleImageLoader
  
  static getInstance(): SampleImageLoader {
    if (!SampleImageLoader.instance) {
      SampleImageLoader.instance = new SampleImageLoader()
    }
    return SampleImageLoader.instance
  }
  
  async loadAllSampleImages(): Promise<SampleImageItem[]> {
    const allImages: SampleImageItem[] = []
    
    try {
      const entries = Array.from(IMAGE_TYPE_CONFIG.entries())
      for (let i = 0; i < entries.length; i++) {
        const entry = entries[i]
        const imageType: ImageType = entry[0]
        const config = entry[1]
        const typeImages = await this.loadImagesByType(imageType, config.directory)
        allImages.push(...typeImages)
      }
      
      console.info(`[SampleImageLoader] 成功加载 ${allImages.length} 张示例图片`)
      return allImages
    } catch (error) {
      console.error(`[SampleImageLoader] 加载示例图片失败: ${error}`)
      return []
    }
  }
  
  async loadImagesByType(imageType: ImageType, directory: string): Promise<SampleImageItem[]> {
    const images: SampleImageItem[] = []
    
    try {
      const predefinedFiles = this.getPredefinedFileList(directory)
      
      let index = 1
      for (let i = 0; i < predefinedFiles.length; i++) {
        const fileName = predefinedFiles[i]
        if (this.isImageFile(fileName)) {
          const imageItem = this.createSampleImageItem(
            fileName,
            imageType,
            directory,
            index
          )
          images.push(imageItem)
          index++
        }
      }
      
      console.info(`[SampleImageLoader] 类型 ${imageType} 加载 ${images.length} 张图片`)
    } catch (error) {
      console.error(`[SampleImageLoader] 加载类型 ${imageType} 图片失败: ${error}`)
    }
    
    return images
  }
  
  private getPredefinedFileList(directory: string): string[] {
    const fileMap = new Map<string, string[]>()
    fileMap.set('chest-xray', ['1.jpg', '2.jpg', '3.jpg', '4.jpg', '5.jpg'])
    fileMap.set('bone-xray', ['1.jpg', '2.jpg', '3.jpg', '4.jpg', '5.webp'])
    fileMap.set('skin-photo', ['1.jpg', '2.jpg', '3.jpg', '4.jpg', '5.jpg'])
    fileMap.set('fundus-photo', ['1.jpg', '2.jpg', '3.jpg', '4.jpg', '5.jpg'])
    fileMap.set('breast-ultrasound', ['1.jpg', '2.jpg', '3.jpg', '4.jpg', '5.jpg'])
    fileMap.set('other', ['1.jpg'])
    
    return fileMap.get(directory) || []
  }
  
  private createSampleImageItem(
    fileName: string,
    imageType: ImageType,
    directory: string,
    index: number
  ): SampleImageItem {
    const imageId = this.generateImageId(imageType, index)
    const rawfilePath = `medical-images/${directory}/${fileName}`
    const format = this.getFileFormat(fileName)
    
    return {
      imageId: imageId,
      imageType: imageType,
      imageName: fileName,
      imageUrl: `resource://RAWFILE/${rawfilePath}`,
      thumbnailUrl: `resource://RAWFILE/${rawfilePath}`,
      format: format,
      size: this.estimateFileSize(format),
      description: `${IMAGE_TYPE_CONFIG.get(imageType)?.name || ''}示例图片${index}`,
      isSample: true
    }
  }
  
  private generateImageId(imageType: ImageType, index: number): string {
    const typePrefix = imageType.replace('_', '-')
    return `SAMPLE-${typePrefix}-${String(index).padStart(3, '0')}`
  }
  
  private isImageFile(fileName: string): boolean {
    const imageExtensions: string[] = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'dcm', 'dicom']
    const extension = this.getFileFormat(fileName).toLowerCase()
    return imageExtensions.includes(extension)
  }
  
  private getFileFormat(fileName: string): string {
    const lastDotIndex = fileName.lastIndexOf('.')
    if (lastDotIndex === -1) {
      return 'unknown'
    }
    return fileName.substring(lastDotIndex + 1).toLowerCase()
  }
  
  private estimateFileSize(format: string): number {
    const sizeMap = new Map<string, number>()
    sizeMap.set('jpg', 2048000)
    sizeMap.set('jpeg', 2048000)
    sizeMap.set('png', 2560000)
    sizeMap.set('webp', 1536000)
    sizeMap.set('gif', 1024000)
    sizeMap.set('bmp', 3072000)
    sizeMap.set('dcm', 5120000)
    sizeMap.set('dicom', 5120000)
    
    return sizeMap.get(format) || 1024000
  }
}

export default SampleImageLoader.getInstance()