import { router } from '@kit.ArkUI';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

class DoctorItem {
  id: number = 0;
  username: string = '';
  phone: string = '';
  age: number = 0;
}

@Entry
@Component
struct DoctorListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State doctors: DoctorItem[] = [];
  @State isLoading: boolean = true;
  @State searchKeyword: string = '';

  aboutToAppear(): void {
    this.loadDoctors();
  }

  private loadDoctors(keyword?: string): void {
    this.isLoading = true;
    const params: Record<string, string> = {};
    if (keyword && keyword.trim() !== '') {
      params['keyword'] = keyword.trim();
    }
    HttpUtil.get<DoctorItem[]>(ApiConstants.DOCTOR_LIST, params as Object, { showLoading: true, loadingText: '加载医生列表...' })
      .then((response) => {
        if (response.success && response.data) {
          const rawData: Object[] = response.data as Object[];
          const list: DoctorItem[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const item: DoctorItem = new DoctorItem();
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            if (raw['id']) { item.id = raw['id'] as number; }
            if (raw['username']) { item.username = raw['username'] as string; }
            if (raw['phone']) { item.phone = raw['phone'] as string; }
            if (raw['age']) { item.age = raw['age'] as number; }
            list.push(item);
          }
          this.doctors = list;
        }
      })
      .catch((err: Error) => {
        console.error('[DoctorListPage] 加载医生列表失败:', err.message);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  private onSearch(): void {
    const keyword: string = this.searchKeyword.trim();
    if (keyword === '') {
      this.loadDoctors();
    } else {
      this.loadDoctors(keyword);
    }
  }

  build() {
    Column() {
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.back();
          });
        Text('选择医生')
          .fontSize(18)
          .fontWeight('bold')
          .flexGrow(1)
          .textAlign(TextAlign.Center);
        Text('')
          .fontSize(16)
          .padding(12);
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 });

      // 搜索栏区域
      Column() {
        Text('👨‍⚕️ 选择医生')
          .fontSize(22)
          .fontWeight('bold')
          .fontColor('#FFFFFF')
          .margin({ bottom: 4 });
        Text('选择一位医生，分享您的健康报告')
          .fontSize(13)
          .fontColor('#FFFFFFBB');

        Row() {
          TextInput({
            placeholder: '搜索医生姓名或手机号'
          })
            .layoutWeight(1)
            .height(42)
            .padding({ left: 16, right: 12 })
            .backgroundColor('#FFFFFF')
            .borderRadius(21)
            .onChange((value: string) => {
              this.searchKeyword = value;
            })
            .onSubmit(() => {
              this.onSearch();
            });
          Text('  🔍')
            .fontSize(16)
            .height(42)
            .padding({ left: 10, right: 14 })
            .backgroundColor('#FFFFFFDD')
            .borderRadius(21)
            .margin({ left: 8 });
        }
        .width('100%')
        .margin({ top: 16 });
      }
      .width('100%')
      .padding(20)
      .linearGradient({
        angle: 135,
        colors: [['#1677FF', 0], ['#36CFC9', 1]]
      })
      .borderRadius({ bottomLeft: 24, bottomRight: 24 });

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.doctors.length === 0) {
        Column() {
          Stack({ alignContent: Alignment.BottomStart }) {
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 135,
                colors: [['#F0F2F5', 0], ['#FAFAFA', 1]]
              })
              .borderRadius(20);

            Column() {
              Text('👨‍⚕️')
                .fontSize(56)
                .margin({ bottom: 16 });
              Text('暂无医生数据')
                .fontSize(18)
                .fontWeight('bold')
                .fontColor('#333333')
                .margin({ bottom: 8 });
              Text('请稍后再试或联系管理员添加医生账号')
                .fontSize(13)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
                .width('75%')
                .lineHeight(20);
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .padding({ bottom: 24 });
          }
          .width('85%')
          .margin({ top: 24, bottom: 24 });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start);
      } else {
        Scroll() {
          Column() {
            ForEach(this.doctors, (doctor: DoctorItem) => {
              Column() {
                Row() {
                  Stack({ alignContent: Alignment.BottomEnd }) {
                    Circle()
                      .width(52)
                      .height(52)
                      .fill('#1677FF');
                    Text(doctor.username.charAt(0))
                      .fontSize(22)
                      .fontWeight('bold')
                      .fontColor('#FFFFFF')
                      .margin({ bottom: 0 });
                  }
                  .margin({ right: 14 });

                  Column({ space: 6 }) {
                    Row() {
                      Text(doctor.username)
                        .fontSize(16)
                        .fontWeight('bold')
                        .fontColor('#333333');
                      Text('执业医师')
                        .fontSize(11)
                        .fontColor('#FFFFFF')
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                        .backgroundColor('#52C41A')
                        .borderRadius(4)
                        .margin({ left: 10 });
                    }

                    Row() {
                      if (doctor.age > 0) {
                        Text(doctor.age + '岁 · ')
                          .fontSize(12)
                          .fontColor('#888888');
                      }
                      if (doctor.phone && doctor.phone !== '') {
                        Text(this.maskPhone(doctor.phone))
                          .fontSize(12)
                          .fontColor('#888888');
                      }
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);

                  Button('咨询')
                    .height(34)
                    .padding({ left: 16, right: 16 })
                    .fontSize(13)
                    .fontWeight('bold')
                    .fontColor('#1677FF')
                    .backgroundColor('#E8F0FF')
                    .borderRadius(17)
                    .onClick(() => {
                      router.push({
                        url: 'pages/DoctorChatPage',
                        params: { doctorId: doctor.id, doctorName: doctor.username, currentUserId: 1 }
                      });
                    });
                }
                .width('100%')
                .alignItems(VerticalAlign.Top);
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ bottom: 10 })
              .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 });
            }, (doctor: DoctorItem) => doctor.id.toString());
          }
          .width('85%')
          .padding({ top: 8, bottom: 48 });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  private maskPhone(phone: string): string {
    if (!phone || phone.length < 7) { return phone; }
    return phone.substring(0, 3) + '****' + phone.substring(phone.length - 4);
  }
}