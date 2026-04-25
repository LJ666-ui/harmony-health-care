import { GlobalTheme } from '../global';

export interface OrganPosition {
  x: number;
  y: number;
}

export interface OrganInfo {
  id: string;
  name: string;
  nameEn: string;
  icon: string;
  category: 'cardiovascular' | 'respiratory' | 'digestive' | 'nervous' | 'urinary' | 'endocrine';
  position: OrganPosition;
  normalRange: string;
  riskFactors: string[];
  symptoms: string[];
}

export interface OrganHealthData {
  organId: string;
  healthScore: number;
  status: 'healthy' | 'sub_healthy' | 'high_risk' | 'diseased';
  metrics: OrganMetric[];
  lastCheckDate: string;
}

export interface OrganMetric {
  name: string;
  value: number;
  unit: string;
  normalMin: number;
  normalMax: number;
  isNormal: boolean;
}

@Component
export struct OrganVisualizer {
  @Prop organs: OrganHealthData[] = [];
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  private heartPos: OrganPosition = { x: 0, y: 180 };
  private lungsPos: OrganPosition = { x: -25, y: 175 };
  private liverPos: OrganPosition = { x: 15, y: 220 };
  private kidneyPos: OrganPosition = { x: 0, y: 260 };
  private brainPos: OrganPosition = { x: 0, y: 60 };
  private pancreasPos: OrganPosition = { x: -20, y: 235 };

  private heartRiskFactors: string[] = ['高血压', '高血脂', '吸烟', '肥胖', '缺乏运动'];
  private heartSymptoms: string[] = ['胸痛', '心悸', '呼吸困难', '疲劳'];
  private lungsRiskFactors: string[] = ['吸烟', '空气污染', '职业暴露', '呼吸道感染'];
  private lungsSymptoms: string[] = ['咳嗽', '咳痰', '气短', '胸闷'];
  private liverRiskFactors: string[] = ['饮酒', '脂肪肝', '病毒性肝炎', '药物损伤'];
  private liverSymptoms: string[] = ['乏力', '食欲不振', '黄疸', '腹胀'];
  private kidneyRiskFactors: string[] = ['高血压', '糖尿病', '肾结石', '药物毒性'];
  private kidneySymptoms: string[] = ['水肿', '尿量异常', '腰痛', '泡沫尿'];
  private brainRiskFactors: string[] = ['高血压', '糖尿病', '动脉硬化', '睡眠障碍'];
  private brainSymptoms: string[] = ['头痛', '记忆力下降', '注意力不集中', '情绪波动'];
  private pancreasRiskFactors: string[] = ['肥胖', '酗酒', '胆石症', '遗传'];
  private pancreasSymptoms: string[] = ['腹痛', '恶心', '血糖波动', '消化不良'];

  private organDefinitions: OrganInfo[] = [
    {
      id: 'heart',
      name: '心脏',
      nameEn: 'Heart',
      icon: '❤️',
      category: 'cardiovascular',
      position: this.heartPos,
      normalRange: '心率60-100次/分',
      riskFactors: this.heartRiskFactors,
      symptoms: this.heartSymptoms
    },
    {
      id: 'lungs',
      name: '肺部',
      nameEn: 'Lungs',
      icon: '🫁',
      category: 'respiratory',
      position: this.lungsPos,
      normalRange: '血氧95-100%',
      riskFactors: this.lungsRiskFactors,
      symptoms: this.lungsSymptoms
    },
    {
      id: 'liver',
      name: '肝脏',
      nameEn: 'Liver',
      icon: '🟤',
      category: 'digestive',
      position: this.liverPos,
      normalRange: 'ALT<40U/L',
      riskFactors: this.liverRiskFactors,
      symptoms: this.liverSymptoms
    },
    {
      id: 'kidney',
      name: '肾脏',
      nameEn: 'Kidney',
      icon: '🫘',
      category: 'urinary',
      position: this.kidneyPos,
      normalRange: '肌酐44-133μmol/L',
      riskFactors: this.kidneyRiskFactors,
      symptoms: this.kidneySymptoms
    },
    {
      id: 'brain',
      name: '大脑',
      nameEn: 'Brain',
      icon: '🧠',
      category: 'nervous',
      position: this.brainPos,
      normalRange: '认知功能正常',
      riskFactors: this.brainRiskFactors,
      symptoms: this.brainSymptoms
    },
    {
      id: 'pancreas',
      name: '胰腺',
      nameEn: 'Pancreas',
      icon: '🔶',
      category: 'endocrine',
      position: this.pancreasPos,
      normalRange: '血糖3.9-6.1mmol/L',
      riskFactors: this.pancreasRiskFactors,
      symptoms: this.pancreasSymptoms
    }
  ];

