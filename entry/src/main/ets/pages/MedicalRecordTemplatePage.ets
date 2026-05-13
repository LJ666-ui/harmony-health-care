import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';

interface MedicalRecordTemplate {
  id: number;
  doctorId: number;
  templateName: string;
  diagnosisTemplate: string;
  treatmentTemplate: string;
  notesTemplate: string;
  isPublic: number;
  usageCount: number;
  createdAt: string;
}

@Entry
@Component
struct MedicalRecordTemplatePage {
  @State templates: MedicalRecordTemplate[] = [];
  @State loading: boolean = false;
  @State showCreateDialog: boolean = false;
  @State selectedTemplate: MedicalRecordTemplate | null = null;

  aboutToAppear() {
    this.loadTemplates();
  }

  async loadTemplates() {
    this.loading = true;
    try {
      const response = await http.createHttp().request(
        'http://localhost:8080/api/doctor/1/medical-record-templates',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        const result: Record<string, Object> = JSON.parse(response.result as string) as Record<string, Object>;
        this.templates = (result.data as MedicalRecordTemplate[]) || [];
      }
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.loading = false;
    }
  }

  async deleteTemplate(id: number) {
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/doctor/medical-record-template/${id}`,
        {
          method: http.RequestMethod.DELETE,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (response.responseCode === 200) {
        this.loadTemplates();
      }
    } catch (error) {
      console.error('删除失败:', error);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('病历模板管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Button('创建模板')
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

      // 模板列表
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
      } else if (this.templates.length === 0) {
        Column() {
          Text('暂无病历模板')
            .fontSize(16)
            .fontColor('#999999')
          
          Button('创建第一个模板')
            .fontSize(14)
            .margin({ top: 16 })
            .onClick(() => {
              this.showCreateDialog = true;
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.templates, (item: MedicalRecordTemplate) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.templateName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                  
                  Blank()
                  
                  Text(item.isPublic === 1 ? '公开' : '私有')
                    .fontSize(12)
                    .fontColor(item.isPublic === 1 ? '#34C759' : '#999999')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor(item.isPublic === 1 ? '#E8F5E9' : '#F5F5F5')
                    .borderRadius(4)
                }
                .width('100%')
                .margin({ bottom: 8 })

                Row() {
                  Text(`诊断: ${item.diagnosisTemplate || '无'}`)
                    .fontSize(12)
                    .fontColor('#666666')
                }
                .width('100%')
                .margin({ bottom: 4 })

                Row() {
                  Text(`治疗: ${item.treatmentTemplate || '无'}`)
                    .fontSize(12)
                    .fontColor('#666666')
                }
                .width('100%')
                .margin({ bottom: 4 })

                Row() {
                  Text(`使用次数: ${item.usageCount}`)
                    .fontSize(12)
                    .fontColor('#999999')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Row() {
                  Button('使用')
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#34C759')
                    .onClick(() => {
                      // 使用模板
                    })

                  Blank()

                  Button('编辑')
                    .fontSize(14)
                    .fontColor('#007DFF')
                    .backgroundColor('#E3F2FD')
                    .onClick(() => {
                      this.selectedTemplate = item;
                    })

                  Button('删除')
                    .fontSize(14)
                    .fontColor('#FF3B30')
                    .backgroundColor('#FFE5E5')
                    .margin({ left: 8 })
                    .onClick(() => {
                      this.deleteTemplate(item.id);
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
    .bindSheet($$this.showCreateDialog, this.CreateTemplateSheet(), {
      height: 500,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  CreateTemplateSheet() {
    Column() {
      Text('创建病历模板')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      // 表单内容
      Column() {
        TextInput({ placeholder: '模板名称' })
          .width('100%')
          .margin({ bottom: 16 })

        TextArea({ placeholder: '诊断模板' })
          .width('100%')
          .height(80)
          .margin({ bottom: 16 })

        TextArea({ placeholder: '治疗方案模板' })
          .width('100%')
          .height(80)
          .margin({ bottom: 16 })

        TextInput({ placeholder: '备注模板' })
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

          Button('创建')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#007DFF')
            .onClick(() => {
              // 创建模板
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
}
