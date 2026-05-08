import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { AdminMock, AdminInfo } from '../mock/adminMock';
import { CurrentAdmin } from '../services/AdminAuthService';

@Entry
@Component
struct AdminManage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentAdmin: AdminInfo | null = null;
  @State searchText: string = '';
  @State filterRole: number = -1;
  @State filteredAdmins: AdminInfo[] = [];
  @State showAddModal: boolean = false;
  @State showResetModal: boolean = false;
  @State editMode: boolean = false;
  @State selectedAdmin: AdminInfo | null = null;
  @State accessDenied: boolean = false;

  @State formUsername: string = '';
  @State formRealName: string = '';
  @State formPhone: string = '';
  @State formEmail: string = '';
  @State formRole: number = 2;
  @State formStatus: number = 1;
  @State formPassword: string = '';
  @State formConfirmPwd: string = '';
  @State resetTargetName: string = '';
  @State resetNewPwd: string = '';
  @State resetConfirmPwd: string = '';

  aboutToAppear(): void {
    const currentAdminData: CurrentAdmin | null = AppStorage.get<CurrentAdmin>('currentAdmin') || null;
    if (currentAdminData) {
      this.currentAdmin = {
        id: currentAdminData.id,
        username: currentAdminData.username,
        password: '',
        real_name: currentAdminData.realName,
        phone: currentAdminData.phone,
        email: currentAdminData.email,
        avatar: '',
        role: currentAdminData.role,
        status: currentAdminData.status,
        last_login_time: '',
        last_login_ip: '',
        create_time: '',
        is_deleted: 0
      };
    }
    if (!this.currentAdmin || this.currentAdmin.role !== 1) {
      this.accessDenied = true;
    } else {
      this.filterAdmins();
    }
  }

  private filterAdmins(): void {
    let result: AdminInfo[] = [...AdminMock.admins];
    if (this.searchText) {
      const keyword: string = this.searchText.toLowerCase();
      result = result.filter(a =>
        a.username.toLowerCase().includes(keyword) ||
        a.real_name.toLowerCase().includes(keyword) ||
        a.phone.includes(keyword)
      );
    }
    if (this.filterRole >= 0) {
      result = result.filter(a => a.role === this.filterRole);
    }
    this.filteredAdmins = result;
  }

  private openAddModal(): void {
    this.editMode = false;
    this.formUsername = '';
    this.formRealName = '';
    this.formPhone = '';
    this.formEmail = '';
    this.formRole = 2;
    this.formStatus = 1;
    this.formPassword = '';
    this.formConfirmPwd = '';
    this.showAddModal = true;
  }

  private openEditModal(admin: AdminInfo): void {
    this.editMode = true;
    this.selectedAdmin = admin;
    this.formUsername = admin.username;
    this.formRealName = admin.real_name;
    this.formPhone = admin.phone;
    this.formEmail = admin.email;
    this.formRole = admin.role;
    this.formStatus = admin.status;
    this.formPassword = '';
    this.formConfirmPwd = '';
    this.showAddModal = true;
  }

  private saveAdmin(): void {
    if (!this.formUsername.trim() || !this.formRealName.trim()) {
      return;
    }
    if (this.editMode && this.selectedAdmin) {
      const idx: number = AdminMock.admins.findIndex(a => a.id === this.selectedAdmin!.id);
      if (idx >= 0) {
        AdminMock.admins[idx].username = this.formUsername;
        AdminMock.admins[idx].real_name = this.formRealName;
        AdminMock.admins[idx].phone = this.formPhone;
        AdminMock.admins[idx].email = this.formEmail;
        AdminMock.admins[idx].role = this.formRole;
        AdminMock.admins[idx].status = this.formStatus;
        if (this.formPassword && this.formPassword.length >= 6) {
          AdminMock.admins[idx].password = this.formPassword;
        }
        if (this.selectedAdmin.id === this.currentAdmin!.id) {
          AppStorage.setOrCreate<AdminInfo>('currentAdmin', AdminMock.admins[idx]);
          this.currentAdmin = AdminMock.admins[idx];
        }
      }
    } else {
      if (!this.formPassword || this.formPassword.length < 6) {
        return;
      }
      const newId: number = AdminMock.admins.length > 0 ?
        AdminMock.admins[AdminMock.admins.length - 1].id + 1 : 1;
      AdminMock.admins.push({
        id: newId,
        username: this.formUsername,
        password: this.formPassword,
        real_name: this.formRealName,
        phone: this.formPhone,
        email: this.formEmail,
        avatar: '',
        role: this.formRole,
        status: this.formStatus,
        last_login_time: '',
        last_login_ip: '',
        create_time: new Date().toISOString().replace('T', ' ').substring(0, 19),
        is_deleted: 0
      });
    }
    this.showAddModal = false;
    this.filterAdmins();
  }

  private deleteAdmin(admin: AdminInfo): void {
    if (admin.id === this.currentAdmin!.id) {
      return;
    }
    const superAdminCount: number = AdminMock.admins.filter(a => a.role === 1 && a.is_deleted === 0).length;
    if (admin.role === 1 && superAdminCount <= 1) {
      return;
    }
    const idx: number = AdminMock.admins.findIndex(a => a.id === admin.id);
    if (idx >= 0) {
      AdminMock.admins.splice(idx, 1);
      this.filterAdmins();
    }
  }

  private toggleStatus(admin: AdminInfo): void {
    if (admin.id === this.currentAdmin!.id) {
      return;
    }
    const idx: number = AdminMock.admins.findIndex(a => a.id === admin.id);
    if (idx >= 0) {
      AdminMock.admins[idx].status = admin.status === 1 ? 0 : 1;
      this.filterAdmins();
    }
  }

  private openResetModal(admin: AdminInfo): void {
    this.selectedAdmin = admin;
    this.resetTargetName = admin.real_name;
    this.resetNewPwd = '';
    this.resetConfirmPwd = '';
    this.showResetModal = true;
  }

  private confirmResetPwd(): void {
    if (!this.resetNewPwd || this.resetNewPwd.length < 6) {
      return;
    }
    if (this.resetNewPwd !== this.resetConfirmPwd) {
      return;
    }
    if (this.selectedAdmin) {
      const idx: number = AdminMock.admins.findIndex(a => a.id === this.selectedAdmin!.id);
      if (idx >= 0) {
        AdminMock.admins[idx].password = this.resetNewPwd;
      }
    }
    this.showResetModal = false;
  }

  build() {
    Column() {
      this.TitleBar();

      if (this.accessDenied) {
        this.AccessDeniedView();
      } else {
        this.SearchBar();
        this.AdminList();

        if (this.showAddModal) {
          this.AddModal();
        }
        if (this.showResetModal) {
          this.ResetPwdModal();
        }
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

      Text('管理员管理')
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
      .backgroundColor('#8B5CF6')
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
  AccessDeniedView() {
    Column({ space: 16 }) {
      Text('🔒')
        .fontSize(48);
      Text('权限不足')
        .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY);
      Text('仅超级管理员可访问此页面')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY);
      Button('返回仪表盘')
        .height(44)
        .padding({ left: 24, right: 24 })
        .backgroundColor('#1E293B')
        .fontColor('#FFFFFF')
        .borderRadius(10)
        .onClick(() => {
          router.replaceUrl({ url: 'pages/AdminDashboard' });
        });
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  SearchBar() {
    Column({ space: 10 }) {
      Row() {
        TextInput({ placeholder: '搜索用户名、姓名、手机号...', text: this.searchText })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 12 })
          .onChange((value: string) => {
            this.searchText = value;
            this.filterAdmins();
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
            this.filterAdmins();
          });
        }
      }

      Row({ space: 8 }) {
        Text('角色筛选：')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor(GlobalTheme.TEXT_SECONDARY);

        Button('全部')
          .height(30)
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .padding({ left: 10, right: 10 })
          .backgroundColor(this.filterRole === -1 ? '#8B5CF6' : '#F0F0F0')
          .fontColor(this.filterRole === -1 ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterRole = -1;
            this.filterAdmins();
          });

        Button('超级管理员')
          .height(30)
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .padding({ left: 10, right: 10 })
          .backgroundColor(this.filterRole === 1 ? '#8B5CF6' : '#F0F0F0')
          .fontColor(this.filterRole === 1 ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterRole = 1;
            this.filterAdmins();
          });

        Button('普通管理员')
          .height(30)
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .padding({ left: 10, right: 10 })
          .backgroundColor(this.filterRole === 2 ? '#8B5CF6' : '#F0F0F0')
          .fontColor(this.filterRole === 2 ? '#FFFFFF' : '#666666')
          .borderRadius(6)
          .onClick(() => {
            this.filterRole = 2;
            this.filterAdmins();
          });
      }

      Text(`共 ${this.filteredAdmins.length} 条记录`)
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
  AdminList() {
    Scroll() {
      Column({ space: 8 }) {
        ForEach(this.filteredAdmins, (admin: AdminInfo) => {
          Column({ space: 10 }) {
            Row() {
              Column({ space: 4 }) {
                Row({ space: 8 }) {
                  Text(admin.real_name)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(GlobalTheme.TEXT_PRIMARY);
                  Text(AdminMock.getRoleName(admin.role))
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(AdminMock.getRoleColor(admin.role))
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor(AdminMock.getRoleColor(admin.role) + '15')
                    .borderRadius(4);
                  Text(AdminMock.getStatusName(admin.status))
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(AdminMock.getStatusColor(admin.status))
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor(AdminMock.getStatusColor(admin.status) + '15')
                    .borderRadius(4);
                  if (admin.id === this.currentAdmin!.id) {
                    Text('当前')
                      .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                      .fontColor('#FAAD14')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor('#FAAD1415')
                      .borderRadius(4);
                  }
                }

                Row({ space: 16 }) {
                  Text(`👤 ${admin.username}`)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_SECONDARY);
                  Text(`📱 ${admin.phone || '未填写'}`)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_SECONDARY);
                }

                Row({ space: 16 }) {
                  Text(`📧 ${admin.email || '未填写'}`)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_HINT);
                  if (admin.last_login_time) {
                    Text(`🕐 ${admin.last_login_time}`)
                      .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                      .fontColor(GlobalTheme.TEXT_HINT);
                  }
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);
            }

            Divider().color('#F0F0F0');

            Row({ space: 6 }) {
              Button({ type: ButtonType.Normal }) {
                Text('✏️ 编辑')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor('#1677FF');
              }
              .height(28)
              .padding({ left: 8, right: 8 })
              .backgroundColor('#1677FF15')
              .borderRadius(6)
              .onClick(() => {
                this.openEditModal(admin);
              });

              Button({ type: ButtonType.Normal }) {
                Text('🔑 重置密码')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor('#FAAD14');
              }
              .height(28)
              .padding({ left: 8, right: 8 })
              .backgroundColor('#FAAD1415')
              .borderRadius(6)
              .onClick(() => {
                this.openResetModal(admin);
              });

              if (admin.id !== this.currentAdmin!.id) {
                Button({ type: ButtonType.Normal }) {
                  Text(admin.status === 1 ? '🚫 禁用' : '✅ 启用')
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(admin.status === 1 ? '#FF4D4F' : '#52C41A');
                }
                .height(28)
                .padding({ left: 8, right: 8 })
                .backgroundColor(admin.status === 1 ? '#FF4D4F15' : '#52C41A15')
                .borderRadius(6)
                .onClick(() => {
                  this.toggleStatus(admin);
                });

                Button({ type: ButtonType.Normal }) {
                  Text('🗑️ 删除')
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#FF4D4F');
                }
                .height(28)
                .padding({ left: 8, right: 8 })
                .backgroundColor('#FF4D4F15')
                .borderRadius(6)
                .onClick(() => {
                  this.deleteAdmin(admin);
                });
              }
            }
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid });
        }, (admin: AdminInfo) => `${admin.id}`);
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 24 });
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto);
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
          Text(this.editMode ? '编辑管理员' : '新增管理员')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY);

          Column({ space: 4 }) {
            Text('用户名 *')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextInput({ placeholder: '请输入登录用户名', text: this.formUsername })
              .height(42)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.formUsername = value;
              });
          }

          Column({ space: 4 }) {
            Text('真实姓名 *')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextInput({ placeholder: '请输入真实姓名', text: this.formRealName })
              .height(42)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.formRealName = value;
              });
          }

          Column({ space: 4 }) {
            Text(this.editMode ? '新密码（留空不修改）' : '密码 *')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextInput({ placeholder: this.editMode ? '留空则不修改密码' : '请输入密码（至少6位）', text: this.formPassword })
              .type(InputType.Password)
              .height(42)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.formPassword = value;
              });
          }

          if (!this.editMode && this.formPassword) {
            Column({ space: 4 }) {
              Text('确认密码 *')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY)
                .width('100%');
              TextInput({ placeholder: '请再次输入密码', text: this.formConfirmPwd })
                .type(InputType.Password)
                .height(42)
                .backgroundColor('#F8FAFC')
                .borderRadius(8)
                .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
                .padding({ left: 12 })
                .onChange((value: string) => {
                  this.formConfirmPwd = value;
                });
            }
          }

          Column({ space: 4 }) {
            Text('手机号')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextInput({ placeholder: '请输入手机号', text: this.formPhone })
              .type(InputType.PhoneNumber)
              .maxLength(11)
              .height(42)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.formPhone = value;
              });
          }

          Column({ space: 4 }) {
            Text('邮箱')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            TextInput({ placeholder: '请输入邮箱', text: this.formEmail })
              .height(42)
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
              .padding({ left: 12 })
              .onChange((value: string) => {
                this.formEmail = value;
              });
          }

          Column({ space: 4 }) {
            Text('角色')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            Row({ space: 8 }) {
              Button('超级管理员')
                .height(36)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.formRole === 1 ? '#8B5CF6' : '#F0F0F0')
                .fontColor(this.formRole === 1 ? '#FFFFFF' : '#666666')
                .borderRadius(8)
                .onClick(() => {
                  this.formRole = 1;
                });
              Button('普通管理员')
                .height(36)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.formRole === 2 ? '#8B5CF6' : '#F0F0F0')
                .fontColor(this.formRole === 2 ? '#FFFFFF' : '#666666')
                .borderRadius(8)
                .onClick(() => {
                  this.formRole = 2;
                });
            }
          }

          Column({ space: 4 }) {
            Text('状态')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .width('100%');
            Row({ space: 8 }) {
              Button('启用')
                .height(36)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.formStatus === 1 ? '#52C41A' : '#F0F0F0')
                .fontColor(this.formStatus === 1 ? '#FFFFFF' : '#666666')
                .borderRadius(8)
                .onClick(() => {
                  this.formStatus = 1;
                });
              Button('禁用')
                .height(36)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.formStatus === 0 ? '#FF4D4F' : '#F0F0F0')
                .fontColor(this.formStatus === 0 ? '#FFFFFF' : '#666666')
                .borderRadius(8)
                .onClick(() => {
                  this.formStatus = 0;
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
              .backgroundColor('#8B5CF6')
              .fontColor('#FFFFFF')
              .borderRadius(10)
              .onClick(() => {
                this.saveAdmin();
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
  ResetPwdModal() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000066')
        .onClick(() => {
          this.showResetModal = false;
        });

      Column({ space: 16 }) {
        Text('重置密码')
          .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.TEXT_PRIMARY);

        Text(`为管理员 ${this.resetTargetName} 设置新密码`)
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor(GlobalTheme.TEXT_SECONDARY);

        Column({ space: 4 }) {
          Text('新密码 *')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%');
          TextInput({ placeholder: '请输入新密码（至少6位）', text: this.resetNewPwd })
            .type(InputType.Password)
            .height(42)
            .backgroundColor('#F8FAFC')
            .borderRadius(8)
            .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
            .padding({ left: 12 })
            .onChange((value: string) => {
              this.resetNewPwd = value;
            });
        }

        Column({ space: 4 }) {
          Text('确认密码 *')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%');
          TextInput({ placeholder: '请再次输入新密码', text: this.resetConfirmPwd })
            .type(InputType.Password)
            .height(42)
            .backgroundColor('#F8FAFC')
            .borderRadius(8)
            .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
            .padding({ left: 12 })
            .onChange((value: string) => {
              this.resetConfirmPwd = value;
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
              this.showResetModal = false;
            });
          Button('确认重置')
            .layoutWeight(1)
            .height(44)
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .backgroundColor('#FAAD14')
            .fontColor('#FFFFFF')
            .borderRadius(10)
            .onClick(() => {
              this.confirmResetPwd();
            });
        }
        .width('100%');
      }
      .width('80%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 20, color: '#00000033', offsetX: 0, offsetY: 4 });
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }
}
