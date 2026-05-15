import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse, HttpMethod, RequestOptions } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { CurrentAdmin } from '../services/AdminAuthService';

interface FamilyMemberInfo {
  id: number;
  userId: number;
  name: string;
  relation: string;
  phone: string;
  idCard: string;
  gender: number;
  age: number;
  address: string;
  isEmergencyContact: number;
  healthCondition: string;
  createTime: string;
  updateTime: string;
}

@Entry
@Component
struct AdminFamily {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentAdmin: CurrentAdmin | null = null;
  @State searchText: string = '';
  @State filterRelation: string = '';
  @State filterEmergency: number = -1;
  @State familyList: FamilyMemberInfo[] = [];
  @State totalRecords: number = 0;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State isLoading: boolean = false;
  @State showAddModal: boolean = false;
  @State showDetailModal: boolean = false;
  @State selectedFamily: FamilyMemberInfo | null = null;
  @State editMode: boolean = false;

  @State formName: string = '';
  @State formUserId: string = '';
  @State formRelation: string = '配偶';
  @State formPhone: string = '';
  @State formGender: number = 1;
  @State formAge: string = '';
  @State formAddress: string = '';
  @State formEmergency: number = 0;
  @State formHealth: string = '';

  private relations: string[] = ['配偶', '子女', '父母', '兄弟姐妹', '其他'];

  private getRelationColor(relation: string): string {
    const map: Record<string, string> = {
      '配偶': '#E91E63',
      '子女': '#2196F3',
      '父母': '#FF9800',
      '兄弟姐妹': '#4CAF50',
      '其他': '#9E9E9E'
    };
    return map[relation] || '#9E9E9E';
  }

  private getGenderName(gender: number): string {
    if (gender === 1) return '男';
    if (gender === 2) return '女';
    return '未知';
  }

  aboutToAppear(): void {
    this.currentAdmin = AppStorage.get<CurrentAdmin>('currentAdmin') || null;
    this.loadFamilyList();
  }

