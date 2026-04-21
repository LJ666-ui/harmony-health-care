import { MedicalAgent, AgentConfig, ConversationContext } from './MedicalAgent';

export class InternalMedicineAgent extends MedicalAgent {
  private keywords: string[] = [
    '血压', '血糖', '糖尿病', '高血压', '心脏病', '感冒', '发烧',
    '咳嗽', '头痛', '头晕', '失眠', '慢性病', '内科', '症状',
    '胸闷', '气短', '乏力', '疲劳', '胃痛', '腹泻', '便秘'
  ];

  constructor() {
    const config: AgentConfig = {
      name: '内科专家',
      description: '擅长慢性病管理、常见症状分析和疾病预防指导',
      specialty: 'internal_medicine',
      systemPrompt: `你是一位经验丰富的内科医生AI助手，专长于：
1. 慢性病管理（高血压、糖尿病、心脏病等）
2. 常见症状分析（头痛、发热、咳嗽等）
3. 疾病预防和健康生活方式指导
4. 用药指导和注意事项

回答要求：
- 专业准确，用通俗易懂的语言解释
- 提供具体可行的建议
- 必要时提醒就医指征
- 保持关怀和耐心`,
      temperature: 0.7,
      maxTokens: 1000
    };
    super(config);
  }

  canHandle(query: string): boolean {
    const lowerQuery: string = query.toLowerCase();
    for (const keyword of this.keywords) {
      if (lowerQuery.indexOf(keyword) >= 0) {
        return true;
      }
    }
    return false;
  }

  protected async generateResponse(prompt: string): Promise<string> {
    const lowerQuery: string = prompt.toLowerCase();

    if (lowerQuery.indexOf('血压') >= 0 || lowerQuery.indexOf('高血压') >= 0) {
      return this.generateBloodPressureResponse(prompt);
    }

    if (lowerQuery.indexOf('糖') >= 0 || lowerQuery.indexOf('糖尿病') >= 0) {
      return this.generateDiabetesResponse(prompt);
    }

    if (lowerQuery.indexOf('失眠') >= 0 || lowerQuery.indexOf('睡眠') >= 0) {
      return this.generateInsomniaResponse(prompt);
    }

    if (lowerQuery.indexOf('心脏') >= 0 || lowerQuery.indexOf('胸闷') >= 0) {
      return this.generateHeartHealthResponse(prompt);
    }

    if (lowerQuery.indexOf('感冒') >= 0 || lowerQuery.indexOf('发烧') >= 0 || lowerQuery.indexOf('咳嗽') >= 0) {
      return this.generateColdResponse(prompt);
    }

    return this.generateGeneralInternalMedicineResponse(prompt);
  }

  private generateBloodPressureResponse(query: string): string {
    return `**关于血压管理，我为您提供以下专业建议：**

📊 **正常血压标准**
• 正常血压：收缩压 < 120 且 舒张压 < 80 mmHg
• 正常高值：收缩压 120-139 或 舒张压 80-89 mmHg
• 高血压：收缩压 ≥ 140 或 舒张压 ≥ 90 mmHg

💊 **日常管理要点**
1. **饮食控制**：每日盐摄入 < 6克，增加钾元素摄入（香蕉、菠菜）
2. **规律运动**：每周150分钟中等强度有氧运动
3. **体重管理**：BMI控制在18.5-24之间
4. **戒烟限酒**：完全戒烟，男性酒精<25g/天，女性<15g/天
5. **监测记录**：每日早晚各测一次，做好记录

⚠️ **需要立即就医的情况**
• 收缩压 ≥ 180 或舒张压 ≥ 110 mmHg
• 伴随剧烈头痛、胸痛、呼吸困难
• 视力突然模糊或言语不清

建议您定期监测血压，如有异常请及时就医。${this.getDisclaimer()}`;
  }

  private generateDiabetesResponse(query: string): string {
    return `**关于血糖管理，请注意以下关键点：**

🎯 **控制目标**
• 空腹血糖：4.4-7.0 mmol/L
• 餐后2小时：<10.0 mmol/L
• 糖化血红蛋白：<7.0%

🍽️ **饮食原则**
1. 控制碳水化合物总量，选择低GI食物
   - 推荐：全谷物、豆类、非淀粉类蔬菜
   - 避免：精制米面、含糖饮料、甜点
2. 少食多餐，定时定量（一日5-6餐）
3. 增加膳食纤维（每日25-30克）

🏃‍♂️ **运动建议**
• 餐后1小时进行运动效果最佳
• 每次中等强度运动20-30分钟
• 避免空腹运动以防低血糖

💉 **监测频率**
• 初诊或调整方案时：每天4-7次
• 血糖稳定后：每周2-4天，每天2-4次

${this.getDisclaimer()}`;
  }

  private generateInsomniaResponse(query: string): string {
    return `**针对睡眠问题，我为您制定改善方案：**

🌙 **睡前准备（睡前1小时）**
1. 远离电子设备（手机、电脑、电视）
2. 调暗卧室灯光，保持安静环境
3. 室温保持在18-22°C
4. 可使用薰衣草香薰或播放轻音乐

💆 **放松技巧**
• **4-7-8呼吸法**：吸气4秒→屏息7秒→呼气8秒，重复4次
• **渐进式肌肉放松**：从脚趾开始，依次紧绷再放松各部位肌肉
• **冥想练习**：专注于呼吸或想象宁静场景

🍵 **助眠食疗**
• 酸枣仁汤：酸枣仁15g，水煎服
• 百合莲子粥：百合30g + 莲子20g煮粥
• 牛奶+蜂蜜：温牛奶250ml加一勺蜂蜜

⏰ **作息建议**
• 固定就寝和起床时间（误差不超过30分钟）
• 午睡限制在20-30分钟内

如果长期失眠超过2周，建议咨询医生排查原因。${this.getDisclaimer()}`;
  }

