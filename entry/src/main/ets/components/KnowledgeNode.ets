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
  onNodeDragEnd?: (node: GraphNode) => void;

  private getTypeIcon(nodeType: string): string {
    if (nodeType === 'DISEASE') { return '🏥'; }
    if (nodeType === 'SYMPTOM') { return '🩺'; }
    if (nodeType === 'HERBAL') { return '🌿'; }
    if (nodeType === 'PRESCRIPTION') { return '💊'; }
    if (nodeType === 'THERAPY') { return '💆'; }
    return '📋';
  }

  private getNodeSize(): number {
    const depth: number = this.node.depthLevel;
    if (depth === 0) { return 60; }
    if (depth === 1) { return 48; }
    return 38;
  }

  private getBorderWidth(): number {
    const depth: number = this.node.depthLevel;
    if (depth === 0) { return 3; }
    if (depth === 1) { return 2; }
    return 1.5;
  }

  private getIconSize(): number {
    const depth: number = this.node.depthLevel;
    if (depth === 0) { return 22; }
    if (depth === 1) { return 17; }
    return 13;
  }

  private getNameSize(): number {
    const depth: number = this.node.depthLevel;
    if (depth === 0) { return 11; }
    if (depth === 1) { return 9; }
    return 8;
  }

  private getShadowRadius(): number {
    const depth: number = this.node.depthLevel;
    if (depth === 0) { return 14; }
    if (depth === 1) { return 8; }
    return 4;
  }

  build() {
    Column() {
      Text(this.getTypeIcon(this.node.type))
        .fontSize(this.getIconSize());
      Text(this.node.name.length > 4 ? this.node.name.substring(0, 4) : this.node.name)
        .fontSize(this.getNameSize())
        .fontColor(this.node.color)
        .fontWeight(this.node.depthLevel === 0 ? FontWeight.Medium : FontWeight.Normal)
        .maxLines(1);
    }
    .width(this.getNodeSize())
    .height(this.getNodeSize())
    .borderRadius(this.getNodeSize() / 2)
    .backgroundColor('#FFFFFF')
    .border({
      width: this.getBorderWidth(),
      color: this.node.color
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .opacity(this.opacityValue)
    .shadow({
      radius: this.getShadowRadius(),
      color: this.node.color + (this.node.depthLevel === 0 ? '35' : '20'),
      offsetX: 0,
      offsetY: this.node.depthLevel === 0 ? 4 : 2
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
        PanGesture({ fingers: 1, distance: 2 })
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
              this.onNodeDragEnd(this.node);
            }
          })
      )
    );
  }
}