import { Prescription } from '../services/ConsultationService';

export function getMockPrescriptions(): Prescription[] {
  return [
    {
      prescriptionId: 1,
      sessionId: 101,
      userId: 1,
      doctorId: 1001,
      prescriptionNo: 'RX202501110001',
      diagnosis: '上呼吸道感染',
      prescriptionContent: JSON.stringify([
        { name: '阿莫西林胶囊', dosage: '0.5g', quantity: '24', unit: '粒' },
        { name: '布洛芬缓释胶囊', dosage: '0.3g', quantity: '12', unit: '粒' },
        { name: '复方甘草片', dosage: '3片', quantity: '30', unit: '片' }
      ]),
      usageInstruction: '阿莫西林每日3次，每次1粒；布洛芬发热时服用，每次1粒；复方甘草片每日3次，每次3片',
      validDays: 7,
      status: 'active',
      createTime: '2025-01-11T08:30:00'
    },
    {
      prescriptionId: 2,
      sessionId: 102,
      userId: 1,
      doctorId: 1002,
      prescriptionNo: 'RX202501100002',
      diagnosis: '高血压',
      prescriptionContent: JSON.stringify([
        { name: '硝苯地平控释片', dosage: '30mg', quantity: '30', unit: '片' },
        { name: '厄贝沙坦片', dosage: '150mg', quantity: '30', unit: '片' }
      ]),
      usageInstruction: '硝苯地平每日1次，每次1片；厄贝沙坦每日1次，每次1片',
      validDays: 30,
      status: 'active',
      createTime: '2025-01-10T14:20:00'
    },
    {
      prescriptionId: 3,
      sessionId: 103,
      userId: 1,
      doctorId: 1003,
      prescriptionNo: 'RX202501080003',
      diagnosis: '糖尿病',
      prescriptionContent: JSON.stringify([
        { name: '二甲双胍缓释片', dosage: '0.5g', quantity: '60', unit: '片' },
        { name: '格列美脲片', dosage: '2mg', quantity: '30', unit: '片' }
      ]),
      usageInstruction: '二甲双胍每日2次，每次1片；格列美脲每日1次，每次1片',
      validDays: 30,
      status: 'active',
      createTime: '2025-01-08T10:15:00'
    },
    {
      prescriptionId: 4,
      sessionId: 104,
      userId: 1,
      doctorId: 1001,
      prescriptionNo: 'RX202501050004',
      diagnosis: '胃炎',
      prescriptionContent: JSON.stringify([
        { name: '奥美拉唑肠溶胶囊', dosage: '20mg', quantity: '14', unit: '粒' },
        { name: '铝碳酸镁咀嚼片', dosage: '0.5g', quantity: '24', unit: '片' }
      ]),
      usageInstruction: '奥美拉唑每日2次，每次1粒；铝碳酸镁每日3次，每次2片',
      validDays: 14,
      status: 'expired',
      createTime: '2025-01-05T16:45:00'
    }
  ];
}

export function getMockPrescriptionById(prescriptionId: number): Prescription | null {
  const prescriptions = getMockPrescriptions();
  for (let i = 0; i < prescriptions.length; i++) {
    if (prescriptions[i].prescriptionId === prescriptionId) {
      return prescriptions[i];
    }
  }
  return null;
}
