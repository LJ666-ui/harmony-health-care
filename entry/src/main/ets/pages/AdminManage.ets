import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse, HttpMethod, RequestOptions } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { CurrentAdmin } from '../services/AdminAuthService';

interface AdminItem {
  id: number;
  username: string;
  realName: string;
  phone: string;
  email: string;
  avatar: string;
  role: number;
  status: number;
  lastLoginTime: string;
  lastLoginIp: string;
  createTime: string;
}

@Entry
@Component
struct AdminManage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentAdmin: CurrentAdmin | null = null;
  @State searchText: string = '';
  @State filterRole: number = -1;
  @State adminList: AdminItem[] = [];
  @State totalRecords: number = 0;
  @State isLoading: boolean = false;
  @State showAddModal: boolean = false;
  @State showResetModal: boolean = false;
  @State editMode: boolean = false;
  @State selectedAdmin: AdminItem | null = null;
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

  private getRoleName(role: number): string {
    if (role === 1) return '超级管理员';
    if (role === 2) return '普通管理员';
    return '未知';
  }

  private getRoleColor(role: number): string {
    if (role === 1) return '#8B5CF6';
    return '#1677FF';
  }

  private getStatusName(status: number): string {
    if (status === 1) return '正常';
    return '禁用';
  }

  private getStatusColor(status: number): string {
    if (status === 1) return '#52C41A';
    return '#FF4D4F';
  }

  aboutToAppear(): void {
    this.currentAdmin = AppStorage.get<CurrentAdmin>('currentAdmin') || null;
    if (!this.currentAdmin || this.currentAdmin.role !== 1) {
      this.accessDenied = true;
    } else {
      this.loadAdminList();
    }
  }

  private async loadAdminList(): Promise<void> {
    this.isLoading = true;
    try {
      const params: Record<string, Object> = {};
      if (this.searchText.trim()) {
        params['keyword'] = this.searchText.trim();
      }
      if (this.filterRole >= 0) {
        params['role'] = String(this.filterRole);
      }

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.ADMIN_ADMIN_LIST,
        undefined,
        Object.keys(params).length > 0 ? params as Object : undefined,
        { isAdmin: true } as RequestOptions
      );

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        const records = data['records'];
        if (Array.isArray(records)) {
          this.adminList = records.map((r: Object): AdminItem => {
            const item = r as Record<string, Object>;
            return {
              id: Number(item['id']) || 0,
              username: String(item['username'] || ''),
              realName: String(item['realName'] || item['real_name'] || ''),
              phone: String(item['phone'] || ''),
              email: String(item['email'] || ''),
              avatar: String(item['avatar'] || ''),
              role: Number(item['role']) || 2,
              status: Number(item['status']) || 0,
              lastLoginTime: String(item['lastLoginTime'] || item['last_login_time'] || ''),
              lastLoginIp: String(item['lastLoginIp'] || item['last_login_ip'] || ''),
              createTime: String(item['createTime'] || item['create_time'] || '')
            };
          });
          this.totalRecords = Number(data['total']) || 0;
        }
      } else {
        ToastUtil.showError(response.message || '加载管理员列表失败', 2000);
      }
    } catch (error) {
      console.error('[AdminManage] 加载失败:', error);
      ToastUtil.showError('网络错误，请检查后端服务', 2000);
    } finally {
      this.isLoading = false;
    }
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

  private openEditModal(admin: AdminItem): void {
    this.editMode = true;
    this.selectedAdmin = admin;
    this.formUsername = admin.username;
    this.formRealName = admin.realName;
    this.formPhone = admin.phone;
    this.formEmail = admin.email;
    this.formRole = admin.role;
    this.formStatus = admin.status;
    this.formPassword = '';
    this.formConfirmPwd = '';
    this.showAddModal = true;
  }

  private async saveAdmin(): Promise<void> {
    if (!this.formUsername.trim() || !this.formRealName.trim()) {
      ToastUtil.showError('用户名和真实姓名不能为空', 1500);
      return;
    }

    try {
      if (this.editMode && this.selectedAdmin) {
        const body: Record<string, Object> = {
          'id': this.selectedAdmin.id,
          'realName': this.formRealName,
          'phone': this.formPhone,
          'email': this.formEmail,
          'role': this.formRole,
          'status': this.formStatus
        };
        const response: BaseResponse<Object> = await HttpUtil.request<Object>(
          HttpMethod.POST,
          ApiConstants.ADMIN_ADMIN_UPDATE,
          body as Object,
          undefined,
          { isAdmin: true } as RequestOptions
        );
        if (response.success) {
          ToastUtil.showSuccess('更新成功', 1500);
          this.showAddModal = false;
          this.loadAdminList();
        } else {
          ToastUtil.showError(response.message || '更新失败', 2000);
        }
      } else {
        if (!this.formPassword || this.formPassword.length < 6) {
          ToastUtil.showError('新增管理员密码不能少于6位', 1500);
          return;
        }
        if (this.formPassword !== this.formConfirmPwd) {
          ToastUtil.showError('两次密码不一致', 1500);
          return;
        }
        const body: Record<string, Object> = {
          'username': this.formUsername,
          'realName': this.formRealName,
          'password': this.formPassword,
          'phone': this.formPhone,
          'email': this.formEmail,
          'role': this.formRole
        };
        const response: BaseResponse<Object> = await HttpUtil.request<Object>(
          HttpMethod.POST,
          ApiConstants.ADMIN_ADMIN_ADD,
          body as Object,
          undefined,
          { isAdmin: true } as RequestOptions
        );
        if (response.success) {
          ToastUtil.showSuccess('添加成功', 1500);
          this.showAddModal = false;
          this.loadAdminList();
        } else {
          ToastUtil.showError(response.message || '添加失败', 2000);
        }
      }
    } catch (error) {
      console.error('[AdminManage] 保存失败:', error);
      ToastUtil.showError('网络错误，请稍后重试', 2000);
    }
  }

  private async deleteAdmin(admin: AdminItem): Promise<void> {
    if (admin.id === this.currentAdmin!.id) {
      ToastUtil.showError('不能删除自己', 1500);
      return;
    }
    try {
      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.ADMIN_ADMIN_DELETE + admin.id,
        undefined,
        undefined,
        { isAdmin: true } as RequestOptions
      );
      if (response.success) {
        ToastUtil.showSuccess('删除成功', 1500);
        this.loadAdminList();
      } else {
        ToastUtil.showError(response.message || '删除失败', 2000);
      }
    } catch (error) {
      console.error('[AdminManage] 删除失败:', error);
      ToastUtil.showError('网络错误', 2000);
    }
  }

  private async toggleStatus(admin: AdminItem): Promise<void> {
    if (admin.id === this.currentAdmin!.id) {
      ToastUtil.showError('不能禁用自己', 1500);
      return;
    }
    try {
      const body: Record<string, Object> = { 'id': admin.id };
      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.ADMIN_ADMIN_TOGGLE_STATUS,
        body as Object,
        undefined,
        { isAdmin: true } as RequestOptions
      );
      if (response.success) {
        ToastUtil.showSuccess(response.message || '操作成功', 1500);
        this.loadAdminList();
      } else {
        ToastUtil.showError(response.message || '操作失败', 2000);
      }
    } catch (error) {
      console.error('[AdminManage] 切换状态失败:', error);
      ToastUtil.showError('网络错误', 2000);
    }
  }

  private openResetModal(admin: AdminItem): void {
    this.selectedAdmin = admin;
    this.resetTargetName = admin.realName;
    this.resetNewPwd = '';
    this.resetConfirmPwd = '';
    this.showResetModal = true;
  }

  private async confirmResetPwd(): Promise<void> {
    if (!this.resetNewPwd || this.resetNewPwd.length < 6) {
      ToastUtil.showError('密码长度不能少于6位', 1500);
      return;
    }
    if (this.resetNewPwd !== this.resetConfirmPwd) {
      ToastUtil.showError('两次密码不一致', 1500);
      return;
    }
    if (!this.selectedAdmin) return;

    try {
      const body: Record<string, Object> = {
        'id': this.selectedAdmin.id,
        'newPassword': this.resetNewPwd
      };
      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.ADMIN_ADMIN_RESET_PASSWORD,
        body as Object,
        undefined,
        { isAdmin: true } as RequestOptions
      );
      if (response.success) {
        ToastUtil.showSuccess('重置密码成功', 1500);
        this.showResetModal = false;
      } else {
        ToastUtil.showError(response.message || '重置密码失败', 2000);
      }
    } catch (error) {
      console.error('[AdminManage] 重置密码失败:', error);
      ToastUtil.showError('网络错误', 2000);
    }
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
            this.loadAdminList();
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
            this.loadAdminList();
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
            this.loadAdminList();
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
            this.loadAdminList();
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
            this.loadAdminList();
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
  AdminList() {
    Scroll() {
      Column({ space: 8 }) {
        ForEach(this.adminList, (admin: AdminItem) => {
          Column({ space: 10 }) {
            Row() {
              Column({ space: 4 }) {
                Row({ space: 8 }) {
                  Text(admin.realName)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(GlobalTheme.TEXT_PRIMARY);
                  Text(this.getRoleName(admin.role))
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(this.getRoleColor(admin.role))
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor(this.getRoleColor(admin.role) + '15')
                    .borderRadius(4);
                  Text(this.getStatusName(admin.status))
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(this.getStatusColor(admin.status))
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor(this.getStatusColor(admin.status) + '15')
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
                  if (admin.lastLoginTime) {
                    Text(`🕐 ${admin.lastLoginTime}`)
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
        }, (admin: AdminItem) => `${admin.id}`);
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
