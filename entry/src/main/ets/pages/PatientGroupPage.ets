import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

interface PatientGroup {
  id: number;
  doctorId: number;
  groupName: string;
  description: string;
  color: string;
  sortOrder: number;
  patientCount?: number;
}

@Entry
@Component
struct PatientGroupPage {
  @State groups: PatientGroup[] = [];
  @State loading: boolean = false;
  @State showCreateDialog: boolean = false;
  @State newGroupName: string = '';
  @State newGroupDescription: string = '';
  @State newGroupColor: string = '#1677FF';
  @State doctorId: number = 1; // TODO: 从登录信息获取

  private colors: string[] = ['#1677FF', '#52C41A', '#FA8C16', '#13C2C2', '#722ED1', '#EB2F96'];

  aboutToAppear() {
    this.loadGroups();
  }

  async loadGroups() {
    this.loading = true;
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/doctor/${this.doctorId}/patient-groups`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        const result: Record<string, Object> = JSON.parse(response.result as string) as Record<string, Object>;
        this.groups = (result.data as PatientGroup[]) || [];
      }
    } catch (error) {
      hilog.error(0x0000, 'PatientGroupPage', `加载分组失败: ${error}`);
    } finally {
      this.loading = false;
    }
  }

  async createGroup() {
    if (!this.newGroupName.trim()) {
      return;
    }

    try {
      const groupData: Record<string, Object> = {
        'groupName': this.newGroupName,
        'description': this.newGroupDescription,
        'color': this.newGroupColor,
        'sortOrder': this.groups.length
      };

      const response = await http.createHttp().request(
        `http://localhost:8080/api/doctor/${this.doctorId}/patient-groups`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(groupData)
        }
      );

      if (response.responseCode === 200) {
        this.showCreateDialog = false;
        this.newGroupName = '';
        this.newGroupDescription = '';
        this.loadGroups();
      }
    } catch (error) {
      hilog.error(0x0000, 'PatientGroupPage', `创建分组失败: ${error}`);
    }
  }

  async deleteGroup(groupId: number) {
    try {
      const response = await http.createHttp().request(
        `http://localhost:8080/api/doctor/patient-group/${groupId}`,
        {
          method: http.RequestMethod.DELETE,
          header: { 'Content-Type': 'application/json' }
        }
      );

      if (response.responseCode === 200) {
        this.loadGroups();
      }
    } catch (error) {
      hilog.error(0x0000, 'PatientGroupPage', `删除分组失败: ${error}`);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#333333');
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back());

        Text('患者分组')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Button('新建')
          .fontSize(14)
          .onClick(() => this.showCreateDialog = true);
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 });

      // 分组列表
      if (this.loading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.groups.length === 0) {
        Column() {
          Text('📁')
            .fontSize(56)
            .margin({ bottom: 16 });
          Text('暂无分组')
            .fontSize(18)
            .fontColor('#333333')
            .margin({ bottom: 8 });
          Text('点击右上角"新建"创建分组')
            .fontSize(14)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        List({ space: 12 }) {
          ForEach(this.groups, (group: PatientGroup) => {
            ListItem() {
              Row() {
                Column() {
                  Row() {
                    Text()
                      .width(8)
                      .height(8)
                      .borderRadius(4)
                      .backgroundColor(group.color);

                    Text(group.groupName)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .margin({ left: 8 });
                  }
                  .margin({ bottom: 4 });

                  if (group.description) {
                    Text(group.description)
                      .fontSize(12)
                      .fontColor('#999999');
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);

                Text(`${group.patientCount || 0}人`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ right: 12 });

                Button('删除')
                  .fontSize(12)
                  .type(ButtonType.Normal)
                  .backgroundColor('#FF4D4F')
                  .fontColor(Color.White)
                  .height(28)
                  .onClick(() => this.deleteGroup(group.id));
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8);
            }
          }, (group: PatientGroup) => group.id.toString());
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12 });
      }

      // 创建分组对话框
      if (this.showCreateDialog) {
        Column() {
          Column() {
            Text('新建分组')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 20 });

            TextInput({ placeholder: '分组名称' })
              .width('100%')
              .height(40)
              .onChange((value: string) => this.newGroupName = value);

            TextInput({ placeholder: '分组描述（可选）' })
              .width('100%')
              .height(40)
              .margin({ top: 12 })
              .onChange((value: string) => this.newGroupDescription = value);

            Row() {
              ForEach(this.colors, (color: string) => {
                Button()
                  .width(32)
                  .height(32)
                  .borderRadius(16)
                  .backgroundColor(color)
                  .border(this.newGroupColor === color ? { width: 2, color: '#333333' } : undefined)
                  .onClick(() => this.newGroupColor = color);
              }, (color: string) => color);
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: 16 });

            Row() {
              Button('取消')
                .layoutWeight(1)
                .backgroundColor('#F5F5F5')
                .fontColor('#666666')
                .onClick(() => this.showCreateDialog = false);

              Button('确定')
                .layoutWeight(1)
                .margin({ left: 12 })
                .onClick(() => this.createGroup());
            }
            .width('100%')
            .margin({ top: 24 });
          }
          .width('80%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(12);
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
