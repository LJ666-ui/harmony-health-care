import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { AdminMock, AdminInfo, UserInfo, FamilyMemberInfo } from '../mock/adminMock';

@Entry
@Component
struct AdminUsers {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentAdmin: AdminInfo | null = null;
  @State searchText: string = '';
  @State filterType: number = -1;
  @State filteredUsers: UserInfo[] = [];
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State showAddModal: boolean = false;
  @State showDetailModal: boolean = false;
  @State selectedUser: UserInfo | null = null;
  @State editMode: boolean = false;

  @State formUsername: string = '';
  @State formPhone: string = '';
  @State formAge: string = '';
  @State formIdCard: string = '';
  @State formUserType: number = 0;

  aboutToAppear(): void {
    this.currentAdmin = AppStorage.get<AdminInfo>('currentAdmin') || null;
    this.filterUsers();
  }

  private filterUsers(): void {
    let result: UserInfo[] = [...AdminMock.users];
    if (this.searchText) {
      const keyword: string = this.searchText.toLowerCase();
      result = result.filter(u =>
        u.username.toLowerCase().includes(keyword) ||
        u.phone.includes(keyword) ||
        u.id_card.includes(keyword)
      );
    }
    if (this.filterType >= 0) {
      result = result.filter(u => u.user_type === this.filterType);
    }
    this.filteredUsers = result;
    this.currentPage = 1;
  }

  private getPagedUsers(): UserInfo[] {
    const start: number = (this.currentPage - 1) * this.pageSize;
    return this.filteredUsers.slice(start, start + this.pageSize);
  }

  private getTotalPages(): number {
    return Math.max(1, Math.ceil(this.filteredUsers.length / this.pageSize));
  }

  private openAddModal(): void {
    this.editMode = false;
    this.formUsername = '';
    this.formPhone = '';
    this.formAge = '';
    this.formIdCard = '';
    this.formUserType = 0;
    this.showAddModal = true;
  }

  private openEditModal(user: UserInfo): void {
    this.editMode = true;
    this.selectedUser = user;
    this.formUsername = user.username;
    this.formPhone = user.phone;
    this.formAge = user.age.toString();
    this.formIdCard = user.id_card;
    this.formUserType = user.user_type;
    this.showAddModal = true;
  }

  private saveUser(): void {
    if (!this.formUsername.trim() || !this.formPhone.trim()) {
      return;
    }
    if (this.editMode && this.selectedUser) {
      const idx: number = AdminMock.users.findIndex(u => u.id === this.selectedUser!.id);
      if (idx >= 0) {
        AdminMock.users[idx].username = this.formUsername;
        AdminMock.users[idx].phone = this.formPhone;
        AdminMock.users[idx].age = parseInt(this.formAge) || 0;
        AdminMock.users[idx].id_card = this.formIdCard;
        AdminMock.users[idx].user_type = this.formUserType;
      }
    } else {
      const newId: number = AdminMock.users.length > 0 ? AdminMock.users[AdminMock.users.length - 1].id + 1 : 1;
      AdminMock.users.push({
        id: newId,
        username: this.formUsername,
        password: '123456',
        phone: this.formPhone,
        age: parseInt(this.formAge) || 0,
        id_card: this.formIdCard,
        user_type: this.formUserType,
        create_time: new Date().toISOString().replace('T', ' ').substring(0, 19),
        is_deleted: 0
      });
    }
    this.showAddModal = false;
    this.filterUsers();
  }

  private deleteUser(user: UserInfo): void {
    const idx: number = AdminMock.users.findIndex(u => u.id === user.id);
    if (idx >= 0) {
      AdminMock.users.splice(idx, 1);
      this.filterUsers();
    }
  }