  private generateHeartHealthResponse(query: string): string {
    return `**关于心血管健康的保护措施：**

❤️ **风险因素识别**
• 不可控：年龄、性别、家族史
• 可控：高血压、高血脂、糖尿病、吸烟、肥胖、缺乏运动

🥗 **护心饮食（地中海饮食模式）**
1. 多吃：蔬菜水果、全谷物、鱼类、坚果、橄榄油
2. 适量：禽肉、蛋类、乳制品
3. 少吃：红肉、加工食品、反式脂肪酸
4. 限盐：每日<6克

🏃‍♂️ **护心运动**
• 有氧运动：每周150分钟中等强度（快走、游泳、骑车）
• 抗阻训练：每周2次，增强心肺功能
• 避免过度剧烈运动

🚨 **警示信号 - 需立即就医**
• 持续胸痛>20分钟，压迫感向左臂/颈部放射
• 严重呼吸困难、冷汗淋漓
• 突发心悸伴头晕晕厥

${this.getDisclaimer()}`;
  }

  private generateColdResponse(query: string): string {
    return `**关于感冒/呼吸道感染的应对方法：**

🤧 **症状分期处理**

**初期（1-2天）**
• 多喝温水，休息充足
• 盐水漱口缓解咽痛
• 适当补充维生素C

**中期（3-5天）**
• 对症用药：退烧药（体温>38.5℃）、止咳药
• 保持室内通风湿润
• 清淡易消化饮食

**恢复期（6-7天）**
• 逐渐恢复正常活动
• 补充营养增强免疫力
• 注意避免受凉复发

💊 **用药提醒**
• 抗生素对病毒性感冒无效，勿自行使用
• 多种感冒药不可同服（注意成分重复）
• 有基础疾病者用药前咨询医生

🏥 **需及时就医的情况**
• 发热>39℃持续3天不退
• 呼吸困难、胸痛
• 症状加重或持续超过10天

${this.getDisclaimer()}`;
  }

  private generateGeneralInternalMedicineResponse(query: string): string {
    return `作为您的内科健康顾问，我可以帮您：

📋 **常见问题咨询**
• 各类慢性病的日常管理
• 身体不适的初步判断
• 预防保健知识
• 用药安全指导

💡 **健康生活建议**
1. **均衡饮食**：多样化食物，适量各类营养素
2. **规律运动**：每周至少150分钟中等强度活动
3. **充足睡眠**：成人7-8小时/天
4. **定期体检**：每年一次全面体检
5. **心理平衡**：保持积极心态，适度减压

请告诉我您的具体症状或关注的问题，我会提供更针对性的建议。

${this.getDisclaimer()}`;
  }
}

export class SurgeryAgent extends MedicalAgent {
  private keywords: string[] = [
    '外伤', '伤口', '出血', '手术', '骨折', '扭伤', '烫伤',
    '划伤', '摔伤', '割伤', '缝合', '拆线', '外科', '术后',
    '包扎', '消毒', '肿胀', '淤青'
  ];

  constructor() {
    const config: AgentConfig = {
      name: '外科专家',
      description: '擅长外伤处理、手术前后护理和急救指导',
      specialty: 'surgery',
      systemPrompt: `你是一位专业的外科医生AI助手，专长于：
1. 外伤处理和伤口护理
2. 手术前后注意事项
3. 急救知识和应急处理
4. 骨科、普外科常见问题

回答要求：
- 步骤清晰，操作指导明确
- 强调安全和无菌操作
- 及时提醒就医指征
- 语言简洁实用`,
      temperature: 0.6,
      maxTokens: 1000
    };
    super(config);
  }

  canHandle(query: string): boolean {
    const lowerQuery: string = query.toLowerCase();
    for (const keyword of this.keywords) {
      if (lowerQuery.indexOf(keyword) >= 0) {
        return true;
      }
    }
    return false;
  }

  protected async generateResponse(prompt: string): Promise<string> {
    const lowerQuery: string = prompt.toLowerCase();

    if (lowerQuery.indexOf('外伤') >= 0 || lowerQuery.indexOf('伤口') >= 0 || lowerQuery.indexOf('出血') >= 0) {
      return this.generateWoundCareResponse();
    }

    if (lowerQuery.indexOf('手术') >= 0 || lowerQuery.indexOf('术后') >= 0) {
      return this.generatePostOpCareResponse();
    }

    if (lowerQuery.indexOf('骨折') >= 0 || lowerQuery.indexOf('扭伤') >= 0) {
      return this.generateOrthopedicResponse();
    }

    if (lowerQuery.indexOf('烫伤') >= 0 || lowerQuery.indexOf('烧伤') >= 0) {
      return this.generateBurnResponse();
    }

    return this.generateGeneralSurgeryResponse();
  }

