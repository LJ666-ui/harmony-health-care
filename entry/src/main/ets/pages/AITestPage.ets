import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequest, AgentId, InputType } from '../ai/models/AITypes';

@Entry
@Component
struct AITestPage {
  @State testResults: string[] = [];
  @State isTesting: boolean = false;
  @State currentTest: string = '';

  private orchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    this.testResults.push('🤖 AI测试页面已加载');
    this.testResults.push('📦 智能体数量: 4');
  }

  async runTest(testName: string, request: AIRequest): Promise<void> {
    this.isTesting = true;
    this.currentTest = testName;
    this.testResults.push(`\n🧪 开始测试: ${testName}`);
    this.testResults.push(`⏳ 请求内容: ${typeof request.input.content === 'string' ? request.input.content : JSON.stringify(request.input.content)}`);

    try {
      const startTime = Date.now();
      const response = await this.orchestrator.process(request);
      const endTime = Date.now();

      this.testResults.push(`✅ 测试通过!`);
      this.testResults.push(`⏱️ 响应时间: ${endTime - startTime}ms`);
      this.testResults.push(`🤖 处理智能体: ${response.agentId}`);
      this.testResults.push(`📝 回复内容:`);
      
      const content = typeof response.output.content === 'string' 
        ? response.output.content 
        : JSON.stringify(response.output.content, null, 2);
      
      const lines = content.split('\n');
      lines.slice(0, 5).forEach(line => {
        this.testResults.push(`   ${line}`);
      });
      if (lines.length > 5) {
        this.testResults.push(`   ... (共${lines.length}行)`);
      }
    } catch (error) {
      this.testResults.push(`❌ 测试失败: ${error}`);
    }

    this.isTesting = false;
  }

  build() {
    Scroll() {
      Column() {
        Text('🤖 AI智能体集成测试')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        if (this.isTesting) {
          Text(`⏳ 正在测试: ${this.currentTest}...`)
            .fontSize(16)
            .fontColor('#FF9800')
            .margin({ bottom: 10 })
        }

        Row({ space: 10 }) {
          Button('测试小艺')
            .onClick(() => this.runTest('XiaoyiAgent - 挂号预约', {
              requestId: 'test-xiaoyi-001',
              userId: 'test-user',
              input: { type: 'text', content: '帮我挂号张医生明天上午' }
            }))

          Button('测试DeepSeek')
            .onClick(() => this.runTest('DeepSeekAgent - 健康咨询', {
              requestId: 'test-deepseek-001',
              userId: 'test-user',
              input: { type: 'text', content: '高血压患者平时饮食要注意什么？' },
              preferences: { preferredAgent: 'deepseek' as AgentId }
            }))
        }
        .margin({ bottom: 10 })

        Row({ space: 10 }) {
          Button('测试Coze')
            .onClick(() => this.runTest('CozeAgent - 医疗问答', {
              requestId: 'test-coze-001',
              userId: 'test-user',
              input: { type: 'text', content: '血压高怎么办？' },
              preferences: { preferredAgent: 'coze' as AgentId }
            }))

          Button('测试HiAI')
            .onClick(() => this.runTest('HiAIAgent - 图像识别', {
              requestId: 'test-hiai-001',
              userId: 'test-user',
              input: { type: 'text', content: '识别这张医疗图片' },
              preferences: { preferredAgent: 'hiai' as AgentId }
            }))
        }
        .margin({ bottom: 10 })

        Button('运行全部测试')
          .width('100%')
          .backgroundColor('#4CAF50')
          .onClick(async () => {
            await this.runTest('1/4 XiaoyiAgent', {
              requestId: 'test-all-001',
              userId: 'test-user',
              input: { type: 'text' as InputType, content: '帮我挂号张医生明天上午' }
            });

            await new Promise<void>(resolve => setTimeout(resolve, 500));

            await this.runTest('2/4 DeepSeekAgent', {
              requestId: 'test-all-002',
              userId: 'test-user',
              input: { type: 'text' as InputType, content: '高血压患者平时饮食要注意什么？' },
              preferences: { preferredAgent: 'deepseek' as AgentId }
            });

            await new Promise<void>(resolve => setTimeout(resolve, 500));

            await this.runTest('3/4 CozeAgent', {
              requestId: 'test-all-003',
              userId: 'test-user',
              input: { type: 'text' as InputType, content: '阿司匹林的副作用有哪些？' },
              preferences: { preferredAgent: 'coze' as AgentId }
            });

            await new Promise<void>(resolve => setTimeout(resolve, 500));

            await this.runTest('4/4 HiAIAgent', {
              requestId: 'test-all-004',
              userId: 'test-user',
              input: { type: 'text' as InputType, content: '识别医学影像' },
              preferences: { preferredAgent: 'hiai' as AgentId }
            });
            
            this.testResults.push('\n🎉 全部测试完成!');
          })
          .margin({ bottom: 20 })

        Divider()
        
        Text('📋 测试日志:')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 10, bottom: 10 })

        List() {
          ForEach(this.testResults, (result: string) => {
            ListItem() {
              Text(result)
                .fontSize(13)
                .fontFamily('monospace')
                .width('100%')
            }
          })
        }
        .layoutWeight(1)
        .width('100%')

        Button('清空日志')
          .margin({ top: 10 })
          .onClick(() => {
            this.testResults = [];
            this.testResults.push('📝 日志已清空');
          })
      }
      .padding(20)
      .width('100%')
      .height('100%')
    }
  }
}
