// 健康工具函数

// 格式化日期
export function formatDate(date: Date, format: string = 'YYYY-MM-DD'): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  const seconds = String(date.getSeconds()).padStart(2, '0');

  switch (format) {
    case 'YYYY-MM-DD':
      return '' + year + '-' + month + '-' + day;
    case 'YYYY/MM/DD':
      return '' + year + '/' + month + '/' + day;
    case 'MM-DD':
      return '' + month + '-' + day;
    case 'HH:mm':
      return '' + hours + ':' + minutes;
    case 'YYYY-MM-DD HH:mm':
      return '' + year + '-' + month + '-' + day + ' ' + hours + ':' + minutes;
    case 'YYYY-MM-DD HH:mm:ss':
      return '' + year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
    default:
      return '' + year + '-' + month + '-' + day;
  }
}

// 解析日期字符串
export function parseDate(dateString: string): Date | null {
  const date = new Date(dateString);
  return isNaN(date.getTime()) ? null : date;
}

// 计算年龄
export function calculateAge(birthDate: Date): number {
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  
  return age;
}

// 计算BMI
export function calculateBMI(weight: number, height: number): number {
  // 体重(kg) / 身高(m)²
  const heightInMeters = height / 100;
  return weight / (heightInMeters * heightInMeters);
}

// 获取BMI分类
export function getBMICategory(bmi: number): {
  category: string;
  color: string;
  description: string;
} {
  if (bmi < 18.5) {
    return {
      category: '偏瘦',
      color: '#4a90e2',
      description: '体重过轻'
    };
  } else if (bmi < 24) {
    return {
      category: '正常',
      color: '#4CAF50',
      description: '健康体重'
    };
  } else if (bmi < 28) {
    return {
      category: '超重',
      color: '#FF9800',
      description: '需要控制体重'
    };
  } else {
    return {
      category: '肥胖',
      color: '#F44336',
      description: '需要减重'
    };
  }
}

// 计算血压分类
export function getBloodPressureCategory(systolic: number, diastolic: number): {
  category: string;
  color: string;
  description: string;
} {
  if (systolic < 120 && diastolic < 80) {
    return {
      category: '正常',
      color: '#4CAF50',
      description: '理想血压'
    };
  } else if (systolic < 130 && diastolic < 85) {
    return {
      category: '正常高值',
      color: '#8BC34A',
      description: '需要注意'
    };
  } else if (systolic < 140 && diastolic < 90) {
    return {
      category: '高血压1级',
      color: '#FF9800',
      description: '建议就医'
    };
  } else if (systolic < 160 && diastolic < 100) {
    return {
      category: '高血压2级',
      color: '#FF5722',
      description: '需要治疗'
    };
  } else {
    return {
      category: '高血压3级',
      color: '#F44336',
      description: '紧急就医'
    };
  }
}

// 计算血糖分类
export function getBloodSugarCategory(value: number, type: 'fasting' | 'postprandial'): {
  category: string;
  color: string;
  description: string;
} {
  if (type === 'fasting') {
    // 空腹血糖
    if (value < 3.9) {
      return {
        category: '低血糖',
        color: '#F44336',
        description: '血糖过低'
      };
    } else if (value < 6.1) {
      return {
        category: '正常',
        color: '#4CAF50',
        description: '正常范围'
      };
    } else if (value < 7.0) {
      return {
        category: '糖尿病前期',
        color: '#FF9800',
        description: '需要注意'
      };
    } else {
      return {
        category: '糖尿病',
        color: '#F44336',
        description: '需要治疗'
      };
    }
  } else {
    // 餐后血糖
    if (value < 7.8) {
      return {
        category: '正常',
        color: '#4CAF50',
        description: '正常范围'
      };
    } else if (value < 11.1) {
      return {
        category: '糖尿病前期',
        color: '#FF9800',
        description: '需要注意'
      };
    } else {
      return {
        category: '糖尿病',
        color: '#F44336',
        description: '需要治疗'
      };
    }
  }
}

// 格式化血压值
export function formatBloodPressure(systolic: number, diastolic: number): string {
  return '' + systolic + '/' + diastolic;
}

// 解析血压值
export function parseBloodPressure(bpString: string): { systolic: number; diastolic: number } | null {
  const parts = bpString.split('/');
  if (parts.length !== 2) return null;
  
  const systolic = parseInt(parts[0]);
  const diastolic = parseInt(parts[1]);
  
  if (isNaN(systolic) || isNaN(diastolic)) return null;
  
  return { systolic, diastolic };
}

// 计算步数目标进度
export function calculateStepsProgress(current: number, target: number = 10000): number {
  return Math.min(Math.round((current / target) * 100), 100);
}

// 计算卡路里目标进度
export function calculateCaloriesProgress(current: number, target: number = 500): number {
  return Math.min(Math.round((current / target) * 100), 100);
}

// 计算体重目标进度
export function calculateWeightProgress(current: number, target: number): number {
  const progress = Math.abs((current - target) / target) * 100;
  return Math.min(Math.round(progress), 100);
}