  private generateWoundCareResponse(): string {
    return `**外伤/伤口处理标准流程：**

🩹 **第一步：评估伤情**
• 检查意识状态（呼叫患者看是否有反应）
• 观察出血量和速度（动脉血喷射状、静脉血涌出）
• 检查有无异物残留

🧼 **第二步：止血清洁**
1. **直接压迫止血**：用干净布料压住伤口5-10分钟
2. **抬高患肢**：高于心脏水平
3. **清洁伤口**：生理盐水或凉开水冲洗
4. **消毒**：碘伏棉球由内向外消毒

🩹 **第三步：包扎固定**
• 无菌纱布覆盖伤口
• 胶布或绷带固定（不要太紧）
• 如有渗血及时更换

⚠️ **必须就医的情况**
• 伤口深可见骨/肌腱
• 出血不止超过10-15分钟
• 动物咬伤（需打破伤风针）
• 生锈金属划伤
• 伤口红肿热痛加重

${this.getDisclaimer()}`;
  }

  private generatePostOpCareResponse(): string {
    return `**手术后护理要点：**

📋 **术前准备**
• 术前8-12小时禁食禁水
• 取下假牙、首饰、隐形眼镜
• 清洁身体，更换病号服
• 告知医生所有用药史和过敏史

🏥 **术后即刻（24小时内）**
• 去枕平卧4-6小时（全麻）
• 监测生命体征（血压、脉搏、呼吸）
• 观察伤口有无渗血
• 按时止痛

🏠 **居家恢复期**
1. **休息**：保证充足睡眠，避免剧烈活动
2. **伤口护理**：
   - 保持干燥清洁
   - 按医嘱换药（通常2-3天一次）
   - 注意观察有无红肿、渗液、裂开
3. **饮食**：从流食→半流食→普食逐步过渡
4. **用药**：按时服用抗生素、止痛药等

📅 **复诊提醒**
• 按时回院复查
• 拆线时间通常为7-14天
• 有异常随时联系医生

🚨 **紧急情况**：发热>38.5℃、剧痛不止、伤口大量出血
${this.getDisclaimer()}`;
  }

  private generateOrthopedicResponse(): string {
    return `**骨科损伤处理指南：**

🦴 **骨折识别**
• 症状：剧烈疼痛、肿胀畸形、功能障碍
• 特殊体征：异常活动、骨擦音

📍 **现场处理原则 - RICE法**
1. **R-Rest（制动）**：停止活动，不要移动伤处
2. **I-Ice（冷敷）**：冰袋敷15-20分钟，间隔2小时
3. **C-Compression（加压）**：弹性绷带包扎
4. **E-Elevation（抬高）**：抬高患肢高于心脏

🔄 **扭伤处理（区别于骨折）**
• 轻度：RICE处理，2-3天恢复
• 中度：制动1-2周，外用药物
• 重度：可能伴韧带撕裂，需就医

⚕️ **固定与转运**
• 用夹板或硬纸板临时固定
• 骨折部位上下两个关节都要固定
• 就近送医，避免二次伤害

${this.getDisclaimer()}`;
  }

  private generateBurnResponse(): string {
    return `**烫伤/烧伤紧急处理：**

🔥 **程度判断**
• I度：皮肤发红、疼痛（如晒伤）
• II度：水泡形成、剧烈疼痛
• III度：皮肤焦黑/苍白、无痛感（需立即送医）

💧 **正确处理步骤（冲-脱-泡-盖-送）**
1. **冲**：流动凉水冲洗15-30分钟
2. **脱**：小心脱去衣物（粘连勿强撕）
3. **泡**：继续浸泡冷水10-20分钟
4. **盖**：无菌纱布覆盖，不要包太紧
5. **送**：大面积或深度烧烫伤立即送医

❌ **错误做法（绝对禁止）**
• 涂抹牙膏、酱油、香油等偏方
• 冰块直接冰敷（加重损伤）
• 刺破水泡（易感染）

🏥 **需立即就医的情况**
• 烫伤面积>手掌大小
• 面、手、足、关节部位烫伤
• III度烫伤
• 化学灼伤、电击伤

${this.getDisclaimer()}`;
  }

  private generateGeneralSurgeryResponse(): string {
    return `作为您的外科健康顾问，我可以提供：

🔪 **外伤处理指导**
• 各类伤口的正确处理方法
• 出血的紧急止血技术
• 伤口感染预防措施

🏥 **手术相关咨询**
• 术前准备事项
• 术后康复指导
• 并发症预防

🦴 **骨科问题**
• 骨折/扭伤初步处理
• 运动损伤防护
• 康复训练建议

请描述您的具体问题，我将提供详细指导。

${this.getDisclaimer()}`;
  }
}

export class TCMAgent extends MedicalAgent {
  private keywords: string[] = [
    '中医', '中药', '针灸', '推拿', '体质', '调理', '养生',
    '穴位', '艾灸', '拔罐', '刮痧', '食疗', '脉象', '舌苔',
    '气虚', '阳虚', '阴虚', '湿热', '肝火', '肾虚'
  ];

  constructor() {
    const config: AgentConfig = {
      name: '中医专家',
      description: '擅长中医理论、体质辨识、中药调理和传统疗法',
      specialty: 'tcm',
      systemPrompt: `你是一位资深中医师AI助手，精通：
1. 中医基础理论（阴阳五行、脏腑经络）
2. 体质辨识与调理方案
3. 中药方剂和食疗建议
4. 传统疗法（针灸、推拿、艾灸等）
5. 四季养生和时令保健

回答要求：
- 结合中医理论解释病因病机
- 提供辨证施治的个性化建议
- 推荐安全的食疗和简易方
- 尊重中医文化，语言典雅`,
      temperature: 0.75,
      maxTokens: 1200
    };
    super(config);
  }

