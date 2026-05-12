/**
 * 小艺Skill意图配置 - 快速导入模板
 * 
 * 使用方法:
 * 1. 复制本文件内容
 * 2. 在华为Skill Studio控制台 → 意图管理 → 批量导入
 * 3. 或逐个手动添加（每个意图约5分钟）
 */

export const INTENT_CONFIGS = {
  // ==================== 1. 挂号预约 ====================
  appointment_booking: {
    intentId: 'appointment_booking',
    displayName: '📅 挂号预约服务',
    description: '处理用户的医生预约和挂号请求',
    priority: 0,
    
    // 训练语句（越多越准确，建议15-20条）
    trainingPhrases: [
      "帮我挂号",
      "我想预约医生",
      "挂个号",
      "预约明天的门诊",
      "帮我看张医生",
      "我要挂号内科",
      "预约下周三上午",
      "挂专家号",
      "取消预约",
      "查询预约状态",
      "挂号张医生明天",
      "看看还有没有号",
      "预约妇科门诊",
      "挂个普通号",
      "预约李主任"
    ],
    
    // 槽位定义（从用户语句中提取的参数）
    slots: [
      {
        name: 'doctor_name',
        type: 'text',
        required: false,
        prompt: '请问要预约哪位医生？',
        examples: ['张医生', '李主任', '王大夫', '赵医生']
      },
      {
        name: 'time',
        type: 'time',
        required: false,
        prompt: '您希望什么时候就诊？',
        examples: ['明天', '后天', '下周三', '今天下午', '这周五']
      },
      {
        name: 'period',
        type: 'enum',
        required: false,
        values: ['上午', '下午', '晚上', '全天'],
        prompt: '您希望上午还是下午就诊？'
      },
      {
        name: 'department',
        type: 'text',
        required: false,
        prompt: '要挂哪个科室？',
        examples: ['内科', '外科', '妇科', '儿科', '骨科', '眼科', '耳鼻喉科']
      }
    ],
    
    // 处理动作
    action: {
      type: 'start_ability',
      bundleName: 'com.example.harmonyhealthcare',
      abilityName: 'AppointmentsAbility',
      paramsMapping: {
        doctor_name: '${doctor_name}',
        time: '${time}',
        period: '${period}',
        department: '${department}'
      }
    },
    
    // TTS回复模板
    ttsTemplate: `好的，正在为您{doctor_name, select, undefined {打开预约页面} other {{doctor_name}}}{time, select, undefined {} other {{time}}}{period, select, undefined {} other {{period}}}。请稍候...`,
    
    displayTemplate: '正在跳转到预约页面...'
  },

  // ==================== 2. AR导航 ====================
  navigation: {
    intentId: 'navigation',
    displayName: '🧭 AR智能导航',
    description: '启动AR导航功能，引导用户前往目标位置',
    priority: 0,
    
    trainingPhrases: [
      "导航去内科",
      "怎么走",
      "打开AR导航",
      "找一下放射科在哪",
      "去急诊怎么走",
      "药房在哪里",
      "帮我导航到三楼",
      "找一下电梯口",
      "停车场在哪",
      "我想去检验科",
      "放射科怎么走",
      "导诊台在什么位置",
      "开始AR导航",
      "带我去看医生"
    ],
    
    slots: [
      {
        name: 'destination',
        type: 'text',
        required: false,
        prompt: '您想去哪里？',
        examples: ['内科', '外科', '药房', '检验科', '急诊', '放射科', '住院部']
      }
    ],
    
    action: {
      type: 'start_ability',
      bundleName: 'com.example.harmonyhealthcare',
      abilityName: 'ARNavigationAbility'
    },
    
    ttsTemplate: '正在为您启动AR导航到{destination, select, undefined {目标位置} other {{destination}}}。请将手机摄像头对准前方，我会通过AR箭头指引您前往。',
    displayTemplate: '正在启动AR导航...'
  },

  // ==================== 3. 紧急求助 ====================
  emergency: {
    intentId: 'emergency',
    displayName: '🚨 紧急求助SOS',
    description: '处理紧急情况，自动拨打120并通知紧急联系人',
    priority: 10,  // 最高优先级
    
    trainingPhrases: [
      "救命",
      "打120",
      "我不舒服",
      "晕倒了",
      "胸痛",
      "呼吸困难",
      "紧急求助",
      "快叫救护车",
      "我不行了",
      "帮帮我",
      "出事了",
      "有人晕倒了",
      "心脏不舒服",
      "突发疾病",
      "救命啊"
    ],
    
    slots: [],  // 紧急情况不需要提取参数
    
    action: {
      type: 'custom',
      handler: 'handleEmergency',
      params: {
        autoCall120: true,
        notifyContacts: true,
        shareLocation: true,
        urgencyLevel: 'high'
      }
    },
    
    ttsTemplate: '⚠️ 检测到紧急情况！\n\n1. 正在为您拨打120急救电话...\n2. 已通知您的紧急联系人...\n3. 正在获取您的GPS定位...\n\n请保持冷静，不要随意移动患者！',
    displayTemplate: '🚨 紧急模式已激活'
  },

  // ==================== 4. 健康查询 ====================
  health_query: {
    intentId: 'health_query',
    displayName: '💓 健康数据查询',
    description: '查询用户的健康记录数据',
    priority: 0,
    
    trainingPhrases: [
      "血压怎么样",
      "查看血糖记录",
      "我的健康数据",
      "最近体检报告",
      "心率正常吗",
      "体重多少",
      "查看健康档案",
      "睡眠质量如何",
      "运动数据",
      "今天的步数",
      "血氧饱和度",
      "体温多少",
      "历史健康记录",
      "我的身体状况"
    ],
    
    slots: [
      {
        name: 'metric',
        type: 'enum',
        required: false,
        values: ['血压', '血糖', '心率', '体重', '体温', '血氧', '睡眠', '运动'],
        prompt: '您想查看哪项健康指标？'
      }
    ],
    
    action: {
      type: 'start_ability',
      bundleName: 'com.example.harmonyhealthcare',
      abilityName: 'HealthRecordsAbility'
    },
    
    ttsTemplate: '正在为您查询{metric, select, undefined {健康数据} other {{metric}}}记录。最近7天数据显示：[数据将在页面展示]...',
    displayTemplate: '正在加载健康数据...'
  },

  // ==================== 5. 风险评估 ====================
  risk_assessment: {
    intentId: 'risk_assessment',
    displayName: '⚕️ 健康风险评估',
    description: '基于用户健康数据进行多维度风险评估',
    priority: 0,
    
    trainingPhrases: [
      "评估风险",
      "健康检查",
      "分析一下我的健康状况",
      "风险预测",
      "做个健康评估",
      "我有什么风险",
      "健康评分",
      "风险评估报告",
      "检查健康状况",
      "生成健康报告",
      "我的风险等级",
      "综合健康分析"
    ],
    
    slots: [],
    
    action: {
      type: 'start_ability',
      bundleName: 'com.example.harmonyhealthcare',
      abilityName: 'RiskAssessmentAbility'
    },
    
    ttsTemplate: '正在进行AI健康风险评估，基于您的近期健康数据分析以下5个维度：高血压、糖尿病、跌倒、衰弱、肌少症。预计需要10-20秒...',
    displayTemplate: '正在进行风险评估...'
  },

  // ==================== 6. 用药提醒 ====================
  medication_reminder: {
    intentId: 'medication_reminder',
    displayName: '💊 用药提醒管理',
    description: '管理用药计划和提醒',
    priority: 0,
    
    trainingPhrases: [
      "吃药提醒",
      "该吃药了",
      "查看用药记录",
      "今天的药吃了吗",
      "设置吃药提醒",
      "药物清单",
      "用药时间表",
      "该服药了",
      "药吃完了吗",
      "查看药品说明",
      "添加新药物",
      "删除用药提醒"
    ],
    
    slots: [],
    
    action: {
      type: 'start_ability',
      bundleName: 'com.example.harmonyhealthcare',
      abilityName: 'MedicationsAbility'
    },
    
    ttsTemplate: '用药提醒页面已打开。\n\n💊 今日待服药清单：\n- [ ] 降压药 - 08:00 (早餐后)\n- [ ] 降糖药 - 12:00 (午餐前)\n- [ ] 钙片 - 20:00 (晚餐后)',
    displayTemplate: '用药提醒'
  },

  // ==================== 7. 康复训练 ====================
  rehab_training: {
    intentId: 'rehab_training',
    displayName: '🏃 康复训练指导',
    description: '提供康复训练课程和运动指导',
    priority: 0,
    
    trainingPhrases: [
      "康复训练",
      "开始运动",
      "太极课程",
      "康复练习",
      "今天做什么运动",
      "推荐运动项目",
      "八段锦教程",
      "适合老人的运动",
      "康复计划",
      "开始锻炼",
      "运动课程列表",
      "太极拳教学",
      "平衡训练",
      "力量训练"
    ],
    
    slots: [
      {
        name: 'exercise_type',
        type: 'enum',
        required: false,
        values: ['太极', '八段锦', '平衡训练', '力量训练', '有氧运动'],
        prompt: '您想进行哪种类型的训练？'
      }
    ],
    
    action: {
      type: 'start_ability',
      bundleName: 'com.example.harmonyhealthcare',
      abilityName: 'RehabAbility'
    },
    
    ttsTemplate: '康复训练课程已打开！\n\n🏃‍♂️ 推荐今日训练计划：\n1. 热身运动 (5分钟)\n2. 核心训练 (15分钟)\n3. 放松拉伸 (5分钟)\n\n我会全程语音指导您完成每个动作。',
    displayTemplate: '康复训练课程'
  },

  // ==================== 8. 设备管理 ====================
  device_control: {
    intentId: 'device_control',
    displayName: '📱 健康设备管理',
    description: '连接和管理健康监测设备',
    priority: -1,  // 低优先级
    
    trainingPhrases: [
      "连接设备",
      "配对手表",
      "打开蓝牙",
      "发现附近设备",
      "同步健康数据",
      "设备电量",
      "断开连接",
      "添加新设备",
      "血压计连接",
      "手环配对",
      "查看已连接设备",
      "设备状态",
      "测量血压",
      "测量血糖"
    ],
    
    slots: [],
    
    action: {
      type: 'start_ability',
      bundleName: 'com.example.harmonyhealthcare',
      abilityName: 'DeviceManagementAbility'
    },
    
    ttsTemplate: '设备管理页面已打开，正在搜索附近可连接的健康设备...\n\n发现设备：\n- 💓 血压计 (蓝牙)\n- ⌚ 智能手表 (蓝牙)\n- ⚖️ 体脂秤 (WiFi)',
    displayTemplate: '设备发现中...'
  }
};

/**
 * 导出所有意图配置
 * 用于批量导入或参考
 */
export default INTENT_CONFIGS;

/**
 * 获取单个意图配置
 */
export function getIntentConfig(intentId: string): any {
  return INTENT_CONFIGS[intentId as keyof typeof INTENT_CONFIGS];
}

/**
 * 获取所有意图ID列表
 */
export function getAllIntentIds(): string[] {
  return Object.keys(INTENT_CONFIGS);
}

/**
 * 统计信息
 */
export function getStats() {
  return {
    totalIntents: Object.keys(INTENT_CONFIGS).length,
    totalTrainingPhrases: Object.values(INTENT_CONFIGS).reduce(
      (sum, config) => sum + config.trainingPhrases.length, 
      0
    ),
    totalSlots: Object.values(INTENT_CONFIGS).reduce(
      (sum, config) => sum + (config.slots?.length || 0), 
      0
    )
  };
}
