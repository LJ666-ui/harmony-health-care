import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';

interface Consultation {
  id: number;
  initiatorId: number;
  patientId: number;
  title: string;
  description: string;
  status: string;
  scheduledTime: string;
  startedTime: string;
  endedTime: string;
  createdAt: string;
}

interface ConsultationRecord {
  id: number;
  consultationId: number;
  doctorId: number;
  content: string;
  recordTime: string;
}

@Entry
@Component
struct ConsultationManagementPage {
  @State consultations: Consultation[] = [];
  @State loading: boolean = false;
  @State selectedTab: number = 0;
  @State showCreateDialog: boolean = false;
  @State selectedConsultation: Consultation | null = null;
  @State records: ConsultationRecord[] = [];

  aboutToAppear() {
    this.loadConsultations();
  }

  async loadConsultations() {
    this.loading = true;
    try {
      const status = this.selectedTab === 0 ? 'pending' : 
                     this.selectedTab === 1 ? 'in_progress' : 
                     this.selectedTab === 2 ? 'completed' : '';
      
      const url = status ? 
        `http://localhost:8080/api/doctor/1/consultations?status=${status}&page=1&pageSize=20` :
        'http://localhost:8080/api/doctor/1/consultations?page=1&pageSize=20';
      
      const response = await http.createHttp().request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.responseCode === 200) {
        const result: Record<string, Object> = JSON.parse(response.result as string) as Record<string, Object>;
        const dataObj: Record<string, Object> = result.data as Record<string, Object>;
        this.consultations = (dataObj.records as Consultation[]) || [];
      }
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.loading = false;
    }
  }

  async startConsultation(id: number) {
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/doctor/consultation/${id}/start`,
        {
          method: http.RequestMethod.PUT,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        this.loadConsultations();
      }
    } catch (error) {
      console.error('开始会诊失败:', error);
    }
  }

  async endConsultation(id: number) {
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/doctor/consultation/${id}/end`,
        {
          method: http.RequestMethod.PUT,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        this.loadConsultations();
      }
    } catch (error) {
      console.error('结束会诊失败:', error);
    }
  }

  async loadRecords(consultationId: number) {
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/doctor/consultation/${consultationId}/records`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        const result: Record<string, Object> = JSON.parse(response.result as string) as Record<string, Object>;
        this.records = (result.data as ConsultationRecord[]) || [];
      }
    } catch (error) {
      console.error('加载记录失败:', error);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('会诊管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Button('发起会诊')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#007DFF')
          .onClick(() => {
            this.showCreateDialog = true;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // Tab切换
      Tabs() {
        TabContent() {
          this.ConsultationList()
        }
        .tabBar('待开始')

        TabContent() {
          this.ConsultationList()
        }
        .tabBar('进行中')

        TabContent() {
          this.ConsultationList()
        }
        .tabBar('已完成')

        TabContent() {
          this.ConsultationList()
        }
        .tabBar('全部')
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.selectedTab = index;
        this.loadConsultations();
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet($$this.showCreateDialog, this.CreateConsultationSheet(), {
      height: 500,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  ConsultationList() {
    if (this.loading) {
      Column() {
        LoadingProgress()
          .width(50)
          .height(50)
          .color('#007DFF')
        
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 10 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (this.consultations.length === 0) {
      Column() {
        Text('暂无会诊')
          .fontSize(16)
          .fontColor('#999999')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.consultations, (item: Consultation) => {
          ListItem() {
            Column() {
              Row() {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                
                Blank()
                
                Text(this.getStatusText(item.status))
                  .fontSize(12)
                  .fontColor(this.getStatusColor(item.status))
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(this.getStatusBgColor(item.status))
                  .borderRadius(4)
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(`患者ID: ${item.patientId}`)
                  .fontSize(12)
                  .fontColor('#666666')
                
                Blank()
                
                Text(item.scheduledTime || '未安排')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(item.description || '无描述')
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ bottom: 12 })

              Row() {
                if (item.status === 'pending') {
                  Button('开始')
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#34C759')
                    .onClick(() => {
                      this.startConsultation(item.id);
                    })
                } else if (item.status === 'in_progress') {
                  Button('结束')
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#FF9500')
                    .onClick(() => {
                      this.endConsultation(item.id);
                    })
                }

                Blank()

                Button('详情')
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .backgroundColor('#E3F2FD')
                  .onClick(() => {
                    this.selectedConsultation = item;
                    this.loadRecords(item.id);
                  })
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ bottom: 12 })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 12 })
    }
  }

  @Builder
  CreateConsultationSheet() {
    Column() {
      Text('发起会诊')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      // 表单内容
      Column() {
        TextInput({ placeholder: '会诊标题' })
          .width('100%')
          .margin({ bottom: 16 })

        TextArea({ placeholder: '会诊描述' })
          .width('100%')
          .height(100)
          .margin({ bottom: 16 })

        TextInput({ placeholder: '患者ID' })
          .width('100%')
          .margin({ bottom: 16 })

        TextInput({ placeholder: '参与医生ID（逗号分隔）' })
          .width('100%')
          .margin({ bottom: 16 })

        Row() {
          Button('取消')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .onClick(() => {
              this.showCreateDialog = false;
            })

          Blank()

          Button('发起')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#007DFF')
            .onClick(() => {
              // 发起会诊
              this.showCreateDialog = false;
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .padding(20)
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'pending':
        return '待开始';
      case 'in_progress':
        return '进行中';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }

  private getStatusColor(status: string): ResourceColor {
    switch (status) {
      case 'pending':
        return '#FF9500';
      case 'in_progress':
        return '#007DFF';
      case 'completed':
        return '#34C759';
      case 'cancelled':
        return '#FF3B30';
      default:
        return '#999999';
    }
  }

  private getStatusBgColor(status: string): ResourceColor {
    switch (status) {
      case 'pending':
        return '#FFF4E6';
      case 'in_progress':
        return '#E3F2FD';
      case 'completed':
        return '#E8F5E9';
      case 'cancelled':
        return '#FFE5E5';
      default:
        return '#F5F5F5';
    }
  }
}