  canHandle(query: string): boolean {
    const lowerQuery: string = query.toLowerCase();
    for (const keyword of this.keywords) {
      if (lowerQuery.indexOf(keyword) >= 0) {
        return true;
      }
    }
    return false;
  }

  protected async generateResponse(prompt: string): Promise<string> {
    const lowerQuery: string = prompt.toLowerCase();

    if (lowerQuery.indexOf('体质') >= 0) {
      return this.generateConstitutionResponse();
    }

    if (lowerQuery.indexOf('中药') >= 0 || lowerQuery.indexOf('药材') >= 0) {
      return this.generateHerbalMedicineResponse();
    }

    if (lowerQuery.indexOf('穴位') >= 0 || lowerQuery.indexOf('针灸') >= 0) {
      return this.generateAcupunctureResponse();
    }

    if (lowerQuery.indexOf('失眠') >= 0 || lowerQuery.indexOf('睡眠') >= 0) {
      return this.generateTCMSleepResponse();
    }

    if (lowerQuery.indexOf('食疗') >= 0 || lowerQuery.indexOf('养生') >= 0) {
      return this.generateDietaryTherapyResponse();
    }

    return this.generateGeneralTCMResponse();
  }

  private generateConstitutionResponse(): string {
    return `**中医九种体质辨识与调理：**

🌿 **平和质（健康型）**
• 表现：面色润泽、精力充沛、舌淡红
• 建议：继续保持，顺四时而适寒暑

😴 **气虚质**
• 表现：易疲乏、气短懒言、自汗
• 调理：黄芪党参补气汤、八段锦练习
• 宜：山药、大枣、鸡肉；忌：生冷油腻

🥶 **阳虚质**
• 表现：怕冷、手脚冰凉、便溏
• 调理：金匮肾气丸加减、艾灸关元穴
•宜：羊肉、生姜、核桃；忌：西瓜、绿豆

🔥 **阴虚质**
• 表现：口干咽燥、手足心热、盗汗
• 调理：六味地黄丸、滋阴降火
• 宜：银耳、百合、鸭肉；忌：辛辣温燥

💧 **痰湿质**
• 表现：体形肥胖、身重困倦、痰多
• 调理：二陈汤、健脾化痰
• 宜：薏米、冬瓜、赤小豆；忌：甜腻肥甘

🌡️ **其余四种体质**
• **湿热质**：面油痤疮、口苦 → 清热祛湿
• **血瘀质**：肤色暗沉、舌紫 → 活血化瘀
• **气郁质**：情绪低落、叹气 → 疏肝解郁
• **特禀质**：过敏体质 → 调摄免疫

${this.getDisclaimer()}`;
  }

  private generateHerbalMedicineResponse(): string {
    return `**常用中药材功效与应用：**

🌱 **补气药**
• 人参：大补元气、复脉固脱（急救虚脱）
• 黄芪：补气升阳、利水消肿（气虚水肿）
• 白术：健脾益气、燥湿利水（脾虚泄泻）

🩸 **补血药**
• 当归：补血活血、调经止痛（妇科要药）
• 熟地：滋阴补血、益精填髓（肝肾亏虚）
• 阿胶：补血止血、滋阴润燥（贫血出血）

🔥 **清热药**
• 金银花：清热解毒（风热感冒）
• 连翘：清热解毒、散结消肿（疮疡肿毒）
• 黄连：清热燥湿、泻火解毒（胃肠湿热）

🌸 **常用配伍经验**
• **气血双补**：当归+黄芪
• **疏肝解郁**：柴胡+白芍
• **健脾祛湿**：茯苓+白术
• **养心安神**：酸枣仁+远志

⚠️ **用药禁忌**
• 孕妇慎用活血化瘀药（红花、桃仁）
• 感冒期间停服滋补药
• 十八反、十九畏注意配伍禁忌

建议在中医师指导下使用中药。${this.getDisclaimer()}`;
  }

  private generateAcupunctureResponse(): string {
    return `**常用穴位与保健按摩：**

🙌 **安神助眠穴位**
• **神门穴**：手腕横纹尺侧端凹陷处
  - 方法：拇指按揉3-5分钟
  - 功效：宁心安神、改善失眠
• **内关穴**：腕横纹上2寸，两筋之间
  - 方法：按揉至有酸胀感
  - 功效：宽胸理气、和胃止呕
• **涌泉穴**：足底前1/3凹陷处
  - 方法：睡前搓热涌泉100次
  - 功效：引火归元、助眠安神

💆 **缓解疲劳穴位**
• **合谷穴**：手背第1、2掌骨间
  - 功效：镇痛、治头痛牙痛
• **足三里**：膝眼下3寸，胫骨外侧
  - 功效：健脾和胃、增强免疫
• **百会穴**：头顶正中线与两耳尖连线交点
  - 功效：升阳举陷、醒脑开窍

⚠️ **注意事项**
• 按摩力度适中，以有酸麻感为宜
• 孕妇禁按合谷、三阴交等穴
• 饭后30分钟内不宜按摩腹部穴位
• 皮肤破损处避免按压

${this.getDisclaimer()}`;
  }

