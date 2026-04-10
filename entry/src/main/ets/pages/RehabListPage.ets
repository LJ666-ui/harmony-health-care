import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { IconCard } from '../components/Card';

export interface RehabCourse {
  id: string;
  icon: string;
  title: string;
  description: string;
  duration: string;
  difficulty: string;
}

@Entry
@Component
struct RehabListPage {
  @State courses: RehabCourse[] = [
    {
      id: '1',
      icon: '🦴',
      title: '颈椎病康复',
      description: '针对颈椎问题的专业康复训练课程',
      duration: '30分钟/次',
      difficulty: '初级'
    },
    {
      id: '2',
      icon: '❤️',
      title: '高血压康复',
      description: '高血压患者的运动康复指导方案',
      duration: '45分钟/次',
      difficulty: '中级'
    },
    {
      id: '3',
      icon: '💪',
      title: '肌力训练',
      description: '全身肌肉力量增强训练计划',
      duration: '40分钟/次',
      difficulty: '中级'
    },
    {
      id: '4',
      icon: '⚖️',
      title: '平衡训练',
      description: '提升身体协调性和平衡能力训练',
      duration: '25分钟/次',
      difficulty: '初级'
    }
  ];

  build() {
    Column() {
      Header({ title: '康复课程', showBack: true });

      Scroll() {
        Column({ space: 16 }) {
          Text('选择康复课程')
            .fontSize(22)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 16, bottom: 8 });

          List() {
            ForEach(this.courses, (course: RehabCourse) => {
              ListItem() {
                Column() {
                  Row() {
                    Column() {
                      Text(course.icon)
                        .fontSize(36)
                    }
                    .width(64)
                    .height(64)
                    .backgroundColor('#1677FF20')
                    .borderRadius(32)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .margin({ right: 16 });

                    Column({ space: 6 }) {
                      Text(course.title)
                        .fontSize(17)
                        .fontWeight('bold')
                        .fontColor('#333333');

                      Text(course.description)
                        .fontSize(13)
                        .fontColor('#666666')
                        .maxLines(2);

                      Row({ space: 12 }) {
                        Text(`⏱ ${course.duration}`)
                          .fontSize(12)
                          .fontColor('#999999');
                        Text(`📊 ${course.difficulty}`)
                          .fontSize(12)
                          .fontColor('#1677FF');
                      }
                    }
                    .layoutWeight(1);
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .border({ width: 1, color: '#f0f0f0' })
                .onClick(() => {
                  router.pushUrl({ url: 'pages/Rehab3DPage' });
                });
              }
              .padding({ bottom: 8 });
            }, (course: RehabCourse) => course.id);
          }
          .width('100%')
          .layoutWeight(1);
        }
        .width('85%')
        .padding({ bottom: 24 });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
