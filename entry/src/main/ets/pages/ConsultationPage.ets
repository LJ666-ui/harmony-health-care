import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';
import { GlobalVoiceAssistant } from '../components/GlobalVoiceAssistant';

@Entry
@Component
struct ConsultationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State aiPreDiagnosisResult: string = '';
  @State aiSuggestedDepartment: string = '';
  @State aiTriageAdvice: string = '';
  @State symptomsInput: string = '';
  @State userId: number = 1;
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.isLoading = false;
  }

  async preDiagnoseWithAI(): Promise<void> {
    if (!this.symptomsInput.trim()) {
      ToastUtil.showInfo('请先输入症状描述');
      return;
    }

    try {
      const request = AIRequestBuilder.createDataRequest(
        `症状描述：${this.symptomsInput}，请进行预问诊和分诊建议`,
        'pre_diagnosis',
        String(this.userId || 'default-user')
      );
      const response = await this.orchestrator.process(request);
      this.aiPreDiagnosisResult = typeof response.output.content === 'string' ? response.output.content : JSON.stringify(response.output.content);
      this.aiSuggestedDepartment = response.suggestions?.[0] || '';
      this.aiTriageAdvice = response.suggestions?.[1] || '';
    } catch (error) {
      console.error('[ConsultationPage] AI预问诊失败:', error);
      this.aiPreDiagnosisResult = 'AI预问诊暂时不可用';
    }
  }

  build() {
    Stack() {
      Column() {
      Header({ title: '在线问诊', showBack: true });

      Scroll() {
        Column() {
          Column({ space: 12 }) {
            Row() {
              Row({ space: 6 }) {
                Text('🩺')
                  .fontSize(18)
                Text('AI 智能预问诊')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333')
              }
              Blank()
              Text('DeepSeek')
                .fontSize(11)
                .fontColor('#6366F1')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor('#EEF2FF')
                .borderRadius(8)
            }
            .width('100%')

            Text('请描述您的症状，AI将为您提供智能预问诊和分诊建议')
              .fontSize(13)
              .fontColor('#999')
              .width('100%')
              .margin({ top: 4 })

            Row() {
              TextInput({ placeholder: '请描述您的症状...', text: this.symptomsInput })
                .type(InputType.Normal)
                .layoutWeight(1)
                .height(40)
                .fontSize(14)
                .backgroundColor('#F8F9FA')
                .borderRadius(20)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.symptomsInput = value;
                })
              Button('分析')
                .height(36)
                .fontSize(13)
                .fontColor('#FFFFFF')
                .backgroundColor('#6366F1')
                .borderRadius(18)
                .margin({ left: 8 })
                .onClick(() => this.preDiagnoseWithAI())
            }
            .width('100%')

            if (this.aiPreDiagnosisResult) {
              Column({ space: 8 }) {
                Text('AI 预问诊结果')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#6366F1')
                Scroll() {
                  Text(this.aiPreDiagnosisResult)
                    .fontSize(13)
                    .fontColor('#475569')
                    .lineHeight(20)
                }
                .width('100%')
                .constraintSize({ maxHeight: 150 })

                if (this.aiSuggestedDepartment) {
                  Row() {
                    Text('推荐科室:')
                      .fontSize(12)
                      .fontColor('#999')
                    Text(this.aiSuggestedDepartment)
                      .fontSize(12)
                      .fontColor('#F59E0B')
                      .fontWeight(FontWeight.Bold)
                  }
                  .margin({ top: 4 })
                }

                if (this.aiTriageAdvice) {
                  Row() {
                    Text('分诊建议:')
                      .fontSize(12)
                      .fontColor('#999')
                    Text(this.aiTriageAdvice)
                      .fontSize(12)
                      .fontColor('#1677FF')
                  }
                  .margin({ top: 2 })
                }
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FAFAFE')
              .borderRadius(10)
              .border({ width: 1, color: '#E0E7FF' })
            }
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
          .margin({ bottom: 16 })
        }
        .width('100%')
        .padding({ top: 16, bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Footer();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')

      GlobalVoiceAssistant()
    }
    .width('100%')
    .height('100%')
  }
}
