import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface FamilyDoctor {
  id: number;
  name: string;
  title: string;
  specialty: string;
  hospital: string;
  rating: number;
  avatar: string;
  isSigned: boolean;
}

@Entry
@Component
struct FamilyDoctorPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State doctors: FamilyDoctor[] = [];
  @State myDoctor: FamilyDoctor | null = null;
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadDoctors();
  }

  async loadDoctors(): Promise<void> {
    this.isLoading = true;
    
    try {
      await new Promise<void>(resolve => setTimeout(resolve, 500));
      
      this.doctors = [
        { id: 1, name: '张医生', title: '主任医师', specialty: '内科、慢性病管理', hospital: '北京协和医院', rating: 4.9, avatar: '👨‍⚕️', isSigned: true },
        { id: 2, name: '李医生', title: '副主任医师', specialty: '全科医学、老年医学', hospital: '北京大学第一医院', rating: 4.8, avatar: '👩‍⚕️', isSigned: false },
        { id: 3, name: '王医生', title: '主治医师', specialty: '家庭医学、预防保健', hospital: '北京同仁医院', rating: 4.7, avatar: '👨‍⚕️', isSigned: false },
        { id: 4, name: '刘医生', title: '副主任医师', specialty: '全科医学、健康管理', hospital: '北京友谊医院', rating: 4.8, avatar: '👩‍⚕️', isSigned: false }
      ];
      
      this.myDoctor = this.doctors.find(d => d.isSigned) || null;
    } catch (error) {
      console.error('[FamilyDoctorPage] 加载数据异常:', error);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  signDoctor(doctor: FamilyDoctor): void {
    const index = this.doctors.findIndex(d => d.id === doctor.id);
    if (index !== -1) {
      // 取消之前的签约
      this.doctors.forEach(d => d.isSigned = false);
      // 签约新医生
      this.doctors[index].isSigned = true;
      this.myDoctor = this.doctors[index];
      ToastUtil.showSuccess('签约成功');
    }
  }

  unsignDoctor(): void {
    if (this.myDoctor) {
      const index = this.doctors.findIndex(d => d.id === this.myDoctor!.id);
      if (index !== -1) {
        this.doctors[index].isSigned = false;
        this.myDoctor = null;
        ToastUtil.showSuccess('已解约');
      }
    }
  }

  consultDoctor(doctor: FamilyDoctor): void {
    router.pushUrl({ 
      url: 'pages/DoctorChatPage',
      params: { doctorId: doctor.id }
    }).catch((error: Error) => {
      console.error('跳转医生对话失败:', error.message);
      ToastUtil.showError('功能开发中');
    });
  }

  build() {
    Column() {
      Header({ title: '家庭医生', showBack: true });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#34495E')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 我的家庭医生
            if (this.myDoctor) {
              Text('我的家庭医生')
                .fontSize(this.isElderMode ? 18 : 16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .width('90%')
                .margin({ top: 15, bottom: 10 })

              Row() {
                Text(this.myDoctor.avatar)
                  .fontSize(50)
                  .margin({ right: 15 })

                Column() {
                  Row() {
                    Text(this.myDoctor.name)
                      .fontSize(this.isElderMode ? 18 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333')
                    
                    Text(this.myDoctor.title)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#666')
                      .margin({ left: 10 })
                  }

                  Text('🏥 ' + this.myDoctor.hospital)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#999')
                    .margin({ top: 5 })

                  Text('专长：' + this.myDoctor.specialty)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#666')
                    .margin({ top: 5 })

                  Row() {
                    Text('⭐ ' + this.myDoctor.rating.toFixed(1))
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#F39C12')
                  }
                  .margin({ top: 5 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('90%')
              .backgroundColor('#E8F5E9')
              .borderRadius(12)
              .padding(15)
              .margin({ bottom: 15 })

              Row() {
                Button('咨询医生')
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor('#fff')
                  .backgroundColor('#34495E')
                  .borderRadius(20)
                  .layoutWeight(1)
                  .onClick(() => this.consultDoctor(this.myDoctor!))

                Button('解约')
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor('#E74C3C')
                  .backgroundColor('#fff')
                  .borderRadius(20)
                  .layoutWeight(1)
                  .margin({ left: 10 })
                  .onClick(() => this.unsignDoctor())
              }
              .width('90%')
              .margin({ bottom: 20 })
            }

            // 推荐医生
            Text('推荐医生')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('90%')
              .margin({ top: 10, bottom: 10 })

            ForEach(this.doctors.filter(d => !d.isSigned), (doctor: FamilyDoctor) => {
              Row() {
                Text(doctor.avatar)
                  .fontSize(40)
                  .margin({ right: 15 })

                Column() {
                  Row() {
                    Text(doctor.name)
                      .fontSize(this.isElderMode ? 18 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333')
                    
                    Text(doctor.title)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#666')
                      .margin({ left: 10 })
                  }

                  Text('🏥 ' + doctor.hospital)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#999')
                    .margin({ top: 5 })

                  Text('专长：' + doctor.specialty)
                    .fontSize(this.isElderMode ? 12 : 10)
                    .fontColor('#666')
                    .margin({ top: 5 })

                  Row() {
                    Text('⭐ ' + doctor.rating.toFixed(1))
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#F39C12')
                  }
                  .margin({ top: 5 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Button('签约')
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor('#fff')
                  .backgroundColor('#34495E')
                  .borderRadius(20)
                  .height(36)
                  .padding({ left: 20, right: 20 })
                  .onClick(() => this.signDoctor(doctor))
              }
              .width('90%')
              .backgroundColor('#fff')
              .borderRadius(12)
              .padding(15)
              .shadow({ radius: 2, color: '#e0e0e0', offsetX: 0, offsetY: 1 })
              .margin({ bottom: 10 })
            })
          }
          .width('100%')
          .padding({ bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      Footer();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')
  }
}
