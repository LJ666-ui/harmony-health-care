import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { AdminMock, AdminInfo, FamilyMemberInfo } from '../mock/adminMock';

@Entry
@Component
struct AdminFamily {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentAdmin: AdminInfo | null = null;
  @State searchText: string = '';
  @State filterRelation: string = '';
  @State filterEmergency: number = -1;
  @State filteredList: FamilyMemberInfo[] = [];
  @State currentPage: number = 1;
  @State pageSize: number = 10;
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

  aboutToAppear(): void {
    this.currentAdmin = AppStorage.get<AdminInfo>('currentAdmin') || null;
    this.filterList();
  }

  private filterList(): void {
    let result: FamilyMemberInfo[] = [...AdminMock.familyMembers];
    if (this.searchText) {
      const keyword: string = this.searchText.toLowerCase();
      result = result.filter(f =>
        f.name.toLowerCase().includes(keyword) ||
        f.phone.includes(keyword) ||
        AdminMock.getUserNameById(f.user_id).toLowerCase().includes(keyword)
      );
    }
    if (this.filterRelation) {
      result = result.filter(f => f.relation === this.filterRelation);
    }
    if (this.filterEmergency >= 0) {
      result = result.filter(f => f.is_emergency_contact === this.filterEmergency);
    }
    this.filteredList = result;
    this.currentPage = 1;
  }

  private getPagedList(): FamilyMemberInfo[] {
    const start: number = (this.currentPage - 1) * this.pageSize;
    return this.filteredList.slice(start, start + this.pageSize);
  }

  private getTotalPages(): number {
    return Math.max(1, Math.ceil(this.filteredList.length / this.pageSize));
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
    this.formUserId = fm.user_id.toString();
    this.formRelation = fm.relation;
    this.formPhone = fm.phone;
    this.formGender = fm.gender;
    this.formAge = fm.age.toString();
    this.formAddress = fm.address;
    this.formEmergency = fm.is_emergency_contact;
    this.formHealth = fm.health_condition;
    this.showAddModal = true;
  }

  private saveFamily(): void {
    if (!this.formName.trim() || !this.formUserId.trim()) {
      return;
    }
    if (this.editMode && this.selectedFamily) {
      const idx: number = AdminMock.familyMembers.findIndex(f => f.id === this.selectedFamily!.id);
      if (idx >= 0) {
        AdminMock.familyMembers[idx].name = this.formName;
        AdminMock.familyMembers[idx].user_id = parseInt(this.formUserId) || 0;
        AdminMock.familyMembers[idx].relation = this.formRelation;
        AdminMock.familyMembers[idx].phone = this.formPhone;
        AdminMock.familyMembers[idx].gender = this.formGender;
        AdminMock.familyMembers[idx].age = parseInt(this.formAge) || 0;
        AdminMock.familyMembers[idx].address = this.formAddress;
        AdminMock.familyMembers[idx].is_emergency_contact = this.formEmergency;
        AdminMock.familyMembers[idx].health_condition = this.formHealth;
      }
    } else {
      const newId: number = AdminMock.familyMembers.length > 0 ?
        AdminMock.familyMembers[AdminMock.familyMembers.length - 1].id + 1 : 1;
      AdminMock.familyMembers.push({
        id: newId,
        user_id: parseInt(this.formUserId) || 0,
        name: this.formName,
        relation: this.formRelation,
        phone: this.formPhone,
        id_card: '',
        gender: this.formGender,
        age: parseInt(this.formAge) || 0,
        address: this.formAddress,
        is_emergency_contact: this.formEmergency,
        health_condition: this.formHealth,
        create_time: new Date().toISOString().replace('T', ' ').substring(0, 19),
        update_time: new Date().toISOString().replace('T', ' ').substring(0, 19),
        is_deleted: 0
      });
    }
    this.showAddModal = false;
    this.filterList();
  }

  private deleteFamily(fm: FamilyMemberInfo): void {
    const idx: number = AdminMock.familyMembers.findIndex(f => f.id === fm.id);
    if (idx >= 0) {
      AdminMock.familyMembers.splice(idx, 1);
      this.filterList();
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
            this.filterList();
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
            this.filterList();
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
            this.filterList();
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
              this.filterList();
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
            this.filterList();
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
            this.filterList();
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
            this.filterList();
          });
      }

      Text(`共 ${this.filteredList.length} 条记录`)
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
        ForEach(this.getPagedList(), (fm: FamilyMemberInfo) => {
          Row() {
            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(fm.name)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(GlobalTheme.TEXT_PRIMARY);
                Text(fm.relation)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(AdminMock.getRelationColor(fm.relation))
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor(AdminMock.getRelationColor(fm.relation) + '15')
                  .borderRadius(4);
                if (fm.is_emergency_contact === 1) {
                  Text('紧急')
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#FAAD14')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('#FAAD1415')
                    .borderRadius(4);
                }
              }

              Row({ space: 12 }) {
                Text(`👤 关联：${AdminMock.getUserNameById(fm.user_id)}`)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_SECONDARY);
                Text(`📱 ${fm.phone || '未填写'}`)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_SECONDARY);
              }

              Row({ space: 12 }) {
                Text(`${AdminMock.getGenderName(fm.gender)} · ${fm.age}岁`)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_HINT);
                if (fm.health_condition) {
                  Text(`健康：${fm.health_condition.length > 12 ? fm.health_condition.substring(0, 12) + '...' : fm.health_condition}`)
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
          if (this.currentPage > 1) this.currentPage--;
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
          if (this.currentPage < this.getTotalPages()) this.currentPage++;
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
          this.DetailRow('关联用户', `${AdminMock.getUserNameById(this.selectedFamily!.user_id)}（ID: ${this.selectedFamily!.user_id}）`);
          this.DetailRow('关系', this.selectedFamily!.relation);
          this.DetailRow('性别', AdminMock.getGenderName(this.selectedFamily!.gender));
          this.DetailRow('年龄', `${this.selectedFamily!.age}岁`);
          this.DetailRow('电话', this.selectedFamily!.phone || '未填写');
          this.DetailRow('身份证', this.selectedFamily!.id_card || '未填写');
          this.DetailRow('地址', this.selectedFamily!.address || '未填写');
          this.DetailRow('紧急联系人', this.selectedFamily!.is_emergency_contact === 1 ? '是' : '否');
          this.DetailRow('健康状况', this.selectedFamily!.health_condition || '无');
          this.DetailRow('创建时间', this.selectedFamily!.create_time);
          this.DetailRow('更新时间', this.selectedFamily!.update_time);

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
