import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface ExpiryOption {
  label: string;
  days: number;
}

interface DoctorInfo {
  id: string;
  name: string;
  hospital: string;
  department: string;
  avatar: string;
}

interface AuthRecord {
  id: string;
  doctorId: string;
  doctorName: string;
  hospital: string;
  dataTypes: string[];
  startDate: string;
  endDate: string;
  status: 'active' | 'expired' | 'revoked';
  remainingDays: number;
}

const MOCK_DOCTORS: DoctorInfo[] = [
  { id: '1', name: '张医生', hospital: '北京协和医院', department: '心内科', avatar: '👨‍⚕️' } as DoctorInfo,
  { id: '2', name: '李医生', hospital: '上海瑞金医院', department: '内分泌科', avatar: '👩‍⚕️' } as DoctorInfo,
  { id: '3', name: '王医生', hospital: '广州中山医院', department: '中医科', avatar: '👨‍⚕️' } as DoctorInfo,
  { id: '4', name: '赵医生', hospital: '成都华西医院', department: '神经内科', avatar: '👩‍⚕️' } as DoctorInfo
];

const DATA_TYPE_OPTIONS: string[] = ['病历记录', '健康档案', '检查报告', '用药记录', '评估报告', '康复进度'];

const EXPIRY_OPTIONS: ExpiryOption[] = [
  { label: '1天', days: 1 } as ExpiryOption,
  { label: '7天', days: 7 } as ExpiryOption,
  { label: '30天', days: 30 } as ExpiryOption,
  { label: '90天', days: 90 } as ExpiryOption,
  { label: '永久', days: -1 } as ExpiryOption
];

