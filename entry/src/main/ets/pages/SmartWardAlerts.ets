/**
 * 智慧病房告警中心页面
 * 提供实时告警展示和处理功能
 */

import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { AlertManager } from '../core/AlertManager';
import { WardAlert } from '../models/SmartWardAlertModels';
import { AlertLevel } from '../models/SmartWardEnums';

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
    switch (level) {
      case AlertLevel.EMERGENCY:
        return '#FF0000';
      case AlertLevel.URGENT:
        return '#FF6600';
      case AlertLevel.WARNING:
        return '#FFAA00';
      case AlertLevel.INFO:
        return '#1890FF';
      default:
        return '#999999';
    }
  }

  getAlertBgColor(level: AlertLevel): string {
    switch (level) {
      case AlertLevel.EMERGENCY:
        return '#FFEBEE';
      case AlertLevel.URGENT:
        return '#FFF3E0';
      case AlertLevel.WARNING:
        return '#FFF8E1';
      case AlertLevel.INFO:
        return '#E3F2FD';
      default:
        return '#F5F5F5';
    }
  }

  getAlertLevelText(level: AlertLevel): string {
    switch (level) {
      case AlertLevel.EMERGENCY:
        return '急救';
      case AlertLevel.URGENT:
        return '紧急';
      case AlertLevel.WARNING:
        return '警告';
      case AlertLevel.INFO:
        return '信息';
      default:
        return '未知';
    }
  }

  build() {
    Column() {
      Header({ title: '告警中心', showBack: true });

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
