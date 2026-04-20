import { RiskItem } from '../ai/RiskAssessmentEngine';

@Component
export struct RiskCard {
  @Prop risk: RiskItem = {
    disease: '',
    label: '',
    probability: 0,
    level: 'LOW',
    color: '#52C41A',
    factors: [],
    evidence: ''
  };
  @Prop compact: boolean = false;
  
  private onClickCallback?: (risk: RiskItem) => void = undefined;

  build() {
    Column() {
      if (this.compact) {
        this.buildCompactCard()
      } else {
        this.buildDetailedCard()
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: this.risk.probability > 0.6 ? 8 : 4,
      color: this.risk.probability > 0.6 ? 
        `${this.risk.color}25` : 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .border({
      width: this.risk.probability > 0.6 ? 2 : 1,
      color: this.risk.probability > 0.6 ? 
        `${this.risk.color}40` : 'rgba(0,0,0,0.06)'
    })
    .onClick(() => {
      if (this.onClickCallback && this.risk) {
        this.onClickCallback(this.risk);
      }
    })
  }

  @Builder buildCompactCard() {
    Row({ space: 10 }) {
      Column({ space: 6 }) {
        Text(this.getIcon())
          .fontSize(24)
        
        Text(`${Math.round(this.risk.probability * 100)}%`)
          .fontSize(18)
          .fontColor(this.risk.color)
          .fontWeight(FontWeight.Bold)
      }
      .width(60)
      
      Column({ space: 4 }) {
        Text(this.risk.label)
          .fontSize(15)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        
        Text(this.getLevelText())
          .fontSize(12)
          .fontColor(this.risk.color)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      if (this.risk.probability > 0.5) {
        Text('⚠️')
          .fontSize(20)
      }
    }
    .width('100%')
    .padding(14)
  }

  @Builder buildDetailedCard() {
    Column({ space: 12 }) {
      Row() {
        Text(this.getIcon())
          .fontSize(28)
        
        Column({ space: 4 }) {
          Text(this.risk.label)
            .fontSize(17)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
          
          Text(this.getLevelText())
            .fontSize(13)
            .fontColor(this.risk.color)
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Column({ space: 2 }) {
          Text(`${Math.round(this.risk.probability * 100)}%`)
            .fontSize(28)
            .fontColor(this.risk.color)
            .fontWeight(FontWeight.Bold)
          
          Text('风险值')
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Progress({ 
        value: this.risk.probability * 100, 
        total: 100, 
        type: ProgressType.Ring 
      })
        .color(this.risk.color)
        .backgroundColor('#F0F0F0')
        .width(60)
        .height(60)
        .style({ strokeWidth: 5 })

      if (this.risk.evidence && this.risk.evidence.length > 0) {
        Column({ space: 6 }) {
          Text('📋 判定依据')
            .fontSize(13)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)
          
          Text(this.risk.evidence)
            .fontSize(13)
            .fontColor('#555555')
            .lineHeight(18)
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
      }

      if (this.risk.factors && this.risk.factors.length > 0) {
        Column({ space: 8 }) {
          Text(`⚡ 风险因素 (${this.risk.factors.length}项)`)
            .fontSize(13)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)
          
          ForEach(this.risk.factors.slice(0, 3), (factor: string, index: number) => {
            Row({ space: 6 }) {
              Text((index + 1).toString())
                .fontSize(11)
                .fontColor('#FFFFFF')
                .backgroundColor(this.risk.color)
                .width(16)
                .height(16)
                .borderRadius(8)
                .textAlign(TextAlign.Center)
              
              Text(factor)
                .fontSize(12)
                .fontColor('#555555')
                .layoutWeight(1)
            }
            .width('100%')
          })
          
          if (this.risk.factors.length > 3) {
            Text(`...还有${this.risk.factors.length - 3}项风险因素`)
              .fontSize(11)
              .fontColor(this.risk.color)
              .textAlign(TextAlign.Center)
              .margin({ top: 4 })
          }
        }
        .width('100%')
      }

      if (this.risk.probability >= 0.7) {
        Row({ space: 8 }) {
          Text('🔔')
            .fontSize(16)
          
          Text('建议尽快就医检查')
            .fontSize(13)
            .fontColor(this.risk.color)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding(10)
        .backgroundColor(`${this.risk.color}10`)
        .borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
  }

  private getIcon(): string {
    switch (this.risk.disease) {
      case 'hypertension': return '💓';
      case 'diabetes': return '🩸';
      case 'fall': return '⚠️';
      case 'frailty': return '👴';
      case 'sarcopenia': return '💪';
      default: return '📊';
    }
  }

  private getLevelText(): string {
    switch (this.risk.level) {
      case 'LOW': return '✅ 低风险';
      case 'MEDIUM': return '⚡ 中等风险';
      case 'HIGH': return '🔴 高风险';
      case 'CRITICAL': return '⛔ 极高风险';
      default: return '';
    }
  }
}
