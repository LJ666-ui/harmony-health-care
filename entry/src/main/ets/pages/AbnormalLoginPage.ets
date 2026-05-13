import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';

interface AbnormalLogin {
  id: number;
  userId: number;
  loginTime: string;
  loginLocation: string;
  deviceInfo: string;
  ipAddress: string;
  abnormalReason: string;
  riskLevel: string;
  isHandled: number;
  handledAt: string;
  handledBy: number;
  handleRemark: string;
  createdAt: string;
}

@Entry
@Component
struct AbnormalLoginPage {
  @State abnormalLogins: AbnormalLogin[] = [];
  @State loading: boolean = false;
  @State selectedTab: number = 0;
  @State statistics: any = null;

  aboutToAppear() {
    this.loadAbnormalLogins();
    this.loadStatistics();
  }

  async loadAbnormalLogins() {
    this.loading = true;
    try {
      const isHandled = this.selectedTab === 0 ? 0 : 1;
      const response = await http.createHttp().request(
        `http://localhost:8080/api/security/abnormal-logins?isHandled=${isHandled}&page=1&pageSize=20`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string);
        this.abnormalLogins = result.data.records || [];
      }
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.loading = false;
    }
  }

  async loadStatistics() {
    try {
      const response = await http.createHttp().request(
        'http://localhost:8080/api/security/abnormal-login/statistics',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string);
        this.statistics = result.data;
      }
    } catch (error) {
      console.error('加载统计失败:', error);
    }
  }

  async handleAbnormalLogin(id: number, remark: string) {
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/security/abnormal-login/${id}/handle`,
        {
          method: http.RequestMethod.PUT,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            handledBy: 1,
            handleRemark: remark
          }
        }
      );
      
      if (response.responseCode === 200) {
        this.loadAbnormalLogins();
        this.loadStatistics();
      }
    } catch (error) {
      console.error('处理失败:', error);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('异常登录检测')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Button('刷新')
          .fontSize(14)
          .onClick(() => {
            this.loadAbnormalLogins();
            this.loadStatistics();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 统计信息
      if (this.statistics) {
        Row() {
          Column() {
            Text('未处理')
              .fontSize(12)
              .fontColor('#999999')
            Text(`${this.statistics.unhandledCount || 0}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF9500')
          }
          .layoutWeight(1)

          Column() {
            Text('高风险')
              .fontSize(12)
              .fontColor('#999999')
            Text(`${this.statistics.highRiskCount || 0}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF3B30')
          }
          .layoutWeight(1)

          Column() {
            Text('中风险')
              .fontSize(12)
              .fontColor('#999999')
            Text(`${this.statistics.mediumRiskCount || 0}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF9500')
          }
          .layoutWeight(1)

          Column() {
            Text('低风险')
              .fontSize(12)
              .fontColor('#999999')
            Text(`${this.statistics.lowRiskCount || 0}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#34C759')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .margin({ top: 1 })
      }

      // Tab切换
      Tabs() {
        TabContent() {
          this.AbnormalLoginList()
        }
        .tabBar('未处理')

        TabContent() {
          this.AbnormalLoginList()
        }
        .tabBar('已处理')
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.selectedTab = index;
        this.loadAbnormalLogins();
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  AbnormalLoginList() {
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
    } else if (this.abnormalLogins.length === 0) {
      Column() {
        Text('暂无异常登录记录')
          .fontSize(16)
          .fontColor('#999999')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.abnormalLogins, (item: AbnormalLogin) => {
          ListItem() {
            Column() {
              Row() {
                Text(`用户ID: ${item.userId}`)
                  .fontSize(14)
                  .fontColor('#333333')
                
                Blank()
                
                Text(this.getRiskLevelText(item.riskLevel))
                  .fontSize(12)
                  .fontColor(this.getRiskLevelColor(item.riskLevel))
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(this.getRiskLevelBgColor(item.riskLevel))
                  .borderRadius(4)
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text(`IP: ${item.ipAddress}`)
                  .fontSize(12)
                  .fontColor('#666666')
                
                Text(item.loginLocation || '未知位置')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ left: 16 })
              }
              .width('100%')
              .margin({ bottom: 4 })

              Row() {
                Text(`设备: ${item.deviceInfo || '未知设备'}`)
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ bottom: 4 })

              Row() {
                Text(`异常原因: ${this.getAbnormalReasonText(item.abnormalReason)}`)
                  .fontSize(12)
                  .fontColor('#FF9500')
              }
              .width('100%')
              .margin({ bottom: 4 })

              Row() {
                Text(`登录时间: ${item.loginTime}`)
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ bottom: 12 })

              if (item.isHandled === 0) {
                Row() {
                  Button('标记为正常')
                    .fontSize(14)
                    .fontColor('#34C759')
                    .backgroundColor('#E8F5E9')
                    .onClick(() => {
                      this.handleAbnormalLogin(item.id, '标记为正常登录');
                    })

                  Blank()

                  Button('标记为异常')
                    .fontSize(14)
                    .fontColor('#FF3B30')
                    .backgroundColor('#FFE5E5')
                    .onClick(() => {
                      this.handleAbnormalLogin(item.id, '确认异常登录');
                    })
                }
                .width('100%')
              } else {
                Row() {
                  Text(`已处理 - ${item.handleRemark || ''}`)
                    .fontSize(12)
                    .fontColor('#999999')
                }
                .width('100%')
              }
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

  private getRiskLevelText(level: string): string {
    switch (level) {
      case 'high':
        return '高风险';
      case 'medium':
        return '中风险';
      case 'low':
        return '低风险';
      default:
        return level;
    }
  }

  private getRiskLevelColor(level: string): ResourceColor {
    switch (level) {
      case 'high':
        return '#FF3B30';
      case 'medium':
        return '#FF9500';
      case 'low':
        return '#34C759';
      default:
        return '#999999';
    }
  }

  private getRiskLevelBgColor(level: string): ResourceColor {
    switch (level) {
      case 'high':
        return '#FFE5E5';
      case 'medium':
        return '#FFF4E6';
      case 'low':
        return '#E8F5E9';
      default:
        return '#F5F5F5';
    }
  }

  private getAbnormalReasonText(reason: string): string {
    switch (reason) {
      case 'abnormal_location':
        return '异常位置';
      case 'abnormal_device':
        return '异常设备';
      case 'abnormal_time':
        return '异常时间';
      default:
        return reason;
    }
  }
}