  private generateTCMSleepResponse(): string {
    return `**从中医角度调理失眠：**

🔍 **辨证分型**
1. **心脾两虚**：多梦易醒、心悸健忘
   → 归脾汤 + 龙眼肉煮粥
2. **阴虚火旺**：心烦不眠、手足心热
   → 黄连阿胶汤 + 百合莲子粥
3. **肝火扰心**：急躁易怒、头晕目眩
   → 龙胆泻肝汤 + 菊花茶
4. **胃气不和**：脘腹胀满、睡卧不安
   → 保和穴 + 山楂麦芽水

🍵 **助眠茶饮方**
• **酸枣仁茶**：酸枣仁15g捣碎，沸水冲泡
• **百合茯苓茶**：百合10g+茯苓10g煮水
• **玫瑰花茶**：玫瑰花5朵+枸杞10粒

🌙 **睡前养生功**
• 叩齿36次（固肾）
• 搓手熨眼（养肝）
• 搓脚心100次（引火归元）
• 腹式呼吸10分钟（调畅气机）

${this.getDisclaimer()}`;
  }

  private generateDietaryTherapyResponse(): string {
    return `**中医食疗养生指南：**

🍂 **四季饮食原则**
• **春季**（养肝）：多吃绿色蔬菜、韭菜、菠菜
• **夏季**（养心）：苦味食物（苦瓜）、绿豆汤
• **秋季**（养肺）：白色食物（梨、银耳、百合）
• **冬季**（养肾）：黑色食物（黑芝麻、黑豆、黑木耳）

🥣 **体质对应食疗**
| 体质 | 推荐 | 避免 |
|------|------|------|
| 气虚 | 山药粥、黄芪炖鸡 | 生冷、萝卜 |
| 阳虚 | 羊肉汤、姜茶 | 西瓜、绿茶 |
| 阴虚 | 银耳羹、鸭肉 | 辛辣、羊肉 |
| 痰湿 | 薏米红豆粥 | 甜腻、油炸 |

🍵 **日常养生茶**
• **明目茶**：菊花+枸杞+决明子
• **降压茶**：山楂+荷叶+菊花
• **降脂茶**：普洱+山楂+陈皮
• **护肝茶**：玫瑰花+佛手+陈皮

${this.getDisclaimer()}`;
  }

  private generateGeneralTCMResponse(): string {
    return `您好！我是您的中医健康顾问，可以为您提供：

📜 **中医理论解读**
• 阴阳五行学说
• 脏腑经络理论
• 病因病机分析

🌿 **中药与方剂**
• 常用中药材功效
• 经典方剂应用
• 中药煎服方法

🙌 **传统疗法指导**
• 穴位按摩技巧
• 艾灸拔罐方法
• 刮痧推拿手法

🍵 **养生食疗推荐**
• 体质辨识调理
• 四季养生要点
• 药膳食谱分享

请问您想了解哪方面的内容？${this.getDisclaimer()}`;
  }
}

export class NutritionAgent extends MedicalAgent {
  private keywords: string[] = [
    '营养', '饮食', '维生素', '蛋白质', '脂肪', '碳水',
    '减肥', '增肌', '膳食', '食物', '热量', '营养素',
    '矿物质', '膳食纤维', '抗氧化', '补充剂', '食谱'
  ];

  constructor() {
    const config: AgentConfig = {
      name: '营养师',
      description: '擅长营养评估、膳食规划和健康饮食指导',
      specialty: 'nutrition',
      systemPrompt: `你是一位专业的注册营养师AI助手，专注于：
1. 营养素知识与功能介绍
2. 个性化膳食规划
3. 特殊人群营养需求
4. 健康体重管理
5. 营养缺乏症预防

回答要求：
- 数据准确，引用权威标准
- 方案可操作性强
- 强调均衡饮食的重要性
- 提供具体的食物选择建议`,
      temperature: 0.65,
      maxTokens: 1000
    };
    super(config);
  }

  canHandle(query: string): boolean {
    const lowerQuery: string = query.toLowerCase();
    for (const keyword of this.keywords) {
      if (lowerQuery.indexOf(keyword) >= 0) {
        return true;
      }
    }
    return false;
  }

  protected async generateResponse(prompt: string): Promise<string> {
    const lowerQuery: string = prompt.toLowerCase();

    if (lowerQuery.indexOf('老年') >= 0 || lowerQuery.indexOf('老人') >= 0) {
      return this.generateElderlyNutritionResponse();
    }

    if (lowerQuery.indexOf('减肥') >= 0 || lowerQuery.indexOf('减脂') >= 0 || lowerQuery.indexOf('体重') >= 0) {
      return this.generateWeightManagementResponse();
    }

    if (lowerQuery.indexOf('维生素') >= 0 || lowerQuery.indexOf('矿物质') >= 0) {
      return this.generateMicronutrientResponse();
    }

    if (lowerQuery.indexOf('糖尿病') >= 0 || lowerQuery.indexOf('血糖') >= 0) {
      return this.generateDiabeticDietResponse();
    }

    if (lowerQuery.indexOf('食谱') >= 0 || lowerQuery.indexOf('吃') >= 0) {
      return this.generateMealPlanningResponse();
    }

    return this.generateGeneralNutritionResponse();
  }

