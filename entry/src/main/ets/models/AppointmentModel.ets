export class AppointmentItem {
  id: number = 0;
  doctorId: number = 0;
  userId: number = 0;
  scheduleDate: string = '';
  schedulePeriod: number = 0;
  appointmentNo: string = '';
  fee: number = 0;
  status: number = 0;
  reason: string = '';
  createTime: string = '';
  updateTime: string = '';

  doctorName: string = '';
  hospitalName: string = '';
  departmentName: string = '';
  title: string = '';
  payStatus: number = 0;
  outTradeNo: string = '';

  static getStatusText(status: number): string {
    const map: Record<number, string> = {
      0: '待就诊',
      1: '已就诊',
      2: '已取消',
      3: '已过期'
    };
    return map[status] || '未知';
  }

  static getStatusColor(status: number): string {
    const map: Record<number, string> = {
      0: '#1677FF',
      1: '#52C41A',
      2: '#999999',
      3: '#FF4D4F'
    };
    return map[status] || '#999999';
  }

  static getPeriodText(period: number): string {
    const map: Record<number, string> = {
      1: '上午',
      2: '下午',
      3: '晚上'
    };
    return map[period] || '';
  }

  static getPeriodTimeRange(period: number): string {
    const map: Record<number, string> = {
      1: '08:00 - 12:00',
      2: '14:00 - 17:00',
      3: '18:00 - 20:00'
    };
    return map[period] || '';
  }

  static getPayStatusText(payStatus: number): string {
    const map: Record<number, string> = {
      0: '待支付',
      1: '已支付',
      2: '已退款'
    };
    return map[payStatus] || '未知';
  }

  static getPayStatusColor(payStatus: number): string {
    const map: Record<number, string> = {
      0: '#FAAD14',
      1: '#52C41A',
      2: '#999999'
    };
    return map[payStatus] || '#999999';
  }
}

export class ScheduleInfo {
  id: number = 0;
  doctorId: number = 0;
  scheduleDate: string = '';
  schedulePeriod: number = 0;
  maxCount: number = 20;
  currentCount: number = 0;
  status: number = 1;
}
