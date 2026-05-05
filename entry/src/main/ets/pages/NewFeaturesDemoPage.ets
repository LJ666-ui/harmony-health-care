/**
 * 新功能展示页面
 * New Features Demo Page
 * 
 * 展示RAG检索、无障碍组件、图表组件的使用示例
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

// 导入无障碍组件
import { AccessibleButton, AccessibleText, AccessibleCard } from '../components/AccessibleComponents';

// 导入图表组件
import { HealthLineChart, HealthGauge, HealthRadarChart } from '../components/ChartComponents';
import type { ChartDataPoint, RadarDimension } from '../components/ChartComponents';

@Entry
@Component
export struct NewFeaturesDemoPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentTab: number = 0;

  // 折线图数据
  private lineChartData: ChartDataPoint[] = [
    { x: 1, y: 120 },
    { x: 2, y: 125 },
    { x: 3, y: 118 },
    { x: 4, y: 130 },
    { x: 5, y: 128 },
    { x: 6, y: 135 },
    { x: 7, y: 132 }
  ];

  // 雷达图数据
  private radarData: RadarDimension[] = [
    { name: '血压', value: 85, maxValue: 100 },
    { name: '血糖', value: 70, maxValue: 100 },
    { name: '心率', value: 90, maxValue: 100 },
    { name: '体重', value: 75, maxValue: 100 },
    { name: '睡眠', value: 80, maxValue: 100 },
    { name: '运动', value: 60, maxValue: 100 }
  ];

  build() {
    Column() {
      Header({ title: '新功能展示' })

      // 标签页切换
      Tabs() {
        TabContent() {
          this.buildAccessibilityDemo()
        }
        .tabBar('无障碍组件')

        TabContent() {
          this.buildChartDemo()
        }
        .tabBar('图表组件')

        TabContent() {
          this.buildRAGDemo()
        }
        .tabBar('RAG检索')
      }
      .barPosition(BarPosition.Start)
      .vertical(false)
      .scrollable(true)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTab = index;
      })
      .layoutWeight(1)

      Footer({ activeIndex: 0 })
    }
    .height('100%')
    .backgroundColor(AccessibilityConfig.getBackgroundColor())
  }

  /**
   * 无障碍组件演示
   */
  @Builder buildAccessibilityDemo(): void {
    Scroll() {
      Column({ space: this.isElderMode ? 20 : 16 }) {
        // 说明文字
        AccessibleText({
          content: '以下是无障碍组件的使用示例，支持老年模式、大字体、高对比度等功能。',
          type: 'body'
        })

        // 按钮示例
        Column({ space: 12 }) {
          AccessibleText({
            content: '按钮组件',
            type: 'subtitle'
          })

          Row({ space: 12 }) {
            AccessibleButton({
              text: '主要按钮',
              type: 'primary',
              onClickHandler: () => {
                console.info('主要按钮点击');
              }
            })

            AccessibleButton({
              text: '成功按钮',
              type: 'secondary',
              onClickHandler: () => {
                console.info('成功按钮点击');
              }
            })
          }
          .width('100%')

          AccessibleButton({
            text: '全宽按钮',
            type: 'primary',
            fullWidth: true,
            voiceHint: '这是一个全宽的主要按钮',
            onClickHandler: () => {
              console.info('全宽按钮点击');
            }
          })
        }
        .width('100%')

        // 卡片示例
        Column({ space: 12 }) {
          AccessibleText({
            content: '卡片组件',
            type: 'subtitle'
          })

          AccessibleCard({
            title: '预约挂号',
            subtitle: '快速预约医院科室',
            icon: '📅',
            showArrow: true,
            onClickHandler: () => {
              router.pushUrl({ url: 'pages/HospitalPage' });
            }
          })

          AccessibleCard({
            title: '健康报告',
            subtitle: '查看您的健康数据分析',
            icon: '📊',
            showArrow: true,
            onClickHandler: () => {
              router.pushUrl({ url: 'pages/ReportPage' });
            }
          })
        }
        .width('100%')
      }
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 图表组件演示
   */
  @Builder buildChartDemo(): void {
    Scroll() {
      Column({ space: this.isElderMode ? 20 : 16 }) {
        // 说明文字
        AccessibleText({
          content: '以下是健康数据可视化组件的使用示例。',
          type: 'body'
        })

        // 折线图
        HealthLineChart({
          data: this.lineChartData,
          title: '血压趋势',
          unit: 'mmHg',
          showGrid: true,
          lineColor: '#1677FF'
        })

        // 仪表盘
        Row({ space: 16 }) {
          HealthGauge({
            value: 85,
            maxValue: 100,
            title: '健康评分',
            unit: '分',
            warningThreshold: 70,
            dangerThreshold: 90
          })
          .layoutWeight(1)

          HealthGauge({
            value: 72,
            maxValue: 100,
            title: '心脏健康',
            unit: '分',
            warningThreshold: 70,
            dangerThreshold: 90
          })
          .layoutWeight(1)
        }
        .width('100%')

        // 雷达图
        HealthRadarChart({
          dimensions: this.radarData,
          title: '健康维度分析'
        })
      }
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * RAG检索演示
   */
  @Builder buildRAGDemo(): void {
    Scroll() {
      Column({ space: this.isElderMode ? 20 : 16 }) {
        // 说明文字
        AccessibleText({
          content: 'RAG检索系统已集成到AI Agent中，提供混合检索、向量检索、关键词检索和智能重排序功能。',
          type: 'body'
        })

        // 功能说明卡片
        AccessibleCard({
          title: '混合检索',
          subtitle: '结合向量检索和关键词检索，准确率提升20%',
          icon: '🔍',
          showArrow: false
        })

        AccessibleCard({
          title: '向量检索',
          subtitle: '基于语义相似度，理解查询意图',
          icon: '🧠',
          showArrow: false
        })

        AccessibleCard({
          title: '关键词检索',
          subtitle: 'BM25算法，精确匹配专业术语',
          icon: '📝',
          showArrow: false
        })

        AccessibleCard({
          title: '智能重排序',
          subtitle: 'Cross-Encoder模型，优化结果排序',
          icon: '🎯',
          showArrow: false
        })

        // 使用说明
        Column() {
          AccessibleText({
            content: '使用方法',
            type: 'subtitle'
          })

          AccessibleText({
            content: 'RAG检索系统已自动集成到AI对话中，您可以直接与AI助手对话，系统会自动检索相关医学知识并生成回答。',
            type: 'body'
          })

          AccessibleButton({
            text: '体验AI对话',
            type: 'primary',
            fullWidth: true,
            onClickHandler: () => {
              router.pushUrl({ url: 'pages/AIAssistantPage' });
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
      }
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }
}
