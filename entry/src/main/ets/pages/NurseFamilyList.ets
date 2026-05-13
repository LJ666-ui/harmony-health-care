import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

interface NurseInfo {
  id: number;
  userId: number;
  nurseNo: string;
  name: string;
}

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
  @StorageLink('nurseInfo') nurseInfoFromStorage: NurseInfo | null = null;
  @State families: FamilyInfo[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear(): Promise<void> {
    console.info('[NurseFamilyList] aboutToAppear currentUserId:', this.currentUserId);
    
    // 如果currentUserId为0，尝试从nurseInfo获取
    if (this.currentUserId === 0 && this.nurseInfoFromStorage) {
      const nurseInfo = this.nurseInfoFromStorage as NurseInfo;
      const fallbackUserId = nurseInfo.userId || nurseInfo.id || 0;
      if (fallbackUserId > 0) {
        console.info('[NurseFamilyList] 从nurseInfo获取userId:', fallbackUserId);
        this.currentUserId = fallbackUserId;
        AppStorage.setOrCreate<number>('userId', fallbackUserId);
      }
    }
    
    console.info('[NurseFamilyList] 最终使用的currentUserId:', this.currentUserId);
    await this.loadFamilies();
  }

  private async loadFamilies(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await HttpUtil.get<FamilyInfo[]>('/nurse/families');
      console.info('[NurseFamilyList] API返回:', JSON.stringify(response));
      
      if (response.success && response.data) {
        console.info('[NurseFamilyList] 家属数量:', response.data.length);
        
        // 手动处理数据，确保ID正确映射
        const rawData: Object[] = response.data as Object[];
        const processedFamilies: FamilyInfo[] = [];
        
        for (let i: number = 0; i < rawData.length; i++) {
          const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
          const family: FamilyInfo = {
            id: Number(raw['id']) || 0,
            name: String(raw['name'] || ''),
            phone: String(raw['phone'] || ''),
            relation: String(raw['relation'] || ''),
            relatedPatientName: raw['relatedPatientName'] ? String(raw['relatedPatientName']) : undefined,
            relatedPatientId: raw['relatedPatientId'] ? Number(raw['relatedPatientId']) : undefined
          };
          
          console.info(`[NurseFamilyList] 处理家属${i}: id=${family.id}, name=${family.name}`);
          processedFamilies.push(family);
        }
        
        this.families = processedFamilies;
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
    console.info('[NurseFamilyList] handleFamilyClick 开始');
    console.info('[NurseFamilyList] currentUserId:', this.currentUserId);
    console.info('[NurseFamilyList] family.id:', family.id);
    console.info('[NurseFamilyList] family.name:', family.name);

    // 尝试多种方式获取有效的nurseId
    let nurseId: number = this.currentUserId;
    
    if (nurseId === 0 && this.nurseInfoFromStorage) {
      const nurseInfo = this.nurseInfoFromStorage as NurseInfo;
      nurseId = nurseInfo.userId || nurseInfo.id || 0;
      console.info('[NurseFamilyList] 从nurseInfo获取nurseId:', nurseId);
    }
    
    // 如果还是0，给出警告但仍然允许继续（后端API会验证身份）
    if (nurseId === 0) {
      console.warn('[NurseFamilyList] ⚠️ 无法确定用户ID，将使用默认值继续');
      nurseId = this.currentUserId; // 使用原始值
    }

    if (!family.id || family.id === 0) {
      console.error('[NurseFamilyList] family.id 无效');
      ToastUtil.showError('家属信息异常');
      return;
    }

    const paramsNurseId: number = nurseId || this.currentUserId;
    
    console.info('[NurseFamilyList] 最终使用的nurseId:', paramsNurseId);
    console.info('[NurseFamilyList] 准备跳转到聊天页面...');

    router.pushUrl({
      url: 'pages/NurseFamilyChatPage',
      params: {
        nurseId: paramsNurseId,
        nurseName: '护士',
        currentUserId: paramsNurseId,
        familyId: family.id,
        familyName: family.name,
        relatedPatientName: family.relatedPatientName || ''
      }
    }).then(() => {
      console.info('[NurseFamilyList] ✅ 跳转成功');
    }).catch((err: Error) => {
      console.error('[NurseFamilyList] ❌ 跳转失败:', err.message);
      ToastUtil.showError('页面跳转失败：' + err.message);
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
          Text('👨‍👩‍👧')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无家属')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text('该护士目前没有负责的患者家属')
            .fontSize(14)
            .fontColor('#BBBBBB')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.families, (family: FamilyInfo, index: number) => {
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
            }
            .width('100%')
            .onClick(() => {
              console.info('[NurseFamilyList] 点击家属:', family.name, 'ID:', family.id);
              this.handleFamilyClick(family);
            })
          }, (family: FamilyInfo) => family.id.toString())
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
