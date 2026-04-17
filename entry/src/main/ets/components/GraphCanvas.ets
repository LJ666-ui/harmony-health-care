interface TestNode {
  id: string;
  name: string;
  x: number;
  y: number;
}

@Component
export struct GraphCanvas {
  @State layoutNodes: TestNode[] = [];

  aboutToAppear(): void {
    const temp: TestNode[] = [];
    for (let i: number = 0; i < 10; i++) {
      temp.push({
        id: 'n' + i,
        name: '节点' + i,
        x: 100 + (i % 5) * 60,
        y: 100 + Math.floor(i / 5) * 80
      });
    }
    this.layoutNodes = temp;
  }

  build() {
    Column() {
      Text('GraphCanvas 组件')
        .fontSize(14)
        .fontColor('#333')
        .margin(10);

      if (this.layoutNodes.length === 0) {
        Text('无数据')
          .fontSize(12)
          .fontColor('#999');
      } else {
        Stack() {
          ForEach(this.layoutNodes, (item: TestNode) => {
            Column() {
              Text(item.name)
                .fontSize(10)
                .fontColor('#333')
            }
            .width(50)
            .height(50)
            .borderRadius(25)
            .backgroundColor('#E8F4FD')
            .border({ width: 1, color: '#1677FF' })
            .position({ x: item.x - 25, y: item.y - 25 });
          }, (item: TestNode) => item.id);
        }
        .width('100%')
        .height(300)
        .backgroundColor('#F5F7FA');

        Text('节点数: ' + this.layoutNodes.length)
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 10 });
      }
    }
    .width('100%')
    .height('100%')
  }
}
