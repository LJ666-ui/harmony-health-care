import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DoctorInfo, DoctorInfoHelper } from '../models/DoctorModel';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import promptAction from '@ohos.promptAction';

const TAG: string = 'DoctorProfilePage';

@Entry
@Component
struct DoctorProfilePage {
  @StorageLink('userId') currentUserId: number = 0;
  @State doctorInfo: DoctorInfo = new DoctorInfo();
  @State isEditing: boolean = false;
  @State isLoading: boolean = false;

  private tempDoctorInfo: DoctorInfo = new DoctorInfo();

  aboutToAppear(): void {
    this.loadDoctorInfo();
  }

  private loadDoctorInfo(): void {
    const doctorInfoFromStorage = AppStorage.get<DoctorInfo>('doctorInfo');
    if (doctorInfoFromStorage) {
      this.doctorInfo = doctorInfoFromStorage;
    }
  }

  private startEditing(): void {
    this.tempDoctorInfo = JSON.parse(JSON.stringify(this.doctorInfo));
    this.isEditing = true;
  }

  private cancelEditing(): void {
    this.isEditing = false;
  }

  private saveChanges(): void {
    this.isLoading = true;
    
    const token: string | undefined = AppStorage.get<string>('doctorToken');
    
    const updateData = {
      realName: this.tempDoctorInfo.realName,
      phone: this.tempDoctorInfo.phone,
      department: this.tempDoctorInfo.department,
      title: this.tempDoctorInfo.title,
      specialty: this.tempDoctorInfo.specialty,
      description: this.tempDoctorInfo.description
    };

    HttpUtil.put(`${ApiConstants.DOCTOR_UPDATE.replace(/\/$/, '')}`, updateData, { 'Token': token || '' })
      .then((response: object) => {
        const res = response as Record<string, Object>;
        if (res['code'] === 200) {
          this.doctorInfo = JSON.parse(JSON.stringify(this.tempDoctorInfo));
          AppStorage.setOrCreate<DoctorInfo>('doctorInfo', this.doctorInfo);
          this.isEditing = false;
          promptAction.showToast({ message: '保存成功' });
        } else {
          promptAction.showToast({ message: (res['message'] as string) || '保存失败' });
        }
      })
      .catch((error: Error) => {
        promptAction.showToast({ message: '网络错误：' + error.message });
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 0 }) {
          this.buildProfileHeader();
          
          if (this.isEditing) {
            this.buildEditForm();
          } else {
            this.buildInfoList();
          }
          
          this.buildMenuList();
        }
        .width('100%')
        .padding({ bottom: 40 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#F5F7FA');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildProfileHeader() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width(90)
          .height(90)
          .borderRadius(45)
          .backgroundColor('#1677FF')
          .shadow({ radius: 12, color: '#1677FF33', offsetX: 0, offsetY: 6 });

        Column({ space: 4 }) {
          Row({ space: 4 }) {
            Column()
              .width(18)
              .height(18)
              .borderRadius(4)
              .backgroundColor('#FFFFFF80')
              .opacity(0.9);
            Column()
              .width(18)
              .height(18)
              .borderRadius(4)
              .backgroundColor('#FFFFFF80')
              .opacity(0.9);
          }

          Row({ space: 4 }) {
            Column()
              .width(18)
              .height(18)
              .borderRadius(4)
              .backgroundColor('#FFFFFF80')
              .opacity(0.9);
            Column()
              .width(18)
              .height(18)
              .borderRadius(4)
              .backgroundColor('#FFFFFF80')
              .opacity(0.9);
          }
        }
        .padding({ bottom: 12 });
      }
      .width(90)
      .height(90);

      Text(this.doctorInfo.realName || '未设置')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333');

      Text(`${this.doctorInfo.department || '未知科室'} | ${this.doctorInfo.title || '未设置职称'}`)
        .fontSize(14)
        .fontColor('#666666');
    }
    .width('100%')
    .padding({ top: 40, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center);

    Row() {
      Button(this.isEditing ? '取消' : '编辑个人信息')
        .fontSize(14)
        .fontColor(this.isEditing ? '#FF6B6B' : '#1677FF')
        .backgroundColor('transparent')
        .onClick(() => {
          if (this.isEditing) {
            this.cancelEditing();
          } else {
            this.startEditing();
          }
        });

      Blank();

      if (this.isEditing) {
        Button('保存')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(20)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.saveChanges();
          });
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF');
  }

  @Builder
  buildEditForm() {
    Column({ space: 0 }) {
      this.buildEditField('姓名', 'realName');
      this.buildDivider();
      this.buildEditField('手机号', 'phone', true);
      this.buildDivider();
      this.buildEditField('科室', 'department');
      this.buildDivider();
      this.buildEditField('职称', 'title');
      this.buildDivider();
      this.buildEditField('专业领域', 'specialty');
      this.buildDivider();
      this.buildEditTextArea('个人简介', 'description');
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 });
  }

