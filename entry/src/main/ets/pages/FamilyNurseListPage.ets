import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import type { Nurse } from '../models/Nurse';

@Entry
@Component
struct FamilyNurseListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State nurses: Nurse[] = [];
  @State isLoading: boolean = true;
  @State searchKeyword: string = '';
  @State familyId: number = 0;

  aboutToAppear(): void {
    console.info('[FamilyNurseListPage] aboutToAppear currentUserId:', this.currentUserId);
    
    const params: Object | undefined = router.getParams();
    if (params) {
      const p: Record<string, Object> = params as Record<string, Object>;
      this.familyId = p['familyId'] as number || this.currentUserId;
      console.info('[FamilyNurseListPage] 从参数获取familyId:', this.familyId);
    } else {
      this.familyId = this.currentUserId;
      console.info('[FamilyNurseListPage] 无参数，使用currentUserId:', this.familyId);
    }
    this.loadNurses();
  }

  private async loadNurses(): Promise<void> {
    this.isLoading = true;
    try {
      const params: Record<string, string> = {};
      if (this.searchKeyword && this.searchKeyword.trim() !== '') {
        params['keyword'] = this.searchKeyword.trim();
      }

      const response: BaseResponse<Nurse[]> = await HttpUtil.get<Nurse[]>('/nurse/list', params);
      
      if (response.success && response.data) {
        this.nurses = response.data;
      } else {
        ToastUtil.showError(response.message || '获取护士列表失败');
      }
    } catch (error) {
      console.error('加载护士列表失败:', error);
      ToastUtil.showError('加载护士列表失败');
    } finally {
      this.isLoading = false;
    }
  }

  private handleNurseClick(nurse: Nurse): void {
    console.info('[FamilyNurseList] handleNurseClick 开始');
    console.info('[FamilyNurseList] familyId:', this.familyId);
    console.info('[FamilyNurseList] currentUserId:', this.currentUserId);
    console.info('[FamilyNurseList] nurse.id:', nurse.id);
    console.info('[FamilyNurseList] nurse.name:', nurse.name);

    if (this.familyId === 0 && this.currentUserId === 0) {
      console.error('[FamilyNurseList] 用户ID无效');
      ToastUtil.showError('用户信息异常，请重新登录');
      return;
    }

    if (!nurse.id || nurse.id === 0) {
      console.error('[FamilyNurseList] nurse.id 无效');
      ToastUtil.showError('护士信息异常');
      return;
    }

    const targetFamilyId: number = this.familyId || this.currentUserId;

    router.pushUrl({
      url: 'pages/FamilyNurseChatPage',
      params: {
        familyId: targetFamilyId,
        nurseId: nurse.id,
        nurseName: nurse.name,
        relatedPatientName: ''
      }
    }).then(() => {
      console.info('[FamilyNurseList] 跳转成功');
    }).catch((err: Error) => {
      console.error('[FamilyNurseList] 跳转失败:', err.message);
      ToastUtil.showError('页面跳转失败：' + err.message);
    });
  }

  private getDepartmentIcon(department: string): string {
    const iconMap: Record<string, string> = {
      '内科': '🏥',
      '外科': '🔪',
      '儿科': '👶',
      '妇产科': '👩',
      '急诊科': '🚑',
      'ICU': '❤️‍🩹',
      '护理部': '💉'
    };
    return iconMap[department] || '🏥';
  }

  build() {
    Column() {
      Header({ title: '选择护士', showBack: true })

      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索护士姓名或工号...', text: this.searchKeyword })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.loadNurses();
          })

        Button('搜索')
          .height(36)
          .padding({ left: 16, right: 16 })
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .borderRadius(18)
          .margin({ left: 8 })
          .onClick(() => {
            this.loadNurses();
          });
      }
      .width('95%')
      .margin({ top: 15, bottom: 10 })

      // 护士列表
      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.nurses.length === 0) {
        Column() {
          Text('👩‍⚕️')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无可用护士')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text('请稍后再试或联系管理员')
            .fontSize(14)
            .fontColor('#BBBBBB')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.nurses, (nurse: Nurse, index: number) => {
            ListItem() {
              Row() {
                // 头像
                Image(nurse.avatar || $r('app.media.startIcon'))
                  .width(50)
                  .height(50)
                  .borderRadius(25)
                  .backgroundColor('#E8F5E9')

                // 信息
                Column() {
                  Row() {
                    Text(nurse.name)
                      .fontSize(this.isElderMode ? 18 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(GlobalTheme.TEXT_PRIMARY)
                      .layoutWeight(1)

                    Text(nurse.nurseNo || 'N' + nurse.id)
                      .fontSize(12)
                      .fontColor('#722ED1')
                      .backgroundColor('#F9F0FF')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(4)
                  }
                  .width('100%')

                  Row() {
                    Text(`${this.getDepartmentIcon(nurse.department)} ${nurse.department}`)
                      .fontSize(13)
                      .fontColor('#52C41A')

                    if (nurse.title) {
                      Text(`  ${nurse.title}`)
                        .fontSize(13)
                        .fontColor('#666666')
                    }
                  }
                  .width('100%')
                  .margin({ top: 4 })

                  Text(`工号: ${nurse.nurseNo}`)
                    .fontSize(11)
                    .fontColor('#BBBBBB')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 12 })

                // 箭头
                Text('>')
                  .fontSize(20)
                  .fontColor('#CCCCCC')
                  .margin({ left: 8 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
            }
            .width('100%')
            .onClick(() => {
              console.info('[FamilyNurseList] 点击护士:', nurse.name, 'ID:', nurse.id);
              this.handleNurseClick(nurse);
            })
          }, (nurse: Nurse) => nurse.id.toString())
        }
        .width('95%')
        .layoutWeight(1)
        .padding({ top: 8, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}