  build() {
    Column() {
      this.TitleBar();
      this.SearchBar();
      this.UserList();
      this.Pagination();

      if (this.showAddModal) {
        this.AddModal();
      }
      if (this.showDetailModal && this.selectedUser) {
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

      Text('用户管理')
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
      .backgroundColor('#1677FF')
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
        TextInput({ placeholder: '搜索用户名、手机号、身份证...', text: this.searchText })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 12 })
          .onChange((value: string) => {
            this.searchText = value;
            this.filterUsers();
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
            this.filterUsers();
          });
        }
      }

      Row({ space: 8 }) {
        Text('类型筛选：')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor(GlobalTheme.TEXT_SECONDARY);

        Button('全部')
          .height(30)
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .padding({ left: 10, right: 10 })
          .backgroundColor(this.filterType === -1 ? '#1677FF' : '#F0F0F0')
          .fontColor(this.filterType === -1 ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterType = -1;
            this.filterUsers();
          });

        Button('医生')
          .height(30)
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .padding({ left: 10, right: 10 })
          .backgroundColor(this.filterType === 1 ? '#1677FF' : '#F0F0F0')
          .fontColor(this.filterType === 1 ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterType = 1;
            this.filterUsers();
          });

        Button('普通用户')
          .height(30)
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .padding({ left: 10, right: 10 })
          .backgroundColor(this.filterType === 0 ? '#1677FF' : '#F0F0F0')
          .fontColor(this.filterType === 0 ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterType = 0;
            this.filterUsers();
          });
      }

      Text(`共 ${this.filteredUsers.length} 条记录`)
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
  UserList() {
    Column({ space: 8 }) {
      ForEach(this.getPagedUsers(), (user: UserInfo) => {
        Row() {
          Column({ space: 4 }) {
            Row({ space: 8 }) {
              Text(user.username)
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight(FontWeight.Medium)
                .fontColor(GlobalTheme.TEXT_PRIMARY);
              Text(AdminMock.getUserTypeName(user.user_type))
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(AdminMock.getUserTypeColor(user.user_type))
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor(AdminMock.getUserTypeColor(user.user_type) + '15')
                .borderRadius(4);
            }

            Row({ space: 16 }) {
              Text(`📱 ${user.phone}`)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
              Text(`🎂 ${user.age}岁`)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
            }

            Text(`🕐 ${user.create_time}`)
              .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_HINT);
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1);

          Column({ space: 6 }) {
            Button({ type: ButtonType.Normal }) {
              Text('查看')
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor('#1677FF');
            }
            .height(28)
            .padding({ left: 10, right: 10 })
            .backgroundColor('#1677FF15')
            .borderRadius(6)
            .onClick(() => {
              this.selectedUser = user;
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
                this.openEditModal(user);
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
                this.deleteUser(user);
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
      }, (user: UserInfo) => `${user.id}`);
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8 })
    .layoutWeight(1);
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

      Column({ space: 16 }) {
        Text(this.editMode ? '编辑用户' : '新增用户')
          .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.TEXT_PRIMARY);

        Column({ space: 6 }) {
          Text('用户名 *')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%');
          TextInput({ placeholder: '请输入用户名', text: this.formUsername })
            .height(44)
            .backgroundColor('#F8FAFC')
            .borderRadius(8)
            .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
            .padding({ left: 12 })
            .onChange((value: string) => {
              this.formUsername = value;
            });
        }

        Column({ space: 6 }) {
          Text('手机号 *')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%');
          TextInput({ placeholder: '请输入手机号', text: this.formPhone })
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .height(44)
            .backgroundColor('#F8FAFC')
            .borderRadius(8)
            .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
            .padding({ left: 12 })
            .onChange((value: string) => {
              this.formPhone = value;
            });
        }

        Column({ space: 6 }) {
          Text('年龄')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%');
          TextInput({ placeholder: '请输入年龄', text: this.formAge })
            .type(InputType.Number)
            .maxLength(3)
            .height(44)
            .backgroundColor('#F8FAFC')
            .borderRadius(8)
            .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
            .padding({ left: 12 })
            .onChange((value: string) => {
              this.formAge = value;
            });
        }

        Column({ space: 6 }) {
          Text('身份证号')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%');
          TextInput({ placeholder: '请输入身份证号', text: this.formIdCard })
            .maxLength(18)
            .height(44)
            .backgroundColor('#F8FAFC')
            .borderRadius(8)
            .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
            .padding({ left: 12 })
            .onChange((value: string) => {
              this.formIdCard = value;
            });
        }

        Column({ space: 6 }) {
          Text('用户类型')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%');
          Row({ space: 8 }) {
            Button('普通用户')
              .height(36)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .padding({ left: 14, right: 14 })
              .backgroundColor(this.formUserType === 0 ? '#1677FF' : '#F0F0F0')
              .fontColor(this.formUserType === 0 ? '#FFFFFF' : '#666666')
              .borderRadius(8)
              .onClick(() => {
                this.formUserType = 0;
              });
            Button('医生')
              .height(36)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .padding({ left: 14, right: 14 })
              .backgroundColor(this.formUserType === 1 ? '#1677FF' : '#F0F0F0')
              .fontColor(this.formUserType === 1 ? '#FFFFFF' : '#666666')
              .borderRadius(8)
              .onClick(() => {
                this.formUserType = 1;
              });
          }
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
            .backgroundColor('#1677FF')
            .fontColor('#FFFFFF')
            .borderRadius(10)
            .onClick(() => {
              this.saveUser();
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

      Column({ space: 12 }) {
        Row() {
          Text('用户详情')
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

        this.DetailRow('用户ID', `${this.selectedUser!.id}`);
        this.DetailRow('用户名', this.selectedUser!.username);
        this.DetailRow('手机号', this.selectedUser!.phone);
        this.DetailRow('年龄', `${this.selectedUser!.age}岁`);
        this.DetailRow('身份证', this.selectedUser!.id_card);
        this.DetailRow('类型', AdminMock.getUserTypeName(this.selectedUser!.user_type));
        this.DetailRow('注册时间', this.selectedUser!.create_time);

        Divider().color('#E2E8F0');

        Row({ space: 8 }) {
          Text('家属信息')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY);
          Text(`(${AdminMock.familyMembers.filter(f => f.user_id === this.selectedUser!.id).length}人)`)
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_HINT);
        }

        ForEach(AdminMock.familyMembers.filter(f => f.user_id === this.selectedUser!.id), (fm: FamilyMemberInfo) => {
          Row({ space: 8 }) {
            Text('•')
              .fontSize(14)
              .fontColor(GlobalTheme.TEXT_SECONDARY);
            Text(`${fm.name}（${fm.relation}）`)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_PRIMARY);
            Text(fm.phone)
              .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_HINT);
          }
          .width('100%')
          .padding({ left: 8, top: 4, bottom: 4 });
        }, (fm: FamilyMemberInfo) => `${fm.id}`);

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
