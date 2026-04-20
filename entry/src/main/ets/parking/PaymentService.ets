/**
 * 支付服务封装
 * 
 * 核心职责：
 * 1. 停车费用支付（UI模拟）
 * 2. 支付记录管理
 * 3. 发票申请（模拟）
 */

export interface PaymentResult {
  success: boolean;
  paymentId?: string;
  transactionId?: string;
  amount: number;
  payTime?: string;
  message?: string;
}

export interface PaymentRecord {
  paymentId: string;
  recordId: string;              // 停车记录ID
  amount: number;
  payMethod: PayMethod;          // 支付方式
  status: PaymentStatus;         // 支付状态
  createTime: string;            // 支付时间
  transactionId?: string;        // 交易流水号
}

export enum PayMethod {
  WECHAT = 'WECHAT',             // 微信支付
  ALIPAY = 'ALIPAY',             // 支付宝
  UNION_PAY = 'UNION_PAY',       // 银联
  CASH = 'CASH'                  // 现金
}

export enum PaymentStatus {
  PENDING = 'PENDING',           // 待支付
  PAID = 'PAID',                 // 已支付
  REFUNDING = 'REFUNDING',      // 退款中
  REFUNDED = 'REFUNDED'          // 已退款
}

export class PaymentService {
  private static instance: PaymentService;
  private paymentRecords: Map<string, PaymentRecord> = new Map();

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): PaymentService {
    if (!PaymentService.instance) {
      PaymentService.instance = new PaymentService();
      console.log('[PaymentService] 创建单例实例');
    }
    return PaymentService.instance;
  }

  /**
   * 执行停车费支付（UI模拟，不真正调起支付）
   */
  async processPayment(
    recordId: string,
    amount: number,
    method: PayMethod = PayMethod.WECHAT
  ): Promise<PaymentResult> {
    try {
      console.log('[PaymentService] 开始处理支付...');
      console.log('  停车记录ID: ' + recordId);
      console.log('  支付金额: ¥' + amount.toFixed(2));
      console.log('  支付方式: ' + method);

      const loadingTime = Math.random() * 1000 + 1000;

      await new Promise(resolve => setTimeout(resolve, loadingTime));

      const isSuccess = Math.random() > 0.1;

      if (isSuccess) {
        const paymentId = 'PAY_' + Date.now();
        const transactionId = 'TXN_' + Date.now() + '_' + 
                              Math.random().toString(36).substr(2, 8).toUpperCase();

        const record: PaymentRecord = {
          paymentId: paymentId,
          recordId: recordId,
          amount: amount,
          payMethod: method,
          status: PaymentStatus.PAID,
          createTime: new Date().toISOString(),
          transactionId: transactionId
        };

        this.paymentRecords.set(paymentId, record);

        console.log('[PaymentService] 支付成功');
        return {
          success: true,
          paymentId: paymentId,
          transactionId: transactionId,
          amount: amount,
          payTime: new Date().toISOString(),
          message: '支付成功'
        };

      } else {
        console.warn('[PaymentService] 支付失败（模拟）');
        return {
          success: false,
          amount: amount,
          message: '支付失败，请重试'
        };
      }

    } catch (error) {
      console.error('[PaymentService] 支付异常:', error.message);
      return {
        success: false,
        amount: amount,
        message: '支付异常: ' + error.message
      };
    }
  }

  /**
   * 查询支付记录
   */
  getPaymentRecord(paymentId: string): PaymentRecord | null {
    return this.paymentRecords.get(paymentId) || null;
  }

  /**
   * 获取所有支付记录
   */
  getAllPaymentRecords(): PaymentRecord[] {
    return Array.from(this.paymentRecords.values());
  }

  /**
   * 申请发票（模拟）
   */
  async applyInvoice(
    paymentId: string,
    invoiceType: string,         // "PERSONAL" | "COMPANY"
    invoiceTitle?: string,       // 抬头（企业发票必填）
    taxNumber?: string           // 税号（企业发票必填）
  ): Promise<{ success: boolean; invoiceId?: string; message: string }> {
    try {
      console.log('[PaymentService] 申请发票...');
      
      const processingTime = Math.random() * 500 + 500;
      await new Promise(resolve => setTimeout(resolve, processingTime));

      const invoiceId = 'INV_' + Date.now();

      console.log('[PaymentService] 发票申请成功，ID: ' + invoiceId);
      return {
        success: true,
        invoiceId: invoiceId,
        message: '发票申请已提交，将在3个工作日内发送至您的邮箱'
      };

    } catch (error) {
      console.error('[PaymentService] 申请发票失败:', error.message);
      return {
        success: false,
        message: '申请失败: ' + error.message
      };
    }
  }

  /**
   * 获取支付方式显示名称
   */
  static getPayMethodName(method: PayMethod): string {
    switch (method) {
      case PayMethod.WECHAT:
        return '微信支付';
      case PayMethod.ALIPAY:
        return '支付宝';
      case PayMethod.UNION_PAY:
        return '银联支付';
      case PayMethod.CASH:
        return '现金支付';
      default:
        return '未知';
    }
  }

  /**
   * 获取支付状态显示名称
   */
  static getStatusName(status: PaymentStatus): string {
    switch (status) {
      case PaymentStatus.PENDING:
        return '待支付';
      case PaymentStatus.PAID:
        return '已支付';
      case PaymentStatus.REFUNDING:
        return '退款中';
      case PaymentStatus.REFUNDED:
        return '已退款';
      default:
        return '未知';
    }
  }
}
