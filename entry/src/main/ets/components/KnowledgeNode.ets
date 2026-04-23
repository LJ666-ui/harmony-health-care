export class GraphNode {
  id: number = 0;
  label: string = '';
  name: string = '';
  type: string = '';
  color: string = '';
  radius: number = 0;
  x: number = 0;
  y: number = 0;
  depthLevel: number = 0;
  description: string = '';
  isCoreNode: number = 0;
}

@Component
export struct KnowledgeNode {
  @Prop node: GraphNode = new GraphNode();
  @Prop opacityValue: number = 1.0;
  onNodeClick?: (node: GraphNode) => void;
  onNodeDragStart?: (node: GraphNode) => void;
  onNodeDragUpdate?: (node: GraphNode, offsetX: number, offsetY: number) => void;
  onNodeDragEnd?: () => void;

  private getTypeIcon(nodeType: string): string {
    if (nodeType === 'DISEASE') { return '🏥'; }
    if (nodeType === 'SYMPTOM') { return '🩺'; }
    if (nodeType === 'HERBAL') { return '🌿'; }
    if (nodeType === 'PRESCRIPTION') { return '💊'; }
    if (nodeType === 'THERAPY') { return '💆'; }
    return '📋';
  }

  private getNodeSize(): number {
    return this.node.depthLevel === 0 ? 52 : 40;
  }

  private getBorderWidth(): number {
    return this.node.depthLevel === 0 ? 2.5 : 1.5;
  }

  private getIconSize(): number {
    return this.node.depthLevel === 0 ? 18 : 14;
  }

  private getNameSize(): number {
    return this.node.depthLevel === 0 ? 10 : 9;
  }

  build() {
    Column() {
      Text(this.getTypeIcon(this.node.type))
        .fontSize(this.getIconSize());
      Text(this.node.name.length > 4 ? this.node.name.substring(0, 4) : this.node.name)
        .fontSize(this.getNameSize())
        .fontColor(this.node.color)
        .maxLines(1);
    }
    .width(this.getNodeSize())
    .height(this.getNodeSize())
    .borderRadius(this.getNodeSize() / 2)
    .backgroundColor('#FFFFFFEE')
    .border({
      width: this.getBorderWidth(),
      color: this.node.color
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .opacity(this.opacityValue)
    .shadow({
      radius: this.node.depthLevel === 0 ? 8 : 4,
      color: this.node.color + '30',
      offsetX: 0,
      offsetY: 2
    })
    .position({
      x: this.node.x - this.getNodeSize() / 2,
      y: this.node.y - this.getNodeSize() / 2
    })
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture({ count: 1 })
          .onAction(() => {
            if (this.onNodeClick) {
              this.onNodeClick(this.node);
            }
          }),
        PanGesture({ fingers: 1, distance: 5 })
          .onActionStart(() => {
            if (this.onNodeDragStart) {
              this.onNodeDragStart(this.node);
            }
          })
          .onActionUpdate((event: GestureEvent) => {
            if (this.onNodeDragUpdate) {
              this.onNodeDragUpdate(this.node, event.offsetX, event.offsetY);
            }
          })
          .onActionEnd(() => {
            if (this.onNodeDragEnd) {
              this.onNodeDragEnd();
            }
          })
      )
    );
  }
}
