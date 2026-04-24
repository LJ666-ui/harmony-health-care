/**
 * 医疗报告相关类型定义
 * 包含报告类型、报告文档、导出格式等数据结构
 */

/**
 * 报告类型枚举
 */
export enum ReportType {
  CONSULTATION = 'consultation',     // 就诊建议
  MEDICATION = 'medication',         // 用药指导
  REHABILITATION = 'rehabilitation'  // 康复方案
}

/**
 * 导出格式枚举
 */
export enum ExportFormat {
  MARKDOWN = 'markdown',
  PDF = 'pdf',
  HTML = 'html'
}

/**
 * 报告章节
 */
export interface ReportSection {
  title: string;               // 章节标题
  content: string;             // 章节内容
  order: number;               // 排序
}

/**
 * 医疗报告
 */
export interface MedicalReport {
  reportId: string;            // 报告ID
  reportType: ReportType;      // 报告类型
  userId: string;              // 用户ID
  sessionId: string;           // 会话ID
  title: string;               // 报告标题
  content: string;             // 报告内容（Markdown格式）
  sections?: ReportSection[];  // 报告章节
  createdAt: number;           // 生成时间
  expireAt: number;            // 过期时间
  metadata?: ReportMetadata;   // 元数据
}

/**
 * 报告元数据
 */
export interface ReportMetadata {
  generatedBy: string[];       // 生成的智能体列表
  knowledgeSources: string[];  // 知识来源
  disclaimer: string;          // 免责声明
  version: string;             // 版本号
}

/**
 * 导出文件
 */
export interface ExportFile {
  filename: string;            // 文件名
  content: string;             // 文件内容
  mimeType: string;            // MIME类型
  size: number;                // 文件大小（字节）
  format: ExportFormat;        // 导出格式
}

/**
 * 报告生成请求
 */
export interface ReportGenerateRequest {
  sessionId: string;           // 会话ID
  reportType: ReportType;      // 报告类型
  format: ExportFormat;        // 导出格式
  includeKnowledge?: boolean;  // 是否包含知识引用
  customSections?: ReportSection[];  // 自定义章节
}

/**
 * 报告模板
 */
export interface ReportTemplate {
  type: ReportType;            // 报告类型
  title: string;               // 模板标题
  sections: ReportSection[];   // 章节模板
  disclaimer: string;          // 免责声明
}
