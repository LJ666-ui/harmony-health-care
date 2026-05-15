import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface AiDoctor {
  id: string;
  name: string;
  title: string;
  specialty: string;
  avatar: string;
  color: string;
  bgColor: string;
}

interface ConsultationMessage {
  doctorId: string;
  content: string;
  timestamp: number;
  type: 'analysis' | 'suggestion' | 'question' | 'conclusion' | 'agreement' | 'disagreement';
}

interface SymptomItem {
  name: string;
  selected: boolean;
}

@Entry
@Component
struct AIConsultationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State currentStep: number = 0;
  @State symptomInput: string = '';
  @State isLoading: boolean = false;
  @State consultationStarted: boolean = false;
  @State showConclusion: boolean = false;
  @State messages: ConsultationMessage[] = [];
  @State typingDoctorId: string = '';
  @State currentTypingDoctor: AiDoctor | null = null;

  private aiDoctors: AiDoctor[] = [
    {
      id: 'tcm',
      name: '李杏林',
      title: '主任医师',
      specialty: '中医',
      avatar: '🎋',
      color: '#C41D3E',
      bgColor: '#FFF1F0'
    },
    {
      id: 'western',
      name: '王明哲',
      title: '副主任医师',
      specialty: '西医',
      avatar: '🔬',
      color: '#1677FF',
      bgColor: '#E6F4FF'
    },
    {
      id: 'mongolian',
      name: '巴特尔',
      title: '蒙医专家',
      specialty: '蒙医',
      avatar: '🌿',
      color: '#52C41A',
      bgColor: '#F6FFED'
    },
    {
      id: 'integrative',
      name: '陈思远',
      title: '中西医结合',
      specialty: '全科',
      avatar: '⚕️',
      color: '#722ED1',
      bgColor: '#F9F0FF'
    }
  ];

  private commonSymptoms: SymptomItem[] = [
    { name: '头痛头晕', selected: false },
    { name: '失眠多梦', selected: false },
    { name: '胃胀反酸', selected: false },
    { name: '胸闷气短', selected: false },
    { name: '腰膝酸软', selected: false },
    { name: '疲劳乏力', selected: false },
    { name: '食欲不振', selected: false },
    { name: '手脚冰凉', selected: false },
    { name: '便秘腹泻', selected: false },
    { name: '咳嗽咳痰', selected: false },
    { name: '关节疼痛', selected: false },
    { name: '心悸心慌', selected: false }
  ];

  private symptomResponses: Record<string, ConsultationMessage[]> = {
    'default': [
      { doctorId: 'tcm', content: '从中医角度分析，患者症状符合"肝郁脾虚"的证型。肝主疏泄，情志不遂则气机郁滞，脾失健运故见胃胀、乏力。脉象当弦细，舌质淡红苔薄白。', timestamp: 1, type: 'analysis' },
      { doctorId: 'western', content: '从现代医学角度，需要排除器质性病变。建议完善血常规、生化全项、甲状腺功能及心电图检查。目前症状可能涉及消化系统与神经系统功能紊乱。', timestamp: 2, type: 'analysis' },
      { doctorId: 'mongolian', content: '蒙医认为此为"赫依"失调所致。"赫依"是人体生命活动的动力，其偏盛或偏衰都会导致上述症状。建议调理"三根"平衡，注重饮食起居规律。', timestamp: 3, type: 'analysis' },
      { doctorId: 'tcm', content: '同意蒙医同事的观点，"赫依"概念与中医的"气"有相通之处。我建议以疏肝健脾为主法，方选逍遥散合四君子汤加减。', timestamp: 4, type: 'agreement' },
      { doctorId: 'western', content: '补充一点，如果检查排除器质性疾病后，可考虑功能性消化不良伴焦虑状态的可能。必要时可联合心理科会诊。', timestamp: 5, type: 'suggestion' },
      { doctorId: 'mongolian', content: '推荐蒙药"阿嘎日-35味散"，配合传统疗术如针灸、推拿效果更佳。同时注意避免寒凉食物，保持心情舒畅。', timestamp: 6, type: 'suggestion' },
      { doctorId: 'integrative', content: '综合各位专家意见，我的整合方案如下：\n\n【诊断方向】\n1. 中医：肝郁脾虚证\n2. 西医：功能性消化不良（待排查）\n3. 蒙医：赫依失调\n\n【综合建议】\n① 先行基础检查排除器质性病变\n② 中药：逍遥散加减 疏肝健脾\n③ 蒙药辅助：阿嘎日-35味散\n④ 生活调摄：规律作息、适度运动、情绪管理\n⑤ 随访：2周后复评\n\n⚠️ 本会诊结果仅供参考，请结合线下就诊', timestamp: 7, type: 'conclusion' }
    ],
    'headache': [
      { doctorId: 'western', content: '头痛需先区分原发性与继发性。若为反复发作的单侧搏动性头痛，需考虑偏头痛；若伴有颈肩僵硬，紧张性头痛可能性大。建议查头颅CT/MRI排除占位性病变。', timestamp: 1, type: 'analysis' },
      { doctorId: 'tcm', content: '中医将头痛分为外感与内伤两大类。若患者长期头痛伴眩晕，多为肝阳上亢或气血亏虚之证。需问诊疼痛性质、部位、诱发因素来辨证。', timestamp: 2, type: 'analysis' },
      { doctorId: 'mongolian', content: '蒙医对头痛有独特认识，分为"白脉病"、"赫依性头痛"等类型。头部"赫依"通道受阻是常见原因，可通过放血疗法、头部按摩等治疗。', timestamp: 3, type: 'analysis' },
      { doctorId: 'integrative', content: '综合意见如下：\n\n【鉴别诊断】\n- 偏头痛（单侧搏动性）\n- 紧张性头痛（双侧压迫感）\n- 颈源性头痛（颈部牵涉）\n\n【治疗方案】\n① 急性期：NSAIDs止痛 + 针灸太阳穴/风池穴\n② 预防：天麻钩藤饮（肝阳上亢）或八珍汤（气血亏虚）\n③ 蒙医特色：额部轻柔按摩 + 避免风寒刺激\n④ 生活方式：减少屏幕时间、保证睡眠', timestamp: 4, type: 'conclusion' }
    ],
    'insomnia': [
      { doctorId: 'tcm', content: '失眠在中医属"不寐"范畴。常见证型有心脾两虚（入睡困难+多梦易醒）、阴虚火旺（心烦失眠+手足心热）、肝火扰心（急躁易怒+难以入眠）。', timestamp: 1, type: 'analysis' },
      { doctorId: 'western', content: '慢性失眠需评估严重程度，可使用匹兹堡睡眠质量指数(PSQI)量表。治疗包括CBT-I认知行为疗法一线推荐，短期可酌情使用苯二氮卓类或非苯二氮卓类助眠药物。', timestamp: 2, type: 'analysis' },
      { doctorId: 'mongolian', content: '蒙医称失眠为"希日乌苏"扰动所致。睡前用温牛奶加黄油饮用，配合"尼如哈"疗法（药浴）可有效改善。避免夜间过度思考。', timestamp: 3, type: 'analysis' },
      { doctorId: 'integrative', content: '【综合诊疗方案】\n\n1️⃣ 辨证施治：\n   - 心脾两虚→归脾汤\n   - 阴虚火旺→黄连阿胶汤\n   - 肝火扰心→龙胆泻肝汤\n\n2️⃣ 西医支持：\n   - CBT-I认知行为干预\n   - 褪黑素（轻度）\n   - 必要时短程药物治疗\n\n3️⃣ 蒙医特色：\n   - 睡前足浴（艾叶+红花）\n   - 头部"安神"穴位按摩\n\n4️⃣ 睡眠卫生：固定作息、卧室降温至18-22℃', timestamp: 4, type: 'conclusion' }
    ]
  };

  getSelectedSymptoms(): string[] {
    const selected: string[] = [];
    for (let i = 0; i < this.commonSymptoms.length; i++) {
      if (this.commonSymptoms[i].selected) {
        selected.push(this.commonSymptoms[i].name);
      }
    }
    return selected;
  }

  getDoctorById(id: string): AiDoctor | undefined {
    for (let i = 0; i < this.aiDoctors.length; i++) {
      if (this.aiDoctors[i].id === id) {
        return this.aiDoctors[i];
      }
    }
    return undefined;
  }

  getFilteredMessages(): ConsultationMessage[] {
    const result: ConsultationMessage[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      if (this.getDoctorById(this.messages[i].doctorId)) {
        result.push(this.messages[i]);
      }
    }
    return result;
  }

  async startConsultation(): Promise<void> {
    if (this.symptomInput.trim() === '' && this.getSelectedSymptoms().length === 0) {
      return;
    }

    this.consultationStarted = true;
    this.isLoading = true;
    this.currentStep = 1;
    this.messages = [];

    let responseKey: string = 'default';
    const symptoms: string[] = this.getSelectedSymptoms();
    if (symptoms.includes('头痛头晕')) {
      responseKey = 'headache';
    } else if (symptoms.includes('失眠多梦')) {
      responseKey = 'insomnia';
    }

    const responses: ConsultationMessage[] = this.symptomResponses[responseKey] || this.symptomResponses['default'];

    for (let i = 0; i < responses.length; i++) {
      const msg: ConsultationMessage = responses[i];
      this.typingDoctorId = msg.doctorId;
      this.currentTypingDoctor = this.getDoctorById(msg.doctorId) ?? null;

      await new Promise<void>((resolve: () => void) => {
        setTimeout(() => {
          this.messages = [...this.messages, msg];
          this.typingDoctorId = '';
          this.currentTypingDoctor = null;
          resolve();
        }, 1200 + Math.random() * 800);
      });
    }

    this.isLoading = false;
    this.showConclusion = true;
    this.currentStep = 2;
  }

  resetConsultation(): void {
    this.currentStep = 0;
    this.symptomInput = '';
    this.consultationStarted = false;
    this.showConclusion = false;
    this.messages = [];
    this.typingDoctorId = '';
    this.currentTypingDoctor = null;
    for (let i = 0; i < this.commonSymptoms.length; i++) {
      this.commonSymptoms[i].selected = false;
    }
  }

  build() {
    Column() {
      Header({ title: 'AI 多科会诊', showBack: true });

      Scroll() {
        Column({ space: 16 }) {
          if (!this.consultationStarted) {
            this.buildIntroSection()
            this.buildSymptomSelector()
          } else {
            this.buildDiscussionSection()
            if (this.showConclusion) {
              this.buildConclusionSection()
            }
          }
        }
        .width('88%')
        .padding({ top: 12, bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Footer({ activeIndex: -1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildIntroSection() {
    Column({ space: 14 }) {
      Row() {
        Text('🧠')
          .fontSize(32)

        Column({ space: 4 }) {
          Text('AI 多学科联合会诊')
            .fontSize(this.isElderMode ? 20 : 18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a2942')

          Text('多位AI医学专家共同分析您的症状')
            .fontSize(this.isElderMode ? 13 : 12)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })
        .layoutWeight(1)
      }

      Row({ space: 8 }) {
        ForEach(this.aiDoctors, (doctor: AiDoctor) => {
          Column({ space: 4 }) {
            Text(doctor.avatar)
              .fontSize(28)

            Text(doctor.name.substring(0, 2))
              .fontSize(this.isElderMode ? 11 : 10)
              .fontWeight(FontWeight.Medium)
              .fontColor(doctor.color)

            Text(doctor.specialty)
              .fontSize(this.isElderMode ? 9 : 8)
              .fontColor('#999999')
          }
          .padding({ top: 8, bottom: 8 })
          .backgroundColor(doctor.bgColor)
          .borderRadius(10)
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }, (doctor: AiDoctor) => doctor.id)
      }

      Column({ space: 8 }) {
        Text('💡 会诊流程')
          .fontSize(this.isElderMode ? 15 : 14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')

        Row({ space: 8 }) {
          ForEach(['选择症状', '专家讨论', '综合结论'], (step: string, index: number) => {
            Column({ space: 4 }) {
              Text(`${index + 1}`)
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width(24)
                .height(24)
                .borderRadius(12)
                .backgroundColor(index === 0 ? '#1677FF' : '#E2E8F0')
                .textAlign(TextAlign.Center)

              Text(step)
                .fontSize(this.isElderMode ? 11 : 10)
                .fontColor(index === 0 ? '#1677FF' : '#999999')
            }
            .alignItems(HorizontalAlign.Center)
            .layoutWeight(1)

            if (index < 2) {
              Text('→')
                .fontSize(14)
                .fontColor('#CCCCCC')
                .margin({ top: -10 })
            }
          }, (step: string, index: number) => `${index}`)
        }
        .width('100%')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Text('⚠️ 本系统仅供健康参考，不替代专业医疗诊断')
        .fontSize(11)
        .fontColor('#FAAD14')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildSymptomSelector() {
    Column({ space: 12 }) {
      Row() {
        Text('📋 选择症状')
          .fontSize(this.isElderMode ? 16 : 15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text(`已选 ${this.getSelectedSymptoms().length} 项`)
          .fontSize(12)
          .fontColor('#1677FF')
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.commonSymptoms, (item: SymptomItem, index: number) => {
          Text(item.name)
            .fontSize(this.isElderMode ? 14 : 13)
            .fontColor(item.selected ? '#FFFFFF' : '#555555')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(item.selected ? '#1677FF' : '#F5F5F5')
            .borderRadius(20)
            .onClick(() => {
              this.commonSymptoms[index].selected = !this.commonSymptoms[index].selected;
            })
            .margin({ right: 8, bottom: 8 })
        }, (item: SymptomItem, index: number) => `${index}`)
      }
      .width('100%')

      TextInput({ placeholder: '补充描述其他症状或不适...', text: this.symptomInput })
        .fontSize(this.isElderMode ? 15 : 14)
        .height(48)
        .width('100%')
        .backgroundColor('#F8FAFC')
        .borderRadius(10)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.symptomInput = value;
        })

      Button('开始AI多科会诊')
        .width('100%')
        .height(48)
        .fontSize(this.isElderMode ? 17 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor(
          (this.symptomInput.trim() !== '' || this.getSelectedSymptoms().length > 0)
            ? '#1677FF' : '#CCCCCC'
        )
        .borderRadius(12)
        .enabled(!this.isLoading && (this.symptomInput.trim() !== '' || this.getSelectedSymptoms().length > 0))
        .onClick(() => {
          this.startConsultation();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildDiscussionSection() {
    Column({ space: 12 }) {
      Row() {
        Text('💬 专家讨论中')
          .fontSize(this.isElderMode ? 16 : 15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        if (this.isLoading && this.typingDoctorId !== '') {
          Row({ space: 4 }) {
            Text('')
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor('#1677FF')
            Text('')
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor('#1677FF')
            Text('')
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor('#1677FF')
          }
          .margin({ left: 8 })
        } else if (!this.isLoading) {
          Text('✅ 会诊完成')
            .fontSize(12)
            .fontColor('#52C41A')
            .margin({ left: 8 })
        }
      }
      .width('100%')

      if (this.isLoading && this.typingDoctorId !== '' && this.currentTypingDoctor) {
        Row({ space: 8 }) {
          Text(this.currentTypingDoctor.avatar)
            .fontSize(22)
          Column({ space: 4 }) {
            Text(this.currentTypingDoctor.name + ' · ' + this.currentTypingDoctor.specialty)
              .fontSize(12)
              .fontColor(this.currentTypingDoctor.color)
              .fontWeight(FontWeight.Medium)
            Row({ space: 4 }) {
              ForEach([0, 1, 2], (_: number, i: number) => {
                Text('')
                  .width(6)
                  .height(6)
                  .borderRadius(3)
                  .backgroundColor('#CCCCCC')
                  .animation({ duration: 300, iterations: -1 })
              }, (_: number, i: number) => `${i}`)
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.currentTypingDoctor.bgColor)
        .borderRadius(12)
        .alignItems(VerticalAlign.Top)
      }

      ForEach(this.getFilteredMessages(), (msg: ConsultationMessage, index: number) => {
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text(this.getDoctorById(msg.doctorId)!.avatar)
              .fontSize(24)

            Column({ space: 2 }) {
              Row({ space: 6 }) {
                Text(this.getDoctorById(msg.doctorId)!.name)
                  .fontSize(this.isElderMode ? 15 : 14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getDoctorById(msg.doctorId)!.color)

                Text(this.getDoctorById(msg.doctorId)!.title)
                  .fontSize(this.isElderMode ? 11 : 10)
                  .fontColor('#999999')

                if (msg.type === 'conclusion') {
                  Text('综合结论')
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#722ED1')
                    .borderRadius(8)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                } else if (msg.type === 'agreement') {
                  Text('赞同')
                    .fontSize(10)
                    .fontColor('#52C41A')
                    .backgroundColor('#F6FFED')
                    .borderRadius(8)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                } else if (msg.type === 'suggestion') {
                  Text('建议')
                    .fontSize(10)
                    .fontColor('#1677FF')
                    .backgroundColor('#E6F4FF')
                    .borderRadius(8)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                }
              }

              Text(msg.content)
                .fontSize(this.isElderMode ? 14 : 13)
                .fontColor('#333333')
                .lineHeight(20)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .padding(14)
        .backgroundColor(msg.type === 'conclusion' ? '#FAF5FF' : '#FFFFFF')
        .borderRadius(12)
        .border({
          width: msg.type === 'conclusion' ? 1.5 : 1,
          color: msg.type === 'conclusion' ? '#B37FEB' : '#F0F0F0'
        })
      }, (msg: ConsultationMessage, index: number) => `${index}`)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildConclusionSection() {
    Column({ space: 14 }) {
      Row() {
        Text('📋 会诊总结')
          .fontSize(this.isElderMode ? 17 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Blank()

        Text('综合四位专家意见')
          .fontSize(11)
          .fontColor('#FFFFFF90')
      }
      .width('100%')
      .padding(14)
      .linearGradient({
        angle: 135,
        colors: [['#722ED1', 0], ['#9254DE', 1]]
      })
      .borderRadius({ topLeft: 12, topRight: 12 })

      Column({ space: 10 }) {
        Row({ space: 8 }) {
          ForEach(this.aiDoctors, (doctor: AiDoctor) => {
            Column({ space: 3 }) {
              Text(doctor.avatar)
                .fontSize(22)
              Text(doctor.specialty)
                .fontSize(9)
                .fontColor(doctor.color)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }, (doctor: AiDoctor) => doctor.id)
        }

        Divider().color('#F0F0F0').strokeWidth(1)

        Text('参与会诊专家已达成以下共识：')
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')

        Row({ space: 10 }) {
          Button('查看详细报告')
            .layoutWeight(1)
            .height(40)
            .fontSize(this.isElderMode ? 14 : 13)
            .backgroundColor('#722ED1')
            .fontColor('#FFFFFF')
            .borderRadius(10)

          Button('重新会诊')
            .layoutWeight(1)
            .height(40)
            .fontSize(this.isElderMode ? 14 : 13)
            .backgroundColor('#F5F5F5')
            .fontColor('#666666')
            .borderRadius(10)
            .onClick(() => {
              this.resetConsultation();
            })
        }
        .width('100%')

        Button('前往预约挂号')
          .width('100%')
          .height(42)
          .fontSize(this.isElderMode ? 15 : 14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#1677FF')
          .fontColor('#FFFFFF')
          .borderRadius(10)
          .onClick(() => {
            router.pushUrl({ url: 'pages/HospitalPage' }).catch(() => {});
          })
      }
      .width('100%')
      .padding(14)

      Text('⚠️ 以上内容由AI生成，仅供参考，请以实际就医诊断为准')
        .fontSize(11)
        .fontColor('#FAAD14')
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#E6D5FF' })
  }
}
