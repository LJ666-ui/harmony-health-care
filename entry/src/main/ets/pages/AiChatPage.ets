import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { Footer } from '../components/Footer';
import BrowseTracker from '../utils/BrowseTracker';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';
import { ttsService } from '../ai/tts/TTSService';

export interface ChatMessage {
  id: string;
  type: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
}

export interface SuggestedQuestion {
  id: string;
  question: string;
  icon: string;
}

export interface ConversationItem {
  role: string;
  content: string;
}

export interface AiChatHistoryItem {
  id: number;
  sessionId: string;
  lastQuestion: string;
  lastAnswer: string;
  messageCount: number;
  createTime: string;
  updateTime: string;
}

export interface UserInfoData {
  age?: number;
  gender?: string;
  allergies?: string[];
}

interface AiChatConversationMsg {
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
}

@Entry
@Component
struct AiChatPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State showSuggestions: boolean = true;
  @State isRecording: boolean = false;
  @State showHistoryPanel: boolean = false;
  @State historyList: AiChatHistoryItem[] = [];
  @State isLoadingHistory: boolean = false;
  @State currentSessionId: string = '';
  @State isSpeaking: boolean = false;
  @State speakingMessageId: string = '';

  private scroller: Scroller = new Scroller();
  private conversationHistory: ConversationItem[] = [];
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  @State suggestedQuestions: SuggestedQuestion[] = [
    { id: '1', question: '\u8840\u538B\u591A\u5C11\u7B97\u6B63\u5E38?', icon: '\u2764' },
    { id: '2', question: '\u8001\u5E74\u4EBA\u5982\u4F55\u9884\u9632\u7CD6\u5C3F\u75C5?', icon: '\uD83D\uDC8A' },
    { id: '3', question: '\u6BCF\u5929\u5E94\u8BE5\u8FD0\u52A8\u591A\u4E45?', icon: '\uD83C\uDFC3' },
    { id: '4', question: '\u5931\u7720\u600E\u4E48\u529E?', icon: '\uD83D\uDE34' },
    { id: '5', question: '\u5982\u4FDD\u6301\u5FC3\u810F\u5065\u5EB7?', icon: '\uD83D\uDCAA' },
    { id: '6', question: '\u996E\u98DF\u4E0A\u6709\u4EC0\u4E48\u6CE8\u610F\u4E8B\u9879?', icon: '\uD83E\uDD57' }
  ];

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    BrowseTracker.recordStart('AI_CHAT', 'PAGE', 4, 'AI\u5065\u5EBB\u987E\u95EE').then(id => {
      this.recordId = id;
    });

    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    this.addSystemMessage('\u60A8\u597D! \u6211\u662FAI\u5065\u5EBB\u987E\u95EE, \u53EF\u4EE5\u5E2E\u60A8\u89E3\u7B54\u5065\u5EBB\u76F8\u5173\u95EE\u9898. \u8BF7\u95EE\u6709\u4EC0\u4E48\u53EF\u4EE5\u5E2E\u52A9\u60A8\u7684?');

    ttsService.initialize().then(success => {
      if (success) {
        console.log('[AiChatPage] TTS引擎就绪');
      }
    });
  }

  aboutToDisappear(): void {
    ttsService.stop();
    this.isSpeaking = false;

    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  addMessage(type: 'user' | 'assistant' | 'system', content: string, isLoading?: boolean, isError?: boolean, errorMessage?: string): void {
    const message: ChatMessage = {
      id: Date.now().toString() + Math.random().toString(36).substring(2, 11),
      type,
      content,
      timestamp: Date.now(),
      isLoading: isLoading ? isLoading : false,
      isError: isError ? isError : false,
      errorMessage: errorMessage
    };

    this.messages.push(message);

    setTimeout(() => {
      try {
        this.scroller.scrollEdge(Edge.Bottom);
      } catch (e) {
        console.error('scroll error:', e);
      }
    }, 100);
  }

  addSystemMessage(content: string): void {
    this.addMessage('system', content);
  }

  addUserMessage(content: string): void {
    this.addMessage('user', content);
    const convItem: ConversationItem = { role: 'user', content };
    this.conversationHistory.push(convItem);
    this.showSuggestions = false;
  }

  addAssistantMessage(content: string, isError?: boolean, errorMessage?: string): void {
    this.addMessage('assistant', content, false, isError, errorMessage);
    if (!isError) {
      const convItem: ConversationItem = { role: 'assistant', content };
      this.conversationHistory.push(convItem);
    }
  }

  addLoadingMessage(): string {
    const loadingId: string = Date.now().toString() + '_loading';
    const message: ChatMessage = {
      id: loadingId,
      type: 'assistant',
      content: '',
      timestamp: Date.now(),
      isLoading: true
    };
    this.messages.push(message);

    setTimeout(() => {
      try {
        this.scroller.scrollEdge(Edge.Bottom);
      } catch (e) {
        console.error('scroll error:', e);
      }
    }, 100);

    return loadingId;
  }

  removeLoadingMessage(loadingId: string): void {
    let filtered: ChatMessage[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      if (this.messages[i].id !== loadingId) {
        filtered.push(this.messages[i]);
      }
    }
    this.messages = filtered;
  }

  async callAiOrchestrator(question: string): Promise<string> {
    const request = AIRequestBuilder.createSimpleRequest(
      question,
      String(AppStorage.get('userId') || 'anonymous')
    );
    request.conversationHistory = this.conversationHistory.slice(-10).map(item => {
      const msg: AiChatConversationMsg = {
        role: item.role as 'user' | 'assistant',
        content: item.content,
        timestamp: Date.now()
      };
      return msg;
    });
    request.preferences = { preferredAgent: 'deepseek' };

    const response = await this.orchestrator.process(request);

    console.log('[AiChatPage] AIOrchestrator response:', {
      agentId: response.agentId,
      confidence: response.output.confidence
    });

    return typeof response.output.content === 'string'
      ? response.output.content
      : JSON.stringify(response.output.content);
  }

  async callAiApi(question: string): Promise<string> {
    try {
      const healthContext: string = this.buildHealthContext();

      const requestData: Record<string, Object> = {};
      requestData['question'] = question;
      requestData['context'] = healthContext;
      let historySlice: ConversationItem[] = [];
      if (this.conversationHistory.length > 10) {
        for (let i = this.conversationHistory.length - 10; i < this.conversationHistory.length; i++) {
          historySlice.push(this.conversationHistory[i]);
        }
      } else {
        for (let j = 0; j < this.conversationHistory.length; j++) {
          historySlice.push(this.conversationHistory[j]);
        }
      }
      requestData['history'] = historySlice;

      if (this.currentSessionId && this.currentSessionId.length > 0) {
        requestData['sessionId'] = this.currentSessionId;
      }

      const response: BaseResponse<Record<string, Object>> = await HttpUtil.post<Record<string, Object>>(ApiConstants.AI_CHAT, requestData);

      if (response.success && response.data) {
        const dataObj: Record<string, Object> = response.data;

        if (dataObj['sessionId']) {
          this.currentSessionId = dataObj['sessionId'] as string;
        }

        let answer: string = dataObj['answer'] as string || dataObj['content'] as string || dataObj['reply'] as string || '';
        if (!answer && dataObj['message']) {
          answer = dataObj['message'] as string;
        }
        return answer;
      } else {
        throw new Error(response.message ? response.message : '\u670D\u52A1\u5668\u8FD4\u56DE\u5F02\u5E38');
      }
    } catch (e) {
      console.error('AI Chat API Error:', e);
      throw new Error('\u7F51\u7EDC\u8FDE\u63A5\u5931\u8D25, \u8BF7\u67E5\u770B\u7F51\u7EDC\u8BBE\u7F6E');
    }
  }

  async callConsultApi(symptomDesc: string): Promise<string> {
    try {
      const healthContext: string = this.buildHealthContext();

      const consultData: Record<string, Object> = {};
      consultData['symptoms'] = symptomDesc;
      consultData['userContext'] = healthContext;
      let consultHistorySlice: ConversationItem[] = [];
      if (this.conversationHistory.length > 6) {
        for (let i = this.conversationHistory.length - 6; i < this.conversationHistory.length; i++) {
          consultHistorySlice.push(this.conversationHistory[i]);
        }
      } else {
        for (let j = 0; j < this.conversationHistory.length; j++) {
          consultHistorySlice.push(this.conversationHistory[j]);
        }
      }
      consultData['history'] = consultHistorySlice;

      const response: BaseResponse<Record<string, Object>> = await HttpUtil.post<Record<string, Object>>(ApiConstants.AI_CONSULT, consultData);

      if (response.success && response.data) {
        const dataObj: Record<string, Object> = response.data;
        let advice: string = dataObj['advice'] as string || dataObj['answer'] as string || dataObj['result'] as string || '';
        if (!advice && dataObj['content']) {
          advice = dataObj['content'] as string;
        }

        const disclaimer: string = '\n\n---\n\u26A0\uFE0F **\u6E29\u99A8\u63D0\u793A**: \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u4E25\u91CD\u8BF7\u5C31\u533B.';
        return advice + disclaimer;
      } else {
        throw new Error(response.message ? response.message : '\u5065\u5EBB\u54A8\u8BE2\u5931\u8D25');
      }
    } catch (e) {
      console.error('AI Consult API Error:', e);
      throw new Error('\u5065\u5EBB\u54A8\u8BE2\u670D\u52A1\u6682\u65F6\u4E0D\u53EF\u7528');
    }
  }

  buildHealthContext(): string {
    let context: string = '';

    try {
      const userInfo: object | undefined = AppStorage.get<object>('userInfo');
      if (userInfo) {
        const user: UserInfoData = userInfo as UserInfoData;
        if (user.age || user.gender) {
          context += '用户信息：' + (user.age || '') + '岁, ' + (user.gender === 'male' ? '男' : '女');
        }
        if (user.allergies && Array.isArray(user.allergies) && user.allergies.length > 0) {
          let allergiesStr = '';
          for (let i = 0; i < user.allergies.length; i++) {
            if (i > 0) {
              allergiesStr = allergiesStr + '、';
            }
            allergiesStr = allergiesStr + user.allergies[i];
          }
          context += ', 过敏史：' + allergiesStr;
        }
      }
    } catch (e) {
      console.error('Build context error:', e);
    }

    return context;
  }

  getMockResponse(question: string): string {
    const lowerQuestion: string = question.toLowerCase();

    if (lowerQuestion.includes('\u8840\u538B')) {
      return `**\u5173\u4E8E\u8840\u538B\u6B63\u5E38\u503C\uFF1A**

\u2022 **\u6B63\u5E38\u8840\u538B**\uFF1A\u6536\u7F29\u538B < 120 mmHg \u4E14 \u8212\u5F20\u538B < 80 mmHg
\u2022 **\u8840\u538B\u9AD8\u524D\u671F**\uFF1A\u6536\u7F29\u538B 120-139 \u6216 \u8212\u5F20\u538B 80-89
\u2022 **\u9AD8\u8840\u538B**\uFF1A\u6536\u7F29\u538B \u2265 140 \u6216 \u8212\u5F20\u538B \u2265 90

**\u5EFA\u8BAE\uFF1A**
1. \u5B9A\u671F\u6D4B\u91CF\u8840\u538B, \u5EFA\u8BAE\u6BCF\u5929\u65E9\u665A\u5404\u6D4B\u4E00\u6B21
2. \u4FDD\u6301\u4F4E\u76D0\u996E\u98DF, \u65E5\u5E38\u76D0\u6444\u5165 < 6\u514B
3. \u9002\u91CF\u8FD0\u52A8, \u6BCF\u5468\u81F3\u5C11150\u5206\u949F\u4E2D\u7B49\u5F3A\u5EA6\u8FD0\u52A8
4. \u4FDD\u6301\u5FC3\u60C5\u6109\u60A6, \u907F\u514D\u60C5\u7EEA\u6FC0\u52A8

> \u26A0\uFE0F \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u5982\u6709\u4E0D\u9002\u8BF7\u53CA\u65F6\u5C31\u533B`;
    }

    if (lowerQuestion.includes('\u7CD6\u5C3F') || lowerQuestion.includes('\u8840\u7CD6')) {
      return `**\u8001\u5E74\u4EBA\u9884\u9632\u7CD6\u5C3F\u75C5\u7684\u5EFA\u8BAE\uFF1A**

**\u996E\u98DF\u65B9\u9762\uFF1A**
1. \u63A7\u5236\u78B3\u6C34\u5316\u5408\u7269\u6444\u5165, \u9009\u62E9\u4F4EGI\u98DF\u7269
2. \u589E\u52A0\u86CB\u767D\u7EA4\u7EF4, \u591A\u5403\u852C\u83DC\u3001\u5168\u8C37\u7269
3. \u5C11\u98DF\u591A\u9910, \u907F\u514D\u66B4\u996E\u66B4\u98DF
4. \u9650\u5236\u7CD6\u5206\u548C\u7CBE\u5236\u98DF\u54C1

**\u8FD0\u52A8\u65B9\u9762\uFF1A**
1. \u6BCF\u5468\u81F3\u5C11150\u5206\u949F\u6709\u6C27\u8FD0\u52A8
2. \u996D\u540E\u6563\u6B6515-30\u5206\u949F
3. \u8FDB\u884C\u9002\u5EA6\u7684\u529B\u91CF\u8BAD\u7EC3

> \u26A0\uFE0F \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u5982\u6709\u4E0D\u9002\u8BF7\u53CA\u65F6\u5C31\u533B`;
    }

    if (lowerQuestion.includes('\u8FD0\u52A8') || lowerQuestion.includes('\u953B\u70BC')) {
      return `**\u63A8\u8350\u7684\u8FD0\u52A8\u65F6\u95F4\u548C\u65B9\u5F0F\uFF1A**

**\u8FD0\u52A8\u65F6\u957F\u5EFA\u8BAE\uFF1A**
\u2022 **\u6BCF\u5468\u603B\u91CF**\uFF1A150-300\u5206\u949F\u4E2D\u7B49\u5F3A\u5EA6\u8FD0\u52A8
\u2022 **\u6BCF\u5929\u5EFA\u8BAE**\uFF1A30-60\u5206\u949F

**\u9002\u5408\u8001\u5E74\u4EBA\u7684\u8FD0\u52A8\uFF1A**
1. **\u6B65\u884C**\uFF1A\u6700\u5B89\u5168\u6709\u6548\u7684\u6709\u6C27\u8FD0\u52A8
2. **\u592A\u6781\u62F3**\uFF1A\u6539\u5584\u5E73\u8861\u80FD\u529B, \u51CF\u5C11\u8DCC\u5012\u98CE\u9669
3. **\u6E38\u6CF3**\uFF1A\u5173\u8282\u8D1F\u62C5\u5C0F, \u5168\u8EAB\u953B\u70BC
4. **\u5E7F\u573A\u821E**\uFF1A\u793E\u4EA4+\u8FD0\u52A8\u7684\u826F\u597D\u9009\u62E9

> \u26A0\uFE0F \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u5982\u6709\u4E0D\u9002\u8BF7\u53CA\u65F6\u5C31\u533B`;
    }

    if (lowerQuestion.includes('\u5931\u7720') || lowerQuestion.includes('\u7761\u7720')) {
      return `**\u6539\u5584\u5931\u7720\u7684\u65B9\u6CD5\uFF1A**

**\u751F\u6D3B\u4E60\u60EF\u8C03\u6574\uFF1A**
1. \u56FA\u5B9A\u4F5C\u606F\u65F6\u95F4, \u6BCF\u5925\u540C\u4E00\u65F6\u95F4\u5165\u7761\u548C\u8D77\u5E8A
2. \u7761\u524D1\u5C0F\u65F6\u907F\u514D\u4F7F\u7528\u7535\u5B50\u8BBE\u5907
3. \u5367\u5BA4\u4FDD\u6301\u5B89\u9759\u3001\u9ED1\u6697\u3001\u51B7\u7239(18-22\u00B0C)

**\u7761\u524D\u653E\u677E\u6280\u5DE7\uFF1A**
1. \u6E29\u6C34\u6CE1\u811A15-20\u5206\u949F
2. \u542C\u8F7B\u97F3\u4E50\u6216\u767D\u5A92\u97F3
3. \u6DF1\u547C\u5438\u7EC3\u4E60(4-7-8\u547C\u5438\u6CD5)

> \u26A0\uFE0F \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u5982\u6709\u4E0D\u9002\u8BF7\u53CA\u65F6\u5C31\u533B`;
    }

    if (lowerQuestion.includes('\u5FC3\u810F') || lowerQuestion.includes('\u5FC3\u8840\u7BA1')) {
      return `**\u4FDD\u6301\u5FC3\u810F\u5065\u5EB7\u7684\u5EFA\u8BAE\uFF1A**

**\u5065\u5EBB\u996E\u98DF\uFF1A**
1. \u5730\u4E2D\u6D77\u996E\u98DF\u6A21\u5F0F\uFF1A\u591A\u852C\u679C\u3001\u5168\u8C37\u7269\u3001\u6A44\u6984\u6CB9
2. \u63A7\u5236\u9971\u548C\u8102\u80AA\u548C\u53CD\u5F0F\u8102\u80AA\u6444\u5165
3. \u9650\u5236\u94A0\u76D0(<6\u514B/\u5929)

**\u89C4\u5F8B\u8FD0\u52A8\uFF1A**
\u2022 \u6BCF\u5468150\u5206\u949F\u4E2D\u7B49\u5F3A\u5EA6\u6709\u6C27\u8FD0\u52A8
\u2022 \u5FEB\u8D70\u3001\u6E38\u6CF3\u3001\u9A91\u81EA\u884C\u8F66\u90FD\u662F\u597D\u9009\u62E9

**\u751F\u6D3B\u65B9\u5F0F\uFF1A**
1. \u6212\u70DF\u9650\u9152
2. \u63A7\u5236\u4F53\u91CD
3. \u7BA1\u7406\u538B\u529B
4. \u5145\u8DB3\u7761\u7720

> \u26A0\uFE0F \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u5982\u6709\u4E0D\u9002\u8BF7\u53CA\u65F6\u5C31\u533B`;
    }

    if (lowerQuestion.includes('\u996E\u98DF') || lowerQuestion.includes('\u5403')) {
      return `**\u8001\u5E74\u4EBA\u996E\u98DF\u6CE8\u610F\u4E8B\u9879\uFF1A**

**\u8425\u517B\u5747\u8861\u539F\u5219\uFF1A**
1. **\u86CB\u767D\u8D28**\uFF1A\u65E5\u5E381-1.2\u514B/\u516C\u65A4\u4F53\u91CD
2. **\u78B3\u6C34\u5316\u5408\u7269**\uFF1A\u9009\u62E9\u5168\u8C37\u7269\u3001\u6742\u7AEE\u4E3A\u4E3B
3. **\u8102\u80AA**\uFF1A\u63A7\u5236\u603B\u91CF, \u9009\u62E9\u690D\u7269\u6CB9

**\u5177\u4F53\u5EFA\u8BAE\uFF1A**
\u2022 **\u5C11\u98DF\u591A\u9910**\uFF1A\u4E00\u65E54-5\u9910, \u6BCF\u9910\u4E03\u5166\u5206\u9971
\u2022 **\u6613\u6D88\u5316**\uFF1A\u98DF\u7269\u716E\u8F6F\u70C2, \u5229\u4E8E\u5438\u6536
\u2022 **\u5145\u8DB3\u6C34\u5206**\uFF1A\u65E5\u5E381500-1700ml

**\u9700\u8981\u9650\u5236\u7684\uFF1A**
\u274C \u9AD8\u76D0(<6\u514B/\u5929)
\u274C \u9AD8\u7CD6\u98DF\u54C1
\u274C \u6CB9\u70B8\u98DF\u54C1

> \u26A0\uFE0F \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u5982\u6709\u4E0D\u9002\u8BF7\u53CA\u65F6\u5C31\u533B`;
    }

    return `\u611F\u8C22\u60A8\u7684\u63D0\u95EE! \u4F5C\u4E3A\u60A8\u7684AI\u5065\u5EBB\u987E\u95EE, \u6211\u7406\u89E3\u60A8\u5173\u5FC3\u8FD9\u4E2A\u95EE\u9898.

\u9488\u5BF9\u60A8\u7684\u95EE\u9898, \u6211\u5EFA\u8BAE\u60A8\uFF1A

1. **\u4FDD\u6301\u826F\u597D\u7684\u751F\u6D3B\u4E60\u60EF** - \u89C4\u5F8B\u4F5C\u606F\u3001\u5747\u8861\u996E\u98DF\u3001\u9002\u5EA6\u8FD0\u52A8
2. **\u5B9A\u671F\u4F53\u68C0** - \u53CA\u65F6\u4E86\u89E3\u8EAB\u4F53\u72B6\u51B5
3. **\u9075\u533B\u5631** - \u5982\u6709\u6162\u6027\u75C5, \u6309\u65F6\u670D\u836F\u590D\u8BCA

**\u6E29\u99A8\u63D0\u793A\uFF1A**
> \u26A0\uFE0F \u6211\u662FAI\u52A9\u624B, \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003. \u5982\u51FA\u73B0\u4E25\u91CD\u4E0D\u9002, \u8BF7\u7ACB\u5373\u5C31\u533B\u6216\u62E8\u6253\u6025\u6551\u7535\u8BDD.`;
  }

  async handleSendMessage(isConsult: boolean = false): Promise<void> {
    const text: string = this.inputText.trim();
    if (!text || this.isLoading) return;

    this.inputText = '';
    this.addUserMessage(text);
    this.isLoading = true;

    const streamMsgId: string = Date.now().toString() + '_stream';
    let streamContent: string = '';

    this.messages.push({
      id: streamMsgId,
      type: 'assistant',
      content: '',
      timestamp: Date.now(),
      isLoading: true
    });

    setTimeout(async () => {
      try {
        const request = AIRequestBuilder.createSimpleRequest(
          text,
          String(AppStorage.get('userId') || 'anonymous')
        );
        request.conversationHistory = this.conversationHistory.slice(-10).map(item => {
          const msg: AiChatConversationMsg = {
            role: item.role as 'user' | 'assistant',
            content: item.content,
            timestamp: Date.now()
          };
          return msg;
        });
        request.preferences = { preferredAgent: 'deepseek' };

        await this.orchestrator.processStream(request, (chunk: string, isDone: boolean) => {
          if (!isDone && chunk.length > 0) {
            streamContent += chunk;
            const msgIndex: number = this.findMessageIndex(streamMsgId);
            if (msgIndex !== -1) {
              this.messages[msgIndex].content = streamContent;
              this.messages[msgIndex].isLoading = !isDone;
            }
          }
          if (isDone) {
            const msgIndex: number = this.findMessageIndex(streamMsgId);
            if (msgIndex !== -1) {
              this.messages[msgIndex].isLoading = false;
              this.messages[msgIndex].content = streamContent;
            }
            if (streamContent && streamContent.length > 0) {
              const convItem: ConversationItem = { role: 'assistant', content: streamContent };
              this.conversationHistory.push(convItem);
            }
          }
        });

      } catch (error) {
        console.error('Error:', error);
        const msgIndex: number = this.findMessageIndex(streamMsgId);
        if (msgIndex !== -1) {
          this.messages.splice(msgIndex, 1);
        }
        const errorMsg: string = error instanceof Error ? error.message : '\u62B1\u6B49, \u53D1\u751F\u4E86\u672A\u77E5\u9519\u8BEF, \u8BF7\u91CD\u8BD5';
        this.addAssistantMessage('', true, errorMsg);
      } finally {
        this.isLoading = false;
      }
    }, 200);
  }

  speakMessage(content: string, messageId: string): void {
    console.log('[AiChatPage] 🔊 点击朗读按钮, content长度:', content.length, 'messageId:', messageId);

    if (this.isSpeaking && this.speakingMessageId === messageId) {
      console.log('[AiChatPage] ⏹️ 停止当前播报');
      ttsService.stop();
      this.isSpeaking = false;
      this.speakingMessageId = '';
      return;
    }

    if (this.isSpeaking) {
      ttsService.stop();
    }

    this.isSpeaking = true;
    this.speakingMessageId = messageId;

    console.log('[AiChatPage] 🎤 开始播报, TTS状态:', ttsService.getIsSpeaking());

    ttsService.speak(content, (event, data) => {
      console.log('[AiChatPage] TTS事件:', event, data || '');
      if (event === 'finish' || event === 'error') {
        this.isSpeaking = false;
        if (event === 'error') {
          ToastUtil.showInfo('语音播放失败: ' + (data || '未知错误'));
        }
      }
    });
  }

  async typewriterEffect(fullText: string): Promise<void> {
    const messageId: string = Date.now().toString() + '_typing';
    let displayedText: string = '';

    this.messages.push({
      id: messageId,
      type: 'assistant',
      content: displayedText,
      timestamp: Date.now()
    });

    const charsPerIteration: number = this.isElderMode ? 3 : 2;
    const delay: number = this.isElderMode ? 40 : 25;

    for (let i: number = 0; i < fullText.length; i += charsPerIteration) {
      displayedText = fullText.substring(0, i + charsPerIteration);

      const msgIndex: number = this.findMessageIndex(messageId);
      if (msgIndex !== -1) {
        this.messages[msgIndex].content = displayedText;
      }

      if (i % 10 === 0) {
        try {
          this.scroller.scrollEdge(Edge.Bottom);
        } catch (e) {}
      }

      await new Promise<void>(resolve => setTimeout(resolve, delay));
    }
  }

  handleSuggestionClick(question: string): void {
    this.inputText = question;
    this.handleSendMessage();
  }

  clearChatHistory(): void {
    this.messages = [];
    this.conversationHistory = [];
    this.showSuggestions = true;
    this.currentSessionId = '';
    this.addSystemMessage('\u5BF9\u8BDD\u5DF2\u6E05\u7A7A. \u6709\u4EC0\u4E48\u6211\u53EF\u4EE5\u5E2E\u52A9\u60A8\u7684?');
  }

  copyMessage(content: string): void {
    ToastUtil.showInfo('\u5DF2\u590D\u5236\u5230\u526A\u8D34\u677F');
  }

  private findMessageIndex(id: string): number {
    for (let i = 0; i < this.messages.length; i++) {
      if (this.messages[i].id === id) {
        return i;
      }
    }
    return -1;
  }

  private findLastUserMessage(messages: ChatMessage[]): ChatMessage | undefined {
    for (let i = 0; i < messages.length; i++) {
      if (messages[i].type === 'user') {
        return messages[i];
      }
    }
    return undefined;
  }

  formatTime(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const hours: string = date.getHours().toString().padStart(2, '0');
    const minutes: string = date.getMinutes().toString().padStart(2, '0');
    return '' + hours + ':' + minutes;
  }

  startVoiceInput(): void {
    if (this.isRecording) return;

    this.isRecording = true;
    ToastUtil.showInfo('\u6B63\u5728\u8046\u542C...');

    setTimeout(() => {
      this.isRecording = false;
      this.inputText = '\u6211\u60F3\u4E86\u89E3\u9AD8\u8840\u538B\u7684\u9884\u9632\u65B9\u6CD5';
      ToastUtil.showInfo('\u5DF2\u586B\u5165\u793A\u4F8B\u6587\u672C(\u6F14\u793A\u6A21\u5F0F)');
    }, 2000);

    setTimeout(() => {
      if (this.isRecording) {
        this.isRecording = false;
      }
    }, 10000);
  }

  async loadChatHistory(): Promise<void> {
    this.isLoadingHistory = true;
    this.showHistoryPanel = true;

    try {
      const url: string = ApiConstants.AI_HISTORY + '?page=1&size=20';
      const response: BaseResponse<AiChatHistoryItem[]> = await HttpUtil.get<AiChatHistoryItem[]>(url);

      if (response.success && response.data) {
        const list: AiChatHistoryItem[] = response.data;
        this.historyList = [];
        for (let i = 0; i < list.length; i++) {
          this.historyList.push(list[i]);
        }
      }
    } catch (e) {
      console.error('\u52A0\u8F7D\u5BF9\u8BDD\u5386\u53F2\u5931\u8D25:', e);
      ToastUtil.showSuccess('\u52A0\u8F7D\u5386\u53F2\u5931\u8D25');
    } finally {
      this.isLoadingHistory = false;
    }
  }

  async continueConversation(item: AiChatHistoryItem): Promise<void> {
    this.currentSessionId = item.sessionId;
    this.showHistoryPanel = false;

    try {
      const url: string = ApiConstants.AI_HISTORY_DETAIL + '?sessionId=' + item.sessionId;
      const response: BaseResponse<ConversationItem[]> = await HttpUtil.get<ConversationItem[]>(url);

      if (response.success && response.data) {
        const historyItems: ConversationItem[] = response.data;
        this.messages = [];
        this.conversationHistory = [];

        for (let i = 0; i < historyItems.length; i++) {
          const convItem: ConversationItem = historyItems[i];
          if (convItem.role === 'user') {
            this.addMessage('user', convItem.content);
          } else if (convItem.role === 'assistant') {
            this.addMessage('assistant', convItem.content);
          }
          this.conversationHistory.push(convItem);
        }
      }
    } catch (e) {
      console.error('\u52A0\u8F7D\u5BF9\u8BDD\u8BE6\u60C5\u5931\u8D25:', e);
      ToastUtil.showSuccess('\u52A0\u8F7D\u5BF9\u8BDD\u5931\u8D25');
    }

    this.showSuggestions = false;
    ToastUtil.showSuccess('\u5DF2\u6062\u590D\u8BE5\u5BF9\u8BDD');
  }

  closeHistoryPanel(): void {
    this.showHistoryPanel = false;
  }

  @Builder
  UserBubble(message: ChatMessage) {
    Row() {
      Blank();

      Column({ space: 4 }) {
        Text(message.content)
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#1677FF')
          .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4 })
          .constraintSize({ maxWidth: '80%' })
          .gesture(
            LongPressGesture()
              .onAction(() => {
                this.copyMessage(message.content);
              })
          );

        Text(this.formatTime(message.timestamp))
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .fontColor('#999999')
          .margin({ right: 8 });
      }
      .alignItems(HorizontalAlign.End);
    }
    .width('100%')
    .padding({ right: 12 });
  }

  @Builder
  AssistantBubble(message: ChatMessage) {
    Row() {
      Column({ space: 8 }) {
        if (message.isLoading) {
          this.ThinkingAnimation();
        } else if (message.isError) {
          this.ErrorMessageBubble(message);
        } else {
          this.MarkdownContent(message.content);
          this.DisclaimerText();

          Text('---')
            .fontSize(1)
            .height(1)
            .width('100%')
            .opacity(0);

          Row() {
            Text(this.formatTime(message.timestamp))
              .fontSize(11)
              .fontColor('#AAAAAA');

            Button(this.isSpeaking && this.speakingMessageId === message.id ? '⏹停止' : '🔊朗读')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .height(32)
              .backgroundColor(this.isSpeaking && this.speakingMessageId === message.id ? '#FF4444' : '#1677FF')
              .fontColor('#FFFFFF')
              .borderRadius(16)
              .onClick(() => {
                console.log('[AiChatPage] 🔊 点击朗读按钮!');
                this.speakMessage(message.content, message.id);
              });
          }
          .width('100%');
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%');

      Blank();
    }
    .width('100%')
    .padding({ left: 12, right: 12 });
  }

  @Builder
  SystemBubble(message: ChatMessage) {
    Row() {
      Column() {
        Text(message.content)
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor('#F0F0F0')
          .borderRadius(20)
          .margin({ top: 8, bottom: 8 });
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .padding({ left: 32, right: 32 });
  }

  @Builder
  ThinkingAnimation() {
    Row({ space: 8 }) {
      Text('\uD83E\uDD14')
        .fontSize(24);

      Column({ space: 4 }) {
        Text('\u6B63\u5728\u601D\u8003\u4E2D...')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#666666');

        Row({ space: 4 }) {
          ForEach([0, 1, 2], (index: number) => {
            Circle()
              .width(8)
              .height(8)
              .fill('#1677FF')
              .opacity(0.4 + index * 0.2)
              .animation({
                duration: 600,
                iterations: -1,
                curve: Curve.EaseInOut,
                delay: index * 200
              });
          });
        }
        .margin({ top: 8 });
      }
    }
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#F5F5F5')
    .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 })
    .constraintSize({ maxWidth: '80%' });
  }

  @Builder
  ErrorMessageBubble(message: ChatMessage) {
    Column({ space: 8 }) {
      Text('\u26A0\uFE0F')
        .fontSize(28);

      Text(message.errorMessage || '\u62B1\u6B49, \u51FA\u73B0\u4E86\u9519\u8BEF')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontColor('#FF4D4F')
        .textAlign(TextAlign.Center);

      Button('\u91CD\u65B0\u53D1\u9001')
        .height(36)
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor('#FFFFFF')
        .backgroundColor('#FF4D4F')
        .borderRadius(18)
        .onClick(() => {
          const reversedMessages: ChatMessage[] = [];
          for (let i = this.messages.length - 1; i >= 0; i--) {
            reversedMessages.push(this.messages[i]);
          }
          const lastUserMsg: ChatMessage | undefined = this.findLastUserMessage(reversedMessages);
          if (lastUserMsg) {
            let filteredMessages: ChatMessage[] = [];
            for (let i = 0; i < this.messages.length; i++) {
              if (this.messages[i].id !== message.id) {
                filteredMessages.push(this.messages[i]);
              }
            }
            this.messages = filteredMessages;
            this.inputText = lastUserMsg.content;
            this.handleSendMessage();
          }
        });
    }
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .backgroundColor('#FFF1F0')
    .border({ width: 1, color: '#FFCCC7' })
    .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 })
    .constraintSize({ maxWidth: '80%' })
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  MarkdownContent(content: string) {
    Column({ space: 8 }) {
      ForEach(this.parseMarkdownToSegments(content), (segment: MarkdownSegment, index: number) => {
        if (segment.type === 'heading') {
          Text(segment.text)
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 8, bottom: 4 });
        } else if (segment.type === 'bold') {
          Text(segment.text)
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');
        } else if (segment.type === 'list') {
          Row({ space: 6 }) {
            Text('\u2022')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#1677FF');

            Text(segment.text)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#333333')
              .layoutWeight(1);
          }
        } else if (segment.type === 'warning') {
          Text(segment.text)
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#FAAD14')
            .fontStyle(FontStyle.Italic)
            .margin({ top: 8 })
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor('#FFFBE6')
            .borderRadius(8);
        } else if (segment.type === 'divider') {
          Divider()
            .color('#F0F0F0')
            .margin({ top: 4, bottom: 4 });
        } else {
          Text(segment.text)
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#333333')
            .lineHeight(22);
        }
      });
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#F5F5F5')
    .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 })
    .constraintSize({ maxWidth: '85%' })
    .gesture(
      LongPressGesture()
        .onAction(() => {
          this.copyMessage(content);
        })
    );
  }

  @Builder
  DisclaimerText() {
    Text('\u26A0\uFE0F \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u5982\u6709\u4E0D\u9002\u8BF7\u53CA\u65F6\u5C31\u533B')
      .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
      .fontColor('#999999')
      .fontStyle(FontStyle.Italic)
      .margin({ top: 6, left: 4 });
  }

  private isListItem(text: string): boolean {
    if (text.length < 3) return false;
    const firstChar = text.charAt(0);
    if (firstChar >= '1' && firstChar <= '9') {
      return text.charAt(1) === '.' && text.charAt(2) === ' ';
    }
    return false;
  }

  parseMarkdownToSegments(text: string): MarkdownSegment[] {
    const segments: MarkdownSegment[] = [];
    const lines: string[] = text.split('\n');

    for (let lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      const trimmedLine: string = lines[lineIdx].trim();

      if (!trimmedLine) {
        continue;
      }

      if (trimmedLine.startsWith('### ')) {
        segments.push({ type: 'heading', text: trimmedLine.substring(4) });
      } else if (trimmedLine.startsWith('## ')) {
        segments.push({ type: 'heading', text: trimmedLine.substring(3) });
      } else if (trimmedLine.startsWith('# ')) {
        segments.push({ type: 'heading', text: trimmedLine.substring(2) });
      } else if (trimmedLine.startsWith('> ') || trimmedLine.indexOf('\u26A0\uFE0F') >= 0) {
        let warningText = trimmedLine;
        if (warningText.startsWith('> ')) {
          warningText = warningText.substring(2);
        }
        segments.push({ type: 'warning', text: warningText });
      } else if (this.isListItem(trimmedLine) || trimmedLine.startsWith('\u2022 ') || trimmedLine.startsWith('- ')) {
        let listText: string = trimmedLine;
        if (this.isListItem(listText)) {
          if (listText.length >= 3 && listText.charAt(1) === '.' && listText.charAt(2) === ' ') {
            listText = listText.substring(3);
          }
        }
        if (listText.startsWith('\u2022 ')) {
          listText = listText.substring(2);
        }
        if (listText.startsWith('- ')) {
          listText = listText.substring(2);
        }
        segments.push({ type: 'list', text: listText });
      } else if (trimmedLine.indexOf('---') >= 0) {
        segments.push({ type: 'divider', text: '' });
      } else if (trimmedLine.indexOf('**') >= 0) {
        const parts: string[] = trimmedLine.split('**');
        for (let partIdx = 0; partIdx < parts.length; partIdx++) {
          const part: string = parts[partIdx];
          if (part.trim()) {
            if (partIdx % 2 === 1) {
              segments.push({ type: 'bold', text: part });
            } else {
              segments.push({ type: 'text', text: part });
            }
          }
        }
      } else if (trimmedLine.length > 0 && (trimmedLine.charAt(0) === '\u274C' || trimmedLine.charAt(0) === '\u2705')) {
        segments.push({ type: 'list', text: trimmedLine });
      } else {
        segments.push({ type: 'text', text: trimmedLine });
      }
    }

    return segments;
  }

  build() {
    Column() {
      Row() {
        Text('\u2190')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#FFFFFF')
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          });

        Text('\uD83E\uDDD0 AI\u5065\u5EBB\u987E\u95EE')
          .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Row({ space: 12 }) {
          Text('\uD83D\uDCDA')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.loadChatHistory();
            });

          Text('\uD83D\uDDD1')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#FFFFFFBB')
            .onClick(() => {
              AlertDialog.show({
                title: '\u6E05\u7A7A\u5BF9\u8BDD',
                message: '\u786E\u5B9A\u8981\u6E05\u7A7A\u6240\u6709\u5BF9\u8BDD\u8BB0\u5F55\u5417?',
                primaryButton: {
                  value: '\u53D6\u6D88',
                  action: () => {}
                },
                secondaryButton: {
                  value: '\u786E\u5B9A',
                  fontColor: '#FF4D4F',
                  action: () => {
                    this.clearChatHistory();
                  }
                }
              });
            });
        }
        .margin({ right: 16 });
      }
      .width('100%')
      .height(56)
      .backgroundColor('#1677FF')
      .justifyContent(FlexAlign.Center);

      if (this.showHistoryPanel) {
        this.HistoryPanel();
      } else if (this.messages.length === 0) {
        this.EmptyState();
      }

      Scroll(this.scroller) {
        Column({ space: 8 }) {
          ForEach(this.messages, (message: ChatMessage) => {
            if (message.type === 'user') {
              this.UserBubble(message);
            } else if (message.type === 'assistant') {
              this.AssistantBubble(message);
            } else if (message.type === 'system') {
              this.SystemBubble(message);
            }
          }, (message: ChatMessage) => message.id);
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#FAFBFC')
      .edgeEffect(EdgeEffect.Spring);

      if (this.showSuggestions && !this.showHistoryPanel && this.messages.length <= 1) {
        this.SuggestionPanel();
      }

      this.InputArea();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  HistoryPanel() {
    Column() {
      Row() {
        Text('\u5BF9\u8BDD\u5386\u53F2')
          .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1);

        Text('\u2715')
          .fontSize(18)
          .fontColor('#999999')
          .onClick(() => {
            this.closeHistoryPanel();
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 });

      if (this.isLoadingHistory) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
            .color('#1677FF');

          Text('\u52A0\u8F7D\u4E2D...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 8 });
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(20);
      } else if (this.historyList.length === 0) {
        Column({ space: 8 }) {
          Text('\uD83D\uDCDD')
            .fontSize(40);

          Text('\u6682\u65E0\u5386\u53F2\u5BF9\u8BDD')
            .fontSize(14)
            .fontColor('#999999');

          Text('\u5F00\u59CB\u548cAI\u804A\u5929\u540E, \u5BF9\u8BDD\u8BB0\u5F55\u4F1A\u4FDD\u5B58\u5728\u6B64')
            .fontSize(12)
            .fontColor('#BBBBBB')
            .textAlign(TextAlign.Center);
        }
        .width('100%')
        .padding(40)
        .alignItems(HorizontalAlign.Center);
      } else {
        List({ space: 8 }) {
          ForEach(this.historyList, (item: AiChatHistoryItem) => {
            ListItem() {
              Row() {
                Column({ space: 4 }) {
                  Text(item.lastQuestion)
                    .fontSize(14)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });

                  Row({ space: 8 }) {
                    Text(item.messageCount + '\u6761\u6D88\u606F')
                      .fontSize(11)
                      .fontColor('#999999');

                    Text(this.formatDateShort(item.updateTime))
                      .fontSize(11)
                      .fontColor('#999999');
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);

                Text('\u27A1')
                  .fontSize(16)
                  .fontColor('#1677FF');
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor('#FFFFFF')
              .borderRadius(10)
              .shadow({ radius: 2, color: '#00000008', offsetX: 0, offsetY: 1 })
              .onClick(() => {
                this.continueConversation(item);
              });
            }
          }, (item: AiChatHistoryItem) => String(item.id));
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 12, right: 12, bottom: 8 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFBFC');
  }

  formatDateShort(dateStr: string): string {
    if (!dateStr) return '';
    const date: Date = new Date(dateStr);
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    return '' + month + '-' + day;
  }

  @Builder
  EmptyState() {
    Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
      // 渐变头部
      Stack({ alignContent: Alignment.BottomStart }) {
        Column()
          .width('100%')
          .height(180)
          .linearGradient({
            angle: 135,
            colors: [['#1677FF', 0], ['#36CFC9', 1]]
          })
          .borderRadius({ topLeft: 20, topRight: 20, bottomLeft: 16, bottomRight: 16 });

        Column({ space: 8 }) {
          Text('\uD83E\uDDD0')
            .fontSize(48)
            .margin({ bottom: 4 });
          Text('AI 健康顾问')
            .fontSize(24)
            .fontWeight('bold')
            .fontColor('#FFFFFF');
          Text('智能健康问答助手，随时为您解答')
            .fontSize(13)
            .fontColor('#FFFFFFBB');
        }
        .width('100%')
        .padding({ left: 28, right: 20, bottom: 24 })
        .alignItems(HorizontalAlign.Start);
      }
      .width('90%')
      .margin({ top: 16, bottom: 20 });

      // 推荐问题卡片
      Column({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
        ForEach(this.suggestedQuestions.slice(0, 3), (question: SuggestedQuestion) => {
          Row({ space: 10 }) {
            Text(question.icon)
              .fontSize(18);

            Text(question.question)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#333333')
              .layoutWeight(1);
            Text('›')
              .fontSize(16)
              .fontColor('#CCCCCC');
          }
          .width('100%')
          .padding({ left: 16, right: 14, top: 14, bottom: 14 })
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
          .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
          .onClick(() => {
            this.handleSuggestionClick(question.question);
          });
        }, (question: SuggestedQuestion) => question.id);

        // 更多问题入口
        Row() {
          Text('查看更多问题')
            .fontSize(13)
            .fontColor('#1677FF');
          Text(' ›')
            .fontSize(13)
            .fontColor('#1677FF');
        }
        .width('100%')
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F0F7FF')
        .borderRadius(12)
        .onClick(() => {
          this.showSuggestions = true;
        });
      }
      .width('85%');

      Blank();
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  SuggestionPanel() {
    Scroll() {
      Column({ space: 8 }) {
        Text('\u5E38\u89C1\u95EE\u9898')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#666666')
          .margin({ left: 16, top: 8, bottom: 4 });

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.suggestedQuestions, (question: SuggestedQuestion) => {
            Text(question.question)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#1677FF')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor('#E6F4FF')
              .borderRadius(16)
              .margin(4)
              .onClick(() => {
                this.handleSuggestionClick(question.question);
              });
          }, (question: SuggestedQuestion) => question.id);
        }
        .padding({ left: 12, right: 12, bottom: 8 });
      }
    }
    .width('100%')
    .height(120)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: '#00000006', offsetX: 0, offsetY: -2 });
  }

  @Builder
  InputArea() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        TextInput({ text: this.inputText, placeholder: '\u8F93\u5165\u60A8\u7684\u5065\u5EBB\u95EE\u9898...' })
          .layoutWeight(1)
          .height(44)
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.inputText = value;
          })
          .onSubmit(() => {
            this.handleSendMessage();
          });

        if (this.inputText.trim()) {
          Text('\u53D1\u9001')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#FFFFFF')
            .width(64)
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor('#1677FF')
            .borderRadius(22)
            .onClick(() => {
              this.handleSendMessage();
            });
        } else {
          Column({ space: 2 }) {
            Text('\uD83C\uDFA4')
              .fontSize(20)
              .onClick(() => {
                this.startVoiceInput();
              });

            if (this.isRecording) {
              Text('\u25CF')
                .fontSize(10)
                .fontColor('#FF4D4F')
                .animation({
                  duration: 800,
                  iterations: -1,
                  curve: Curve.EaseInOut
                });
            }
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.isRecording ? '#FFF1F0' : '#F0F0F0')
          .borderRadius(22)
          .onClick(() => {
            this.startVoiceInput();
          });
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 });

      Text('AI\u56DE\u7B54\u53EA\u4F9B\u53C2\u8003, \u4E0D\u80FD\u66FF\u4EE3\u533B\u751F\u8BCA\u65AD')
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .fontColor('#BBBBBB')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 });
    }
    .width('100%')
    .backgroundColor('#FFFFFF');
  }
}

interface MarkdownSegment {
  type: 'text' | 'heading' | 'bold' | 'list' | 'warning' | 'divider';
  text: string;
}
