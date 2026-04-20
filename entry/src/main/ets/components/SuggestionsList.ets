import { Suggestion } from '../ai/RiskAssessmentEngine';

@Component
export struct SuggestionsList {
  @Prop suggestions: Suggestion[] = [];
  @Prop showCategory: boolean = true;
  @Prop maxItems: number = 10;
  
  expandedCategories: string[] = [];
  groupedData: Record<string, Suggestion[]> = {};
  categoryList: string[] = [];

  aboutToAppear(): void {
    this.prepareGroupedData();
  }

  prepareGroupedData(): void {
    this.groupedData = {};
    
    for (const suggestion of this.suggestions) {
      const category = suggestion.category || '其他';
      
      if (!this.groupedData[category]) {
        this.groupedData[category] = [];
      }
      
      this.groupedData[category].push(suggestion);
    }

    this.categoryList = Object.keys(this.groupedData);
  }

  build() {
    if (!this.suggestions || this.suggestions.length === 0) {
      this.buildEmptyView()
    } else {
      if (this.showCategory) {
        this.buildGroupedView()
      } else {
        this.buildListView()
      }
    }
  }

  @Builder buildEmptyView() {
    Column({ space: 12 }) {
      Text('💡')
        .fontSize(36)
      
      Text('暂无建议')
        .fontSize(16)
        .fontColor('#999999')
      
      Text('评估完成后将显示个性化健康建议')
        .fontSize(13)
        .fontColor('#BBBBBB')
    }
    .width('100%')
    .padding(40)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildGroupedView() {
    Column({ space: 0 }) {
      ForEach(this.categoryList, (category: string) => {
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text(this.getCategoryIcon(category))
              .fontSize(18)
            
            Text(category)
              .fontSize(15)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
            
            Blank()
            
            Text(`${this.groupedData[category].length}条`)
              .fontSize(11)
              .fontColor('#999999')
              .backgroundColor('#F5F5F5')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(10)
          }
          .width('100%')
          .padding({ left: 4, right: 4, top: 8 })
          
          ForEach(this.getSuggestionsForCategory(category), 
            (suggestion: Suggestion, index: number) => {
              this.buildSuggestionItem(suggestion, index)
            }
          )
        }
        .width('100%')
        .margin({ bottom: 12 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({
          radius: 3,
          color: 'rgba(0,0,0,0.04)',
          offsetX: 0,
          offsetY: 1
        })
      })
    }
    .width('100%')
  }

  getSuggestionsForCategory(category: string): Suggestion[] {
    return (this.groupedData[category] || []).slice(0, this.maxItems);
  }

  @Builder buildListView() {
    List({ space: 8 }) {
      ForEach(this.suggestions.slice(0, this.maxItems), 
        (suggestion: Suggestion, index: number) => {
          ListItem() {
            this.buildSuggestionItem(suggestion, index)
          }
        }
      )
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder buildSuggestionItem(suggestion: Suggestion, index: number) {
    Row({ space: 10 }) {
      Column({ space: 4 }) {
        Text(this.getPriorityIcon(suggestion.priority))
          .fontSize(18)
        
        Text((index + 1).toString())
          .fontSize(11)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .width(18)
          .height(18)
          .borderRadius(9)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.getPriorityColor(suggestion.priority))
      }
      .width(28)

      Column({ space: 4 }) {
        Row({ space: 6 }) {
          Text(suggestion.content)
            .fontSize(14)
            .fontColor('#333333')
            .lineHeight(20)
            .layoutWeight(1)
          
          if (suggestion.targetDisease) {
            Text(this.getDiseaseLabel(suggestion.targetDisease))
              .fontSize(11)
              .fontColor('#1677FF')
              .backgroundColor('#E6F4FF')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
          }
        }
        .width('100%')

        Row({ space: 6 }) {
          Text(this.getPriorityText(suggestion.priority))
            .fontSize(11)
            .fontColor(this.getPriorityColor(suggestion.priority))
          
          if (this.showCategory) {
            Text(suggestion.category)
              .fontSize(11)
              .fontColor('#999999')
          }
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .margin({ left: 12, right: 12, top: 4, bottom: 4 })
    .backgroundColor(index % 2 === 0 ? '#FAFAFA' : '#FFFFFF')
    .borderRadius(8)
  }

  getPriorityIcon(priority: 'HIGH' | 'MEDIUM' | 'LOW'): string {
    switch (priority) {
      case 'HIGH': return '🔴';
      case 'MEDIUM': return '🟡';
      case 'LOW': return '🟢';
      default: return '⚪';
    }
  }

  getPriorityColor(priority: 'HIGH' | 'MEDIUM' | 'LOW'): string {
    switch (priority) {
      case 'HIGH': return '#FF4D4F';
      case 'MEDIUM': return '#FAAD14';
      case 'LOW': return '#52C41A';
      default: return '#999999';
    }
  }

  getPriorityText(priority: 'HIGH' | 'MEDIUM' | 'LOW'): string {
    switch (priority) {
      case 'HIGH': return '高优先级';
      case 'MEDIUM': return '中优先级';
      case 'LOW': return '低优先级';
      default: return '';
    }
  }

  getCategoryIcon(category: string): string {
    const iconMap: Record<string, string> = {
      '血压管理': '💓',
      '血糖管理': '🩸',
      '饮食调整': '🥗',
      '生活方式': '🏃',
      '运动训练': '💪',
      '安全防护': '🛡️',
      '运动处方': '🏋️',
      '营养干预': '🍎',
      '肌肉健康': '💊',
      '运动建议': '🚶',
      '睡眠管理': '😴',
      '系统错误': '❌'
    };

    return iconMap[category] || '💡';
  }

  getDiseaseLabel(diseaseKey: string): string {
    const labelMap: Record<string, string> = {
      'hypertension': '高血压',
      'diabetes': '糖尿病',
      'fall': '跌倒风险',
      'frailty': '衰弱',
      'sarcopenia': '肌少症'
    };

    return labelMap[diseaseKey] || diseaseKey;
  }
}
