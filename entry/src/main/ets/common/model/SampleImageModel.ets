export enum ImageType {
  CHEST_XRAY = 'CHEST_XRAY',
  BONE_XRAY = 'BONE_XRAY',
  SKIN_PHOTO = 'SKIN_PHOTO',
  FUNDUS_PHOTO = 'FUNDUS_PHOTO',
  BREAST_ULTRASOUND = 'BREAST_ULTRASOUND',
  OTHER = 'OTHER'
}

export interface SampleImageItem {
  imageId: string
  imageType: ImageType
  imageName: string
  imageUrl: string
  thumbnailUrl: string
  format: string
  size: number
  description: string
  isSample: boolean
}

export interface ImageTypeGroup {
  type: ImageType
  typeName: string
  typeIcon: string
  images: SampleImageItem[]
  isExpanded: boolean
}

export interface ImageTypeInfo {
  name: string
  icon: string
  directory: string
}

const imageTypeConfigMap: Array<[ImageType, ImageTypeInfo]> = [
  [ImageType.CHEST_XRAY, { name: '胸部X光', icon: '📷', directory: 'chest-xray' }],
  [ImageType.BONE_XRAY, { name: '骨骼X光', icon: '🦴', directory: 'bone-xray' }],
  [ImageType.SKIN_PHOTO, { name: '皮肤照片', icon: '🔬', directory: 'skin-photo' }],
  [ImageType.FUNDUS_PHOTO, { name: '眼底照片', icon: '👁', directory: 'fundus-photo' }],
  [ImageType.BREAST_ULTRASOUND, { name: '乳腺超声', icon: '💝', directory: 'breast-ultrasound' }],
  [ImageType.OTHER, { name: '其他类型', icon: '📁', directory: 'other' }]
]

export const IMAGE_TYPE_CONFIG: Map<ImageType, ImageTypeInfo> = new Map<ImageType, ImageTypeInfo>(imageTypeConfigMap)