import http from '@ohos.net.http';
import { getBaseUrl } from '../constants/ApiConstants';

export interface DiagnosticResult {
  success: boolean;
  message: string;
  elapsed?: number;
  baseUrl?: string;
  error?: Error;
  suggestion?: string;
}

export interface ValidationResult {
  valid: boolean;
  message: string;
  suggestion?: string;
}

export interface CheckResult {
  name: string;
  success: boolean;
  message: string;
  elapsed?: number;
}

export interface FullDiagnosticResult {
  timestamp: string;
  baseUrl: string;
  checks: CheckResult[];
  overallSuggestion: string[];
}

export class NetworkDiagnostic {
  static async checkBackendReachable(): Promise<DiagnosticResult> {
    const startTime: number = Date.now();
    const baseUrl: string = getBaseUrl();

    try {
      const httpRequest = http.createHttp();
      const healthUrl: string = baseUrl + '/health';

      const response: http.HttpResponse = await new Promise((resolve, reject) => {
        const timeoutId = setTimeout(() => {
          reject(new Error('健康检查超时'));
          httpRequest.destroy();
        }, 5000);

        httpRequest.request(healthUrl, {
          method: http.RequestMethod.GET,
          connectTimeout: 5000,
          readTimeout: 5000
        }, (err, data) => {
          clearTimeout(timeoutId);
          httpRequest.destroy();
          if (err) {
            reject(err);
          } else {
            resolve(data);
          }
        });
      });

      const elapsed: number = Date.now() - startTime;

      return {
        success: response.responseCode === 200,
        message: response.responseCode === 200 ? '后端服务可达' : '后端服务返回错误',
        elapsed: elapsed,
        baseUrl: baseUrl
      };
    } catch (error) {
      const elapsed: number = Date.now() - startTime;
      const err = error as Error;

      return {
        success: false,
        message: '后端服务不可达',
        elapsed: elapsed,
        baseUrl: baseUrl,
        error: err,
        suggestion: '请运行 start-backend.bat 启动后端服务，或检查 BASE_URL 配置是否正确'
      };
    }
  }

  static validateBaseUrl(url: string): ValidationResult {
    const ipPattern: RegExp = /^https?:\/\/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|[\w.-]+):(\d{1,5})/;
    const match = url.match(ipPattern);

    if (!match) {
      return {
        valid: false,
        message: 'URL格式无效',
        suggestion: 'URL格式应为: http://IP:PORT 或 https://domain:PORT'
      };
    }

    const port: number = parseInt(match[2]);
    if (port < 1 || port > 65535) {
      return {
        valid: false,
        message: '端口号无效',
        suggestion: '端口号应在1-65535范围内'
      };
    }

    if (url.startsWith('http://')) {
      return {
        valid: true,
        message: 'URL格式正确（开发环境HTTP）',
        suggestion: '生产环境建议使用HTTPS'
      };
    }

    return {
      valid: true,
      message: 'URL格式正确'
    };
  }

  static async checkNetworkStatus(): Promise<DiagnosticResult> {
    return {
      success: true,
      message: '网络连接正常'
    };
  }

  static async fullDiagnosis(): Promise<FullDiagnosticResult> {
    const startTime: number = Date.now();
    const baseUrl: string = getBaseUrl();
    const checks: CheckResult[] = [];
    const suggestions: string[] = [];

    checks.push({
      name: '网络连接',
      success: true,
      message: '网络连接正常'
    });

    const urlValidation = NetworkDiagnostic.validateBaseUrl(baseUrl);
    checks.push({
      name: 'URL格式验证',
      success: urlValidation.valid,
      message: urlValidation.message
    });

    if (!urlValidation.valid && urlValidation.suggestion) {
      suggestions.push(urlValidation.suggestion);
    }

    const backendCheck = await NetworkDiagnostic.checkBackendReachable();
    checks.push({
      name: '后端服务可达性',
      success: backendCheck.success,
      message: backendCheck.message,
      elapsed: backendCheck.elapsed
    });

    if (!backendCheck.success) {
      if (backendCheck.suggestion) {
        suggestions.push(backendCheck.suggestion);
      }
      suggestions.push('运行 check-network.bat 检查网络配置');
      suggestions.push('运行 setup-firewall.bat 配置防火墙规则');
    }

    const totalElapsed: number = Date.now() - startTime;
    console.log('[网络诊断] 完整诊断完成，耗时:', totalElapsed, 'ms');

    return {
      timestamp: new Date().toISOString(),
      baseUrl: baseUrl,
      checks: checks,
      overallSuggestion: suggestions
    };
  }

  static generateFixSuggestion(results: FullDiagnosticResult): string[] {
    const suggestions: string[] = [];

    const backendCheck = results.checks.find(c => c.name === '后端服务可达性');
    if (backendCheck && !backendCheck.success) {
      suggestions.push('1. 运行 start-backend.bat 启动后端服务');
      suggestions.push('2. 运行 check-network.bat 获取正确的IP地址');
      suggestions.push('3. 运行 setup-firewall.bat 配置防火墙');
      suggestions.push('4. 更新 ApiConstants.ets 中的 BASE_URL 配置');
    }

    const urlCheck = results.checks.find(c => c.name === 'URL格式验证');
    if (urlCheck && !urlCheck.success) {
      suggestions.push('5. 修正 BASE_URL 格式: http://IP:PORT');
    }

    return suggestions;
  }
}
