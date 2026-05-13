import { textToSpeech } from '@kit.CoreSpeechKit';

export interface TTSConfig {
  language: string;
  speed: number;
  volume: number;
  pitch: number;
}

export type TTSCallback = (event: 'start' | 'finish' | 'error', data?: string) => void;

interface TTSSpeakListener {
  onStart?: (requestId: string, response: textToSpeech.StartResponse) => void;
  onComplete?: (requestId: string, response: textToSpeech.CompleteResponse) => void;
  onStop?: (requestId: string, response: textToSpeech.StopResponse) => void;
  onError?: (requestId: string, errorCode: number, errorMessage: string) => void;
}

export class TTSService {
  private static instance: TTSService | null = null;

  private ttsEngine: textToSpeech.TextToSpeechEngine | null = null;
  private isSpeaking: boolean = false;
  private config: TTSConfig;
  private initialized: boolean = false;
  private currentCallback: TTSCallback | undefined;

  private constructor() {
    this.config = {
      language: 'zh-CN',
      speed: 1.0,
      volume: 1.0,
      pitch: 1.0
    };
    console.log('[TTSService] 初始化');
  }

  static getInstance(): TTSService {
    if (!TTSService.instance) {
      TTSService.instance = new TTSService();
    }
    return TTSService.instance;
  }

  async initialize(): Promise<boolean> {
    try {
      console.log('[TTSService] 正在初始化TTS引擎...');

      this.ttsEngine = await textToSpeech.createEngine({
        language: this.config.language,
        online: 1,
        person: 0
      });

      const listener: TTSSpeakListener = {
        onStart: (_requestId: string, _response: textToSpeech.StartResponse) => {
          console.log('[TTSService] 🎤 开始播报');
          this.isSpeaking = true;
        },
        onComplete: (_requestId: string, _response: textToSpeech.CompleteResponse) => {
          console.log('[TTSService] ✅ 播报完成');
          this.isSpeaking = false;
          this.currentCallback?.('finish');
        },
        onStop: (_requestId: string, _response: textToSpeech.StopResponse) => {
          console.log('[TTSService] ⏹️ 播报已停止');
          this.isSpeaking = false;
        },
        onError: (_requestId: string, errorCode: number, errorMessage: string) => {
          console.error('[TTSService] ❌ 播报错误:', errorCode, errorMessage);
          this.isSpeaking = false;
          this.currentCallback?.('error', errorMessage);
        }
      };

      this.ttsEngine.setListener(listener as textToSpeech.SpeakListener);

      this.initialized = true;
      console.log('[TTSService] ✅ TTS引擎初始化成功');
      return true;
    } catch (e) {
      console.error('[TTSService] ❌ TTS引擎初始化失败，使用模拟模式:', e);
      this.initialized = false;
      return true;
    }
  }

  async speak(text: string, callback?: TTSCallback): Promise<void> {
    if (!text || text.trim().length === 0) return;

    const cleanText = this.cleanTextForTTS(text);

    if (this.isSpeaking) {
      this.stop();
    }

    this.currentCallback = callback;
    callback?.('start');

    try {
      if (this.ttsEngine && this.initialized) {
        this.speakWithEngine(cleanText);
      } else {
        await this.simulateSpeak(cleanText, callback);
      }
    } catch (error) {
      this.isSpeaking = false;
      console.error('[TTSService] 播报异常:', error);
      callback?.('error', String(error));
    }
  }

  private speakWithEngine(text: string): void {
    if (!this.ttsEngine || !this.initialized) {
      throw new Error('TTS引擎未初始化');
    }

    console.log('[TTSService] 🔊 开始语音播报:', text.substring(0, 80) + '...');

    this.isSpeaking = true;

    this.ttsEngine.speak(text, {
      requestId: 'tts_' + Date.now().toString(),
      extraParams: {
        speed: this.config.speed,
        volume: this.config.volume,
        pitch: this.config.pitch
      }
    });
  }

  stop(): void {
    if (this.isSpeaking && this.ttsEngine) {
      try {
        this.ttsEngine.stop();
        console.log('[TTSService] ⏹️ 停止播报');
      } catch (e) {
        console.error('[TTSService] 停止失败:', e);
      }
    }
    this.isSpeaking = false;
  }

  getIsSpeaking(): boolean {
    return this.isSpeaking;
  }

  setSpeed(speed: number): void {
    this.config.speed = Math.max(0.5, Math.min(2.0, speed));
  }

  setVolume(volume: number): void {
    this.config.volume = Math.max(0.0, Math.min(2.0, volume));
  }

  setLanguage(language: string): void {
    this.config.language = language;
  }

  private cleanTextForTTS(text: string): string {
    let cleaned = text
      .replace(/[#*_~`>\[\]()|]/g, '')
      .replace(/\*\*([^*]+)\*\*/g, '$1')
      .replace(/\n{3,}/g, '\n\n')
      .replace(/[🎉🤖⏱️📋🍎💊🏃⚠️🔴✅❌🌊🧪📦🧠💡]/g, '')
      .trim();

    cleaned = cleaned.replace(/^\d+\.\s*/gm, '');
    cleaned = cleaned.replace(/^[-•·]\s*/gm, '');

    return cleaned;
  }

  private async simulateSpeak(text: string, callback?: TTSCallback): Promise<void> {
    console.log('[TTSService] 🗣️ 模拟模式播报:', text.substring(0, 60) + '...');

    this.isSpeaking = true;

    const charsPerSecond = 8 / this.config.speed;
    const totalDuration = Math.min(Math.max(text.length / charsPerSecond * 1000, 1000), 30000);

    await new Promise(resolve => setTimeout(resolve, totalDuration));

    if (this.isSpeaking) {
      this.isSpeaking = false;
      console.log('[TTSService] ✅ 模拟播报完成');
      callback?.('finish');
    }
  }

  destroy(): void {
    this.stop();
    if (this.ttsEngine) {
      try {
        this.ttsEngine.shutdown();
        this.ttsEngine = null;
      } catch (e) {
        console.error('[TTSService] 销毁失败:', e);
      }
    }
    this.initialized = false;
  }
}

export const ttsService = TTSService.getInstance();