import { HealthData } from '../ai/HealthFeatureExtractor';

interface QuestionItem {
  id: string;
  category: string;
  question: string;
  type: 'SINGLE' | 'MULTI' | 'NUMBER' | 'SLIDER';
  options?: { label: string; value: any; score: number }[];
  min?: number;
  max?: number;
  unit?: string;
  required: boolean;
}

@Entry
@Component
struct AssessmentQuestionnairePage {
  @State currentStep: number = 0;
  @State answers: { [key: string]: any } = {};
  @State isSubmitting: boolean = false;

  private questions: QuestionItem[] = [
    {
      id: 'age',
      category: '基本信息',
      question: '您的年龄是？',
      type: 'NUMBER',
      min: 18,
      max: 120,
      unit: '岁',
      required: true
    },
    {
      id: 'gender',
      category: '基本信息',
      question: '您的性别？',
      type: 'SINGLE',
      options: [
        { label: '男', value: 'MALE', score: 0 },
        { label: '女', value: 'FEMALE', score: 0 }
      ],
      required: true
    },
    {
      id: 'height',
      category: '体格指标',
      question: '您的身高（cm）？',
      type: 'NUMBER',
      min: 100,
      max: 220,
      unit: 'cm',
      required: true
    },
    {
      id: 'weight',
      category: '体格指标',
      question: '您的体重（kg）？',
      type: 'NUMBER',
      min: 30,
      max: 200,
      unit: 'kg',
      required: true
    },
    {
      id: 'systolic_bp',
      category: '血压情况',
      question: '您最近的收缩压（高压）是多少？',
      type: 'SLIDER',
      min: 70,
      max: 200,
      unit: 'mmHg',
      required: true
    },
    {
      id: 'diastolic_bp',
      category: '血压情况',
      question: '您最近的舒张压（低压）是多少？',
      type: 'SLIDER',
      min: 40,
      max: 130,
      unit: 'mmHg',
      required: true
    },
    {
      id: 'fasting_glucose',
      category: '血糖情况',
      question: '您最近一次空腹血糖值（mmol/L）？',
      type: 'SLIDER',
      min: 2.0,
      max: 15.0,
      unit: 'mmol/L',
      required: true
    },
    {
      id: 'resting_hr',
      category: '心率情况',
      question: '您的静息心率（次/分钟）？',
      type: 'SLIDER',
      min: 40,
      max: 140,
      unit: 'bpm',
      required: false
    },
    {
      id: 'exercise_freq',
      category: '生活方式',
      question: '您每周进行体育锻炼的次数？',
      type: 'SINGLE',
      options: [
        { label: '几乎不运动', value: 0, score: 3 },
        { label: '1-2次/周', value: 1.5, score: 2 },
        { label: '3-4次/周', value: 3.5, score: 1 },
        { label: '5-7次/周', value: 6, score: 0 }
      ],
      required: true
    },
    {
      id: 'sleep_duration',
      category: '生活方式',
      question: '您平均每晚睡眠时长？',
      type: 'SINGLE',
      options: [
        { label: '<5小时', value: 4.5, score: 3 },
        { label: '5-6小时', value: 5.5, score: 2 },
        { label: '7-8小时', value: 7.5, score: 0 },
        { label: '>9小时', value: 10, score: 1 }
      ],
      required: true
    },
    {
      id: 'medication_count',
      category: '用药情况',
      question: '您目前正在服用的药物种类数量？',
      type: 'SINGLE',
      options: [
        { label: '无', value: 0, score: 0 },
        { label: '1-3种', value: 2, score: 1 },
        { label: '4-6种', value: 5, score: 2 },
        { label: '7种以上', value: 8, score: 3 }
      ],
      required: true
    },
    {
      id: 'fall_history',
      category: '跌倒风险',
      question: '过去一年内是否有过跌倒经历？',
      type: 'SINGLE',
      options: [
        { label: '没有跌倒过', value: 0, score: 0 },
        { label: '跌倒过1次', value: 1, score: 2 },
        { label: '跌倒过2-3次', value: 2.5, score: 3 },
        { label: '跌倒超过3次', value: 4, score: 4 }
      ],
      required: true
    }
  ];

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '📝 健康问卷评估', 
        showBack: true 
      })

      this.buildProgressBar()

      if (this.currentStep < this.questions.length) {
        this.buildQuestionView()
      } else {
        this.buildSummaryView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildProgressBar() {
    Row({ space: 8 }) {
      ForEach(this.questions.slice(0, Math.min(this.currentStep + 1, this.questions.length)), 
        (_: Object, index: number) => {
          Column()
            .width((this.questions.length > 0 ? (100 / this.questions.length) : 25) + '%')
            .height(4)
            .borderRadius(2)
            .backgroundColor('#1677FF')
        }
      )

      ForEach(this.questions.slice(Math.min(this.currentStep + 1, this.questions.length)), 
        (_: Object) => {
          Column()
            .width('flexGrow')
            .height(4)
            .borderRadius(2)
            .backgroundColor('#E8E8E8')
        }
      )
    }
    .width('100%')
    .padding({ horizontal: 16 })
    .margin({ top: 12, bottom: 8 })

    Text(`${this.currentStep + 1} / ${this.questions.length}`)
      .fontSize(13)
      .fontColor('#999999')
      .textAlign(TextAlign.Center)
      .width('100%')
  }

  @Builder buildQuestionView() {
    Column({ space: 20 }) {
      Text(`第${this.currentStep + 1}题`)
        .fontSize(14)
        .fontColor('#1677FF')
        .fontWeight(FontWeight.Medium)

      Text(this.questions[this.currentStep].category)
        .fontSize(12)
        .fontColor('#666666')
        .backgroundColor('#E6F4FF')
        .padding({ horizontal: 10, vertical: 4 })
        .borderRadius(10)

      Text(this.questions[this.currentStep].question)
        .fontSize(20)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .lineHeight(28)

      if (this.questions[this.currentStep].required) {
        Text('* 必填项')
          .fontSize(12)
          .fontColor('#FF4D4F')
      }

      this.buildAnswerInput()

      Row({ space: 12 }) {
        Button('上一题')
          .layoutWeight(1)
          .height(48)
          .fontSize(15)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(24)
          .enabled(this.currentStep > 0)
          .onClick(() => {
            if (this.currentStep > 0) {
              this.currentStep--;
            }
          })

        Button(this.currentStep === this.questions.length - 1 ? '完成问卷' : '下一题')
          .layoutWeight(1)
          .height(48)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(24)
          .onClick(() => this.goToNext())
      }
      .width('100%')

      Blank()
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 24, right: 24, top: 16, bottom: 24 })
  }

  @Builder buildAnswerInput() {
    const question = this.questions[this.currentStep];

    switch (question.type) {
      case 'SINGLE':
        this.buildSingleChoice(question);
        break;
      case 'NUMBER':
        this.buildNumberInput(question);
        break;
      case 'SLIDER':
        this.buildSliderInput(question);
        break;
      default:
        this.buildSingleChoice(question);
    }
  }

  @Builder buildSingleChoice(question: QuestionItem) {
    Column({ space: 10 }) {
      ForEach(question.options || [], (option: Object) => {
        const opt = option as { label: string; value: any; score: number };
        
        Row({ space: 10 }) {
          if (this.answers[question.id] === opt.value) {
            Text('✓')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .width(22)
              .height(22)
              .borderRadius(11)
              .backgroundColor('#1677FF')
              .textAlign(TextAlign.Center)
          } else {
            Text('')
              .width(22)
              .height(22)
              .borderRadius(11)
              .border({
                width: 2,
                color: '#D9D9D9'
              })
          }

          Text(opt.label)
            .fontSize(15)
            .fontColor('#333333')
          
          Blank()
        }
        .width('100%')
        .padding(14)
        .backgroundColor(
          this.answers[question.id] === opt.value ? '#E6F4FF' : '#FAFAFA'
        )
        .borderRadius(10)
        .border({
          width: this.answers[question.id] === opt.value ? 2 : 1,
          color: this.answers[question.id] === opt.value ? '#1677FF' : '#E8E8E8'
        })
        .onClick(() => {
          this.answers[question.id] = opt.value;
        })
      })
    }
    .width('100%')
  }

  @Builder buildNumberInput(question: QuestionItem) {
    Column({ space: 12 }) {
      TextInput({ 
        placeholder: `请输入${question.unit || ''}`,
        text: this.answers[question.id]?.toString() || ''
      })
        .type(InputType.Number)
        .width('100%')
        .height(50)
        .fontSize(16)
        .backgroundColor('#FAFAFA')
        .borderRadius(10)
        .onChange((value: string) => {
          const numValue = parseFloat(value);
          if (!isNaN(numValue)) {
            this.answers[question.id] = numValue;
          }
        })

      if (question.min !== undefined && question.max !== undefined) {
        Slider({
          value: this.answers[question.id] || ((question.min! + question.max!) / 2),
          min: question.min!,
          max: question.max!,
          step: question.unit === 'mmol/L' ? 0.1 : 1,
          style: SliderStyle.OutSet
        })
          .blockColor('#1677FF')
          .trackColor('#E8E8E8')
          .selectedColor('#1677FF')
          .showTips(true)
          .onChange((value: number) => {
            this.answers[question.id] = parseFloat(value.toFixed(1));
          })
      }
    }
    .width('100%')
  }

  @Builder buildSliderInput(question: QuestionItem) {
    Column({ space: 16 }) {
      Text(`${this.answers[question.id] || '-'} ${question.unit || ''}`)
        .fontSize(32)
        .fontColor('#1677FF')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .width('100%')

      Slider({
        value: this.answers[question.id] || ((question.min! + question.max!) / 2),
        min: question.min!,
        max: question.max!,
        step: question.unit === 'mmol/L' ? 0.1 : 1,
        style: SliderStyle.OutSet
      })
        .blockColor('#1677FF')
        .trackColor('#E8E8E8')
        .selectedColor('#1677FF')
        .showTips(true)
        .onChange((value: number) => {
          this.answers[question.id] = parseFloat(value.toFixed(1));
        })

      Row() {
        Text(`${question.min}${question.unit || ''}`)
          .fontSize(12)
          .fontColor('#999999')
        
        Blank()
        
        Text(`${question.max}${question.unit || ''}`)
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder buildSummaryView() {
    Scroll() {
      Column({ space: 16 }) {
        Text('✅ 问卷填写完成！')
          .fontSize(22)
          .fontColor('#52C41A')
          .fontWeight(FontWeight.Bold)

        Text('以下是您提交的健康信息摘要，确认无误后点击"开始AI评估"'
          )
          .fontSize(14)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)

        this.buildSummaryCard()

        Button('🚀 开始AI风险评估')
          .width('100%')
          .height(56)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#1677FF')
          .borderRadius(28)
          .enabled(!this.isSubmitting)
          .onClick(() => this.submitQuestionnaire())

        Button('← 返回修改')
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .onClick(() => {
            this.currentStep = this.questions.length - 1;
          })
      }
      .padding(24)
    }
    .layoutWeight(1)
  }

  @Builder buildSummaryCard() {
    Column({ space: 12 }) {
      Text('📋 健康数据汇总')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      ForEach(this.questions.filter(q => q.required), (question: Object) => {
        const q = question as QuestionItem;
        
        Row() {
          Text(q.question.replace('？', '').replace('?', ''))
            .fontSize(14)
            .fontColor('#666666')
            .layoutWeight(1)
          
          Text(this.formatAnswer(q))
            .fontSize(14)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding({ vertical: 8 })
        .border({ width: { bottom: 1 }, color: '#F0F0F0' })
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  private formatAnswer(question: QuestionItem): string {
    const value = this.answers[question.id];
    
    if (value === undefined || value === null) return '-';
    
    if (question.unit && typeof value === 'number') {
      return `${value}${question.unit}`;
    }
    
    if (question.options) {
      const option = question.options.find(opt => opt.value === value);
      return option?.label || String(value);
    }
    
    return String(value);
  }

  private goToNext(): void {
    const question = this.questions[this.currentStep];

    if (question.required && this.answers[question.id] === undefined) {
      AlertDialog.show({
        title: '提示',
        message: '请先回答此问题再继续',
        primaryText: '确定'
      });
      return;
    }

    if (this.currentStep < this.questions.length - 1) {
      this.currentStep++;
    } else {
      this.currentStep = this.questions.length;
    }
  }

  private async submitQuestionnaire(): Promise<void> {
    this.isSubmitting = true;

    try {
      console.log('[AssessmentQuestionnairePage] 提交问卷数据...');

      const healthData = this.convertAnswersToHealthData();

      console.log('[AssessmentQuestionnairePage] 转换后的健康数据:');
      console.log(`  年龄: ${healthData.age}`);
      console.log(`  血压: ${healthData.bloodPressure.systolic}/${healthData.bloodPressure.diastolic}`);

      router.replaceUrl({
        url: 'pages/RiskAssessmentPage',
        params: {
          healthData: JSON.stringify(healthData),
          fromQuestionnaire: true
        }
      });

    } catch (error) {
      console.error('[AssessmentQuestionnairePage] 提交失败:', error instanceof Error ? error.message : String(error));
      
      AlertDialog.show({
        title: '错误',
        message: '数据处理失败，请重试',
        primaryText: '确定'
      });
    } finally {
      this.isSubmitting = false;
    }
  }

  private convertAnswersToHealthData(): HealthData {
    const height = parseFloat(this.answers['height']) || 170;
    const weight = parseFloat(this.answers['weight']) || 70;
    const bmi = weight / ((height / 100) ** 2);

    return {
      age: parseInt(this.answers['age']) || 65,
      gender: this.answers['gender'] || 'MALE',
      bloodPressure: {
        systolic: parseFloat(this.answers['systolic_bp']) || 120,
        diastolic: parseFloat(this.answers['diastolic_bp']) || 80
      },
      bloodGlucose: {
        fasting: parseFloat(this.answers['fasting_glucose']) || 5.5
      },
      heartRate: {
        resting: parseFloat(this.answers['resting_hr']) || 72
      },
      bodyMetrics: {
        height: height,
        weight: weight,
        bmi: parseFloat(bmi.toFixed(1))
      },
      exerciseFrequency: parseFloat(this.answers['exercise_freq']) || 2,
      medicationCount: parseInt(this.answers['medication_count']) || 0,
      sleepData: {
        durationHours: parseFloat(this.answers['sleep_duration']) || 7
      }
    };
  }
}

@Component
struct NavigationTitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;

  build() {
    Row() {
      if (this.showBack) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
      }

      Text(this.title)
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      if (this.showBack) {
        Text('')
          .width(24)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
