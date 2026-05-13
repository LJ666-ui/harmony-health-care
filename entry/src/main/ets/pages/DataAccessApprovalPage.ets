import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';

interface DataAccessApplication {
  id: number;
  requesterId: number;
  requesterRole: string;
  approverId: number;
  dataType: string;
  dataId: number;
  reason: string;
  duration: number;
  status: string;
  approvedAt: string;
  expiresAt: string;
  createdAt: string;
}

@Entry
@Component
struct DataAccessApprovalPage {
  @State applications: DataAccessApplication[] = [];
  @State loading: boolean = false;
  @State selectedTab: number = 0;

  aboutToAppear() {
    this.loadPendingApplications();
  }

  async loadPendingApplications() {
    this.loading = true;
    try {
      const response = await http.createHttp().request(
        'http://localhost:8080/api/security/data-access-pending?page=1&pageSize=20',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string);
        this.applications = result.data.records || [];
      }
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.loading = false;
    }
  }

  async approveApplication(id: number) {
    try {
      const response = await http.createHttp().request(
        'http://localhost:8080/api/security/data-access-approve',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            applicationId: id,
            approverId: 1,
            approved: true,
            comment: '同意访问'
          }
        }
      );
      
      if (response.responseCode === 200) {
        this.loadPendingApplications();
      }
    } catch (error) {
      console.error('审批失败:', error);
    }
  }

  async rejectApplication(id: number) {
    try {
      const response = await http.createHttp().request(
        'http://localhost:8080/api/security/data-access-approve',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            applicationId: id,
            approverId: 1,
            approved: false,
            comment: '拒绝访问'
          }
        }
      );
      
      if (response.responseCode === 200) {
        this.loadPendingApplications();
      }
    } catch (error) {
      console.error('拒绝失败:', error);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('数据访问审批')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Button('刷新')
          .fontSize(14)
          .onClick(() => {
            this.loadPendingApplications();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // Tab切换
      Tabs() {
        TabContent() {
          this.ApplicationList()
        }
        .tabBar('待审批')

        TabContent() {
          Text('已审批')
            .fontSize(16)
            .fontColor('#999999')
        }
        .tabBar('已审批')
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.selectedTab = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  ApplicationList() {
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
    } else if (this.applications.length === 0) {
      Column() {
        Text('暂无待审批申请')
          .fontSize(16)
          .fontColor('#999999')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.applications, (item: DataAccessApplication) => {
          ListItem() {
            Column() {
              Row() {
                Text(`申请人ID: ${item.requesterId}`)
                  .fontSize(14)
                  .fontColor('#333333')
                
                Blank()
                
                Text(item.status === 'pending' ? '待审批' : item.status)
                  .fontSize(12)
                  .fontColor('#FF9500')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor('#FFF4E6')
                  .borderRadius(4)
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(`数据类型: ${item.dataType}`)
                  .fontSize(12)
                  .fontColor('#666666')
                
                Text(`数据ID: ${item.dataId}`)
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 16 })
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(`申请原因: ${item.reason}`)
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(`访问时长: ${item.duration}小时`)
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ bottom: 12 })

              Row() {
                Button('批准')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#007DFF')
                  .onClick(() => {
                    this.approveApplication(item.id);
                  })

                Blank()

                Button('拒绝')
                  .fontSize(14)
                  .fontColor('#FF3B30')
                  .backgroundColor('#FFE5E5')
                  .onClick(() => {
                    this.rejectApplication(item.id);
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
}
