/**
 * AI问诊主页面（简化版）
 * 提供基础的AI问诊功能
 */

@Entry
@Component
struct AiConsultationPage {
  @State private question: string = '';
  @State private messages: MessageItem[] = [];
  @State private isLoading: boolean = false;

  aboutToAppear() {
    // 初始化欢迎消息
    const welcomeMessage: MessageItem = {
      id: 'welcome',
      role: 'assistant',
      content: '您好！我是AI智能问诊助手。请描述您的症状或问题，我会为您提供专业的医疗建议。',
      timestamp: Date.now()
    };
    this.messages.push(welcomeMessage);
  }

  private async sendQuestion() {
    if (this.question.trim() === '' || this.isLoading) {
      return;
    }

    const userQuestion = this.question;
    this.question = '';
    this.isLoading = true;

    // 添加用户消息
    const userMessage: MessageItem = {
      id: 'user_' + Date.now(),
      role: 'user',
      content: userQuestion,
      timestamp: Date.now()
    };
    this.messages.push(userMessage);

    // 模拟AI响应
    await this.delay(1000);

    const response = this.generateResponse(userQuestion);

    // 添加助手消息
    const assistantMessage: MessageItem = {
      id: 'assistant_' + Date.now(),
      role: 'assistant',
      content: response,
      timestamp: Date.now()
    };
    this.messages.push(assistantMessage);

    this.isLoading = false;
  }

  private generateResponse(question: string): string {
    const questionLower = question.toLowerCase();

    if (questionLower.includes('头痛') || questionLower.includes('头晕')) {
      return '【内科智能体】\n根据您描述的头痛症状，建议：\n1. 注意休息，保证充足睡眠\n2. 避免长时间使用电子设备\n3. 如症状持续或加重，建议就医检查\n\n请注意，这只是一般性建议，具体诊断需要专业医生进行。';
    } else if (questionLower.includes('发烧') || questionLower.includes('发热')) {
      return '【内科智能体】\n关于发热症状：\n1. 多饮水，注意休息\n2. 可采用物理降温\n3. 体温超过38.5°C建议就医\n4. 注意观察其他症状\n\n如有不适，请及时就医。';
    } else if (questionLower.includes('高血压')) {
      return '【内科智能体】\n高血压管理建议：\n1. 规律服药，不可自行停药\n2. 低盐饮食，控制钠摄入\n3. 适量运动，保持健康体重\n4. 定期监测血压\n5. 定期复查\n\n血压控制目标：140/90mmHg以下';
    } else if (questionLower.includes('糖尿病')) {
      return '【营养智能体】\n糖尿病饮食指导：\n1. 控制碳水化合物摄入\n2. 选择低GI食物\n3. 增加膳食纤维\n4. 定时定量进餐\n5. 避免高糖高脂食物\n\n建议在内分泌科医生指导下制定个性化方案。';
    } else if (questionLower.includes('康复') || questionLower.includes('运动')) {
      return '【康复智能体】\n运动康复建议：\n1. 循序渐进，从低强度开始\n2. 注意热身和放松\n3. 避免运动损伤\n4. 观察身体反应，不适即停\n5. 建议在专业康复师指导下进行\n\n请问您具体想了解哪方面的康复知识？';
    } else if (questionLower.includes('饮食') || questionLower.includes('营养')) {
      return '【营养智能体】\n健康饮食建议：\n1. 均衡多样，荤素搭配\n2. 多摄入蔬菜水果\n3. 适量优质蛋白\n4. 控制油脂和盐分\n5. 规律进餐，避免暴饮暴食\n\n请问您有特殊的饮食需求吗？';
    } else if (questionLower.includes('中医') || questionLower.includes('体质')) {
      return '【中医智能体】\n中医体质辨识：\n中医将人体体质分为九种：平和质、气虚质、阳虚质、阴虚质、痰湿质、湿热质、血瘀质、气郁质、特禀质。\n\n不同体质需要不同的调理方法。建议到中医科进行专业体质辨识。';
    } else {
      return '感谢您的咨询。为了给您提供更准确的建议，请详细描述您的症状或问题。\n\n例如：\n- 我最近头痛\n- 高血压怎么管理\n- 糖尿病饮食要注意什么\n\n如有紧急情况，请及时就医。';
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: Function) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  build() {
    Column() {
      // 标题栏
      this.TitleBar();

      // 消息列表
      this.MessageList();

      // 输入区域
      this.InputArea();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder
  TitleBar() {
    Row() {
      Text('AI智能问诊')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333');
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF');
  }

  @Builder
  MessageList() {
    List() {
      ForEach(this.messages, (message: MessageItem) => {
        ListItem() {
          this.MessageItem(message);
        }
      }, (message: MessageItem) => message.id);
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 });
  }

  @Builder
  MessageItem(message: MessageItem) {
    Column() {
      if (message.role === 'user') {
        Row() {
          Text(message.content)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .padding(12)
            .backgroundColor('#4A90E2')
            .borderRadius({ topLeft: 16, topRight: 4, bottomLeft: 16, bottomRight: 16 });
        }
        .width('100%')
        .justifyContent(FlexAlign.End);
      } else {
        Column() {
          Text(message.content)
            .fontSize(16)
            .fontColor('#333333')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      }
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 });
  }

  @Builder
  InputArea() {
    Row() {
      TextInput({ placeholder: '请描述您的症状或问题...', text: this.question })
        .layoutWeight(1)
        .height(40)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.question = value;
        })
        .onSubmit(() => {
          this.sendQuestion();
        });

      Button(this.isLoading ? '发送中...' : '发送')
        .width(80)
        .height(40)
        .margin({ left: 8 })
        .backgroundColor(this.isLoading ? '#CCCCCC' : '#4A90E2')
        .fontColor('#FFFFFF')
        .borderRadius(20)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.sendQuestion();
        });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF');
  }
}

/**
 * 消息项接口
 */
interface MessageItem {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
}
