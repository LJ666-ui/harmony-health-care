import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { ConsultationService, OnlineDoctor } from '../services/ConsultationService';

interface Department {
  id: number;
  name: string;
  icon: string;
  color: string;
}

interface Doctor {
  id: number;
  name: string;
  title: string;
  department: string;
  rating: number;
  avatar: string;
}

@Entry
@Component
struct ConsultationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State departments: Department[] = [];
  @State recommendedDoctors: Doctor[] = [];
  @State isLoading: boolean = true;
  private consultationService: ConsultationService = ConsultationService.getInstance();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    
    try {
      const onlineDoctors = await this.consultationService.getOnlineDoctors();
      
      const doctors: Doctor[] = [];
      for (let i = 0; i < onlineDoctors.length; i++) {
        const doc = onlineDoctors[i];
        const doctor: Doctor = {
          id: doc.doctorId,
          name: doc.doctorName,
          title: doc.title,
          department: doc.department,
          rating: doc.rating,
          avatar: doc.avatar || '👨‍⚕️'
        };
        doctors.push(doctor);
      }
      this.recommendedDoctors = doctors;

      const deptMap = new Map<number, Department>();
      for (let i = 0; i < onlineDoctors.length; i++) {
        const doc = onlineDoctors[i];
        if (!deptMap.has(doc.doctorId)) {
          const dept: Department = {
            id: doc.doctorId,
            name: doc.department,
            icon: this.getDepartmentIcon(doc.department),
            color: this.getDepartmentColor(doc.department)
          };
          deptMap.set(doc.doctorId, dept);
        }
      }
      this.departments = Array.from(deptMap.values());

      if (this.departments.length === 0) {
        const dept1: Department = { id: 1, name: '内科', icon: '🫀', color: '#E74C3C' };
        const dept2: Department = { id: 2, name: '外科', icon: '🔪', color: '#3498DB' };
        const dept3: Department = { id: 3, name: '儿科', icon: '👶', color: '#F39C12' };
        const dept4: Department = { id: 4, name: '妇产科', icon: '🤰', color: '#E91E63' };
        this.departments = [dept1, dept2, dept3, dept4];
      }
    } catch (error) {
      console.error('[ConsultationPage] 加载数据异常:', error);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  private getDepartmentIcon(deptName: string): string {
    const iconMap: Map<string, string> = new Map([
      ['内科', '🫀'],
      ['外科', '🔪'],
      ['儿科', '👶'],
      ['妇产科', '🤰'],
      ['骨科', '🦴'],
      ['眼科', '👁️'],
      ['耳鼻喉科', '👂'],
      ['皮肤科', '🧴']
    ]);
    return iconMap.get(deptName) || '🏥';
  }

  private getDepartmentColor(deptName: string): string {
    const colorMap: Map<string, string> = new Map([
      ['内科', '#E74C3C'],
      ['外科', '#3498DB'],
      ['儿科', '#F39C12'],
      ['妇产科', '#E91E63'],
      ['骨科', '#9B59B6'],
      ['眼科', '#2ECC71'],
      ['耳鼻喉科', '#00BCD4'],
      ['皮肤科', '#FF9800']
    ]);
    return colorMap.get(deptName) || '#3498DB';
  }

  selectDepartment(dept: Department): void {
    router.pushUrl({ 
      url: 'pages/DoctorListPage',
      params: { departmentId: dept.id, departmentName: dept.name }
    }).catch((error: Error) => {
      console.error('跳转医生列表失败:', error.message);
      ToastUtil.showError('功能开发中');
    });
  }

  consultDoctor(doctor: Doctor): void {
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
      Header({ title: '在线问诊', showBack: true });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#F39C12')
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
            // 科室选择
            Text('选择科室')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('90%')
              .margin({ top: 15, bottom: 10 })

            Grid() {
              ForEach(this.departments, (dept: Department) => {
                GridItem() {
                  Column() {
                    Text(dept.icon)
                      .fontSize(32)
                    Text(dept.name)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#333')
                      .margin({ top: 5 })
                  }
                  .width('100%')
                  .height(80)
                  .backgroundColor('#fff')
                  .borderRadius(12)
                  .justifyContent(FlexAlign.Center)
                  .shadow({ radius: 2, color: '#e0e0e0', offsetX: 0, offsetY: 1 })
                }
                .onClick(() => this.selectDepartment(dept))
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsGap(10)
            .columnsGap(10)
            .width('90%')
            .height(180)

            // 推荐医生
            Text('推荐医生')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('90%')
              .margin({ top: 25, bottom: 10 })

            ForEach(this.recommendedDoctors, (doctor: Doctor) => {
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

                  Text(doctor.department)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#999')
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

                Button('咨询')
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor('#fff')
                  .backgroundColor('#F39C12')
                  .borderRadius(20)
                  .height(36)
                  .padding({ left: 20, right: 20 })
                  .onClick(() => this.consultDoctor(doctor))
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
