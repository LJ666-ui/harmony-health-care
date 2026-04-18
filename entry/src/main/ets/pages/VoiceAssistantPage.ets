import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { Footer } from '../components/Footer';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';

export interface VoiceCommand {
  id: string;
  icon: string;
  title: string;
  keywords: string[];
  description: string;
  targetPage?: string;
  isEmergency?: boolean;
  reply: string;
  mode: 'health' | 'command';
}

export interface ChatMessage {
  id: string;
  type: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  isEmergency?: boolean;
  isVoice?: boolean;
}

export interface ConversationItem {
  role: string;
  content: string;
}

export interface ChatMode {
  id: string;
  name: string;
  icon: string;
  description: string;
}

@Entry
@Component
struct VoiceAssistantPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State currentModeIndex: number = 0;
  @State isRecording: boolean = false;
  @State recordStatus: string = '\u70B9\u51FB\u6216\u6309\u4F4F\u9EA6\u514B\u98CE\u5F00\u59CB\u8BF4\u8BDD';
  @State recognizedText: string = '';
  @State scaleValue: number = 1.0;
  @State rippleOpacity1: number = 0;
  @State rippleOpacity2: number = 0;
  @State rippleOpacity3: number = 0;
  @State chatMessages: ChatMessage[] = [];
  @State showEmergencyDialog: boolean = false;
  @State isTtsEnabled: boolean = true;
  @State isLoading: boolean = false;
  @State inputText: string = '';
  @State recordId: number = 0;

  private scroller: Scroller = new Scroller();
  private conversationHistory: ConversationItem[] = [];
  private retryCount: number = 0;
  private maxRetryCount: number = 3;

  @State chatModes: ChatMode[] = [
    { id: 'general', name: '\u901A\u7528\u95EE\u7B54', icon: '\uD83E\uDDE0', description: '\u5E38\u89C1\u5065\u5EBB\u95EE\u9898' },
    { id: 'consult', name: '\u5065\u5EBB\u54A8\u8BE2', icon: '\uD83D\uDC69\u200D\u2695\uFE0F', description: '\u75C7\u72B6\u63CF\u8FF0\u5206\u6790' },
    { id: 'risk', name: '\u98CE\u9669\u8BC4\u4F30', icon: '\uD83D\uDCCA', description: '\u62A5\u544A\u89E3\u8BFB' },
    { id: 'rehab', name: '\u5EB7\u590D\u6307\u5BFC', icon: '\uD83C\uDFCB', description: '\u5EB7\u590D\u8BAD\u7EC3\u5EFA\u8BAE' },
    { id: 'other', name: '\u5176\u4ED6', icon: '\uD83D\uDCAC', description: '\u81EA\u7531\u5BF9\u8BDD' }
  ];

  @State voiceCommands: VoiceCommand[] = [
    { id: '1', icon: '\uD83D\uDCCB', title: '\u6302\u53F7/\u9884\u7EA6', keywords: ['\u6302\u53F7', '\u9884\u7EA6', '\u95E8\u8BCA'], description: '\u5FEB\u901F\u9884\u7EA6\u533B\u751F\u95E8\u8BCA', targetPage: 'pages/Appointments', reply: '\u5DF2\u4E3A\u60A8\u6253\u5F00\u9884\u7EA6\u9875\u9762, \u60A8\u53EF\u4EE5\u9009\u62E9\u533B\u751F\u548C\u65F6\u95F4\u8FDB\u884C\u9884\u7EA6.', mode: 'command' },
    { id: '2', icon: '\uD83D\uDDFA', title: '\u6253\u5F00AR\u5BFC\u22EA', keywords: ['\u5BFC\u22EA', '\u627E\u79D1\u5BA4', 'AR'], description: '\u667A\u80FD\u5BFC\u22EA\u5230\u79D1\u5BA4\u4F4D\u7F6E', targetPage: 'pages/ARNavigationPage', reply: '\u6B63\u5728\u542F\u52A8AR\u5BFC\u22EA, \u8BF7\u5C06\u624B\u673A\u5BF9\u51C6\u524D\u65B9, \u6211\u4F1A\u4E3A\u60A8\u6307\u5F15\u8DEF\u7EBF.', mode: 'command' },
    { id: '3', icon: '\uD83D\uDCCA', title: '\u67E5\u8BE2\u5065\u5EBB\u8BB0\u5F55', keywords: ['\u5065\u5EBB\u8BB0\u5F55', '\u67E5\u8BB0\u5F55', '\u5386\u53F2\u6570\u636E'], description: '\u67E5\u770B\u5386\u53F2\u5065\u5EBB\u6570\u636E', targetPage: 'pages/HealthRecords', reply: '\u5DF2\u4E3A\u60A8\u6253\u5F00\u5065\u5EBB\u8BB0\u5F55\u9875\u9762, \u60A8\u53EF\u4EE5\u67E5\u770B\u8840\u538B\u3001\u8840\u7CD6\u7B49\u5386\u53F2\u6570\u636E\u8D8B\u52BF\u56FE.', mode: 'command' },
    { id: '4', icon: '\uD83D\uDC8A', title: '\u8BBE\u7F6E\u7528\u836F\u63D0\u9192', keywords: ['\u7528\u836F', '\u5403\u836F', '\u836F\u7269'], description: '\u7BA1\u7406\u836F\u7269\u670D\u7528\u65F6\u95F4', targetPage: 'pages/Medications', reply: '\u7528\u836F\u63D0\u9192\u9875\u9762\u5DF2\u6253\u5F00, \u60A8\u53EF\u4EE5\u67E5\u770B\u4ECA\u65E5\u5F85\u670D\u7528\u7684\u836F\u7269\u5E76\u8BBE\u7F6E\u63D0\u9192\u65F6\u95F4.', mode: 'command' },
    { id: '5', icon: '\u26A0\uFE0F', title: '\u5065\u5EBB\u98CE\u9669\u8BC4\u4F30', keywords: ['\u98CE\u9669\u8BC4\u4F30', '\u98CE\u9669', '\u8BC4\u4F30'], description: '\u83B7\u53D6\u4E2A\u6027\u5316\u98CE\u9669\u62A5\u544A', targetPage: 'pages/RiskAssessmentPage', reply: '\u6B63\u5728\u4E3A\u60A8\u751F\u6210\u5065\u5EBB\u98CE\u9669\u8BC4\u4F30\u62A5\u544A, \u5305\u542B\u591A\u7EF4\u5EA6\u98CE\u9669\u5206\u6790.', mode: 'command' },
    { id: '6', icon: '\uD83C\uDFE5', title: '\u67E5\u627E\u9644\u8FD1\u533B\u9662', keywords: ['\u533B\u9662', '\u8BCA\u6240', '\u9644\u8FD1'], description: '\u641C\u7D22\u5468\u8FB9\u533B\u7597\u673A\u6784', targetPage: 'pages/HospitalPage', reply: '\u5DF2\u4E3A\u60A8\u641C\u7D22\u9644\u8FD1\u533B\u9662, \u6309\u8DDD\u79BB\u6392\u5E8F, \u60A8\u53EF\u4EE5\u6839\u636E\u9700\u8981\u9009\u62E9\u5C31\u8BCA\u533B\u9662.', mode: 'command' },
    { id: '7', icon: '\uD83E\uDDD8', title: '\u5EB7\u590D\u8BAD\u7EC3', keywords: ['\u5EB7\u590D', '\u8BAD\u7EC3', '\u8FD0\u52A8'], description: '\u8FDB\u5165\u5EB7\u590D\u8BFE\u7A0B\u5217\u8868', targetPage: 'pages/RehabListPage', reply: '\u5EB7\u590D\u8BFE\u7A0B\u5217\u8868\u5DF2\u6253\u5F00, \u63A8\u8350\u60A8\u4ECE\u9888\u697C\u5EB7\u590D\u8BAD\u7EC3\u5F00\u59CB, \u9002\u5408\u65E5\u5E38\u7EC3\u4E60.', mode: 'command' },
    { id: '8', icon: '\uD83D\uDCD6', title: '\u9605\u8BFB\uD55C\u666E\u6587\u7AE0', keywords: ['\uD55C\u666E', '\u6587\u7AE0', '\u77E5\u8BC6'], description: '\u6D4F\u89C8\u533B\u5B66\u77E5\u8BC6\u5E93', targetPage: 'pages/ScienceListPage', reply: '\uD55C\u666E\u6587\u7AE0\u5E93\u5DF2\u4E3A\u60A8\u6253\u5F00, \u6DB5\u76D6\u5FC3\u8840\u7BA1\u3001\u9AA8\u79D1\u3001\u8425\u517B\u5B66\u7B49\u591A\u4E2A\u9886\u57DF.', mode: 'command' },
    { id: '9', icon: '\u231A', title: '\u8FDE\u63A5\u8BBE\u5907', keywords: ['\u8BBE\u5907', '\u8FDE\u63A5', '\u914D\u5BF9'], description: '\u914D\u5BF9\u5065\u5EBB\u76D1\u6D4B\u8BBE\u5907', targetPage: 'pages/DeviceDiscoveryPage', reply: '\u8BBE\u5907\u53D1\u73B0\u9875\u9762\u5DF2\u6253\u5F00, \u8BF7\u5728\u9644\u8FD1\u641C\u7D22\u53EF\u8FDE\u63A5\u7684\u5065\u5EBB\u76D1\u6D4B\u8BBE\u5907.', mode: 'command' },
    { id: '10', icon: '\uD83D\uDD12', title: '\u9690\u79C1\u8BBE\u7F6E', keywords: ['\u9690\u79C1', '\u6743\u9650', '\u8BBE\u7F6E'], description: '\u7BA1\u7406\u6570\u636E\u8BBF\u95EE\u6743\u9650', targetPage: 'pages/PrivacyPage', reply: '\u9690\u79C1\u8BBE\u7F6E\u9875\u9762\u5DF2\u6253\u5F00, \u60A8\u53EF\u4EE5\u67E5\u770B\u548C\u7BA1\u7406\u60A8\u7684\u6570\u636E\u4F7F\u7528\u6743\u9650.', mode: 'command' },
    { id: '11', icon: '\uD83C\uDF98', title: '\u7D27\u6025\u6C42\u52A9', keywords: ['\u7D27\u6025', '\u6C42\u52A9', '120', '\u6551\u547D'], description: '\u4E00\u952E\u62E8\u6253120\u6025\u6551\u7535\u8BDD', isEmergency: true, reply: '\u68C0\u6D4B\u5230\u7D27\u6025\u6C42\u52A9\u6307\u4EE4! \u6B63\u5728\u4E3A\u60A8\u51C6\u5907\u62E8\u6253120\u6025\u6551\u7535\u8BDD...', mode: 'command' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    const storedMessages = AppStorage.get<ChatMessage[]>('voiceChatMessages');
    if (storedMessages && storedMessages.length > 0) {
      this.chatMessages = storedMessages;
    } else {
      this.addMessage('system', '\u6B22\u8FCE\u4F7F\u7528\u5C0F\u827A\u8BED\u97F3\u52A9\u624B!\n\n\uD83D\uDCAA \u4F7F\u7528\u63D0\u793A:\n\u2022 \u70B9\u51FB\u9EA6\u514B\u98CE\u6309\u94AE\u5F00\u59CB\u5F55\u97F3\n\u2022 \u8BF4\"\u8840\u538B\u9AD8\u600E\u4E48\u529E\"\u8FDB\u884C\u5065\u5EBB\u54A8\u8BE2\n\u2022 \u8BF4\"\u6253\u5F00\u5065\u5EBB\u8BB0\u5F55\"\u6267\u884C\u64CD\u4F5C\u6307\u4EE4\n\n\u8BF7\u95EE\u6709\u4EC0\u4E48\u53EF\u4EE5\u5E2E\u52A9\u60A8\u7684?');
    }
    BrowseTracker.recordStart('VOICE_ASSISTANT', 'PAGE', 8, '语音助手').then((id: number) => {
      this.recordId = id;
    });
  }

  aboutToDisappear(): void {
    if (this.recordId > 0) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  get currentMode(): ChatMode {
    return this.chatModes[this.currentModeIndex];
  }

  addMessage(type: 'user' | 'assistant' | 'system', content: string, isEmergency?: boolean, isVoice?: boolean): void {
    const message: ChatMessage = {
      id: Date.now().toString() + Math.random().toString(36).substring(2, 11),
      type,
      content,
      timestamp: Date.now(),
      isEmergency,
      isVoice
    };

    const newMessages: ChatMessage[] = [...this.chatMessages, message];
    this.chatMessages = newMessages;
    AppStorage.setOrCreate<ChatMessage[]>('voiceChatMessages', newMessages);

    setTimeout(() => {
      try {
        this.scroller.scrollEdge(Edge.Bottom);
      } catch (e) {
        console.error('scroll error:', e);
      }
    }, 100);
  }

  async startRecording(): Promise<void> {
    if (this.isRecording || this.isLoading) return;

    this.isRecording = true;
    this.recordStatus = '\u6B63\u5728\u8046\u542C...';
    this.recognizedText = '';
    this.scaleValue = 1.15;
    this.rippleOpacity1 = 0.6;
    this.retryCount = 0;

    setTimeout(() => {
      this.rippleOpacity2 = 0.4;
    }, 200);

    setTimeout(() => {
      this.rippleOpacity3 = 0.2;
    }, 400);

    await this.startDemoRecognition();
  }

  stopRecording(): void {
    if (!this.isRecording) return;

    this.isRecording = false;
    this.recordStatus = '\u5904\u7406\u4E2D...';
    this.scaleValue = 0.95;
    this.rippleOpacity1 = 0;
    this.rippleOpacity2 = 0;
    this.rippleOpacity3 = 0;

    if (this.recognizedText.trim()) {
      this.processRecognizedText(this.recognizedText.trim());
    } else {
      this.handleRecognitionFailure('\u672A\u68C0\u6D4B\u5230\u8BED\u97F3\u8F93\u5165, \u8BF7\u91CD\u8BD5');
    }
  }

  async startDemoRecognition(): Promise<void> {
    const demoPhrases: string[] = [
      '\u8840\u538B\u9AD8\u600E\u4E48\u529E',
      '\u6253\u5F00\u5065\u5EBB\u8BB0\u5F55',
      '\u67E5\u627E\u9644\u8FD1\u533B\u9662',
      '\u9884\u7EA6\u6302\u53F7',
      '\u8840\u7CD6\u6B63\u5E38\u503C\u662F\u591A\u5C11'
    ];

    const randomIndex: number = Math.floor(Math.random() * demoPhrases.length);
    const randomPhrase: string = demoPhrases[randomIndex];

    let displayText: string = '';
    for (let i = 0; i < randomPhrase.length; i++) {
      await new Promise<void>((resolve: () => void) => {
        setTimeout(() => {
          displayText += randomPhrase[i];
          this.recognizedText = displayText;
          this.recordStatus = `\u8BC6\u522B\u4E2D: ${displayText}...`;
          resolve();
        }, 150 + Math.random() * 100);
      });
    }

    this.recordStatus = `\u8BC6\u522B\u5B8C\u6210: ${randomPhrase}`;

    setTimeout(() => {
      this.stopRecording();
    }, 500);
  }

  handleRecognitionFailure(errorMsg: string): void {
    this.retryCount++;

    if (this.retryCount <= this.maxRetryCount) {
      this.addMessage('system', `\u274C \u8BC6\u522B\u5931\u8D25(${this.retryCount}/${this.maxRetryCount}): ${errorMsg}\n\u8BF7\u70B9\u51FB\u9EA6\u514B\u98CE\u91CD\u65B0\u5C1D\u8BD5`);
    } else {
      this.addMessage('system', `\u274C \u8FDE\u7EED${this.maxRetryCount}\u6B21\u8BC6\u522B\u5931\u8D25\n\n\u53EF\u80FD\u539F\u56E0:\n\u2022 \u9EA6\u514B\u98CE\u6743\u9650\u672A\u5F00\u542F\n\u2022 \u7F51\u7EDC\u8FDE\u63A5\u5F02\u5E38\n\u2022 \u8BF4\u8BDD\u58F0\u97F3\u592A\u5C0F\n\n\u5EFA\u8BAE:\n\u2022 \u68C0\u67E5\u9EA6\u514B\u98CE\u6743\u9650\u8BBE\u7F6E\n\u2022 \u5728\u5B89\u9759\u73AF\u5883\u91CD\u8BD5\n\u2022 \u6216\u4F7F\u7528\u6587\u5B57\u8F93\u5165\u4EE3\u66FF`);
      this.resetRecordingUI();
    }
  }

  resetRecordingUI(): void {
    this.isRecording = false;
    this.recordStatus = '\u70B9\u51FB\u6216\u6309\u4F4F\u9EA6\u514B\u98CE\u5F00\u59CB\u8BF4\u8BDD';
    this.scaleValue = 1.0;
    this.rippleOpacity1 = 0;
    this.rippleOpacity2 = 0;
    this.rippleOpacity3 = 0;
    this.recognizedText = '';
  }

  processRecognizedText(text: string): void {
    this.addMessage('user', text, false, true);

    const convItem: ConversationItem = { role: 'user', content: text };
    this.conversationHistory.push(convItem);

    const matchedCommand: VoiceCommand | undefined = this.matchCommand(text);

    if (matchedCommand !== undefined) {
      this.executeCommand(matchedCommand);
    } else {
      this.callAiForResponse(text);
    }
  }

  matchCommand(input: string): VoiceCommand | undefined {
    const lowerInput: string = input.toLowerCase();

    for (let i = 0; i < this.voiceCommands.length; i++) {
      const cmd: VoiceCommand = this.voiceCommands[i];
      const keywords: string[] = cmd.keywords;
      for (let j = 0; j < keywords.length; j++) {
        if (lowerInput.indexOf(keywords[j].toLowerCase()) >= 0) {
          return cmd;
        }
      }
    }

    return undefined;
  }

  executeCommand(command: VoiceCommand): void {
    if (command.isEmergency) {
      this.showEmergencyDialog = true;
      this.addMessage('assistant', command.reply, true);
      return;
    }

    this.isLoading = true;
    this.addMessage('assistant', command.reply);

    setTimeout(() => {
      this.isLoading = false;
      if (command.targetPage) {
        setTimeout(() => {
          try {
            router.pushUrl({ url: command.targetPage! });
          } catch (e) {
            console.error('\u8DEF\u7531\u8DF3\u8F6C\u5931\u8D25:', e);
            this.addMessage('system', '\u26A0\uFE0F \u9875\u9762\u8DF3\u8F6C\u5931\u8D25, \u8BF7\u624B\u52A8\u4ECE\u9996\u9875\u8FDB\u5165');
          }
        }, 800);
      }
    }, 500);
  }

  async callAiForResponse(question: string): Promise<void> {
    this.isLoading = true;
    this.addMessage('assistant', '\uD83E\uDD14 \u6B63\u5728\u601D\u8003\u4E2D...');

    try {
      const answer: string = await this.fetchAiResponse(question);
      this.updateLastAssistantMessage(answer);

      const convItem: ConversationItem = { role: 'assistant', content: answer };
      this.conversationHistory.push(convItem);

    } catch (error) {
      const errorMsg: string = error instanceof Error ? error.message : 'AI\u670D\u52A1\u6682\u65F6\u4E0D\u53EF\u7528';
      this.updateLastAssistantMessage(`\u62B1\u6B49, \u83B7\u53D6\u5065\u5EBB\u5EFA\u8BAE\u5931\u8D25: ${errorMsg}\n\n\u60A8\u53EF\u4EE5\u7A0D\u540E\u91CD\u8BD5, \u6216\u76F4\u63A5\u8054\u7CFB\u4E13\u4E1A\u533B\u751F\u54A8\u8BE2.`);
    } finally {
      this.isLoading = false;
    }
  }

  updateLastAssistantMessage(newContent: string): void {
    const messages: ChatMessage[] = [];
    for (let i = 0; i < this.chatMessages.length; i++) {
      if (i === this.chatMessages.length - 1 && this.chatMessages[i].type === 'assistant') {
        const updatedMsg: ChatMessage = {
          id: this.chatMessages[i].id,
          type: this.chatMessages[i].type,
          content: newContent,
          timestamp: this.chatMessages[i].timestamp,
          isEmergency: this.chatMessages[i].isEmergency,
          isVoice: this.chatMessages[i].isVoice
        };
        messages.push(updatedMsg);
      } else {
        messages.push(this.chatMessages[i]);
      }
    }
    this.chatMessages = messages;
    AppStorage.setOrCreate<ChatMessage[]>('voiceChatMessages', messages);
  }

  async fetchAiResponse(question: string): Promise<string> {
    try {
      const healthContext: string = this.buildHealthContext();

      let apiUrl: string = ApiConstants.AI_CHAT;
      const requestData: Record<string, Object> = {};
      requestData['question'] = question;
      requestData['context'] = healthContext;
      requestData['history'] = this.getHistoryArray();
      requestData['mode'] = this.currentMode.id;

      if (this.currentMode.id === 'consult') {
        apiUrl = ApiConstants.AI_CONSULT;
        requestData['symptoms'] = question;
        requestData['userContext'] = healthContext;
      }

      const response: BaseResponse<Record<string, Object>> = await HttpUtil.post<Record<string, Object>>(apiUrl, requestData);

      if (response.success && response.data) {
        const dataObj: Record<string, Object> = response.data;
        let content: string = dataObj['answer'] as string || dataObj['content'] as string || dataObj['reply'] as string || dataObj['advice'] as string || dataObj['result'] as string || '';

        if (!content && dataObj['message']) {
          content = dataObj['message'] as string;
        }

        if (this.currentMode.id === 'consult' || this.currentMode.id === 'risk') {
          const disclaimer: string = '\n\n---\n\u26A0\uFE0F **\u6E29\u99A8\u63D0\u793A**: \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u5982\u6709\u4E0D\u9002\u8BF7\u53CA\u65F6\u5C31\u533B.';
          content = content + disclaimer;
        }

        return content;
      } else {
        throw new Error(response.message ? response.message : '\u670D\u52A1\u5668\u8FD4\u56DE\u9519\u8BEF');
      }
    } catch (e) {
      console.error('Fetch AI Response Error:', e);
      return this.getMockAnswer(question);
    }
  }

  getMockAnswer(question: string): string {
    const mockAnswers: Record<string, string> = {
      '\u8840\u538B': '\u5173\u4E8E\u8840\u538B\u95EE\u9898:\n\n\u2705 **\u6210\u4EBA\u6B63\u5E38\u8840\u538B\u8303\u56F4:**\n\u2022 \u6536\u7F29\u538B(\u9AD8\u538B): 90-139 mmHg\n\u2022 \u8212\u5F20\u538B(\u4F4E\u538B): 60-89 mmHg\n\n\uD83D\uDCAA **\u9AD8\u8840\u538B\u5EFA\u8BAE:**\n1. \u4F4E\u76D0\u996E\u98DF(\u65E5\u5E38<5g\u76D0)\n2. \u89C4\u5F8B\u8FD0\u52A8(\u6BCF\u5468150\u5206\u949F)\n3. \u63A7\u5236\u4F53\u91CD(BMI 18.5-24)\n4. \u6212\u70DF\u9650\u9152\n5. \u5B9A\u671F\u76D1\u6D4B\u8840\u538B',
      '\u8840\u7CD6': '\u5173\u4E8E\u8840\u7CD6\u95EE\u9898:\n\n\u2705 **\u6B63\u5E38\u8840\u7CD6\u53C2\u8003\u503C:**\n\u2022 \u7A7A\u8179\u8840\u7CD6: 3.9-6.1 mmol/L\n\u2022 \u996D\u540E2\u5C0F\u65F6: <7.8 mmol/L\n\n\uD83D\uDCAA **\u7CD6\u5C3F\u75C5\u9884\u9632:**\n1. \u63A7\u5236\u78B3\u6C34\u6444\u5165\n2. \u589E\u52A0\u86CB\u767D\u7EA4\u7EF4\n3. \u89C4\u5F8B\u8FD0\u52A8\n4. \u4FDD\u6301\u5065\u5EBB\u4F53\u91CD',
      'default': '\u611F\u8C22\u60A8\u7684\u5065\u5EBB\u63D0\u95EE!\n\n\u57FA\u4E8E\u60A8\u7684\u63CF\u8FF0, \u6211\u5EFA\u8BAE:\n\n1. \uD83D\uDCCB **\u89C2\u5BDF\u75C7\u72B6\u53D8\u5316** - \u8BB0\u5F55\u51FA\u73B0\u7684\u65F6\u95F4\u548C\u9891\u7387\n2. \uD83D\uDC8A **\u4FDD\u6301\u826F\u597D\u4F5C\u606F** - \u5145\u8DB3\u7761\u7720, \u89C4\u5F8B\u996E\u98DF\n3. \uD83C\uDFCB **\u9002\u5EA6\u6D3B\u52A8** - \u6BCF\u592930\u5206\u949F\n4. \u26A0\uFE0F **\u53CA\u65F6\u5C31\u533B** - \u5982\u75C7\u72B6\u6301\u7EED\u6216\u52A0\u91CD'
    };

    let mockAnswer: string = mockAnswers['default'];
    const keys: string[] = Object.keys(mockAnswers);
    for (let i = 0; i < keys.length; i++) {
      if (question.indexOf(keys[i]) >= 0) {
        mockAnswer = mockAnswers[keys[i]];
        break;
      }
    }

    const disclaimer: string = '\n\n---\n\u26A0\uFE0F **\u6E29\u99A8\u63D0\u793A**: \u4EE5\u4E0A\u5EFA\u8BAE\u53EA\u4F9B\u53C2\u8003, \u5982\u6709\u4E0D\u9002\u8BF7\u53CA\u65F6\u5C31\u533B.';
    return mockAnswer + disclaimer;
  }

  getHistoryArray(): ConversationItem[] {
    const result: ConversationItem[] = [];
    const startIndex: number = Math.max(0, this.conversationHistory.length - 10);
    for (let i = startIndex; i < this.conversationHistory.length; i++) {
      result.push(this.conversationHistory[i]);
    }
    return result;
  }

  buildHealthContext(): string {
    let context: string = '\u7528\u623B\u57FA\u672C\u4FE1\u606F: ';

    try {
      const userInfo: object | undefined = AppStorage.get<object>('userInfo');
      if (userInfo) {
        const user: Record<string, Object> = userInfo as Record<string, Object>;
        if (user['age']) {
          context += `\n\u5E74\u9F84: ${user['age']}`;
        }
        if (user['gender']) {
          context += `\n\u6027\u522B: ${user['gender']}`;
        }
        if (user['allergies']) {
          context += `\n\u8FC7\u654F\u53F2: ${JSON.stringify(user['allergies'])}`;
        }
      }
    } catch (error) {
      console.error('\u6784\u5EFA\u5065\u5EBB\u4E0A\u4E0B\u6587\u5931\u8D25:', error);
    }

    return context;
  }

  switchMode(index: number): void {
    if (index < 0 || index >= this.chatModes.length) return;
    this.currentModeIndex = index;
    ToastUtil.showInfo(`\u5DF2\u5207\u6362\u81F3${this.currentMode.name}`);
  }

  handleEmergencyCall(): void {
    ToastUtil.emergencyCall();
    this.showEmergencyDialog = false;

    setTimeout(() => {
      this.addMessage('assistant', '\u5DF2\u4E3A\u60A8\u6A21\u62DF\u62E8\u6253120\u6025\u6551\u7535\u8BDD. \u8BF7\u6CE8\u610F: \u8FD9\u662F\u6A21\u62DF\u529F\u80FD, \u771F\u5B9E\u7D27\u6025\u60C5\u51B5\u8BF7\u76F4\u63A5\u62E8\u6255120.');
    }, 2000);
  }

  clearChatHistory(): void {
    this.chatMessages = [];
    this.conversationHistory = [];
    AppStorage.setOrCreate<ChatMessage[]>('voiceChatMessages', []);
    this.resetRecordingUI();
    this.addMessage('system', '\u5BF9\u8BDD\u5386\u53F2\u5DF2\u6E05\u7A7A. \u6709\u4EC0\u4E48\u6211\u53EF\u4EE5\u5E2E\u52A9\u60A8\u7684?');
  }

  build() {
    Column() {
      Row() {
        Text('\u2190')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          });

        Text('\u5C0F\u827A\u8BED\u97F3\u52A9\u624B')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('\uD83D\uDDD1')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#999999')
          .margin({ right: 16 })
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
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center);

      Scroll(this.scroller) {
        Column({ space: 8 }) {
          ForEach(this.chatMessages, (message: ChatMessage) => {
            if (message.type === 'system') {
              Column() {
                Text(message.content)
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#666666')
                  .lineHeight(this.isElderMode ? 22 : 18)
                  .padding(12)
                  .backgroundColor('#F0F5FF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#D4E3FF' });
              }
              .width('92%')
              .alignItems(HorizontalAlign.Center)
              .margin({ top: 8 });
            } else if (message.type === 'user') {
              Row() {
                Blank();
                Column({ space: 4 }) {
                  Row({ space: 4 }) {
                    if (message.isVoice) {
                      Text('\uD83C\uDFA4')
                        .fontSize(12)
                        .fontColor('#1677FF');
                    }
                    Text(message.content)
                      .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                      .fontColor('#FFFFFF');
                  }
                  .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                  .backgroundColor('#1677FF')
                  .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4 })
                  .constraintSize({ maxWidth: '75%' });

                  Text(this.formatTime(message.timestamp))
                    .fontSize(10)
                    .fontColor('#CCCCCC')
                    .margin({ right: 4 });
                }
                .alignItems(HorizontalAlign.End);
              }
              .width('100%')
              .padding({ right: 12 });
            } else {
              Row() {
                Column({ space: 6 }) {
                  Row({ space: 4 }) {
                    Text('\uD83E\uDD16')
                      .fontSize(16);

                    Text(message.content)
                      .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                      .fontColor('#333333')
                      .lineHeight(20)
                      .layoutWeight(1);
                  }
                  .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                  .backgroundColor('#F5F5F5')
                  .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 })
                  .constraintSize({ maxWidth: '82%' });

                  Text(this.formatTime(message.timestamp))
                    .fontSize(10)
                    .fontColor('#CCCCCC')
                    .margin({ left: 4 });
                }
                .alignItems(HorizontalAlign.Start);
                Blank();
              }
              .width('100%')
              .padding({ left: 12 });
            }
          }, (message: ChatMessage) => message.id);
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);

      this.ModeSelector();

      this.VoiceInputArea();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  ModeSelector() {
    Column({ space: 8 }) {
      Text('\u5BF9\u8BDD\u6A21\u5F0F')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#666666')
        .margin({ left: 16, top: 8 });

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.chatModes, (mode: ChatMode, index: number) => {
            Column({ space: 4 }) {
              Text(mode.icon)
                .fontSize(18);

              Text(mode.name)
                .fontSize(10)
                .fontColor(this.currentModeIndex === index ? '#1677FF' : '#666666')
                .fontWeight(this.currentModeIndex === index ? FontWeight.Bold : FontWeight.Normal);
            }
            .width(64)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.currentModeIndex === index ? '#E6F4FF' : '#FFFFFF')
            .borderRadius(10)
            .border(this.currentModeIndex === index ? { width: 1.5, color: '#1677FF' } : { width: 0, color: 'transparent' })
            .shadow({ radius: 2, color: '#00000008', offsetX: 0, offsetY: 1 })
            .onClick(() => {
              this.switchMode(index);
            });
          }, (mode: ChatMode, index: number) => mode.id + String(index));
        }
        .padding({ left: 12, right: 12, bottom: 6 });
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%');
    }
    .width('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  VoiceInputArea() {
    Column({ space: 10 }) {
      Text(this.recordStatus)
        .fontSize(13)
        .fontColor(this.isRecording ? '#1677FF' : '#999999')
        .textAlign(TextAlign.Center)
        .width('100%');

      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(130)
          .height(130)
          .fill(this.isRecording ? '#E6F4FF' : '#F0F0F0');

        if (this.isRecording) {
          Circle()
            .width(110)
            .height(110)
            .fill('#BBE4FF')
            .opacity(this.rippleOpacity1);

          Circle()
            .width(90)
            .height(90)
            .fill('#8ECFFF')
            .opacity(this.rippleOpacity2);

          Circle()
            .width(70)
            .height(70)
            .fill('#52C41A')
            .scale({ x: this.scaleValue, y: this.scaleValue });
        } else {
          Circle()
            .width(70)
            .height(70)
            .fill('#1677FF');
        }

        Text(this.isRecording ? '\u26A1' : '\uD83C\uDFA4')
          .fontSize(28)
          .fontColor('#FFFFFF')
      }
      .width(130)
      .height(130)
      .onClick(() => {
        if (!this.isRecording) {
          this.startRecording();
        } else {
          this.stopRecording();
        }
      })
      .gesture(
        LongPressGesture()
          .onAction(() => {
            if (!this.isRecording) {
              this.startRecording();
            }
          })
      );

      Row({ space: 12 }) {
        TextInput({
          text: this.inputText ?? '',
          placeholder: '\u6216\u8F93\u5165\u6587\u5B57...'
        })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.inputText = value;
            this.recognizedText = value;
          })
          .onSubmit(() => {
            if (this.inputText.trim()) {
              this.stopRecording();
              this.processRecognizedText(this.inputText.trim());
              this.inputText = '';
              this.recognizedText = '';
            }
          });

        Text('\u53D1\u9001')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(60)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#1677FF')
          .borderRadius(20)
          .onClick(() => {
            if (this.recognizedText.trim()) {
              this.processRecognizedText(this.recognizedText.trim());
              this.recognizedText = '';
            }
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16 });

      Text('\u6309\u4F4F\u9EA6\u514B\u98CE\u8BF4\u8BDD, \u677E\u5F00\u7ED3\u675F\u5F55\u97F3')
        .fontSize(11)
        .fontColor('#BBBBBB')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 8 });
    }
    .width('100%')
    .padding({ top: 10, bottom: 6 })
    .backgroundColor('#FFFFFF');
  }

  formatTime(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const hours: string = date.getHours().toString().padStart(2, '0');
    const minutes: string = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
}