// 获取健康评分
export function calculateHealthScore(metrics: {
  bmi?: number;
  bloodPressure?: { systolic: number; diastolic: number };
  bloodSugar?: number;
  steps?: number;
  sleep?: number;
}): number {
  let score = 100;
  
  // BMI评分
  if (metrics.bmi) {
    if (metrics.bmi < 18.5 || metrics.bmi >= 28) {
      score -= 20;
    } else if (metrics.bmi >= 24 && metrics.bmi < 28) {
      score -= 10;
    }
  }
  
  // 血压评分
  if (metrics.bloodPressure) {
    const systolic = metrics.bloodPressure.systolic;
    const diastolic = metrics.bloodPressure.diastolic;
    if (systolic >= 140 || diastolic >= 90) {
      score -= 20;
    } else if (systolic >= 130 || diastolic >= 85) {
      score -= 10;
    }
  }
  
  // 血糖评分
  if (metrics.bloodSugar) {
    if (metrics.bloodSugar >= 7.0) {
      score -= 20;
    } else if (metrics.bloodSugar >= 6.1) {
      score -= 10;
    }
  }
  
  // 步数评分
  if (metrics.steps) {
    if (metrics.steps < 5000) {
      score -= 10;
    } else if (metrics.steps >= 10000) {
      score += 10;
    }
  }
  
  // 睡眠评分
  if (metrics.sleep) {
    if (metrics.sleep < 6) {
      score -= 10;
    } else if (metrics.sleep >= 8) {
      score += 10;
    }
  }
  
  return Math.max(0, Math.min(100, score));
}

// 获取健康建议
export function getHealthRecommendations(score: number): string[] {
  const recommendations: string[] = [];
  
  if (score >= 90) {
    recommendations.push('继续保持健康的生活方式');
    recommendations.push('定期进行健康检查');
    recommendations.push('保持适量运动');
  } else if (score >= 70) {
    recommendations.push('注意饮食均衡');
    recommendations.push('增加日常运动量');
    recommendations.push('保证充足睡眠');
  } else if (score >= 50) {
    recommendations.push('需要改善生活习惯');
    recommendations.push('建议咨询医生');
    recommendations.push('控制体重和血压');
  } else {
    recommendations.push('立即就医检查');
    recommendations.push('调整生活方式');
    recommendations.push('遵医嘱进行治疗');
  }
  
  return recommendations;
}

// 格式化时间间隔
export function formatTimeAgo(timestamp: number): string {
  const now = Date.now();
  const diff = now - timestamp;
  
  const minutes = Math.floor(diff / (1000 * 60));
  const hours = Math.floor(diff / (1000 * 60 * 60));
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  
  if (minutes < 1) {
    return '刚刚';
  } else if (minutes < 60) {
    return minutes + '分钟前';
  } else if (hours < 24) {
    return hours + '小时前';
  } else if (days < 7) {
    return days + '天前';
  } else {
    return formatDate(new Date(timestamp), 'YYYY-MM-DD');
  }
}

// 生成随机颜色
export function generateRandomColor(): string {
  const colors = [
    '#4a90e2', '#96ceb4', '#ff6b6b', '#f5a623', '#9b59b6',
    '#4ecdc4', '#45b7d1', '#ff9ff3', '#54a0ff', '#5f27cd'
  ];
  return colors[Math.floor(Math.random() * colors.length)];
}

// 获取健康指标图标
export function getHealthMetricIcon(type: string): string {
  const iconMap: Record<string, string> = {
    'heart_rate': '❤️',
    'blood_pressure': '🩸',
    'blood_sugar': '🍬',
    'temperature': '🌡️',
    'weight': '⚖️',
    'oxygen': '💨',
    'steps': '👣',
    'calories': '🔥'
  };
  
  return iconMap[type] || '📊';
}

// 获取健康指标单位
export function getHealthMetricUnit(type: string): string {
  const unitMap: Record<string, string> = {
    'heart_rate': 'bpm',
    'blood_pressure': 'mmHg',
    'blood_sugar': 'mmol/L',
    'temperature': '°C',
    'weight': 'kg',
    'oxygen': '%',
    'steps': '步',
    'calories': 'kcal'
  };
  
  return unitMap[type] || '';
}

// 验证手机号
export function validatePhone(phone: string): boolean {
  if (!phone || phone.length !== 11) return false;
  if (phone.charAt(0) !== '1') return false;
  const secondChar = phone.charAt(1);
  if (secondChar < '3' || secondChar > '9') return false;
  for (let i = 2; i < 11; i++) {
    if (phone.charAt(i) < '0' || phone.charAt(i) > '9') return false;
  }
  return true;
}

// 验证邮箱
export function validateEmail(email: string): boolean {
  if (!email || email.length === 0) return false;
  const atIndex = email.indexOf('@');
  if (atIndex <= 0 || atIndex >= email.length - 1) return false;
  const dotIndex = email.lastIndexOf('.');
  if (dotIndex <= atIndex + 1 || dotIndex >= email.length - 1) return false;
  return true;
}

// 深拷贝对象
export function deepClone<T>(obj: T): T {
  return JSON.parse(JSON.stringify(obj));
}

// 防抖函数
export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: number | undefined;
  
  return function executedFunction(...args: Parameters<T>) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// 节流函数
export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean;
  
  return function executedFunction(...args: Parameters<T>) {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
}