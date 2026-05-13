import { SettingsUtil } from './SettingsUtil';
import { http } from '@kit.NetworkKit';

export enum AuditAction {
  VIEW_PATIENT_LIST = 'VIEW_PATIENT_LIST',
  VIEW_PATIENT_DETAIL = 'VIEW_PATIENT_DETAIL',
  SEARCH_PATIENT = 'SEARCH_PATIENT',
  REFRESH_DATA = 'REFRESH_DATA'
}

export interface AuditLog {
  action: AuditAction;
  targetId?: string;
  targetName?: string;
  operatorId: string;
  operatorName: string;
  timestamp: number;
  details?: Record<string, Object>;
}

const AUDIT_LOG_URL = 'https://api.healthcare.com/api/v1/audit/logs';

export class AuditLogger {
  private static instance: AuditLogger | null = null;
  private logQueue: AuditLog[] = [];
  private isProcessing: boolean = false;

  private constructor() {}

  static getInstance(): AuditLogger {
    if (AuditLogger.instance === null) {
      AuditLogger.instance = new AuditLogger();
    }
    return AuditLogger.instance;
  }

  async logPatientListView(): Promise<void> {
    const log = await this.createAuditLog(AuditAction.VIEW_PATIENT_LIST);
    await this.addLog(log);
  }

  async logPatientDetailView(patientId: string, patientName: string): Promise<void> {
    const log = await this.createAuditLog(
      AuditAction.VIEW_PATIENT_DETAIL,
      patientId,
      patientName
    );
    await this.addLog(log);
  }

  async logSearchAction(keyword: string): Promise<void> {
    const log = await this.createAuditLog(AuditAction.SEARCH_PATIENT);
    const details: Record<string, Object> = {};
    details['keyword'] = keyword;
    log.details = details;
    await this.addLog(log);
  }

  async logRefreshAction(target: string): Promise<void> {
    const log = await this.createAuditLog(AuditAction.REFRESH_DATA);
    const details: Record<string, Object> = {};
    details['target'] = target;
    log.details = details;
    await this.addLog(log);
  }

  private async createAuditLog(
    action: AuditAction,
    targetId?: string,
    targetName?: string
  ): Promise<AuditLog> {
    const userInfo = await SettingsUtil.getInstance().getNurseInfo();
    const info = userInfo as Record<string, Object> || {};
    
    return {
      action: action,
      targetId: targetId,
      targetName: targetName,
      operatorId: (info['id'] as string) || 'unknown',
      operatorName: (info['name'] as string) || 'unknown',
      timestamp: Date.now()
    };
  }

  private async addLog(log: AuditLog): Promise<void> {
    this.logQueue.push(log);
    await this.processQueue();
  }

  private async processQueue(): Promise<void> {
    if (this.isProcessing || this.logQueue.length === 0) {
      return;
    }

    this.isProcessing = true;

    while (this.logQueue.length > 0) {
      const log = this.logQueue.shift();
      if (log) {
        await this.uploadLog(log);
      }
    }

    this.isProcessing = false;
  }

  private async uploadLog(log: AuditLog): Promise<void> {
    try {
      const token = await SettingsUtil.getInstance().getNurseToken();
      const httpRequest = http.createHttp();

      await httpRequest.request(AUDIT_LOG_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        extraData: JSON.stringify(log),
        connectTimeout: 5000,
        readTimeout: 5000
      });

      httpRequest.destroy();
    } catch (e) {
      console.error('AuditLogger - uploadLog failed:', e);
    }
  }
}