@Entry
@Component
struct DataAuthPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State authRecords: AuthRecord[] = [
    {
      id: '1',
      doctorId: '1',
      doctorName: '张医生',
      hospital: '北京协和医院',
      dataTypes: ['病历记录', '检查报告'],
      startDate: '2026-04-01',
      endDate: '2026-05-01',
      status: 'active',
      remainingDays: 17
    } as AuthRecord,
    {
      id: '2',
      doctorId: '2',
      doctorName: '李医生',
      hospital: '上海瑞金医院',
      dataTypes: ['健康档案', '用药记录'],
      startDate: '2026-03-15',
      endDate: '2026-04-15',
      status: 'active',
      remainingDays: 1
    } as AuthRecord,
    {
      id: '3',
      doctorId: '3',
      doctorName: '王医生',
      hospital: '广州中山医院',
      dataTypes: ['评估报告'],
      startDate: '2026-02-01',
      endDate: '2026-03-01',
      status: 'expired',
      remainingDays: 0
    } as AuthRecord
  ];

  @State showNewAuthDialog: boolean = false;
  @State selectedDoctor: DoctorInfo | null = null;
  @State selectedDataTypes: string[] = [];
  @State selectedExpiryIndex: number = 2;
  @State searchKey: string = '';
  @State showDoctorPicker: boolean = false;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  getFilteredDoctors(): DoctorInfo[] {
    if (!this.searchKey.trim()) {
      return MOCK_DOCTORS;
    }
    const key: string = this.searchKey.toLowerCase();
    return MOCK_DOCTORS.filter((doc: DoctorInfo) =>
      doc.name.includes(key) || doc.hospital.includes(key) || doc.department.includes(key)
    );
  }

  toggleDataType(type: string): void {
    const index: number = this.selectedDataTypes.indexOf(type);
    if (index > -1) {
      this.selectedDataTypes.splice(index, 1);
    } else {
      this.selectedDataTypes.push(type);
    }
  }

  selectDoctor(doctor: DoctorInfo): void {
    this.selectedDoctor = doctor;
    this.showDoctorPicker = false;
    this.searchKey = '';
  }

  revokeAuth(record: AuthRecord): void {
    promptAction.showDialog({
      title: '撤销授权',
      message: `确定要撤销对 ${record.doctorName} 的数据授权吗？`,
      buttons: [{ text: '取消', color: '#999999' }, { text: '确定撤销', color: '#FF4D4F' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        record.status = 'revoked';
        record.remainingDays = 0;
        ToastUtil.operationSuccess('已撤销授权');
      }
    });
  }

  extendAuth(record: AuthRecord): void {
    promptAction.showDialog({
      title: '延长授权',
      message: '选择延长时间：',
      buttons: [{ text: '+7天', color: '#1677FF' }, { text: '+30天', color: '#1677FF' }, { text: '取消', color: '#999999' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 0 || result.index === 1) {
        const addDays: number = result.index === 0 ? 7 : 30;
        record.remainingDays += addDays;
        ToastUtil.operationSuccess(`已延长${addDays}天`);
      }
    });
  }

  confirmNewAuth(): void {
    if (!this.selectedDoctor) {
      ToastUtil.showInfo('请先选择医生');
      return;
    }
    if (this.selectedDataTypes.length === 0) {
      ToastUtil.showInfo('请至少选择一种数据类型');
      return;
    }

    const today: Date = new Date();
    const expiryDays: number = EXPIRY_OPTIONS[this.selectedExpiryIndex].days;
    const endDate: Date = expiryDays === -1 ? new Date(today.getTime() + 365 * 24 * 60 * 60 * 1000) : new Date(today.getTime() + expiryDays * 24 * 60 * 60 * 1000);

    const newRecord: AuthRecord = {
      id: `${Date.now()}`,
      doctorId: this.selectedDoctor.id,
      doctorName: this.selectedDoctor.name,
      hospital: this.selectedDoctor.hospital,
      dataTypes: [...this.selectedDataTypes],
      startDate: this.formatDate(today),
      endDate: this.formatDate(endDate),
      status: 'active',
      remainingDays: expiryDays === -1 ? 365 : expiryDays
    };

    this.authRecords.unshift(newRecord);
    this.showNewAuthDialog = false;
    this.resetNewAuthForm();
    ToastUtil.operationSuccess(`已向 ${this.selectedDoctor.name} 授权`);
  }

  formatDate(date: Date): string {
    const year: number = date.getFullYear();
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  resetNewAuthForm(): void {
    this.selectedDoctor = null;
    this.selectedDataTypes = [];
    this.selectedExpiryIndex = 2;
    this.searchKey = '';
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'active': return '#52C41A';
      case 'expired': return '#999999';
      case 'revoked': return '#FF4D4F';
      default: return '#999999';
    }
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'active': return '有效';
      case 'expired': return '已过期';
      case 'revoked': return '已撤销';
      default: return '未知';
    }
  }

  build() {
    Stack() {
      Column() {
        Header({ title: '数据授权管理', showBack: true });

        Scroll() {
          Column({ space: 16 }) {

            Column({ space: 12 }) {
              Row() {
                Text('📋 我的授权列表')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .layoutWeight(1);

                Text(`${this.authRecords.filter((r: AuthRecord) => r.status === 'active').length} 个有效`)
                  .fontSize(12)
                  .fontColor('#52C41A')
                  .backgroundColor('#F6FFED')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .borderRadius(12);
              }
              .width('100%');

              if (this.authRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('🔒')
                    .fontSize(64);

                  Text('暂无授权记录')
                    .fontSize(16)
                    .fontColor('#666666');

                  Text('您可以在此管理对医生的数据授权')
                    .fontSize(13)
                    .fontColor('#999999');
                }
                .width('100%')
                .height(300)
                .justifyContent(FlexAlign.Center);
              } else {
                ForEach(this.authRecords, (record: AuthRecord) => {
                  this.buildAuthCard(record);
                }, (record: AuthRecord) => record.id);
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

            Button('+ 新建授权')
              .width('100%')
              .height(50)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(25)
              .onClick(() => {
                this.showNewAuthDialog = true;
                this.resetNewAuthForm();
              });

            Column({ space: 12 }) {
              Text('📖 授权说明')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%');

              ForEach([
                '授权后，选定的医生可查看您指定的健康数据类型',
                '您可以随时撤销已授予的授权',
                '授权到期后，医生将无法继续访问您的数据',
                '所有授权操作都会被记录在访问日志中'
              ], (tip: string, index: number) => {
                Row({ space: 8 }) {
                  Text(`${index + 1}.`)
                    .fontSize(13)
                    .fontColor('#1677FF')
                    .fontWeight(FontWeight.Medium);

                  Text(tip)
                    .fontSize(13)
                    .fontColor('#666666')
                    .lineHeight(20)
                    .layoutWeight(1);
                }
                .width('100%');
              }, (tip: string, index: number) => `tip_${index}`);
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#E6F7FF')
            .borderRadius(12);
          }
          .width('85%')
          .padding({ top: 16, bottom: 100 });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);

        Footer({ activeIndex: 4 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA');

      if (this.showNewAuthDialog) {
        this.buildNewAuthDialog();
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  buildAuthCard(record: AuthRecord) {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Text(record.doctorName === '张医生' ? '👨‍⚕️' : record.doctorName === '李医生' ? '👩‍⚕️' : '👨‍⚕️')
          .fontSize(36);

        Column({ space: 4 }) {
          Text(record.doctorName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');

          Text(record.hospital)
            .fontSize(12)
            .fontColor('#666666');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Column({ space: 4 }) {
          Text(this.getStatusText(record.status))
            .fontSize(11)
            .fontColor(this.getStatusColor(record.status))
            .fontWeight(FontWeight.Medium);

          if (record.status === 'active') {
            Text(`剩余 ${record.remainingDays} 天`)
              .fontSize(10)
              .fontColor(record.remainingDays <= 3 ? '#FAAD14' : '#52C41A');
          }
        }
        .alignItems(HorizontalAlign.End);
      }
      .width('100%');

      Row({ space: 8 }) {
        Text('📁 授权数据：')
          .fontSize(12)
          .fontColor('#999999');

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(record.dataTypes, (type: string) => {
            Text(type)
              .fontSize(10)
              .fontColor('#1677FF')
              .backgroundColor('#E6F7FF')
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(8)
              .margin(2);
          }, (type: string) => type);
        }
        .layoutWeight(1);
      }
      .width('100%');

      Row({ space: 16 }) {
        Text(`📅 ${record.startDate} ~ ${record.endDate}`)
          .fontSize(11)
          .fontColor('#999999')
          .layoutWeight(1);

        if (record.status === 'active') {
          Row({ space: 8 }) {
            Button('延长')
              .height(28)
              .fontSize(11)
              .fontColor('#1677FF')
              .backgroundColor('#E6F7FF')
              .borderRadius(14)
              .onClick(() => this.extendAuth(record));

            Button('撤销')
              .height(28)
              .fontSize(11)
              .fontColor('#FF4D4F')
              .backgroundColor('#FFF1F0')
              .borderRadius(14)
              .onClick(() => this.revokeAuth(record));
          }
        }
      }
      .width('100%');
    }
    .width('100%')
    .padding(14)
    .backgroundColor(record.status === 'revoked' ? '#FFF7F7' : record.status === 'expired' ? '#FAFAFA' : '#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: record.status === 'active' ? '#D6E4FF' : '#F0F0F0' });
  }

  @Builder
  buildNewAuthDialog() {
    Column() {
      Blank();

      Column({ space: 20 }) {
        Row() {
          Text('新建数据授权')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1);

          Text('✕')
            .fontSize(22)
            .fontColor('#999999')
            .onClick(() => {
              this.showNewAuthDialog = false;
            });
        }
        .width('100%');

        Column({ space: 8 }) {
          Text('选择医生 *')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%');

          if (this.selectedDoctor) {
            Row({ space: 10 }) {
              Text(this.selectedDoctor.avatar)
                .fontSize(28);

              Column({ space: 2 }) {
                Text(this.selectedDoctor.name)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333');

                Text(`${this.selectedDoctor.hospital} · ${this.selectedDoctor.department}`)
                  .fontSize(11)
                  .fontColor('#666666');
              }
              .layoutWeight(1);

              Text('重新选择')
                .fontSize(12)
                .fontColor('#1677FF')
                .onClick(() => {
                  this.selectedDoctor = null;
                });
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F0F5FF')
            .borderRadius(8)
            .border({ width: 1, color: '#D6E4FF' });
          } else {
            TextInput({ placeholder: '搜索医生姓名或医院...', text: this.searchKey })
              .width('100%')
              .height(40)
              .fontSize(13)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.searchKey = value;
              });

            if (this.searchKey || this.showDoctorPicker) {
              Scroll() {
                Column({ space: 4 }) {
                  ForEach(this.getFilteredDoctors(), (doctor: DoctorInfo) => {
                    Row({ space: 10 }) {
                      Text(doctor.avatar)
                        .fontSize(24);

                      Column({ space: 2 }) {
                        Text(doctor.name)
                          .fontSize(13)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333333');

                        Text(`${doctor.hospital} · ${doctor.department}`)
                          .fontSize(11)
                          .fontColor('#999999');
                      }
                      .layoutWeight(1);
                    }
                    .width('100%')
                    .padding(10)
                    .backgroundColor('#FAFAFA')
                    .borderRadius(6)
                    .onClick(() => this.selectDoctor(doctor));
                  }, (doctor: DoctorInfo) => doctor.id);
                }
                .width('100%')
                .padding({ bottom: 4 });
              }
              .width('100%')
              .height(150)
              .scrollBar(BarState.On)
              .margin({ top: 4 });
            }
          }
        }
        .width('100%');

        Column({ space: 8 }) {
          Row() {
            Text('选择数据类型 *')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .layoutWeight(1);

            Text(`已选 ${this.selectedDataTypes.length} 项`)
              .fontSize(11)
              .fontColor('#1677FF');
          }
          .width('100%');

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(DATA_TYPE_OPTIONS, (type: string) => {
              Text(type)
                .fontSize(12)
                .fontColor(this.selectedDataTypes.includes(type) ? '#FFFFFF' : '#666666')
                .backgroundColor(this.selectedDataTypes.includes(type) ? '#1677FF' : '#F5F5F5')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(15)
                .margin(4)
                .onClick(() => this.toggleDataType(type));
            }, (type: string) => type);
          }
          .width('100%');
        }
        .width('100%');

        Column({ space: 8 }) {
          Text('有效期 *')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%');

          Row({ space: 8 }) {
            ForEach(EXPIRY_OPTIONS, (option: ExpiryOption, index: number) => {
              Text(option.label)
                .fontSize(12)
                .fontColor(this.selectedExpiryIndex === index ? '#FFFFFF' : '#666666')
                .backgroundColor(this.selectedExpiryIndex === index ? '#1677FF' : '#F5F5F5')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .borderRadius(18)
                .onClick(() => {
                  this.selectedExpiryIndex = index;
                });
            }, (option: ExpiryOption, index: number) => `expiry_${index}`);
          }
          .width('100%');
        }
        .width('100%');

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(() => {
              this.showNewAuthDialog = false;
            });

          Button('确认授权')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(22)
            .onClick(() => this.confirmNewAuth());
        }
        .width('100%');
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 20, color: '#00000030', offsetX: 0, offsetY: 10 });

      Blank();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000060')
    .justifyContent(FlexAlign.Center);
  }
}