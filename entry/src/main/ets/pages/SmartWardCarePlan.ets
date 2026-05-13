/**
 * 智慧病房护理计划页面
 * 提供护理任务时间线管理功能
 */

import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { TaskStatus } from '../models/SmartWardEnums';
import { CareTask } from '../models/SmartWardTaskModels';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct SmartWardCarePlan {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State tasks: CareTask[] = [];
  @State isLoading: boolean = true;
  @State selectedFilter: string = 'all';
  @State aiCarePlanOptimization: string = '';
  @State aiTaskPriorityAdvice: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    this.loadTasks();
  }

  loadTasks(): void {
    this.isLoading = true;
    // 模拟加载护理任务数据
    setTimeout(() => {
      this.tasks = [
        {
          taskId: 'TASK_001',
          taskName: '测量血压',
          taskType: 'VITAL_SIGNS',
          scheduledTime: Date.now() + 3600000,
          frequency: 'q4h',
          assignedNurse: '李护士',
          roomId: 'ROOM_301',
          roomNumber: '301',
          patientId: 'P001',
          patientName: '张**',
          status: TaskStatus.PENDING,
          isRecurring: true,
          priority: 8
        },
        {
          taskId: 'TASK_002',
          taskName: '输液更换',
          taskType: 'MEDICATION',
          scheduledTime: Date.now() + 7200000,
          frequency: 'qd',
          assignedNurse: '王护士',
          roomId: 'ROOM_301',
          roomNumber: '301',
          patientId: 'P001',
          patientName: '张**',
          status: TaskStatus.PENDING,
          isRecurring: true,
          priority: 9
        },
        {
          taskId: 'TASK_003',
          taskName: '协助翻身',
          taskType: 'CARE',
          scheduledTime: Date.now() + 1800000,
          frequency: 'q2h',
          assignedNurse: '李护士',
          roomId: 'ROOM_302',
          roomNumber: '302',
          patientId: 'P002',
          patientName: '李**',
          status: TaskStatus.IN_PROGRESS,
          isRecurring: true,
          priority: 7
        }
      ];
      this.isLoading = false;
    }, 500);
  }

  handleBack(): void {
    router.back();
  }

  completeTask(taskId: string): void {
    const task = this.tasks.find(t => t.taskId === taskId);
    if (task) {
      task.status = TaskStatus.COMPLETED;
      task.completedAt = Date.now();
    }
  }

  getStatusColor(status: TaskStatus): string {
    const colorMap: Record<TaskStatus, string> = {
      [TaskStatus.PENDING]: '#FF9800',
      [TaskStatus.IN_PROGRESS]: '#2196F3',
      [TaskStatus.COMPLETED]: '#4CAF50',
      [TaskStatus.SKIPPED]: '#9E9E9E',
      [TaskStatus.OVERDUE]: '#F44336'
    };
    return colorMap[status] || '#999999';
  }

  getStatusText(status: TaskStatus): string {
    const textMap: Record<TaskStatus, string> = {
      [TaskStatus.PENDING]: '待处理',
      [TaskStatus.IN_PROGRESS]: '进行中',
      [TaskStatus.COMPLETED]: '已完成',
      [TaskStatus.SKIPPED]: '已跳过',
      [TaskStatus.OVERDUE]: '已超期'
    };
    return textMap[status] || '未知';
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
  }

  async optimizeCarePlanWithAI(): Promise<void> {
    const taskSummary = this.tasks.map(t =>
      `${t.taskName} - ${t.patientName} (${this.formatTime(t.scheduledTime)}) [优先级:${t.priority}]`
    ).join('\n');
    try {
      const response = await this.orchestrator.process({
        type: 'text',
        content: `护理任务列表：\n${taskSummary}\n请优化护理计划安排`,
        intent: 'health_consultation'
      });
      this.aiCarePlanOptimization = response.output.content;
    } catch (error) {
      console.error('[SmartWardCarePlan] AI护理优化失败:', error);
      this.aiCarePlanOptimization = '';
    }
  }

  async getTaskPriorityAdvice(): Promise<void> {
    const highPriorityTasks = this.tasks.filter(t => t.priority >= 8);
    if (highPriorityTasks.length === 0) return;
    try {
      const response = await this.orchestrator.process({
        type: 'text',
        content: `高优先级任务：${highPriorityTasks.map(t => t.taskName).join('、')}，请给出执行建议`,
        intent: 'general_chat'
      });
      this.aiTaskPriorityAdvice = response.output.content;
    } catch (error) {
      console.error('[SmartWardCarePlan] AI任务建议失败:', error);
      this.aiTaskPriorityAdvice = '';
    }
  }

  build() {
    Column() {
      Header({ title: '护理计划', showBack: true });

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 统计信息
            Row() {
              Text(`任务总数: ${this.tasks.length}`)
                .fontSize(14)
                .margin({ right: 20 })

              Text(`待处理: ${this.tasks.filter(t => t.status === TaskStatus.PENDING).length}`)
                .fontSize(14)
                .fontColor('#FF9800')

              Text(`已完成: ${this.tasks.filter(t => t.status === TaskStatus.COMPLETED).length}`)
                .fontSize(14)
                .fontColor('#4CAF50')
            }
            .width('100%')
            .padding(15)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)

            // 任务列表
            Column() {
              ForEach(this.tasks, (task: CareTask) => {
                Column() {
                  Row() {
                    // 时间
                    Text(this.formatTime(task.scheduledTime))
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .margin({ right: 12 })

                    Column() {
                      Text(task.taskName)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)

                      Text(`${task.roomNumber}病房 - ${task.patientName} - ${task.assignedNurse}`)
                        .fontSize(12)
                        .fontColor('#666')
                        .margin({ top: 4 })

                      Text(`频率: ${task.frequency} | 优先级: ${task.priority}`)
                        .fontSize(10)
                        .fontColor('#999')
                        .margin({ top: 2 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Text(this.getStatusText(task.status))
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(4)
                      .backgroundColor(this.getStatusColor(task.status))
                  }
                  .width('100%')
                  .padding(15)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .margin({ bottom: 10 })
                  .shadow({ radius: 2, color: '#00000010' })
                })
              })
            }
            .padding(15)
          }
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
