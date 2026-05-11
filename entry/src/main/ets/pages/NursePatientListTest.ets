import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'NursePatientListTest';

interface PatientInfo {
  id: number;
  username: string;
  phone: string;
  age?: number;
}

@Entry
@Component
struct NursePatientListTest {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State patients: PatientInfo[] = [];
  @State isLoading: boolean = true;
  @State debugInfo: string = '初始化...';

  async aboutToAppear(): Promise<void> {
    this.debugInfo = 'aboutToAppear 开始执行';
    hilog.info(0x0000, TAG, '%{public}s', this.debugInfo);
    
    try {
      this.debugInfo = '开始请求后端接口...';
      hilog.info(0x0000, TAG, '%{public}s', this.debugInfo);
      
      const baseUrl: string = ApiConstants.BASE_URL;
      const url: string = '/user/all-patients';
      
      hilog.info(0x0000, TAG, 'baseUrl=%{public}s', baseUrl);
      hilog.info(0x0000, TAG, 'url=%{public}s', url);
      
      this.debugInfo = '发送HTTP请求...';
      const response = await HttpUtil.get<PatientInfo[]>(url);
      
      hilog.info(0x0000, TAG, 'response success=%{public}b', response.success);
      hilog.info(0x0000, TAG, 'response code=%{public}d', response.code !== undefined ? response.code : -1);
      hilog.info(0x0000, TAG, 'response data length=%{public}d', 
        response.data !== undefined && response.data !== null ? response.data.length : -1);
      
      if (response.success && response.data !== null && response.data !== undefined) {
        this.patients = response.data;
        this.debugInfo = `成功加载 ${this.patients.length} 个患者`;
        hilog.info(0x0000, TAG, '%{public}s', this.debugInfo);
        
        if (this.patients.length > 0) {
          const first = this.patients[0];
          hilog.info(0x0000, TAG, '第一个患者：id=%{public}d, username=%{public}s', 
            first.id, first.username);
        }
      } else {
        this.debugInfo = `请求失败：${response.message || '未知错误'}`;
        hilog.error(0x0000, TAG, '%{public}s', this.debugInfo);
      }
    } catch (error) {
      this.debugInfo = `异常：${String(error)}`;
      hilog.error(0x0000, TAG, '%{public}s', this.debugInfo);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 调试信息栏（醒目的黄色）
      Column() {
        Text(`[状态] ${this.debugInfo}`)
          .fontSize(14)
          .fontColor('#FF0000')
          .fontWeight(FontWeight.Bold)
        
        Text(`[数据] 患者数量：${this.patients.length}, 加载中：${this.isLoading}`)
          .fontSize(12)
          .fontColor('#333333')
          .margin({ top: 4 })
      }
      .width('100%')
      .backgroundColor('#FFFF00')
      .padding(12)
      .margin({ bottom: 8 })
      
      Header({ title: '患者列表（测试版）' })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#3498DB')
          
          Text('正在加载患者数据...')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.patients.length === 0) {
        Column() {
          Text('😢')
            .fontSize(64)
          
          Text('暂无患者数据')
            .fontSize(18)
            .fontColor('#666666')
            .margin({ top: 16 })
          
          Text(this.debugInfo)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
            .textAlign(TextAlign.Center)
            .padding({ left: 20, right: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.patients, (patient: PatientInfo, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(`#${index + 1}`)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1677FF')
                  
                  Text(patient.username || '未知姓名')
                    .fontSize(this.isElderMode ? 20 : 18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ top: 8 })
                  
                  if (patient.phone) {
                    Text(`📱 ${patient.phone}`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 4 })
                  }
                  
                  if (patient.age) {
                    Text(`🎂 ${patient.age}岁`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 2 })
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                
                Text('查看详情 >')
                  .fontSize(14)
                  .fontColor('#1677FF')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({
                radius: 4,
                color: '#00000010',
                offsetX: 0,
                offsetY: 2
              })
              .onClick(() => {
                ToastUtil.showSuccess(`点击了患者：${patient.username}`);
              })
            }
          }, (patient: PatientInfo) => `${patient.id}`)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
