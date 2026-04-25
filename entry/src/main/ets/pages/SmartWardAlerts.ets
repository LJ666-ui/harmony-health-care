/**
 * 智慧病房告警中心页面
 * 提供实时告警展示和处理功能
 */

import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { AlertManager } from '../core/AlertManager';
import { WardAlert, AlertLevel } from '../models/SmartWardAlertModels';

@Entry
@Component
struct SmartWardAlerts {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State alerts: WardAlert[] = [];
  @State isLoading: boolean = true;
  @State selectedTab: string = 'all';

  private alertManager = AlertManager.getInstance();

  aboutToAppear(): void {
    this.loadAlerts();
  }

  loadAlerts(): void {
    this.isLoading = true;
    // 模拟加载告警数据
    setTimeout(() => {
      this.alerts = this.alertManager.getAlerts();
      this.isLoading = false;
    }, 500);
  }

  handleBack(): void {
    router.back();
  }

  acknowledgeAlert(alertId: string): void {
    this.alertManager.acknowledgeAlert(alertId, '当前用户');
    this.loadAlerts();
  }

  getAlertColor(level: AlertLevel): string {
    const colorMap: Record<AlertLevel, string> = {
      [AlertLevel.EMERGENCY]: '#FF0000',
      [AlertLevel.URGENT]: '#FF6600',
      [AlertLevel.WARNING]: '#FFAA00',
      [AlertLevel.INFO]: '#1890FF'
    };
    return colorMap[level] || '#999999';
  }

  getAlertBgColor(level: AlertLevel): string {
    const colorMap: Record<AlertLevel, string> = {
      [AlertLevel.EMERGENCY]: '#FFEBEE',
      [AlertLevel.URGENT]: '#FFF3E0',
      [AlertLevel.WARNING]: '#FFF8E1',
      [AlertLevel.INFO]: '#E3F2FD'
    };
    return colorMap[level] || '#F5F5F5';
  }

  getAlertLevelText(level: AlertLevel): string {
    const textMap: Record<AlertLevel, string> = {
      [AlertLevel.EMERGENCY]: '急救',
      [AlertLevel.URGENT]: '紧急',
      [AlertLevel.WARNING]: '警告',
      [AlertLevel.INFO]: '信息'
    };
    return textMap[level] || '未知';
  }

  build() {
    Column() {
      Header({ title: '告警中心', showBack: true, onBack: () => this.handleBack() });

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          // 统计信息
          Row() {
            Text(`总告警: ${this.alerts.length}`)
              .fontSize(14)
              .margin({ right: 20 })

            Text(`未确认: ${this.alerts.filter(a => !a.isAcknowledged).length}`)
              .fontSize(14)
              .fontColor('#F44336')
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)

          // 告警列表
          Column() {
            ForEach(this.alerts, (alert: WardAlert) => {
              Column() {
                Row() {
                  Text(this.getAlertLevelText(alert.level))
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                    .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                    .borderRadius(3)
                    .backgroundColor(this.getAlertColor(alert.level))

                  Column() {
                    Text(alert.message)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)

                    Text(`${alert.roomNumber}病房 - ${alert.triggeredAt ? new Date(alert.triggeredAt).toLocaleString() : ''}`)
                      .fontSize(12)
                      .fontColor('#666')
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  if (!alert.isAcknowledged) {
                    Button('确认')
                      .fontSize(12)
                      .height(28)
                      .onClick(() => this.acknowledgeAlert(alert.alertId))
                  } else {
                    Text('已确认')
                      .fontSize(12)
                      .fontColor('#4CAF50')
                      .padding({ left: 8, right: 8 })
                  }
                }
                .width('100%')
                .padding(15)
                .backgroundColor(this.getAlertBgColor(alert.level))
                .borderRadius(8)
                .margin({ bottom: 10 })
              })
            })
          }
          .padding(15)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