  private async loadFamilyList(): Promise<void> {
    this.isLoading = true;
    try {
      const params: Record<string, Object> = {
        'page': String(this.currentPage),
        'size': String(this.pageSize)
      };
      if (this.searchText.trim()) {
        params['keyword'] = this.searchText.trim();
      }
      if (this.filterRelation) {
        params['relation'] = this.filterRelation;
      }
      if (this.filterEmergency >= 0) {
        params['isEmergencyContact'] = String(this.filterEmergency);
      }

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.ADMIN_FAMILY_LIST,
        undefined,
        params as Object,
        { isAdmin: true } as RequestOptions
      );

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        const records = data['records'];
        if (Array.isArray(records)) {
          this.familyList = records.map((r: Object): FamilyMemberInfo => {
            const item = r as Record<string, Object>;
            return {
              id: Number(item['id']) || 0,
              userId: Number(item['userId'] || item['user_id']) || 0,
              name: String(item['name'] || ''),
              relation: String(item['relation'] || ''),
              phone: String(item['phone'] || ''),
              idCard: String(item['idCard'] || item['id_card'] || ''),
              gender: Number(item['gender']) || 0,
              age: Number(item['age']) || 0,
              address: String(item['address'] || ''),
              isEmergencyContact: Number(item['isEmergencyContact'] || item['is_emergency_contact']) || 0,
              healthCondition: String(item['healthCondition'] || item['health_condition'] || ''),
              createTime: String(item['createTime'] || item['create_time'] || ''),
              updateTime: String(item['updateTime'] || item['update_time'] || '')
            };
          });
          this.totalRecords = Number(data['total']) || 0;
        }
      } else {
        ToastUtil.showError(response.message || '加载家属列表失败', 2000);
      }
    } catch (error) {
      console.error('[AdminFamily] 加载失败:', error);
      ToastUtil.showError('网络错误，请检查后端服务', 2000);
    } finally {
      this.isLoading = false;
    }
  }

  private getTotalPages(): number {
    return Math.max(1, Math.ceil(this.totalRecords / this.pageSize));
  }

  private openAddModal(): void {
    this.editMode = false;
    this.formName = '';
    this.formUserId = '';
    this.formRelation = '配偶';
    this.formPhone = '';
    this.formGender = 1;
    this.formAge = '';
    this.formAddress = '';
    this.formEmergency = 0;
    this.formHealth = '';
    this.showAddModal = true;
  }

  private openEditModal(fm: FamilyMemberInfo): void {
    this.editMode = true;
    this.selectedFamily = fm;
    this.formName = fm.name;
    this.formUserId = fm.userId.toString();
    this.formRelation = fm.relation;
    this.formPhone = fm.phone;
    this.formGender = fm.gender;
    this.formAge = fm.age.toString();
    this.formAddress = fm.address;
    this.formEmergency = fm.isEmergencyContact;
    this.formHealth = fm.healthCondition;
    this.showAddModal = true;
  }

  private async saveFamily(): Promise<void> {
    if (!this.formName.trim() || !this.formUserId.trim()) {
      ToastUtil.showError('家属姓名和关联用户ID不能为空', 1500);
      return;
    }

    try {
      const body: Record<string, Object> = {
        'name': this.formName,
        'userId': this.formUserId,
        'relation': this.formRelation,
        'phone': this.formPhone,
        'gender': this.formGender,
        'age': this.formAge || 0,
        'address': this.formAddress,
        'isEmergencyContact': this.formEmergency,
        'healthCondition': this.formHealth
      };

      let response: BaseResponse<Object>;

      if (this.editMode && this.selectedFamily) {
        body['id'] = this.selectedFamily.id;
        response = await HttpUtil.request<Object>(
          HttpMethod.POST,
          ApiConstants.ADMIN_FAMILY_UPDATE,
          body as Object,
          undefined,
          { isAdmin: true } as RequestOptions
        );
      } else {
        response = await HttpUtil.request<Object>(
          HttpMethod.POST,
          ApiConstants.ADMIN_FAMILY_ADD,
          body as Object,
          undefined,
          { isAdmin: true } as RequestOptions
        );
      }

      if (response.success) {
        ToastUtil.showSuccess(this.editMode ? '更新成功' : '添加成功', 1500);
        this.showAddModal = false;
        this.loadFamilyList();
      } else {
        ToastUtil.showError(response.message || '操作失败', 2000);
      }
    } catch (error) {
      console.error('[AdminFamily] 保存失败:', error);
      ToastUtil.showError('网络错误，请稍后重试', 2000);
    }
  }

  private async deleteFamily(fm: FamilyMemberInfo): Promise<void> {
    try {
      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.ADMIN_FAMILY_DELETE + fm.id,
        undefined,
        undefined,
        { isAdmin: true } as RequestOptions
      );

      if (response.success) {
        ToastUtil.showSuccess('删除成功', 1500);
        this.loadFamilyList();
      } else {
        ToastUtil.showError(response.message || '删除失败', 2000);
      }
    } catch (error) {
      console.error('[AdminFamily] 删除失败:', error);
      ToastUtil.showError('网络错误', 2000);
    }
  }

  build() {
    Column() {
      this.TitleBar();
      this.SearchBar();
      this.FamilyList();
      this.Pagination();

      if (this.showAddModal) {
        this.AddModal();
      }
      if (this.showDetailModal && this.selectedFamily) {
        this.DetailModal();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  TitleBar() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text('←')
          .fontSize(20)
          .fontColor('#FFFFFF');
      }
      .width(40)
      .height(40)
      .backgroundColor('#334155')
      .borderRadius(10)
      .onClick(() => {
        router.back();
      });

      Text('家属管理')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .textAlign(TextAlign.Center);

      Button({ type: ButtonType.Normal }) {
        Text('+ 新增')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#FFFFFF');
      }
      .height(36)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#52C41A')
      .borderRadius(8)
      .onClick(() => {
        this.openAddModal();
      });
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#1E293B')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  SearchBar() {
    Column({ space: 10 }) {
      Row() {
        TextInput({ placeholder: '搜索家属姓名、电话、关联用户...', text: this.searchText })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 12 })
          .onChange((value: string) => {
            this.searchText = value;
            this.loadFamilyList();
          });
        if (this.searchText) {
          Button({ type: ButtonType.Normal }) {
            Text('✕')
              .fontSize(14)
              .fontColor('#999');
          }
          .width(32)
          .height(32)
          .backgroundColor('#F5F5F5')
          .borderRadius(6)
          .margin({ left: 8 })
          .onClick(() => {
            this.searchText = '';
            this.loadFamilyList();
          });
        }
      }

      Row({ space: 6 }) {
        Text('关系：')
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .fontColor(GlobalTheme.TEXT_SECONDARY);

        Button('全部')
          .height(28)
          .fontSize(10)
          .padding({ left: 8, right: 8 })
          .backgroundColor(!this.filterRelation ? '#1677FF' : '#F0F0F0')
          .fontColor(!this.filterRelation ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterRelation = '';
            this.loadFamilyList();
          });

        ForEach(this.relations, (rel: string) => {
          Button(rel)
            .height(28)
            .fontSize(10)
            .padding({ left: 8, right: 8 })
            .backgroundColor(this.filterRelation === rel ? '#1677FF' : '#F0F0F0')
            .fontColor(this.filterRelation === rel ? '#FFFFFF' : '#666666')
            .borderRadius(6)
            .onClick(() => {
              this.filterRelation = rel;
              this.loadFamilyList();
            });
        }, (rel: string) => rel);
      }

      Row({ space: 6 }) {
        Text('紧急联系人：')
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .fontColor(GlobalTheme.TEXT_SECONDARY);

        Button('全部')
          .height(28)
          .fontSize(10)
          .padding({ left: 8, right: 8 })
          .backgroundColor(this.filterEmergency === -1 ? '#FAAD14' : '#F0F0F0')
          .fontColor(this.filterEmergency === -1 ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterEmergency = -1;
            this.loadFamilyList();
          });

        Button('是')
          .height(28)
          .fontSize(10)
          .padding({ left: 8, right: 8 })
          .backgroundColor(this.filterEmergency === 1 ? '#FAAD14' : '#F0F0F0')
          .fontColor(this.filterEmergency === 1 ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterEmergency = 1;
            this.loadFamilyList();
          });

        Button('否')
          .height(28)
          .fontSize(10)
          .padding({ left: 8, right: 8 })
          .backgroundColor(this.filterEmergency === 0 ? '#FAAD14' : '#F0F0F0')
          .fontColor(this.filterEmergency === 0 ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterEmergency = 0;
            this.loadFamilyList();
          });
      }

      Text(`共 ${this.totalRecords} 条记录`)
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_HINT)
        .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12, left: 12, right: 12 });
  }

  @Builder
  FamilyList() {
    Scroll() {
      Column({ space: 8 }) {
        ForEach(this.familyList, (fm: FamilyMemberInfo) => {
          Row() {
            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(fm.name)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(GlobalTheme.TEXT_PRIMARY);
                Text(fm.relation)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(this.getRelationColor(fm.relation))
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor(this.getRelationColor(fm.relation) + '15')
                  .borderRadius(4);
                if (fm.isEmergencyContact === 1) {
                  Text('紧急')
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#FAAD14')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('#FAAD1415')
                    .borderRadius(4);
                }
              }

              Row({ space: 12 }) {
                Text(`👤 关联用户ID：${fm.userId}`)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_SECONDARY);
                Text(`📱 ${fm.phone || '未填写'}`)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_SECONDARY);
              }

              Row({ space: 12 }) {
                Text(`${this.getGenderName(fm.gender)} · ${fm.age}岁`)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_HINT);
                if (fm.healthCondition) {
                  Text(`健康：${fm.healthCondition.length > 12 ? fm.healthCondition.substring(0, 12) + '...' : fm.healthCondition}`)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_HINT)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1);

            Column({ space: 6 }) {
              Button({ type: ButtonType.Normal }) {
                Text('详情')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor('#1677FF');
              }
              .height(28)
              .padding({ left: 10, right: 10 })
              .backgroundColor('#1677FF15')
              .borderRadius(6)
              .onClick(() => {
                this.selectedFamily = fm;
                this.showDetailModal = true;
              });

              Row({ space: 6 }) {
                Button({ type: ButtonType.Normal }) {
                  Text('✏️')
                    .fontSize(14);
                }
                .width(28)
                .height(28)
                .backgroundColor('#FAAD1415')
                .borderRadius(6)
                .onClick(() => {
                  this.openEditModal(fm);
                });

                Button({ type: ButtonType.Normal }) {
                  Text('🗑️')
                    .fontSize(14);
                }
                .width(28)
                .height(28)
                .backgroundColor('#FF4D4F15')
                .borderRadius(6)
                .onClick(() => {
                  this.deleteFamily(fm);
                });
              }
            }
            .alignItems(HorizontalAlign.End);
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid });
        }, (fm: FamilyMemberInfo) => `${fm.id}`);
      }
      .padding({ left: 12, right: 12, top: 8 });
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto);
  }

  @Builder
  Pagination() {
    Row({ space: 8 }) {
      Button('上一页')
        .height(32)
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.currentPage > 1 ? '#1677FF' : '#E8ECF2')
        .fontColor(this.currentPage > 1 ? '#FFFFFF' : '#999999')
        .borderRadius(6)
        .enabled(this.currentPage > 1)
        .onClick(() => {
          if (this.currentPage > 1) {
            this.currentPage--;
            this.loadFamilyList();
          }
        });

      Text(`${this.currentPage} / ${this.getTotalPages()}`)
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY);

      Button('下一页')
        .height(32)
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.currentPage < this.getTotalPages() ? '#1677FF' : '#E8ECF2')
        .fontColor(this.currentPage < this.getTotalPages() ? '#FFFFFF' : '#999999')
        .borderRadius(6)
        .enabled(this.currentPage < this.getTotalPages())
        .onClick(() => {
          if (this.currentPage < this.getTotalPages()) {
            this.currentPage++;
            this.loadFamilyList();
          }
        });
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .border({ width: 0.5, color: '#E2E8F0', style: BorderStyle.Solid });
  }

  @Builder
  AddModal() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000066')
        .onClick(() => {
          this.showAddModal = false;
        });

      Scroll() {
        Column({ space: 14 }) {
          Text(this.editMode ? '编辑家属' : '新增家属')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY);

          Column({ space: 4 }) {
            Text('家属姓名 *')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextInput({ placeholder: '请输入家属姓名', text: this.formName })
              .height(42)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.formName = value;
              });
          }

          Column({ space: 4 }) {
            Text('关联用户ID *')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextInput({ placeholder: '请输入关联用户ID', text: this.formUserId })
              .type(InputType.Number)
              .height(42)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.formUserId = value;
              });
          }

          Column({ space: 4 }) {
            Text('与用户关系 *')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            Row({ space: 6 }) {
              ForEach(this.relations, (rel: string) => {
                Button(rel)
                  .height(32)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .padding({ left: 10, right: 10 })
                  .backgroundColor(this.formRelation === rel ? '#1677FF' : '#F0F0F0')
                  .fontColor(this.formRelation === rel ? '#FFFFFF' : '#666666')
                  .borderRadius(6)
                  .onClick(() => {
                    this.formRelation = rel;
                  });
              }, (rel: string) => rel);
            }
          }

          Column({ space: 4 }) {
            Text('联系电话')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextInput({ placeholder: '请输入联系电话', text: this.formPhone })
              .type(InputType.PhoneNumber)
              .height(42)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.formPhone = value;
              });
          }

          Row({ space: 12 }) {
            Column({ space: 4 }) {
              Text('性别')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
              Row({ space: 6 }) {
                Button('男')
                  .height(32)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .padding({ left: 12, right: 12 })
                  .backgroundColor(this.formGender === 1 ? '#1677FF' : '#F0F0F0')
                  .fontColor(this.formGender === 1 ? '#FFFFFF' : '#666666')
                  .borderRadius(6)
                  .onClick(() => {
                    this.formGender = 1;
                  });
                Button('女')
                  .height(32)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .padding({ left: 12, right: 12 })
                  .backgroundColor(this.formGender === 2 ? '#EC4899' : '#F0F0F0')
                  .fontColor(this.formGender === 2 ? '#FFFFFF' : '#666666')
                  .borderRadius(6)
                  .onClick(() => {
                    this.formGender = 2;
                  });
              }
            }
            .layoutWeight(1);

            Column({ space: 4 }) {
              Text('年龄')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
              TextInput({ placeholder: '年龄', text: this.formAge })
                .type(InputType.Number)
                .height(42)
                .backgroundColor('#F8FAFC')
                .borderRadius(8)
                .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
                .padding({ left: 12 })
                .onChange((value: string) => {
                  this.formAge = value;
                });
            }
            .layoutWeight(1);
          }

          Column({ space: 4 }) {
            Text('居住地址')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextInput({ placeholder: '请输入居住地址', text: this.formAddress })
              .height(42)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.formAddress = value;
              });
          }

          Column({ space: 4 }) {
            Text('是否紧急联系人')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            Row({ space: 8 }) {
              Button('否')
                .height(32)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.formEmergency === 0 ? '#FAAD14' : '#F0F0F0')
                .fontColor(this.formEmergency === 0 ? '#FFFFFF' : '#666666')
                .borderRadius(6)
                .onClick(() => {
                  this.formEmergency = 0;
                });
              Button('是')
                .height(32)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.formEmergency === 1 ? '#FAAD14' : '#F0F0F0')
                .fontColor(this.formEmergency === 1 ? '#FFFFFF' : '#666666')
                .borderRadius(6)
                .onClick(() => {
                  this.formEmergency = 1;
                });
            }
          }

          Column({ space: 4 }) {
            Text('健康状况')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextArea({ placeholder: '请输入健康状况备注', text: this.formHealth })
              .height(60)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding(12)
              .onChange((value: string) => {
                this.formHealth = value;
              });
          }

          Row({ space: 12 }) {
            Button('取消')
              .layoutWeight(1)
              .height(44)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .backgroundColor('#F0F0F0')
              .fontColor('#666666')
              .borderRadius(10)
              .onClick(() => {
                this.showAddModal = false;
              });
            Button('保存')
              .layoutWeight(1)
              .height(44)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .backgroundColor('#52C41A')
              .fontColor('#FFFFFF')
              .borderRadius(10)
              .onClick(() => {
                this.saveFamily();
              });
          }
          .width('100%');
        }
        .width('85%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 20, color: '#00000033', offsetX: 0, offsetY: 4 });
      }
      .scrollBar(BarState.Auto);
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }

  @Builder
  DetailModal() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000066')
        .onClick(() => {
          this.showDetailModal = false;
        });

      Scroll() {
        Column({ space: 12 }) {
          Row() {
            Text('家属详情')
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.TEXT_PRIMARY);
            Blank();
            Text('✕')
              .fontSize(20)
              .fontColor(GlobalTheme.TEXT_HINT)
              .onClick(() => {
                this.showDetailModal = false;
              });
          }
          .width('100%');

          Divider().color('#E2E8F0');

          this.DetailRow('ID', `${this.selectedFamily!.id}`);
          this.DetailRow('姓名', this.selectedFamily!.name);
          this.DetailRow('关联用户ID', `${this.selectedFamily!.userId}`);
          this.DetailRow('关系', this.selectedFamily!.relation);
          this.DetailRow('性别', this.getGenderName(this.selectedFamily!.gender));
          this.DetailRow('年龄', `${this.selectedFamily!.age}岁`);
          this.DetailRow('电话', this.selectedFamily!.phone || '未填写');
          this.DetailRow('身份证', this.selectedFamily!.idCard || '未填写');
          this.DetailRow('地址', this.selectedFamily!.address || '未填写');
          this.DetailRow('紧急联系人', this.selectedFamily!.isEmergencyContact === 1 ? '是' : '否');
          this.DetailRow('健康状况', this.selectedFamily!.healthCondition || '无');
          this.DetailRow('创建时间', this.selectedFamily!.createTime);
          this.DetailRow('更新时间', this.selectedFamily!.updateTime);

          Button('关闭')
            .width('100%')
            .height(44)
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .backgroundColor('#F0F0F0')
            .fontColor('#666666')
            .borderRadius(10)
            .margin({ top: 4 })
            .onClick(() => {
              this.showDetailModal = false;
            });
        }
        .width('85%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 20, color: '#00000033', offsetX: 0, offsetY: 4 });
      }
      .scrollBar(BarState.Auto);
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }

  @Builder
  DetailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width(80);
      Text(value)
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .layoutWeight(1);
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 });
  }
}
