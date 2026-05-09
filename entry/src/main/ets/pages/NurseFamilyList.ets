import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

interface FamilyInfo {
  id: number;
  name: string;
  phone: string;
  relation: string;
  relatedPatientName?: string;
  relatedPatientId?: number;
}

@Entry
@Component
struct NurseFamilyList {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;
  @State families: FamilyInfo[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear(): Promise<void> {
    await this.loadFamilies();
  }

  private async loadFamilies(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await HttpUtil.get<FamilyInfo[]>('/nurse/families');
      if (response.success && response.data) {
        this.families = response.data;
      } else {
        ToastUtil.showError(response.message || '加载家属列表失败');
      }
    } catch (error) {
      console.error('加载家属列表失败:', error);
      ToastUtil.showError('加载家属列表失败');
    } finally {
      this.isLoading = false;
    }
  }

  private handleFamilyClick(family: FamilyInfo): void {
    router.pushUrl({
      url: 'pages/NurseFamilyChatPage',
      params: {
        nurseId: this.currentUserId,
        nurseName: '护士',
        currentUserId: this.currentUserId,
        familyId: family.id,
        familyName: family.name,
        relatedPatientName: family.relatedPatientName || ''
      }
    });
  }

  build() {
    Column() {
      Header({ title: '选择家属' })

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.families.length === 0) {
        Column() {
          Text('暂无家属')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.families, (family: FamilyInfo) => {
            ListItem() {
              Row() {
                Column() {
                  Text(family.name)
                    .fontSize(this.isElderMode ? 20 : 18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)

                  Text(`关系: ${family.relation}`)
                    .fontSize(14)
                    .fontColor(GlobalTheme.TEXT_SECONDARY)
                    .margin({ top: 4 })

                  if (family.relatedPatientName) {
                    Text(`关联患者: ${family.relatedPatientName}`)
                      .fontSize(14)
                      .fontColor(GlobalTheme.TEXT_SECONDARY)
                      .margin({ top: 4 })
                  }

                  Text(`电话: ${family.phone}`)
                    .fontSize(14)
                    .fontColor(GlobalTheme.TEXT_SECONDARY)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('>')
                  .fontSize(20)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.handleFamilyClick(family);
              })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