  @Builder
  buildEditField(label: string, field: string, isPhone: boolean = false) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#333333')
        .width(80);

      TextInput({ text: (this.tempDoctorInfo as Record<string, Object>)[field] as string || '' })
        .fontSize(15)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.End)
        .type(isPhone ? InputType.PhoneNumber : InputType.Normal)
        .onChange((value: string) => {
          (this.tempDoctorInfo as Record<string, Object>)[field] = value;
        });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 });
  }

  @Builder
  buildEditTextArea(label: string, field: string) {
    Column({ space: 12 }) {
      Row() {
        Text(label)
          .fontSize(15)
          .fontColor('#333333');
      }
      .width('100%')
      .padding({ left: 20, right: 20 });

      TextArea({ text: (this.tempDoctorInfo as Record<string, Object>)[field] as string || '' })
        .fontSize(15)
        .fontColor('#333333')
        .width('calc(100% - 40px)')
        .height(120)
        .margin({ left: 20, right: 20 })
        .onChange((value: string) => {
          (this.tempDoctorInfo as Record<string, Object>)[field] = value;
        });
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 });
  }

  @Builder
  buildInfoList() {
    Column() {
      this.buildInfoItem('工号', this.doctorInfo.employeeNo || '-');
      this.buildDivider();
      this.buildInfoItem('姓名', this.doctorInfo.realName || '-');
      this.buildDivider();
      this.buildInfoItem('手机号', this.doctorInfo.phone || '-');
      this.buildDivider();
      this.buildInfoItem('科室', this.doctorInfo.department || '-');
      this.buildDivider();
      this.buildInfoItem('职称', this.doctorInfo.title || '-');
      
      if (this.doctorInfo.specialty && this.doctorInfo.specialty.trim() !== '') {
        this.buildDivider();
        this.buildInfoItem('专业领域', this.doctorInfo.specialty);
      }
      
      if (this.doctorInfo.description && this.doctorInfo.description.trim() !== '') {
        this.buildDivider();
        this.buildDescriptionItem('个人简介', this.doctorInfo.description);
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 });
  }

  @Builder
  buildInfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#333333')
        .width(80);

      Text(value)
        .fontSize(15)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.End);
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 });
  }

  @Builder
  buildDescriptionItem(label: string, value: string) {
    Column({ space: 8 }) {
      Row() {
        Text(label)
          .fontSize(15)
          .fontColor('#333333');
      }
      .width('100%')
      .padding({ left: 20, right: 20 });
      
      Text(value)
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(22)
        .width('calc(100% - 40px)')
        .padding({ left: 20, right: 20 });
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 });
  }

  @Builder
  buildDivider() {
    Row()
      .width('calc(100% - 40px)')
      .height(1)
      .backgroundColor('#EEEEEE')
      .margin({ left: 20, right: 20 });
  }

  @Builder
  buildMenuList() {
    Column() {
      this.buildMenuItem('修改密码', () => {
        router.pushUrl({
          url: 'pages/ChangePasswordPage'
        });
      });

      this.buildMenuItem('消息通知', () => {
        promptAction.showToast({ message: '消息通知设置开发中' });
      });

      this.buildMenuItem('帮助与反馈', () => {
        promptAction.showToast({ message: '帮助与反馈开发中' });
      });

      this.buildMenuItem('关于我们', () => {
        promptAction.showToast({ message: '关于我们页面开发中' });
      });
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 })
    .borderRadius({ topLeft: 12, topRight: 12 });
  }

  @Builder
  buildMenuItem(title: string, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(15)
        .fontColor('#333333');

      Blank();

      Text('>')
        .fontSize(16)
        .fontColor('#CCCCCC');
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 17, bottom: 17 })
    .onClick(onClick);

    if (title !== '关于我们') {
      Row()
        .width('calc(100% - 40px)')
        .height(1)
        .backgroundColor('#F5F5F5')
        .margin({ left: 20, right: 20 });
    }
  }
}