  private generateElderlyNutritionResponse(): string {
    return `**老年人营养需求与膳食指南：**

👴 **生理特点与需求变化**
• 基础代谢率降低10-20%
• 消化吸收能力减弱
• 肌肉量减少（肌少症风险）
• 钙流失加速（骨质疏松）

📊 **每日推荐摄入量**
| 营养素 | 推荐量 | 优质来源 |
|--------|--------|----------|
| 蛋白质 | 1.0-1.2g/kg | 鱼、禽、蛋、奶、豆 |
| 钙 | 1200mg | 牛奶、酸奶、豆腐 |
| 维生素D | 800-1000IU | 蛋黄、鱼类、补充剂 |
| 膳食纤维 | 25-30g | 全谷物、蔬果 |
| 水分 | 1500-1700ml | 水、汤、淡茶 |

🍽️ **饮食原则**
1. **少量多餐**：一日4-5餐，每餐七分饱
2. **优质蛋白优先**：每餐包含一种高蛋白食物
3. **软烂易消化**：烹饪方式以蒸煮炖为主
4. **充足钙质**：每天300-500ml奶制品
5. **限制"三高"**：低盐(<6g)、低糖、低脂

⚠️ **需要关注的营养素**
• 维生素B12（吸收下降）→ 补充剂或强化食品
• 维生素D（日照减少）→ 适当日晒+补充
• 蛋白质（合成减少）→ 分散到各餐摄入

${this.getDisclaimer()}`;
  }

  private generateWeightManagementResponse(): string {
    return `**科学减重营养方案：**

⚖️ **能量平衡原理**
• 减重核心：消耗 > 摄入
• 安全减重速度：每周0.5-1kg
• 每1kg脂肪 ≈ 7700千卡热量缺口

🔢 **计算您的目标热量**
• 基础代谢(BMR)：男性=10×体重(kg)+6.25×身高(cm)-5×年龄+5
• 每日总消耗(TDEE)=BMR×活动系数(1.2-1.9)
• 减重摄入=TDEE-500kcal

🥗 **减重膳食结构**
• 碳水化合物：45-50%（优选复合碳水）
• 蛋白质：25-30%（增加饱腹感）
• 脂肪：25-30%（控制总量）

📋 **实操建议**
1. **早餐必吃**：启动代谢，防止暴食
2. **餐盘法则**：1/2蔬菜+1/4蛋白+1/4主食
3. **进食顺序**：汤→菜→肉→主食
4. **细嚼慢咽**：每口咀嚼20次以上
5. **饮水充足**：餐前一杯水增加饱腹感

🚫 **应避免的食物**
• 含糖饮料（奶茶、可乐）
• 加工零食（薯片、饼干）
• 油炸食品
• 精制甜点

${this.getDisclaimer()}`;
  }

  private generateMicronutrientResponse(): string {
    return `**重要微量营养素详解：**

💊 **脂溶性维生素**
• **维生素A**：维持视力、免疫功能
  - RNI：800μgRAE/天
  - 来源：肝脏、胡萝卜、蛋黄
• **维生素D**：钙磷代谢、骨骼健康
  - RNI：10μg/天（成人）
  - 来源：日光照射、深海鱼
• **维生素E**：抗氧化、保护细胞
  - AI：14mgα-TE/天
  - 来源：坚果、植物油

💧 **水溶性维生素**
• **维生素B族**：能量代谢关键
  - B1(硫胺素)：粗粮、瘦肉
  - B2(核黄素)：奶类、绿叶菜
  - B12：动物性食品（素食者需补充）
• **维生素C**：胶原蛋白合成、免疫力
  - RNI：100mg/天
  - 来源：新鲜果蔬（猕猴桃、柑橘）

🏋️‍♂️ **重要矿物质**
• **钙**：骨骼牙齿、肌肉收缩（1000mg/天）
• **铁**：造血、携氧（男性12mg，女性20mg）
• **锌**：免疫、伤口愈合（12.5mg/天）
• **镁**：神经肌肉功能（330mg/天）

${this.getDisclaimer()}`;
  }

  private generateDiabeticDietResponse(): string {
    return `**糖尿病患者饮食管理：**

🎯 **血糖控制目标**
• 空腹：4.4-7.0 mmol/L
• 餐后2h：<10.0 mmol/L
• HbA1c：<7.0%

🍽️ **碳水化合物管理**
1. **控制总量**：每日200-300g（个体化调整）
2. **选择低GI食物**：
   - ✅ 推荐：燕麦、糙米、豆类、非淀粉蔬菜
   - ❌ 避免：白米饭、馒头、甜点、含糖饮料
3. **分散摄入**：少食多餐，避免单餐过量

🥩 **蛋白质选择**
• 优质来源：鱼、禽、蛋、奶、大豆
• 每日摄入：1.0-1.2g/kg理想体重
• 限制加工肉类（香肠、培根）

🥬 **膳食纤维的作用**
• 目标量：25-30g/天
• 作用：延缓葡萄糖吸收、增加饱腹感
• 来源：全谷物、豆类、蔬菜、水果

📝 **实用技巧**
• 学会看营养成分表
• 使用食物交换份法
• 记录饮食日记监测血糖反应

${this.getDisclaimer()}`;
  }

  private generateMealPlanningResponse(): string {
    return `**健康膳食搭配示例：**

🌅 **早餐方案（约400-500kcal）**
• 全麦面包2片 + 煮鸡蛋1个
• 牛奶250ml + 圣女果5颗
• 或：燕麦片40g + 低脂牛奶 + 蓝莓

☀️ **午餐方案（约600-700kcal）**
• 杂粮饭150g（糙米+小米）
• 清蒸鱼150g（或少油炒鸡胸肉）
• 蒜蓉西兰花200g
• 紫菜蛋花汤一碗

🌙 **晚餐方案（约500-600kcal）**
• 豆腐100g + 蔬菜沙拉
• 玉米半根 + 小番茄
• 或：杂粮粥1碗 + 凉拌三丝

🍎 **加餐选择（可选）**
• 上午10点：坚果一小把（约15g）
• 下午3点：水果一个（苹果/梨）
• 睡前：无糖酸奶100g

💡 **一周饮食多样化原则**
• 每周至少25种不同食物
• 每天5种颜色的蔬果
• 主食粗细搭配，荤素结合

${this.getDisclaimer()}`;
  }

