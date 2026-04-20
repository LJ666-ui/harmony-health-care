import { EmergencyContact } from '../monitoring/RealtimeMonitor';
import { EmergencyNotifier } from '../monitoring/EmergencyNotifier';

@Entry
@Component
struct EmergencyContactsPage {
  @State contacts: EmergencyContact[] = [];
  @State isLoading: boolean = true;
  @State showAddDialog: boolean = false;
  @State showDetailDialog: boolean = false;
  @State selectedContact: EmergencyContact | null = null;
  @State newContactName: string = '';
  @State newContactPhone: string = '';
  @State newContactRelation: string = '家人';
  @State newContactIsPrimary: boolean = false;
  @State notificationStats: {
    totalSent: number;
    successRate: number;
    recentFailures: number;
  } | null = null;

  private notifierService: EmergencyNotifier = EmergencyNotifier.getInstance();

  aboutToAppear(): void {
    console.log('[EmergencyContactsPage] 页面加载');
    this.loadData();
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '📞 紧急联系人', 
        showBack: true 
      })

      if (this.isLoading) {
        this.buildLoadingView()
      } else {
        Scroll() {
          Column({ space: 16 }) {
            this.buildInfoCard()

            this.buildAddButton()

            this.buildContactsList()

            if (this.notificationStats) {
              this.buildNotificationStats()
            }
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }

      if (this.showAddDialog) {
        this.buildAddContactDialog()
      }

      if (this.showDetailDialog && this.selectedContact) {
        this.buildContactDetailDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildLoadingView() {
    Column({ space: 20 }) {
      LoadingProgress()
        .width(60)
        .height(60)
        .color('#1677FF')
      
      Text('正在加载联系人...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildInfoCard() {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        Text('⚠️')
          .fontSize(24)

        Column({ space: 4 }) {
          Text('紧急联系人说明')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)

          Text('当系统检测到危急健康预警时，将自动向紧急联系人发送通知')
            .fontSize(13)
            .fontColor('#666666')
            .lineHeight(18)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Column({ space: 8 }) {
        Text('建议设置：')
          .fontSize(14)
          .fontColor('#666666')
          .fontWeight(FontWeight.Medium)

        ForEach([
          '至少设置2-3位紧急联系人',
          '包含家庭成员和/或邻居',
          '确保联系电话准确有效',
          '定期检查联系人信息是否更新'
        ], (tip: string) => {
          Row({ space: 6 }) {
            Text('•')
              .fontSize(13)
              .fontColor('#1677FF')
            
            Text(tip)
              .fontSize(13)
              .fontColor('#666666')
          }
          .width('100%')
        })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#E6F4FF30')
      .borderRadius(10)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildAddButton() {
    Button('+ 添加紧急联系人')
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .backgroundColor('#1677FF')
      .borderRadius(24)
      .onClick(() => {
        this.showAddDialog = true;
      })
  }

  @Builder buildContactsList() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('我的联系人')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Text(`${this.contacts.length}`)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .width(20)
          .height(20)
          .borderRadius(10)
          .textAlign(TextAlign.Center)
          .backgroundColor('#1677FF')

        Blank()
      }
      .width('100%')

      if (this.contacts.length === 0) {
        this.buildEmptyContacts()
      } else {
        ForEach(this.contacts, (contact: Object) => {
          const contactItem = contact as EmergencyContact;
          
          this.buildContactCard(contactItem)
        })
      }
    }
    .width('100%')
  }

  @Builder buildEmptyContacts() {
    Column({ space: 16 }) {
      Text('📱')
        .fontSize(48)

      Text('暂无紧急联系人')
        .fontSize(16)
        .fontColor('#666666')

      Text('点击上方按钮添加紧急联系人')
        .fontSize(13)
        .fontColor('#BBBBBB')

      Button('立即添加')
        .height(40)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(20)
        .margin({ top: 8 })
        .onClick(() => this.showAddDialog = true)
    }
    .width('100%')
    .padding(32)
    .backgroundColor('#FAFAFA')
    .borderRadius(12)
  }

  @Builder buildContactCard(contact: EmergencyContact) {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(contact.name.substring(0, 1))
            .fontSize(28)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .width(50)
            .height(50)
            .borderRadius(25)
            .backgroundColor(
              contact.isPrimary ? '#FF4D4F' : '#1677FF'
            )
            .textAlign(TextAlign.Center)
        }

        Column({ space: 4 }) {
          Row({ space: 8 }) {
            Text(contact.name)
              .fontSize(17)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)

            if (contact.isPrimary) {
              Text('主要联系人')
                .fontSize(11)
                .fontColor('#FF4D4F')
                .fontWeight(FontWeight.Bold)
                .padding({ horizontal: 6, vertical: 2 })
                .backgroundColor('#FFF2F0')
                .borderRadius(8)
            }
          }
          .width('100%')

          Text(`${contact.relation} · ${contact.phone}`)
            .fontSize(14)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: contact.enabled })
          .onChange((isOn: boolean) => {
            this.toggleContactEnabled(contact.id, isOn);
          })
      }
      .width('100%')

      Row({ space: 8 }) {
        Button('查看详情')
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(18)
          .onClick(() => this.showContactDetail(contact))

        Button('发送测试')
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .fontColor('#52C41A')
          .backgroundColor('#F6FFED')
          .borderRadius(18)
          .onClick(() => this.sendTestNotification(contact))

        Button('删除')
          .height(36)
          .fontSize(13)
          .fontColor('#FF4D4F')
          .backgroundColor('#FFF2F0')
          .borderRadius(18)
          .onClick(() => this.deleteContact(contact))
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.04)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder buildNotificationStats() {
    Column({ space: 12 }) {
      Text('📊 通知统计（近7天）')
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      Row({ space: 8 }) {
        this.buildStatItem('总发送数', String(this.notificationStats!.totalSent), '#1677FF')
        this.buildStatItem('成功率', `${this.notificationStats!.successRate}%`, '#52C41A')
        this.buildStatItem('近期失败', String(this.notificationStats!.recentFailures), '#FF4D4F')
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder buildStatItem(label: string, value: string, color: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(22)
        .fontColor(color)
        .fontWeight(FontWeight.Bold)

      Text(label)
        .fontSize(12)
        .fontColor('#999999')
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
  }

  @Builder buildAddContactDialog() {
    Column() {
      Row() {
        Text('添加紧急联系人')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('✕')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => this.showAddDialog = false)
      }
      .width('100%')
      .padding(16)

      Divider()
        .color('#EEEEEE')

      Column({ space: 16 }) {
        TextInput({ placeholder: '请输入姓名', text: this.newContactName })
          .width('100%')
          .height(50)
          .fontSize(15)
          .onChange((value: string) => {
            this.newContactName = value;
          })

        TextInput({ placeholder: '请输入手机号', text: this.newContactPhone })
          .width('100%')
          .height(50)
          .fontSize(15)
          .type(InputType.PhoneNumber)
          .onChange((value: string) => {
            this.newContactPhone = value;
          })

        Select([
          { value: '家人' },
          { value: '配偶' },
          { value: '子女' },
          { value: '兄弟姐妹' },
          { value: '邻居' },
          { value: '朋友' },
          { value: '医生' },
          { value: '其他' }
        ])
          .value(this.newContactRelation)
          .selected(0)
          .font({ size: 14 })
          .width('100%')

        Row({ space: 12 }) {
          Text('设为主要联系人')
            .fontSize(14)
            .fontColor('#666666')

          Blank()

          Toggle({ type: ToggleType.Switch, isOn: this.newContactIsPrimary })
            .onChange((isOn: boolean) => {
              this.newContactIsPrimary = isOn;
            })
        }
        .width('100%')

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(() => this.showAddDialog = false)

          Button('确认添加')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(22)
            .onClick(() => this.addNewContact())
        }
        .width('100%')
      }
      .padding(16)
    }
    .width('90%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.2)',
      offsetX: 0,
      offsetY: 8
    })
  }

  @Builder buildContactDetailDialog() {
    if (!this.selectedContact) return;

    Column() {
      Row() {
        Text('联系人详情')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('✕')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => {
            this.showDetailDialog = false;
            this.selectedContact = null;
          })
      }
      .width('100%')
      .padding(16)

      Divider()
        .color('#EEEEEE')

      Scroll() {
        Column({ space: 16 }) {
          Row({ space: 12 }) {
            Text(this.selectedContact.name.substring(0, 1))
              .fontSize(36)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .width(70)
              .height(70)
              .borderRadius(35)
              .backgroundColor(this.selectedContact.isPrimary ? '#FF4D4F' : '#1677FF')
              .textAlign(TextAlign.Center)

            Column({ space: 6 }) {
              Text(this.selectedContact.name)
                .fontSize(22)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)

              Text(this.selectedContact.relation)
                .fontSize(15)
                .fontColor('#666666')

              if (this.selectedContact.isPrimary) {
                Text('⭐ 主要联系人')
                  .fontSize(13)
                  .fontColor('#FF4D4F')
                  .fontWeight(FontWeight.Medium)
                  .padding({ horizontal: 8, vertical: 3 })
                  .backgroundColor('#FFF2F0')
                  .borderRadius(10)
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          this.buildDetailItem('电话号码', this.selectedContact.phone, '📞')
          this.buildDetailItem('关系', this.selectedContact.relation, '👥')
          this.buildDetailItem('状态', this.selectedContact.enabled ? '已启用' : '已禁用', 
                              this.selectedContact.enabled ? '✅' : '❌')
          this.buildDetailItem('主要联系人', this.selectedContact.isPrimary ? '是' : '否',
                              this.selectedContact.isPrimary ? '⭐' : '○')
          
          if (this.selectedContact.createdAt) {
            this.buildDetailItem('创建时间', new Date(this.selectedContact.createdAt).toLocaleString('zh-CN'), '📅')
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      Divider()
        .color('#EEEEEE')

      Row({ space: 12 }) {
        Button('关闭')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .onClick(() => {
            this.showDetailDialog = false;
            this.selectedContact = null;
          })

        Button('编辑')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(22)
          .onClick(() => console.log('[EmergencyContactsPage] 编辑联系人'))
      }
      .padding(16)
    }
    .width('90%')
    .maxHeight('80%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.2)',
      offsetX: 0,
      offsetY: 8
    })
  }

  @Builder buildDetailItem(label: string, value: string, icon: string) {
    Row({ space: 12 }) {
      Text(icon)
        .fontSize(18)

      Text(label)
        .fontSize(14)
        .fontColor('#999999')
        .width(80)

      Text(value)
        .fontSize(15)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)

      Blank()
    }
    .width('100%')
    .padding({ vertical: 8, horizontal: 4 })
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;

    try {
      await new Promise(resolve => setTimeout(resolve, 400));

      this.contacts = [
        {
          id: 'CONTACT_001',
          name: '张伟',
          phone: '13812345678',
          relation: '儿子',
          isPrimary: true,
          enabled: true,
          createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()
        },
        {
          id: 'CONTACT_002',
          name: '李芳',
          phone: '13987654321',
          relation: '女儿',
          isPrimary: false,
          enabled: true,
          createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()
        },
        {
          id: 'CONTACT_003',
          name: '王强',
          phone: '13611112222',
          relation: '邻居',
          isPrimary: false,
          enabled: true,
          createdAt: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000).toISOString()
        }
      ];

      try {
        this.notificationStats = this.notifierService.getStatistics();
      } catch (error) {
        console.warn('[EmergencyContactsPage] 获取统计失败');
        
        this.notificationStats = {
          totalSent: 12,
          successRate: 91.7,
          recentFailures: 1
        };
      }

      console.log(`[EmergencyContactsPage] 加载了 ${this.contacts.length} 个联系人`);

    } catch (error) {
      console.error('[EmergencyContactsPage] 加载失败:', error instanceof Error ? error.message : String(error));
      
      this.contacts = [];
    } finally {
      this.isLoading = false;
    }
  }

  private addNewContact(): void {
    if (!this.newContactName.trim()) {
      AlertDialog.show({
        title: '提示',
        message: '请输入联系人姓名',
        primaryText: '确定'
      });
      return;
    }

    if (!this.newContactPhone.trim()) {
      AlertDialog.show({
        title: '提示',
        message: '请输入手机号码',
        primaryText: '确定'
      });
      return;
    }

    const phoneRegex = /^1[3-9]\d{9}$/;
    
    if (!phoneRegex.test(this.newContactPhone)) {
      AlertDialog.show({
        title: '提示',
        message: '请输入正确的手机号码格式',
        primaryText: '确定'
      });
      return;
    }

    const newContact: EmergencyContact = {
      id: `CONTACT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      name: this.newContactName.trim(),
      phone: this.newContactPhone.trim(),
      relation: this.newContactRelation,
      isPrimary: this.newContactIsPrimary,
      enabled: true,
      createdAt: new Date().toISOString()
    };

    if (newContact.isPrimary) {
      for (const c of this.contacts) {
        c.isPrimary = false;
      }
    }

    this.contacts.push(newContact);

    this.contacts.sort((a, b) => {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return 0;
    });

    this.showAddDialog = false;
    
    this.newContactName = '';
    this.newContactPhone = '';
    this.newContactRelation = '家人';
    this.newContactIsPrimary = false;

    AlertDialog.show({
      title: '✅ 添加成功',
      message: `联系人"${newContact.name}"已添加`,
      primaryText: '确定'
    });

    console.log(`[EmergencyContactsPage] 添加联系人: ${newContact.name}`);
  }

  private showContactDetail(contact: EmergencyContact): void {
    this.selectedContact = contact;
    this.showDetailDialog = true;
  }

  private async sendTestNotification(contact: EmergencyContact): Promise<void> {
    AlertDialog.show({
      title: '发送测试通知',
      message: `确定要向${contact.name}(${contact.phone})发送测试通知吗？`,
      primaryText: '取消',
      secondaryText: '确认发送',
      onSecondaryClick: async () => {
        const success = await this.notifierService.sendTestNotification(contact);
        
        AlertDialog.show({
          title: success ? '✅ 发送成功' : '❌ 发送失败',
          message: success ? 
            `测试通知已成功发送给${contact.name}` :
            `发送测试通知失败，请检查网络连接或联系信息是否正确`,
          primaryText: '确定'
        });
      }
    });
  }

  private deleteContact(contact: EmergencyContact): void {
    AlertDialog.show({
      title: '⚠️ 确认删除',
      message: `确定要删除联系人"${contact.name}"吗？删除后将无法接收该联系人的紧急通知。`,
      primaryText: '取消',
      secondaryText: '确认删除',
      onSecondaryClick: () => {
        const index = this.contacts.findIndex(c => c.id === contact.id);
        
        if (index > -1) {
          this.contacts.splice(index, 1);
          
          AlertDialog.show({
            title: '✅ 删除成功',
            message: `联系人"${contact.name}"已删除`,
            primaryText: '确定'
          });
          
          console.log(`[EmergencyContactsPage] 删除联系人: ${contact.name}`);
        }
      }
    });
  }

  private toggleContactEnabled(contactId: string, enabled: boolean): void {
    const index = this.contacts.findIndex(c => c.id === contactId);
    
    if (index > -1) {
      this.contacts[index].enabled = enabled;
      
      console.log(`[EmergencyContactsPage] 联系人${enabled ? '启用' : '禁用'}: ${this.contacts[index].name}`);
    }
  }
}

@Component
struct NavigationTitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;

  build() {
    Row() {
      if (this.showBack) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
      }

      Text(this.title)
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
