import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { FamilyService } from '../services/FamilyService';
import { FamilyMember, FamilyMemberHelper, FamilyRelation, CreateFamilyRequest } from '../models/FamilyMember';
import { SessionManager } from '../utils/SessionManager';
import { BaseResponse } from '../common/utils/HttpUtil';
import { AuthManager, UserRole } from '../utils/AuthManager';

@Entry
@Component
struct FamilyPage {
  @StorageLink('userId') userId: number = 0;
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @State familyMembers: FamilyMember[] = [];
  @State isLoading: boolean = false;
  @State showAddDialog: boolean = false;
  @State editingMember: FamilyMember | null = null;
  @State hasAccess: boolean = false;

  @State newMember: CreateFamilyRequest = {
    name: '',
    relation: FamilyRelation.OTHER,
    phone: '',
    isEmergencyContact: false
  };

  aboutToAppear(): void {
    this.checkAccess();
  }

  private checkAccess(): void {
    const authManager: AuthManager = AuthManager.getInstance();
    const currentRole: UserRole = authManager.getCurrentRole();

    if (currentRole === UserRole.GUEST) {
      promptAction.showToast({ message: '请先登录' });
      router.replaceUrl({ url: 'pages/Login' });
      return;
    }

    if (currentRole !== UserRole.USER && currentRole !== UserRole.DOCTOR) {
      promptAction.showToast({ message: '无权访问此页面' });
      router.back();
      return;
    }

    this.hasAccess = true;
    this.loadFamilyMembers();
  }

  async loadFamilyMembers(): Promise<void> {
    this.isLoading = true;
    try {
      const response: BaseResponse<FamilyMember[]> = await FamilyService.getMyFamily();
      if (response.success && response.data) {
        this.familyMembers = response.data;
      } else {
        promptAction.showToast({ message: response.message || '加载家属信息失败' });
      }
    } catch (e) {
      console.error('Load family members failed:', e);
      promptAction.showToast({ message: '加载家属信息失败' });
    } finally {
      this.isLoading = false;
    }
  }

  async deleteMember(id: number): Promise<void> {
    promptAction.showDialog({
      title: '确认删除',
      message: '确定要删除这位家属信息吗？',
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '删除', color: '#FF0000' }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        try {
          const response: BaseResponse<void> = await FamilyService.deleteFamily(id);
          if (response.success) {
            promptAction.showToast({ message: '删除成功' });
            await this.loadFamilyMembers();
          } else {
            promptAction.showToast({ message: response.message || '删除失败' });
          }
        } catch (e) {
          console.error('Delete family member failed:', e);
          promptAction.showToast({ message: '删除失败' });
        }
      }
    });
  }

  async setEmergency(id: number, isEmergency: boolean): Promise<void> {
    try {
      const response: BaseResponse<FamilyMember> = await FamilyService.setEmergencyContact(id, isEmergency);
      if (response.success) {
        promptAction.showToast({ message: isEmergency ? '已设为紧急联系人' : '已取消紧急联系人' });
        await this.loadFamilyMembers();
      } else {
        promptAction.showToast({ message: response.message || '操作失败' });
      }
    } catch (e) {
      console.error('Set emergency contact failed:', e);
      promptAction.showToast({ message: '操作失败' });
    }
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .onClick(() => router.back())
        
        Text('家属管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('新增')
          .onClick(() => {
            this.showAddDialog = true;
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 100 })
      } else if (this.familyMembers.length === 0) {
        Column() {
          Text('暂无家属信息')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 16 })
          
          Button('添加家属')
            .onClick(() => {
              this.showAddDialog = true;
            })
        }
        .margin({ top: 100 })
      } else {
        List() {
          ForEach(this.familyMembers, (member: FamilyMember) => {
            ListItem() {
              Column() {
                Row() {
                  Text(FamilyMemberHelper.getDisplayName(member))
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                  
                  Blank()
                  
                  if (member.isEmergencyContact) {
                    Text('紧急联系人')
                      .fontSize(12)
                      .fontColor('#FF0000')
                      .backgroundColor('#FFECEC')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(4)
                  }
                }
                .width('100%')

                Row() {
                  Text(`关系: ${FamilyMemberHelper.getRelationLabel(member.relation)}`)
                    .fontSize(14)
                    .fontColor('#666666')
                  
                  Text(`电话: ${FamilyMemberHelper.maskPhone(member.phone)}`)
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ left: 16 })
                }
                .width('100%')
                .margin({ top: 8 })

                Row() {
                  Button(member.isEmergencyContact ? '取消紧急联系人' : '设为紧急联系人')
                    .fontSize(12)
                    .height(32)
                    .onClick(() => {
                      this.setEmergency(member.id, !member.isEmergencyContact);
                    })

                  Button('删除')
                    .fontSize(12)
                    .height(32)
                    .fontColor('#FF0000')
                    .backgroundColor('#FFECEC')
                    .margin({ left: 8 })
                    .onClick(() => {
                      this.deleteMember(member.id);
                    })
                }
                .width('100%')
                .margin({ top: 8 })
                .justifyContent(FlexAlign.End)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .margin({ bottom: 8 })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet($$this.showAddDialog, this.addMemberSheet(), {
      height: 400,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  addMemberSheet() {
    Column() {
      Text('新增家属')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      TextInput({ placeholder: '姓名' })
        .width('90%')
        .height(40)
        .onChange((value: string) => {
          this.newMember.name = value;
        })

      TextInput({ placeholder: '电话' })
        .width('90%')
        .height(40)
        .margin({ top: 12 })
        .onChange((value: string) => {
          this.newMember.phone = value;
        })

      Row() {
        Text('关系:')
        Select([
          { value: FamilyRelation.SPOUSE },
          { value: FamilyRelation.CHILD },
          { value: FamilyRelation.PARENT },
          { value: FamilyRelation.SIBLING },
          { value: FamilyRelation.OTHER }
        ])
          .selected(4)
          .onSelect((index: number) => {
            const relations: string[] = [
              FamilyRelation.SPOUSE,
              FamilyRelation.CHILD,
              FamilyRelation.PARENT,
              FamilyRelation.SIBLING,
              FamilyRelation.OTHER
            ];
            this.newMember.relation = relations[index];
          })
      }
      .width('90%')
      .margin({ top: 12 })

      Row() {
        Text('紧急联系人')
        Toggle({ type: ToggleType.Switch, isOn: this.newMember.isEmergencyContact || false })
          .onChange((isOn: boolean) => {
            this.newMember.isEmergencyContact = isOn;
          })
      }
      .width('90%')
      .margin({ top: 12 })

      Button('保存')
        .width('90%')
        .height(40)
        .margin({ top: 20 })
        .onClick(async () => {
          if (!this.newMember.name || !this.newMember.phone) {
            promptAction.showToast({ message: '请填写姓名和电话' });
            return;
          }
          
          try {
            const response: BaseResponse<FamilyMember> = await FamilyService.addFamily(this.newMember);
            if (response.success) {
              promptAction.showToast({ message: '添加成功' });
              this.showAddDialog = false;
              this.newMember = {
                name: '',
                relation: FamilyRelation.OTHER,
                phone: '',
                isEmergencyContact: false
              };
              await this.loadFamilyMembers();
            } else {
              promptAction.showToast({ message: response.message || '添加失败' });
            }
          } catch (e) {
            console.error('Add family member failed:', e);
            promptAction.showToast({ message: '添加失败' });
          }
        })
    }
    .width('100%')
    .padding(20)
  }
}