  private generateGeneralNutritionResponse(): string {
    return `作为您的专属营养师，我可以帮您：

📊 **营养状况评估**
• 分析当前饮食习惯
• 识别潜在的营养不足
• 制定改进计划

🍽️ **个性化膳食规划**
• 根据年龄、性别、活动量定制
• 慢性病特殊饮食方案
• 减重/增肌营养支持

📚 **营养知识科普**
• 七大营养素的功能与来源
• 食物标签解读技巧
• 健康烹饪方法

💊 **补充剂指导**
• 是否需要额外补充
• 如何选择安全有效的产品

请告诉我您的具体情况（年龄、身高体重、健康状况、饮食偏好），我会为您制定更精准的营养方案！

${this.getDisclaimer()}`;
  }
}

export class RehabAgent extends MedicalAgent {
  private keywords: string[] = [
    '康复', '运动', '锻炼', '训练', '物理治疗', '运动处方',
    '拉伸', '力量', '有氧', '柔韧性', '健身', '颈椎',
    '腰椎', '肩周炎', '关节炎', '疼痛', '姿势'
  ];

  constructor() {
    const config: AgentConfig = {
      name: '康复治疗师',
      description: '擅长运动康复、物理治疗和运动处方制定',
      specialty: 'rehab',
      systemPrompt: `你是一位专业的康复治疗师AI助手，专精于：
1. 运动处方制定（FITT原则）
2. 常见肌骨问题康复指导
3. 功能训练方案设计
4. 慢性疼痛自我管理
5. 颈肩腰腿保健操

回答要求：
- 运动方案安全有效、循序渐进
- 动作描述清晰易懂
- 明确强度、频率、时间参数
- 强调注意事项和安全警示`,
      temperature: 0.6,
      maxTokens: 1000
    };
    super(config);
  }

  canHandle(query: string): boolean {
    const lowerQuery: string = query.toLowerCase();
    for (const keyword of this.keywords) {
      if (lowerQuery.indexOf(keyword) >= 0) {
        return true;
      }
    }
    return false;
  }

  protected async generateResponse(prompt: string): Promise<string> {
    const lowerQuery: string = prompt.toLowerCase();

    if (lowerQuery.indexOf('运动') >= 0 || lowerQuery.indexOf('锻炼') >= 0 || lowerQuery.indexOf('健身') >= 0) {
      return this.generateExercisePrescriptionResponse();
    }

    if (lowerQuery.indexOf('颈椎') >= 0 || lowerQuery.indexOf('脖子') >= 0 || lowerQuery.indexOf('颈肩') >= 0) {
      return this.generateCervicalSpineResponse();
    }

    if (lowerQuery.indexOf('腰椎') >= 0 || lowerQuery.indexOf('腰痛') >= 0 || lowerQuery.indexOf('腰部') >= 0) {
      return this.generateLumbarSpineResponse();
    }

    if (lowerQuery.indexOf('膝盖') >= 0 || lowerQuery.indexOf('膝关节') >= 0 || lowerQuery.indexOf(' arthritis') >= 0) {
      return this.generateKneeRehabResponse();
    }

    if (lowerQuery.indexOf('老人') >= 0 || lowerQuery.indexOf('老年') >= 0) {
      return this.generateElderlyRehabResponse();
    }

    return this.generateGeneralRehabResponse();
  }

  private generateExercisePrescriptionResponse(): string {
    return `**科学运动处方（FITT原则）：**

📋 **FITT五要素**
• **F-Frequency（频率）**：每周运动次数
• **I-Intensity（强度）**：运动负荷大小
• **T-Time（时间）**：每次运动时长
• **T-Type（类型）**：运动方式选择
• **V-Volume（总量）**：每周总运动量

🏃‍♂️ **推荐运动方案**

**有氧运动（基础）**
• 频率：每周3-5次
• 强度：心率=(220-年龄)×60-80%
• 时间：30-60分钟/次
• 类型：快走、慢跑、游泳、骑车

**抗阻训练（增肌/塑形）**
• 频率：每周2-3次（隔日进行）
• 强度：8-12RM（每组能做8-12次的重量）
• 组数：每个动作2-3组
• 类型：器械训练或自重训练

**柔韧性训练（必备）**
• 频率：每天
• 时间：10-15分钟
• 类型：静态拉伸、瑜伽

📅 **周训练示例**
| 周一 | 周二 | 周三 | 周四 | 周五 | 周六 | 周日 |
|------|------|------|------|------|------|------|
| 有氧 | 抗阻 | 休息/瑜伽 | 有氧 | 抗阻 | 户外活动 | 完全休息 |

⚠️ **安全提示**
• 运动前热身5-10分钟
• 出现不适立即停止
• 循序渐进增加负荷

${this.getDisclaimer()}`;
  }

