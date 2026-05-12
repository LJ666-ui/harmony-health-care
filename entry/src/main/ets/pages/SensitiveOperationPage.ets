import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';

interface SensitiveOperation {
  id: number;
  userId: number;
  operationType: string;
  resourceType: string;
  resourceId: number;
  reason: string;
  status: string;
  confirmationCode: string;
  confirmedAt: string;
  cancelledAt: string;
  createdAt: string;
}

@CustomDialog
@Component
struct SensitiveOperationConfirmDialog {
  controller: CustomDialogController;
  @State confirmationCode: string = '';
  @State operationId: number = 0;
  onConfirm: (code: string) => void;

  build() {
    Column() {
      Text('敏感操作确认')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Text('请输入6位确认码以完成此操作')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 20 })

      TextInput({ placeholder: '请输入确认码' })
        .width('100%')
        .type(InputType.Number)
        .maxLength(6)
        .onChange((value: string) => {
          this.confirmationCode = value;
        })
        .margin({ bottom: 20 })

      Row() {
        Button('取消')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .onClick(() => {
            this.controller.close();
          })

        Blank()

        Button('确认')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#007DFF')
          .enabled(this.confirmationCode.length === 6)
          .onClick(() => {
            this.onConfirm(this.confirmationCode);
            this.controller.close();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
  }
}

@Entry
@Component
struct SensitiveOperationPage {
  @State operations: SensitiveOperation[] = [];
  @State loading: boolean = false;
  @State showConfirmDialog: boolean = false;
  @State selectedOperation: SensitiveOperation | null = null;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: SensitiveOperationConfirmDialog({
      onConfirm: (code: string) => {
        this.confirmOperation(code);
      }
    }),
    autoCancel: true
  });

  aboutToAppear() {
    this.loadOperations();
  }

  async loadOperations() {
    this.loading = true;
    try {
      const response = await http.createHttp().request(
        'http://localhost:8080/api/security/sensitive-operation/user/1?status=pending_confirmation&page=1&pageSize=20',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string);
        this.operations = result.data.records || [];
      }
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.loading = false;
    }
  }

  async confirmOperation(code: string) {
    if (!this.selectedOperation) return;
    
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/security/sensitive-operation/${this.selectedOperation.id}/confirm`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            confirmationCode: code
          }
        }
      );
      
      if (response.responseCode === 200) {
        this.loadOperations();
      }
    } catch (error) {
      console.error('确认失败:', error);
    }
  }

  async cancelOperation(id: number) {
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/security/sensitive-operation/${id}/cancel`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        this.loadOperations();
      }
    } catch (error) {
      console.error('取消失败:', error);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('敏感操作确认')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Button('刷新')
          .fontSize(14)
          .onClick(() => {
            this.loadOperations();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 操作列表
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
      } else if (this.operations.length === 0) {
        Column() {
          Text('暂无待确认操作')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.operations, (item: SensitiveOperation) => {
            ListItem() {
              Column() {
                Row() {
                  Text(this.getOperationTypeText(item.operationType))
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                  
                  Blank()
                  
                  Text('待确认')
                    .fontSize(12)
                    .fontColor('#FF9500')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor('#FFF4E6')
                    .borderRadius(4)
                }
                .width('100%')
                .margin({ bottom: 8 })

                Row() {
                  Text(`资源类型: ${item.resourceType}`)
                    .fontSize(12)
                    .fontColor('#666666')
                  
                  Text(`资源ID: ${item.resourceId}`)
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ left: 16 })
                }
                .width('100%')
                .margin({ bottom: 8 })

                Row() {
                  Text(`原因: ${item.reason || '无'}`)
                    .fontSize(12)
                    .fontColor('#666666')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Row() {
                  Text(`确认码: ${item.confirmationCode}`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#007DFF')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Row() {
                  Button('确认')
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#34C759')
                    .onClick(() => {
                      this.selectedOperation = item;
                      this.dialogController.open();
                    })

                  Blank()

                  Button('取消')
                    .fontSize(14)
                    .fontColor('#FF3B30')
                    .backgroundColor('#FFE5E5')
                    .onClick(() => {
                      this.cancelOperation(item.id);
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
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private getOperationTypeText(type: string): string {
    switch (type) {
      case 'delete':
        return '删除操作';
      case 'update':
        return '修改操作';
      case 'export':
        return '导出操作';
      default:
        return type;
    }
  }
}