  getStatusColor(status: string): string {
    switch (status) {
      case 'healthy':
        return '#52C41A';
      case 'sub_healthy':
        return '#FAAD14';
      case 'high_risk':
        return '#FF7A45';
      case 'diseased':
        return '#FF4D4F';
      default:
        return '#999999';
    }
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'healthy':
        return '健康';
      case 'sub_healthy':
        return '亚健康';
      case 'high_risk':
        return '高危';
      case 'diseased':
        return '异常';
      default:
        return '未知';
    }
  }

  getOrganDefinition(organId: string): OrganInfo | null {
    for (let i = 0; i < this.organDefinitions.length; i++) {
      if (this.organDefinitions[i].id === organId) {
        return this.organDefinitions[i];
      }
    }
    return null;
  }

  getOverallHealthScore(): number {
    if (this.organs.length === 0) {
      return 100;
    }

    let totalScore: number = 0;
    for (let i = 0; i < this.organs.length; i++) {
      totalScore += this.organs[i].healthScore;
    }
    return Math.round(totalScore / this.organs.length);
  }

  getOverallStatus(): string {
    const score: number = this.getOverallHealthScore();
    if (score >= 85) {
      return 'healthy';
    } else if (score >= 70) {
      return 'sub_healthy';
    } else if (score >= 50) {
      return 'high_risk';
    } else {
      return 'diseased';
    }
  }

  getCategoryName(category: string): string {
    switch (category) {
      case 'cardiovascular':
        return '心血管系统';
      case 'respiratory':
        return '呼吸系统';
      case 'digestive':
        return '消化系统';
      case 'nervous':
        return '神经系统';
      case 'urinary':
        return '泌尿系统';
      case 'endocrine':
        return '内分泌系统';
      default:
        return '其他';
    }
  }

  build() {
    Column() {
      Row() {
        Text('器官健康总览')
          .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.TEXT_PRIMARY)

        Blank()

        Row() {
          Text(`综合评分: ${this.getOverallHealthScore()}分`)
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getStatusColor(this.getOverallStatus()))

          Text(this.getStatusText(this.getOverallStatus()))
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#FFFFFF')
            .backgroundColor(this.getStatusColor(this.getOverallStatus()))
            .borderRadius(10)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .margin({ bottom: 16 })

      List({ space: 12 }) {
        ForEach(this.organs, (organ: OrganHealthData, index: number) => {
          ListItem() {
            this.OrganCard(organ)
          }
        }, (organ: OrganHealthData, index: number) => `${index}`)
      }
      .layoutWeight(1)
      .width('100%')

      if (this.organs.length === 0) {
        Column() {
          Text('暂无器官数据')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_HINT)
          Text('请完善个人健康档案以获取器官分析')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_LIGHT)
            .margin({ top: 4 })
        }
        .height(200)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  OrganCard(organ: OrganHealthData) {
    Column() {
      Row() {
        Text(this.getOrganDefinition(organ.organId)?.icon || '🏥')
          .fontSize(28)

        Column() {
          Text(this.getOrganDefinition(organ.organId)?.name || '未知器官')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight(FontWeight.Medium)
            .fontColor(GlobalTheme.TEXT_PRIMARY)

          if (this.getOrganDefinition(organ.organId)) {
            Text(this.getCategoryName(this.getOrganDefinition(organ.organId)!.category))
              .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)

        Column() {
          Text(`${organ.healthScore}`)
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getStatusColor(organ.status))

          Text(this.getStatusText(organ.status))
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor(this.getStatusColor(organ.status))
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      if (organ.metrics && organ.metrics.length > 0) {
        Row({ space: 12 }) {
          ForEach(organ.metrics.slice(0, 3), (metric: OrganMetric, mIndex: number) => {
            Column() {
              Text(metric.name)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY)

              Text(`${metric.value}${metric.unit}`)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontWeight(FontWeight.Medium)
                .fontColor(metric.isNormal ? GlobalTheme.SUCCESS_COLOR : GlobalTheme.ERROR_COLOR)
            }
            .alignItems(HorizontalAlign.Center)
            .flexGrow(1)
          }, (metric: OrganMetric, mIndex: number) => `${mIndex}`)
        }
        .width('100%')
        .margin({ top: 12 })
        .padding(10)
        .backgroundColor('#F5F7FA')
        .borderRadius(8)
      }

      if (this.getOrganDefinition(organ.organId) && this.getOrganDefinition(organ.organId)!.normalRange) {
        Row() {
          Text('参考范围:')
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
          Text(this.getOrganDefinition(organ.organId)!.normalRange)
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ left: 4 })
        }
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
  }
}