  private generateCervicalSpineResponse(): string {
    return `**颈椎保健与康复方案：**

⚠️ **危险信号（需立即就医）**
• 手臂放射性麻木疼痛
• 行走不稳、踩棉花感
• 头晕伴恶心呕吐

🧘 **颈椎保健操（每天2组）**

**1. 颈部环绕**
• 动作：缓慢转头画圆（顺逆各5圈）
• 要领：动作轻缓，幅度适中
• 时长：1分钟

**2. 抗阻训练**
• 动作：手抵额头/后脑/侧头，头用力对抗手的阻力
• 组数：每个方向保持5秒×5次
• 作用：增强颈部肌肉力量

**3. 收下巴**
• 动作：水平向后收下巴（做出双下巴）
• 保持：5秒×10次
• 作用：纠正头前伸姿势

**4. 肩胛骨活动**
• 动作：耸肩→下沉→前旋→后旋
• 次数：各方向10次

💻 **办公族预防建议**
• 显示器高度与视线平齐
• 每45分钟起身活动
• 手机举到视线高度使用
• 选择支撑性好的枕头

${this.getDisclaimer()}`;
  }

  private generateLumbarSpineResponse(): string {
    return `**腰椎保健与腰痛康复：**

🚨 **红旗征（需就医）**
• 腿部放射痛至膝以下
• 会阴区麻木/大小便异常
• 夜间静息痛（躺下也痛）

🏃 **急性期处理（48小时内）**
1. 卧床休息（硬板床）
2. 冷敷：冰袋15-20分钟，间隔2小时
3. 避免弯腰提重物
4. 可佩戴腰围保护

💪 **康复期训练（疼痛缓解后）**

**1. 麦肯基伸展**
• 俯卧位，双手撑起上半身
• 保持髋部贴地
• 重复10次×3组

**2. 臀桥**
• 仰卧屈膝，抬起臀部
• 保持5秒，感受臀部发力
• 15次×3组

**3. 鸟狗式**
• 四肢着地，对侧手脚伸直
• 保持5秒，左右交替
• 每侧10次×3组

**4. 死虫子**
• 仰卧四肢朝天，交替放低对侧手脚
• 核心收紧，腰部不离地
• 每侧10次×3组

🪑 **日常姿势建议**
• 坐姿时腰部要有支撑
• 避免久坐（每45分钟起来活动）
• 搬重物时先蹲下再起立

${this.getDisclaimer()}`;
  }

  private generateKneeRehabResponse(): string {
    return `**膝关节康复与保护方案：**

🦵 **膝关节常见问题**
• 髌股疼痛综合征（跑步膝）
• 半月板损伤
• 骨关节炎
• 韧带损伤

💪 **康复训练计划**

**阶段1：急性期（疼痛明显）**
• RICE原则：休息、冰敷、加压、抬高
• 避免深蹲、跳跃、下山
• 等长收缩：靠墙静蹲（角度从小开始）

**阶段2：亚急性期（疼痛减轻）**
• 直腿抬高：15次×3组
• 短弧终末伸膝：最后30°范围
• 静态自行车（低阻力）

**阶段3：强化期（无痛或微痛）**
• 深蹲（渐进增加角度）
• 弓步蹲：每侧12次×3组
• 登台阶训练
• 臀中肌训练（弹力带侧向走）

🛡️ **日常保护策略**
• 控制体重（每超重1kg=膝盖多承受3-4kg压力）
• 穿合适的鞋子（良好的足弓支撑）
• 避免长时间跪姿
• 运动前充分热身
• 加强臀部和髋部肌肉训练

${this.getDisclaimer()}`;
  }

  private generateElderlyRehabResponse(): string {
    return `**老年人运动康复方案：**

🎯 **运动目标**
• 维持肌肉量和骨密度
• 预防跌倒（平衡训练）
• 保持心肺功能
• 改善关节灵活性

📋 **推荐运动组合**

**有氧运动（每周150分钟）**
✅ **最佳选择**
• 快走（最安全有效）
• 太极拳（身心兼修）
• 游泳（关节负担小）
• 广场舞（社交+运动）

**抗阻训练（每周2-3次）**
• 弹力带训练（安全易行）
• 自重深蹲（扶椅辅助）
• 握力训练（预防 sarcopenia）
• 每个动作8-12次×2组

**平衡训练（每天5-10分钟）**
• 单脚站立（扶墙开始）
• 脚跟-脚尖踮步走
• 太极基本动作

**柔韧性训练（每天）**
• 颈部、肩部、躯干、下肢拉伸
• 每个部位保持15-30秒

⚠️ **特别注意事项**
• 从低强度开始循序渐进
• 运动前后充分热身和整理
• 避免憋气（Valsalva动作）
• 保证水分补充
• 有心血管疾病者需医生评估后再开始

${this.getDisclaimer()}`;
  }

  private generateGeneralRehabResponse(): string {
    return `作为您的康复治疗师，我可以提供：

🏥 **康复评估与方案**
• 肌骨系统功能评估
• 个性化康复计划制定
• 进展跟踪与方案调整

🏃‍♂️ **专项康复指导**
• 颈椎病康复训练
• 腰椎间盘突出康复
• 膝关节术后康复
• 肩周炎功能训练
• 运动损伤恢复

📋 **运动处方服务**
• 健身计划制定
• 减脂/增肌方案
• 慢性病运动指导
• 老年人防跌倒训练

💡 **健康教育**
• 正确的坐站行走姿势
• 人体工学环境设置
• 日常保健习惯养成

请告诉我您的主要问题或康复目标，我会为您制定详细的训练方案！

${this.getDisclaimer()}`;
  }
}
